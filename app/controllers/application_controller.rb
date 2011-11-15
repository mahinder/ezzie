 
 #Fedena
#Copyright 2011 Foradian Technologies Private Limited
#
#This product includes software developed at
#Project Fedena - http://www.projectfedena.org/
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery # :secret => '434571160a81b5595319c859d32060c1'
  #filter_parameter_logging :password
  
  before_filter { |c| Authorization.current_user = c.current_user }
  before_filter :message_user
  
  #before_filter :set_user_language
  
def only_assigned_employee_allowed
  puts "i am in only_assigned_employee_allowed"
    if @current_user.employee?
      @employee_subjects= @current_user.employee_record.subjects.map { |n| n.subject_id}
      privilege = @current_user.privileges.map{|p| p.id}
      if @employee_subjects.empty? and !privilege.include?(8) and !privilege.include?(16)
          flash[:notice] = "Sorry, you are not allowed to access that page."
          redirect_to :controller => 'user', :action => 'dashboard'
      else
        @allow_access = true
      end
    end
  end

  def restrict_employees_from_exam
    puts "i am in restrict_employees_from_exam"
    if @current_user.employee?
      @employee_subjects= @current_user.employee_record.subjects.map { |n| n.subject_id}
      if @employee_subjects.empty? and !@current_user.privileges.map{|p| p.id}.include?(1) and !@current_user.privileges.map{|p| p.id}.include?(2) and !@current_user.privileges.map{|p| p.id}.include?(3)
        flash[:notice] = "Sorry, you are not allowed to access that page."
        redirect_to :controller => 'user', :action => 'dashboard'
      else
        @allow_for_exams = true
      end
    end
  end

  def block_unauthorised_entry
     puts "i am in block_unauthorised_entry"
    if @current_user.employee?
      @employee_subjects= @current_user.employee_record.subjects.map { |n| n.subject_id}
      if @employee_subjects.empty? and !@current_user.privileges.map{|p| p.id}.include?(1)
        flash[:notice] = "Sorry, you are not allowed to access that page."
        redirect_to :controller => 'user', :action => 'dashboard'
      else
        @allow_for_exams = true
      end
    end
  end
  
 
 def message_user
    @current_user = current_user
  end

  def current_user
    User.find(session[:user_id]) unless session[:user_id].nil?
    end
  
  
  
  def permission_denied
         puts "i am in permission_denied"

    flash[:notice] = "Sorry, you are not allowed to access that page."
    redirect_to :controller => 'users', :action => 'dashboard'
  end
  
  protected
  def login_required
    redirect_to '/' unless session[:user_id]
  end

  def configuration_settings_for_hr
         puts "i am in configuration_settings_for_hr"

    hr = Schooldatum.find_by_config_value("HR")
    if hr.nil?
      redirect_to :controller => 'users', :action => 'dashboard'
      flash[:notice] = "Sorry, you are not allowed to access that page."
    end
  end

  

  
  def only_admin_allowed
             puts "i am in only_admin_allowed"

    redirect_to :controller => 'users', :action => 'dashboard' unless current_user.admin?
  end

  

  def protect_user_data
             puts "i am in protect_user_data"

    unless current_user.admin?
      unless params[:id].to_s == current_user.username
        flash[:notice] = "You are not allowed to view that information."
        redirect_to :controller=>"users", :action=>"dashboard"
      end
    end
  end

  def protect_other_employee_data
             puts "i am in protect_other_employee_data"

    if current_user.employee?
      employee = current_user.employee_record
      #    pri = Privilege.find(:all,:select => "privilege_id",:conditions=> 'privileges_users.user_id = ' + current_user.id.to_s, :joins =>'INNER JOIN `privileges_users` ON `privileges`.id = `privileges_users`.privilege_id' )
      #    privilege =[]
      #    pri.each do |p|
      #      privilege.push p.privilege_id
      #    end
      #    unless privilege.include?('9') or privilege.include?('14') or privilege.include?('17') or privilege.include?('18') or privilege.include?('19')
      unless params[:id].to_i == employee.id
        flash[:notice] = 'You are not allowed to view that information.'
        redirect_to :controller=>"users", :action=>"dashboard"
      end
    end
  end

  def protect_leave_history
     puts "i am in protect_leave_history"
    if current_user.employee?
      employee = Employee.find(params[:id])
      employee_user = employee.user
      unless employee_user.id == current_user.id
        unless current_user.role_symbols.include?(:hr_basics) or current_user.role_symbols.include?(:employee_attendance)
          flash[:notice] = "Access denied"
          redirect_to :controller=>"users", :action=>"dashboard"
        end
      end
    end
  end
  #  end

  #reminder filters
  def protect_view_reminders
    reminder = Reminder.find(params[:id2])
    unless reminder.recipient == current_user.id
      flash[:notice] = 'You are not allowed to view that information.'
      redirect_to :controller=>"reminder", :action=>"index"
    end
  end

  def protect_sent_reminders
    reminder = Reminder.find(params[:id2])
    unless reminder.sender == current_user.id
      flash[:notice] = 'You are not allowed to view that information.'
      redirect_to :controller=>"reminder", :action=>"index"
    end
  end

 
  def protect_leave_dashboard
    employee = Employee.find(params[:id])
    employee_user = employee.user
    #    unless permitted_to? :employee_attendance_pdf, :employee_attendance
    unless employee_user.id == current_user.id
      flash[:notice] = "Access denied"
      redirect_to :controller=>"user", :action=>"dashboard"
      #    end
    end
  end

  def protect_applied_leave
    applied_leave = ApplyLeave.find(params[:id])
    applied_employee = applied_leave.employee
    applied_employee_user = applied_employee.user
    unless applied_employee_user.id == current_user.id
      flash[:notice]="Access denied!"
      redirect_to :controller=>"user", :action=>"dashboard"
    end
  end

  def protect_manager_leave_application_view
    applied_leave = ApplyLeave.find(params[:id])
    applied_employee = applied_leave.employee
    applied_employees_manager = Employee.find(applied_employee.reporting_manager_id)
    applied_employees_manager_user = applied_employees_manager.user
    unless applied_employees_manager_user.id == current_user.id
      flash[:notice]="Access denied!"
      redirect_to :controller=>"user", :action=>"dashboard"
    end
  end

  
 
   
  
 
 

  #   private
  #    def set_user_language
  #      #I18n.locale = 'es'
  #    end
end
  

   
  
 