class MonthlyPayslip < ActiveRecord::Base
  validates :salary_date, presence: true

  belongs_to :payroll_category
  belongs_to :employee
  belongs_to :approver ,:class_name => 'User'
  belongs_to :rejector ,:class_name => 'User'

  def approve(user_id)
    self.is_approved = true
    self.approver_id = user_id
    self.save
  end

  def reject(user_id, reason)
    self.is_rejected = true
    self.rejector_id = user_id
    self.reason = reason
    self.save
  end

  def self.find_and_filter_by_department(salary_date,dept_id)
    payslips = ""
    individual_payslip_category = ""
    unless dept_id =="All"
      active_employees_in_dept = Employee.find(:all,:select=>"id",:conditions=>"employee_department_id = #{dept_id}")
      archived_employees_in_dept = ArchivedEmployee.find(:all,:select=>"former_id",:conditions=>"employee_department_id = #{dept_id}")
      all_employees_in_dept = active_employees_in_dept.collect(&:id) + archived_employees_in_dept.collect{|a| a.former_id.to_i}
      payslips = self.find_all_by_salary_date(salary_date.to_date,:conditions=>["employee_id IN (?)",all_employees_in_dept],:order=> "payroll_category_id ASC",:include=>[:payroll_category])
      individual_payslip_category = IndividualPayslipCategory.find_all_by_salary_date(salary_date.to_date,:conditions=>["employee_id IN (?)",all_employees_in_dept],:order=>"id ASC")
    else
      payslips = self.find_all_by_salary_date(salary_date.to_date,:order=> "payroll_category_id ASC",:include=>[:payroll_category])
      individual_payslip_category = IndividualPayslipCategory.find_all_by_salary_date(salary_date.to_date,:order=>"id ASC")
    end
    grouped_monthly_payslips = payslips.group_by(&:employee_id) unless payslips.blank?
    grouped_individual_payslip_categories = individual_payslip_category.group_by(&:employee_id) unless individual_payslip_category.blank?
    return_hash = {:monthly_payslips=>grouped_monthly_payslips,:individual_payslip_category=>grouped_individual_payslip_categories }
    return_hash
  end

  def active_or_archived_employee
    employee = Employee.find(:first,:conditions=>"id=#{self.employee_id}")
    if employee.blank?
      return  ArchivedEmployee.find(:first,:conditions=>"former_id=#{self.employee_id}")
    else
      return employee
    end
  end


  def status_as_text
    if is_approved ==true
      status = "Approved"
    elsif is_rejected ==true
      status = "Rejected"
    else
      status = "Pending"
    end
    return status
  end


  def self.total_employees_salary(start_date,end_date,dept_id="")
    total_monthly_payslips  = ""
    unless dept_id.blank?
      active_employees_in_dept = Employee.find(:all,:select=>"id",:conditions=>"employee_department_id = #{dept_id}")
      archived_employees_in_dept = ArchivedEmployee.find(:all,:select=>"former_id",:conditions=>"employee_department_id = #{dept_id}")
      all_employees_in_dept = active_employees_in_dept.collect(&:id) + archived_employees_in_dept.collect{|a| a.former_id.to_i}
      total_monthly_payslips = self.find(:all,:select=>"employee_id,amount,payroll_category_id,salary_date",:order => 'salary_date desc',:conditions => ["salary_date >= ? and salary_date <= ? and is_approved = 1 and employee_id IN (?)",start_date.to_date,end_date.to_date,all_employees_in_dept],:include=>[:payroll_category])
    else
      total_monthly_payslips = self.find(:all,:select=>"employee_id,amount,payroll_category_id,salary_date",:order => 'salary_date desc',:conditions => ["salary_date >= ? and salary_date <= ? and is_approved = 1",start_date.to_date,end_date.to_date],:include=>[:payroll_category])
    end
    
    employee_ids = []
    employee_ids = total_monthly_payslips.collect(&:employee_id) unless total_monthly_payslips.blank?
    unless employee_ids.blank?
      employee_ids.uniq!
      total_individual_payslips = IndividualPayslipCategory.find(:all,:conditions =>"salary_date >= '#{start_date.to_date}' and salary_date <= '#{end_date.to_date}' AND employee_id IN (#{employee_ids.join(",")})",:order=>"id ASC")
    end
    total_salary = 0
    unless total_monthly_payslips.blank?
      total_monthly_payslips.each do |payslip|
        total_salary += payslip.amount.to_f if payslip.payroll_category.is_deduction==false
        total_salary -= payslip.amount.to_f if payslip.payroll_category.is_deduction==true
      end
    end
    unless total_individual_payslips.blank?
      total_individual_payslips.each do |payslip|
        total_salary += payslip.amount.to_f if payslip.is_deduction==false
        total_salary -= payslip.amount.to_f if payslip.is_deduction==true
      end
    end
    {:total_salary=>total_salary,:monthly_payslips=>total_monthly_payslips,:individual_categories=>total_individual_payslips}
  end


end
