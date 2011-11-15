class EmployeeCategory < ActiveRecord::Base
  validates :name, :prefix, presence: true,uniqueness: true
 # named_scope :active, :conditions => {:status => true }
  has_many :employee_positions
  has_many :employees
end
