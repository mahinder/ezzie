class PayrollCategory < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :monthly_paslips
end
