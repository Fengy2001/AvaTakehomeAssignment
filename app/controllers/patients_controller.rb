require 'csv'

class PatientsController < ApplicationController
  # Initialize the hashmap for schema and abbreviations. Should probably find a way to not hard code this but not sure how.
  KNOWN_COLUMNS = [
    'health identifier',
    'health identifier province',
    'first name',
    'middle name',
    'last name',
    'date of birth',
    'sex',
    'phone',
    'email',
    'address 1',
    'address 2',
    'address city',
    'address province',
    'address postal code'
  ]

  PROVINCES = {
    'ALBERTA' => 'AB',
    'BRITISH COLUMBIA' => 'BC',
    'MANITOBA' => 'MB',
    'NEW BRUNSWICK' => 'NB',
    'NEWFOUNDLAND AND LABRADOR' => 'NL',
    'NORTHWEST TERRITORIES' => 'NT',
    'NOVA SCOTIA' => 'NS',
    'NUNAVUT' => 'NU',
    'ONTARIO' => 'ON',
    'PRINCE EDWARD ISLAND' => 'PE',
    'QUEBEC' => 'QC',
    'SASKATCHEWAN' => 'SK',
    'YUKON' => 'YT'
  }

  # See the details of the database
  def index
    @patients = Patient.includes(:patient_contacts, :address, :uncategorized).all
  end

  def new
  end

  # This function honestly does alot, if I have the time split this up more.
  def upload
    if params[:csv_file].blank?
      redirect_to new_patient_path, alert: 'No file selected'
      return
    end

    started = Time.now
    skipped = []
    provinces = Hash.new(0)

    csv = CSV.read(params[:csv_file].path, headers: true)
    extra_columns = csv.headers.compact - KNOWN_COLUMNS

    summary = {
      'rows_in_file' => csv.size,
      'imported' => 0,
      'skipped' => 0,
      'percent' => 0,
      'created' => 0,
      'updated' => 0,
      'unchanged' => 0,
      'missing_phone' => 0,
      'missing_email' => 0,
      'incomplete_address' => 0,
      'seconds' => 0
    }

    csv.each_with_index do |row, index|
      health_id = row['health identifier'].to_i

      if health_id == 0
        skipped << "Row #{index + 2}: bad health identifier"
        next
      end

      begin
        outcome = import_row(row, health_id)

        summary['imported'] += 1
        summary[outcome] += 1
        count_gaps(row, summary)
        provinces[abbreviate_province(row['health identifier province'])] += 1
      rescue ActiveRecord::RecordInvalid => e
        skipped << "Row #{index + 2}: #{e.message}"
      end
    end

    summary['skipped'] = skipped.size
    summary['seconds'] = (Time.now - started).round(2)

    if summary['rows_in_file'] > 0
      summary['percent'] = (summary['imported'] * 100.0 / summary['rows_in_file']).round(1)
    end

    flash[:import_summary] = summary
    flash[:by_province] = provinces
    flash[:extra_columns] = extra_columns
    flash[:skipped] = skipped.first(10)

    redirect_to patients_path
  end

  private
  def import_row(row, health_id)
    Patient.transaction do
      province = abbreviate_province(row['health identifier province'])

      patient = Patient.find_or_initialize_by(health_id: health_id, health_identifier_provider: province)
      new_patient = patient.new_record?

      patient.assign_attributes(
        first_name: row['first name'],
        middle_name: row['middle name'],
        last_name: row['last name'],
        dob: row['date of birth'],
        sex: row['sex']
      )

      changed = patient.changed?
      patient.updated_on = Time.current if changed
      patient.save!

      changed = true if save_contact(patient, 'Phone', row['phone'])
      changed = true if save_contact(patient, 'Email', row['email'])

      street = [row['address 2'], row['address 1']].compact.join(', ')
      address = Address.find_or_initialize_by(patient_id: patient.id)
      changed = true if save_changes(address,
        unit_street: street,
        city: row['address city'],
        province: abbreviate_province(row['address province']),
        postal: row['address postal code']
      )

      uncategorized = Uncategorized.find_or_initialize_by(patient_id: patient.id)
      changed = true if save_changes(uncategorized, misc: row.to_h.except(*KNOWN_COLUMNS))

      if new_patient
        'created'
      elsif changed
        'updated'
      else
        'unchanged'
      end
    end
  end


  """
  Below are helper functions used to do a little bit of data transformation (Alberta to AB)/save reults.
  """
  def save_contact(patient, contact_type, value)
    return false if value.blank?
    contact = PatientContact.find_or_initialize_by(patient_id: patient.id, contact_type: contact_type)
    save_changes(contact, value: value)
  end

  def save_changes(record, attributes)
    record.assign_attributes(attributes)
    changed = record.changed?
    record.save!
    changed
  end

  def count_gaps(row, summary)
    summary['missing_phone'] += 1 if row['phone'].blank?
    summary['missing_email'] += 1 if row['email'].blank?
    address_values = [row['address 1'], row['address city'], row['address province'], row['address postal code']]
    summary['incomplete_address'] += 1 if address_values.any?(&:blank?)
  end

  def abbreviate_province(name)
    key = name.to_s.upcase
    return key if PROVINCES.value?(key)
    PROVINCES[key] || name
  end
end