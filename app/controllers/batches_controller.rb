class BatchesController < ApplicationController
 def index
    @batches = @course.batches
  end

  def new
    @course = Course.find(params[:course])
    @batch = @course.batches.build
  end

  def create
    @course = Course.find(params[:course])
    @batch = @course.batches.build(params[:batch])

    if @batch.save
      flash[:notice] = 'Batch created successfully.'
       redirect_to :controller => 'courses',:action=>'show',:course => @course.id
     else
       redirect_to :action=>'new',:course => @course.id
       flash[:notice] = 'Batch not created successfully.'
    end
  end

  def edit
    @batch = Batch.find params[:batch] 
    @course = Course.find params[:course]
  end

  def update
    @batch = Batch.find params[:id] 
    @course = Course.find params[:course_id]
        if @batch.update_attributes(params[:batch])
      flash[:notice] = 'Updated batch details successfully.'
      redirect_to :action=>'show',:id => params[:id],:course_id => params[:course_id]
    else
      flash[:notice] = "Please fill all feilds"
      redirect_to :action=>'edit'
    end
  end

  def show
     @batch = Batch.find params[:id] 
     @course = Course.find params[:course_id]
    @students = Student.find(:all,:conditions => {:batch_id => params[:id]})
    end

  def destroy
     @batch = Batch.find params[:batch] 
    @course = Course.find params[:course]
   
    if Student.find(:all,:conditions => { :is_deleted => false ,:batch_id => @batch}).empty?
      @batch.inactivate
      flash[:notice] = 'Batch deleted successfully.'
      redirect_to :controller => 'courses', :action=>'show',:course => params[:course]
    else
      flash[:notice] = 'Unable to delete Batch.Please delete all Students first'

      redirect_to :controller => 'courses', :action=>'show',:course => params[:course]
    end
  end

  def assign_tutor
    @batch = Batch.find_by_id(params[:id])
    @assigned_employee = @batch.employee_id.split(",") unless @batch.employee_id.nil?
    @departments = EmployeeDepartment.find(:all)
  end

  def update_employees
    @employees = Employee.find_all_by_employee_department_id(params[:department_id])
    @batch = Batch.find_by_id(params[:batch_id])
    render :update do |page|
      page.replace_html 'employee-list', :partial => 'employee_list'
    end
  end

  def assign_employee
    @batch = Batch.find_by_id(params[:batch_id])
    @employees = Employee.find_all_by_employee_department_id(params[:department_id])
    unless @batch.employee_id.blank?
    @assigned_emps = @batch.employee_id.split(',')
    else
    @assigned_emps = []
    end
    @assigned_emps.push(params[:id].to_s)
    @batch.update_attributes :employee_id => @assigned_emps.join(",")
    @assigned_employee = @assigned_emps.join(",")
    render :update do |page|
      page.replace_html 'employee-list', :partial => 'employee_list'
      page.replace_html 'tutor-list', :partial => 'assigned_tutor_list'
    end
  end

  def remove_employee
    @batch = Batch.find_by_id(params[:batch_id])
    @employees = Employee.find_all_by_employee_department_id(params[:department_id])
    @assigned_emps = @batch.employee_id.split(',')
    @removed_emps = @assigned_emps.delete(params[:id].to_s)
    @assigned_emps = @assigned_emps.join(",")
    @batch.update_attributes :employee_id =>@assigned_emps
    render :update do |page|
      page.replace_html 'employee-list', :partial => 'employee_list'
      page.replace_html 'tutor-list', :partial => 'assigned_tutor_list'
    end
  end

  private
  def init_data
    @batch = Batch.find params[:id] if ['show', 'edit', 'update', 'destroy'].include? action_name
    @course = Course.find params[:course_id]
  end
end
