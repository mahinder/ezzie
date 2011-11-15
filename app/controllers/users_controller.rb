class UsersController < ApplicationController
   layout :choose_layout
 before_filter :login_required, :except => [:forgot_password, :login, :set_new_password, :reset_password]
 before_filter :only_admin_allowed, :only => [:edit, :create, :index, :edit_privilege, :user_change_password]
 before_filter :protect_user_data, :only => [:profile, :user_change_password]
 #filter_access_to :edit_privilege
  def choose_layout
    return 'login' if action_name == 'login' or action_name == 'set_new_password'
    return 'forgotpw' if action_name == 'forgot_password'
    return 'dashboard' if action_name == 'dashboard'
    'application'
  end

  def all
    puts "hey i am in all"
     @users = User.all
  end

  def list_user
    if params[:user_type] == 'Admin'
      @users = User.find(:all, :conditions => {:admin => true}, :order => 'first_name ASC')
      render(:update) do |page|
        page.replace_html 'users', :partial=> 'users'
        page.replace_html 'employee_user', :text => ''
        page.replace_html 'student_user', :text => ''
      end
    elsif params[:user_type] == 'Employee'
      render(:update) do |page|
        hr = Schooldatum.find_by_config_value("HR")
        unless hr.nil?
          page.replace_html 'employee_user', :partial=> 'employee_user'
          page.replace_html 'users', :text => ''
          page.replace_html 'student_user', :text => ''
        else
          @users = User.find_all_by_employee(1)
          page.replace_html 'users', :partial=> 'users'
          page.replace_html 'employee_user', :text => ''
          page.replace_html 'student_user', :text => ''
        end
      end
    elsif params[:user_type] == 'Student'
      render(:update) do |page|
        page.replace_html 'student_user', :partial=> 'student_user'
        page.replace_html 'users', :text => ''
        page.replace_html 'employee_user', :text => ''
      end
    elsif params[:user_type] == ''
      @users = ""
      render(:update) do |page|
        page.replace_html 'users', :partial=> 'users'
        page.replace_html 'employee_user', :text => ''
        page.replace_html 'student_user', :text => ''
      end
    end
  end

  def list_employee_user
    emp_dept = params[:dept_id]
    @employee = Employee.find_all_by_employee_department_id(emp_dept, :order =>'first_name ASC')
    @users = @employee.collect { |employee| employee.user}
    @users.delete(nil)
    render(:update) {|page| page.replace_html 'users', :partial=> 'users'}
  end

  def list_student_user
    batch = params[:batch_id]
    @student = Student.find_all_by_batch_id(batch, :conditions => { :is_active => true },:order =>'first_name ASC')
    @users = @student.collect { |student| student.user}
    @users.delete(nil)
    render(:update) {|page| page.replace_html 'users', :partial=> 'users'}
  end

  def change_password

    if request.post?
      @user = current_user
      if User.authenticate?(@user.username, params[:user][:old_password])
        if params[:user][:new_password] == params[:user][:confirm_password]
          @user.password = params[:user][:new_password]
          @user.update_attributes(:password => @user.password,
          :role => @user.role_name
          )
          flash[:notice] = 'Password changed successfully.'
          redirect_to :action => 'dashboard'
        else
          flash[:warn_notice] = '<p>Password confirmation failed. Please try again.</p>'
        end
      else
        flash[:warn_notice] = '<p>The old password you entered is incorrect. Please enter valid password.</p>'
      end
    end
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

 

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find_by_username(params[:id])
    @current_user = current_user
  end

  # POST /users
  # POST /users.json
  def create
    @school = Schooldatum.available_modules
    @user = User.new(params[:user])
    if request.post?
      @school.include?('HR')
      @employee=Employee.new
      @employee.first_name = @user.first_name
      @employee.last_name = @user.last_name
      @employee.employee_number = @user.username
      @employee.employee_category_id = 1
      @employee.employee_position_id = 1
      @employee.employee_department_id = 1
      @employee.employee_grade_id = 1
      @employee.date_of_birth = Date.today - 20.year
      @employee.joining_date = Date.today - 5.year

      respond_to do |format|
        if @employee.save
          flash[:notice]= "user created successfully!"
          format.html {  redirect_to :controller=>'users', :action => 'edit', :id => @user.username, notice: 'User was successfully created.' }
          format.json { render json: @user, status: :created, location: @user }
        else
          flash[:warn_notice]= "user not created"
          format.html { render action: "new" }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        @current_user = current_user
        format.html {  redirect_to :controller=>'users', :action => 'profile', :id => @user.username, notice: 'User was successfully created.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

 

  def profile
    @school = Schooldatum.available_modules
    @current_user =  current_user
    @username = @current_user.username
    puts " current user is #{@username}"
    @user = User.find_by_username(params[:id])
    puts "user is #{@user}"
    unless @user.nil?
      @employee = Employee.find_by_employee_number(@user.username)
    #@student = Student.find_by_admission_no(@user.username)
    else
      flash[:notice] = 'User profile not found.'
      redirect_to :action => 'dashboard'
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end

  def user_change_password
    user = User.find_by_username(params[:id])

    if request.post?
      if params[:user][:new_password]=='' and params[:user][:confirm_password]==''
        flash[:warn_notice]= "<p>Password fields cannot be blank!</p>"
      else
        if params[:user][:new_password] == params[:user][:confirm_password]
          user.password = params[:user][:new_password]
          user.update_attributes(:password => user.password,
          :role => user.role_name
          )
          flash[:notice]= "Password has been updated successfully!"
          redirect_to :action=>"edit", :id=>user.username
        else
          flash[:warn_notice] = 'Password confirmation failed. Please try again.'
        end
      end

    end
  end

  def dashboard
    @user = current_user

    @school = Schooldatum.available_modules
    puts "user role name is #{@user.role_name.downcase}"
    @employee = @user.employee_record if ['employee','admin'].include?(@user.role_name.downcase)
     puts "employeename is #{@employee}"
    @student = @user.student_record  if @user.role_name.downcase == 'student'
     puts "ustudent name is #{@ustudent}"
    @dash_news = News.find(:all, :limit => 5)
  end

  def login
    puts "iam in login"
    @institute = Schooldatum.find_by_config_key("LogoName")
    if request.post? and params[:user]
      @user = User.new(params[:user])
      user = User.find_by_username @user.username
      if user and User.authenticate?(@user.username, @user.password)
        session[:user_id] = user.id
        flash[:notice] = "Welcome, #{user.first_name} #{user.last_name}!"
        redirect_to :controller => 'users', :action => 'dashboard', :id => user.id
      else
        flash[:notice] = 'Invalid username or password combination'
      end
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = 'Logged out'
    redirect_to :controller => 'users', :action => 'login'
  end

  def forgot_password
    #    flash[:notice]="You do not have permission to access forgot password!"
    #    redirect_to :action=>"login"
    @network_state = Schooldatum.find_by_config_key("NetworkState")
    if request.post? and params[:reset_password]
      if user = User.find_by_email(params[:reset_password][:email])
        user.reset_password_code = Digest::SHA1.hexdigest( "#{user.email}#{Time.now.to_s.split(//).sort_by {rand}.join}" )
        user.reset_password_code_until = 1.day.from_now
        user.role = user.role_name
        user.save(false)
        UserNotifier.deliver_forgot_password(user)
        flash[:notice] = "Reset Password link emailed to #{user.email}"
        redirect_to :action => "index"
      else
        flash[:notice] = "No user exists with email address #{params[:reset_password][:email]}"
      end
    end
  end

  def reset_password
    user = User.find_by_reset_password_code(params[:id])
    if user
      if user.reset_password_code_until > Time.now
        redirect_to :action => 'set_new_password', :id => user.reset_password_code
      else
        flash[:notice] = 'Reset time expired'
        redirect_to :action => 'index'
      end
    else
      flash[:notice]= 'Invalid reset link'
      redirect_to :action => 'index'
    end
  end

  def set_new_password
    if request.post?
      user = User.find_by_reset_password_code(params[:id])
      if user
        if params[:set_new_password][:new_password] === params[:set_new_password][:confirm_password]
          user.password = params[:set_new_password][:new_password]
          user.update_attributes(:password => user.password, :reset_password_code => nil, :reset_password_code_until => nil, :role => user.role_name)
          #User.update(user.id, :password => params[:set_new_password][:new_password],
          # :reset_password_code => nil, :reset_password_code_until => nil)
          flash[:notice] = 'Password succesfully reset. Use new password to log in.'
          redirect_to :action => 'index'
        else
          flash[:notice] = 'Password confirmation failed. Please enter password again.'
          redirect_to :action => 'set_new_password', :id => user.reset_password_code
        end
      else
        flash[:notice] = 'You have followed an invalid link. Please try again.'
        redirect_to :action => 'index'
      end
    end
  end

  def edit_privilege
    @privileges = Privilege.find(:all)
    @user = User.find_by_username(params[:id])
    if request.post?
      new_privileges = params[:user][:privilege_ids] if params[:user]
      new_privileges ||= []
      @user.privileges = Privilege.find_all_by_id(new_privileges)

      flash[:notice] = 'Role updated.'
      redirect_to :action => 'profile',:id => @user.username
    end
  end

end
