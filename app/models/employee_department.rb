class EmployeeDepartment < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :code, uniqueness: true
  has_many :employeeses
  scope :active, :conditions => {:status => true }

  
  def department_total_salary(start_date,end_date)
    total = 0
    self.employees.each do |e|
      salary_dates = e.all_salaries(start_date,end_date)
      salary_dates.each do |s|
        total += e.employee_salary(s.salary_date.to_date)
      end
    end
    total
  end
end
