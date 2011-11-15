class EmployeePosition < ActiveRecord::Base
  validates :name, :employee_category_id, presence: true, uniqueness: true
  #named_scope :active, :conditions => {:status => true }
  belongs_to :employee_category
  has_many :employee
end
