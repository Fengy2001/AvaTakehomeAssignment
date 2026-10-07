class Patient < ApplicationRecord
  has_many :patient_contacts, dependent: :destroy
  has_one :address, dependent: :destroy
  has_one :uncategorized, dependent: :destroy

  validates :health_id, :health_identifier_provider, :first_name, :last_name, :dob, :sex, :updated_on, presence: true
end