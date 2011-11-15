class EmployeeLeaveType < ActiveRecord::Base
  has_many :employee_leaves
  has_many :employee_attendances
  validates :code, :name, uniqueness: true, presence: true
  validates :max_leave_count, format: { with: /^[0-9]*\z/ }
end
