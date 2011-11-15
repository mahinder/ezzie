class RemindersController < ApplicationController
  before_filter :login_required
  before_filter :protect_view_reminders, :only=>[:view_reminder,:mark_unread,:delete_reminder_by_recipient]
  before_filter :protect_sent_reminders, :only=>[:view_sent_reminder,:delete_reminder_by_sender]
  def index
    @user = current_user
    @reminders = Reminder.paginate(:page => params[:page], :conditions=>["recipient = '#{@user.id}' and is_deleted_by_recipient = false"], :order=>"created_at DESC")
    @read_reminders = Reminder.find_all_by_recipient(@user.id, :conditions=>"is_read = true and is_deleted_by_recipient = false", :order=>"created_at DESC")
    @new_reminder_count = Reminder.find_all_by_recipient(@user.id, :conditions=>"is_read = false and is_deleted_by_recipient = false")
  end

  def create_reminder
    @user = current_user
    @departments = EmployeeDepartment.find(:all)
    @new_reminder_count = Reminder.find_all_by_recipient(@user.id, :conditions=>"is_read = false")
    unless params[:send_to].nil?
      recipients_array = params[:send_to].split(",").collect{ |s| s.to_i }
      @recipients = User.find(recipients_array)
    end
    if request.post?
      unless params[:reminder][:body] == "" or params[:recipients] == ""
        recipients_array = params[:recipients].split(",").collect{ |s| s.to_i }
        recipients_array.each do |r|
          user = User.find(r)
          Reminder.create(:sender => @user.id, :recipient => user.id, :subject=>params[:reminder][:subject],
          :body=>params[:reminder][:body], :is_read=>false, :is_deleted_by_sender=>false,:is_deleted_by_recipient=>false)
        end
        flash[:notice] = "Message sent successfully"
        redirect_to :controller=>"reminders", :action=>"create_reminder"
      else
        flash[:notice]="<b>ERROR:</b>Please fill the required fields to create this message"
        redirect_to :controller=>"reminders", :action=>"create_reminder"
      end
    end
  end

  def select_employee_department
    @user = current_user
    @departments = EmployeeDepartment.find(:all, :conditions=>"status = true")
    render :partial=>"select_employee_department"
  end

  def select_users
    @user = current_user
    users = User.find(:all, :conditions=>"student = false")
    @to_users = users.map { |s| s.id unless s.nil? }
    render :partial=>"to_users", :object => @to_users
  end

  def select_student_course
    @user = current_user
    @batches = Batch.active
    render :partial=> "select_student_course"
  end

  def to_employees
    if params[:dept_id] == ""
      render :update do |page|
        page.replace_html "to_employees", :text => ""
      end
    return
    end
    department = EmployeeDepartment.find(params[:dept_id])
    employees = Employee.where("employee_department_id", params[:dept_id])
    @to_users = employees.map { |s| s.user.id unless s.user.nil? }
    @to_users.delete nil
    render :update do |page|
      page.replace_html 'to_users', :partial => 'to_users', :object => @to_users
    end
  end

  def to_students
    if params[:batch_id] == ""
      render :update do |page|
        page.replace_html "to_user", :text => ""
      end
    return
    end

    batch = Batch.find(params[:batch_id])
    students = batch.students
    @to_users = students.map { |s| s.user.id unless s.user.nil? }
    @to_users.delete nil
    render :update do |page|
      page.replace_html 'to_users2', :partial => 'to_users', :object => @to_users
    end
  end

  def update_recipient_list
    recipients_array = params[:recipients].split(",").collect{ |s| s.to_i }
    @recipients = User.find(recipients_array)
    render :update do |page|
      page.replace_html 'recipient-list', :partial => 'recipient_list'
    end
  end

  def sent_reminder
    @user = current_user
    @sent_reminders = Reminder.paginate(:page => params[:page], :conditions=>["sender = '#{@user.id}' and is_deleted_by_sender = false"],  :order=>"created_at DESC")
    @new_reminder_count = Reminder.find_all_by_recipient(@user.id, :conditions=>"is_read = false")
  end

  def view_sent_reminder
    @sent_reminder = Reminder.find(params[:id2])
  end

  def delete_reminder_by_sender
    @sent_reminder = Reminder.find(params[:id2])
    Reminder.update(@sent_reminder.id, :is_deleted_by_sender => true)
    flash[:notice] = "Reminder deleted."
    redirect_to :action =>"sent_reminder"
  end

  def delete_reminder_by_recipient
    user = current_user
    employee = user.employee_record
    @reminder = Reminder.find(params[:id2])
    Reminder.update(@reminder.id, :is_deleted_by_recipient => true)
    flash[:notice] = "Reminder deleted."
    redirect_to :action =>"index"
  end

  def view_reminder
    user = current_user
    @new_reminder = Reminder.find(params[:id2])
    Reminder.update(@new_reminder.id, :is_read => true)
    @sender = User.find(@new_reminder.sender)

    if request.post?
      unless params[:reminder][:body] == "" or params[:recipients] == ""
        Reminder.create(:sender=>user.id, :recipient=>@sender.id, :subject=>params[:reminder][:subject],
        :body=>params[:reminder][:body], :is_read=>false, :is_deleted_by_sender=>false,:is_deleted_by_recipient=>false)
        flash[:notice]="Your reply has been sent"
        redirect_to :controller=>"reminder", :action=>"view_reminder", :id2=>params[:id2]
      else
        flash[:notice]="<b>ERROR:</b>Please enter both subject and body"
        redirect_to :controller=>"reminder", :action=>"view_reminder",:id2=>params[:id2]
      end
    end
  end

  def mark_unread
    @reminder = Reminder.find(params[:id2])
    Reminder.update(@reminder.id, :is_read => false)
    flash[:notice] = "Reminder marked unread."
    redirect_to :controller=>"reminder", :action=>"index"
  end

  def pull_reminder_form
    @employee = Employee.find(params[:id])
    @manager = Employee.find(@employee.reporting_manager_id).user
    render :partial => "send_reminder"
  end

  def send_reminder
    unless params[:create_reminder][:message] == "" or params[:create_reminder][:to] == ""
      Reminder.create(:sender=>params[:create_reminder][:from], :recipient=>params[:create_reminder][:to], :subject=>params[:create_reminder][:subject],
      :body=>params[:create_reminder][:message] , :is_read=>false, :is_deleted_by_sender=>false,:is_deleted_by_recipient=>false)
      render(:update) do |page|
        page.replace_html 'error-msg', :text=> '<p class="flash-msg">Your message has been sent</p>'
      end
    else
      render(:update) do |page|
        page.replace_html 'error-msg', :text=> '<p class="flash-msg">Please enter message and subject.</p>'
      end
    end
  end
end
