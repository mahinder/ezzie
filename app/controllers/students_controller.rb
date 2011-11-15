class StudentsController < ApplicationController
  # GET /students
  # GET /students.json
  def index
    @students = Student.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @students }
    end
  end


  def show
    @student = Student.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @student }
    end
  end
  
  def new
    @student = Student.new
    @last_admitted_student = Student.find(:last)
    @config = Schooldatum.find_by_config_key('AdmissionNumberAutoIncrement')
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @student }
    end
  end

  def create
    @student = Student.new(params[:student])
    @last_admitted_student = Student.find(:last)
    @config = Schooldatum.find_by_config_key('AdmissionNumberAutoIncrement')
    respond_to do |format|
      if @student.save
        #format.html { redirect_to @student, notice: 'Student was successfully created.' }
        format.html { redirect_to :action => 'second_form', :id => @student.id }
        #format.json { render json: @student, status: :created, location: @student }
      else
        format.html { render action: "new" }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  
  def second_form
    @student = Student.find params[:id], :include => [:guardians]
    @guardian = Guardian.new
  end

  def guardians
    @student = Student.find params[:id]
    @parents = @student.guardians
  end
  

  def create_guardian
    @student = Student.find params[:id], :include => [:guardians]
    @guardian = Guardian.new(params[:guardian])
    respond_to do |format|
      if @guardian.save
        format.html { redirect_to :action => 'second_form', :id => @student.id }
        format.json { render json: @guardian, status: :created, location: @guardian }
      else
        format.html { render action: "second_form" }
        format.json { render json: @guardian.errors, status: :unprocessable_entity }
      end
    end
  end

  def third_form 
    @student = Student.find params[:id]
    @parents = @student.guardians
    if @parents.empty?
      redirect_to :controller => "students", :action => "new", :id => @student.id
    end
    return if params[:immediate_contact].nil?
     if request.post?
      @student = Student.update(@student.id, :immediate_contact_id => params[:immediate_contact][:contact])
     end
      redirect_to :action => "previous_data", :id => @student.id
  end

  def previous_data
    @student = Student.find(params[:id])
    @previous_data = StudentPreviousData.new params[:student_previous_details]
    @previous_subject = StudentPreviousSubjectMark.find_all_by_student_id(@student)
    if request.post?
      @previous_data.save
      redirect_to :action => "add_details", :id => @student.id
    else
      return
    end
  end
  def previous_data_edit
    @student = Student.find(params[:id])
    @previous_data = StudentPreviousData.find_by_student_id(params[:id])
    @previous_subject = StudentPreviousSubjectMark.find_all_by_student_id(@student)
    if request.post?
      @previous_data.update_attributes(params[:previous_data])
      redirect_to :action => "show_previous_details", :id => @student.id
    end
  end
  def previous_subject
    @student = Student.find(params[:id])
    render(:update) do |page|
      page.replace_html "subject", :partial=>"previous_subject"
    end
  end
  
  def save_previous_subject
    @previous_subject = StudentPreviousSubjectMark.new params[:student_previous_subject_details]
    @previous_subject.save
    #@all_previous_subject = StudentPreviousSubjectMark.find(:all,:conditions=>"student_id = #{@previous_subject.student_id}")
  end
  
   def delete_previous_subject
    @previous_subject = StudentPreviousSubjectMark.find(params[:id1])
    @student =Student.find(@previous_subject.student_id)
    if@previous_subject.delete
      @previous_subject=StudentPreviousSubjectMark.find_all_by_student_id(@student.id)
    end
    #@all_previous_subject = StudentPreviousSubjectMark.find(:all,:conditions=>"student_id = #{@previous_subject.student_id}")
  end

  def show_previous_details
    @student = Student.find(params[:id])
    @previous_data = StudentPreviousData.find_by_student_id(@student.id)
    @previous_subjects = StudentPreviousSubjectMark.find_all_by_student_id(@student.id)
  end

  def profile
   @student = Student.find(params[:id])
   @states = CountryState.find(@student.state_id)
   @address = @student.address_line1.to_s + ' ' + @student.address_line2.to_s
   @additional_fields = StudentAdditionalField.all(:conditions=>"status = true")
   @previous_data = StudentPreviousData.find_by_student_id(@student.id)
   @immediate_contact = Guardian.find(@student.immediate_contact_id) \
    unless @student.immediate_contact_id.nil? or @student.immediate_contact_id == ''
    render :pdf=>'profile_pdf'
  end

  def edit_guardian
    @parent = Guardian.find(params[:id])
    @student = Student.find(@parent.ward_id)
    @countries = Country.all
    if request.post? and @parent.update_attributes(params[:parent_detail])
      flash[:notice] = "Parent Record updated!"
      redirect_to :controller => "students", :action => "guardians", :id => @student.id
    end
  end
  def del_guardian
    @guardian = Guardian.find(params[:id])
    @student = @guardian.ward
    if @guardian.is_immediate_contact?
      if @guardian.destroy
        flash[:notice] = "Guardian has been deleted"
        redirect_to :controller => 'students', :action => 'third_form', :id => @student.id
      end
    else
      if @guardian.destroy
        flash[:notice] = "Guardian has been deleted"
        redirect_to :controller => 'students', :action => 'profile', :id => @student.id
      end
    end
  end
  def add_guardian
    @student = Student.find(params[:id])
    @parent_info = Guardian.new(params[:parent_detail])
    @countries = Country.all
    if request.post? and @parent_info.save
      flash[:notice] = "Parent details saved for #{@parent_info.ward_id}"
      redirect_to :controller => "students" , :action => "profile", :id => @parent_info.ward_id
    end
  end
  def edit
    @student = Student.find(params[:id])
    @config = Schooldatum.find_by_config_key('AdmissionNumberAutoIncrement')
  end

  def update
    @student = Student.find(params[:id])

    respond_to do |format|
      if @student.update_attributes(params[:student])
        format.html { redirect_to :action => 'profile', :id => @student.id, notice: 'Student was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @student = Student.find(params[:id])
    @student.destroy

    respond_to do |format|
      format.html { redirect_to students_url }
      format.json { head :ok }
    end
  end
   def add_additional_details
    @additional_details = StudentAdditionalField.find(:all)
    @additional_field = StudentAdditionalField.new(params[:additional_field])
    if request.post? and @additional_field.save
      flash[:notice] = "Additional field created"
      redirect_to :controller => "students", :action => "add_additional_details"
    end
  end
  def add_details
    @student = Student.find(params[:id])
    @additional_fields = StudentAdditionalField.find(:all, :conditions=> "status = true")
    if @additional_fields.empty?
      redirect_to :controller => "students", :action => "profile", :id => @student.id
    end
    if request.post?
      params[:student_additional_details].each_pair do |k, v|
        StudentAdditionalDetails.create(:student_id => params[:id],
          :additional_field_id => k,:additional_info => v['additional_info'])
      end
      flash[:notice] = "Student records saved for #{@student.first_name} #{@student.last_name}."
      redirect_to :controller => "students", :action => "profile", :id => @student.id
    end
  end
  def edit_admission4
    @student = Student.find(params[:id])
    @additional_fields = StudentAdditionalField.find(:all, :conditions=> "status = true")
    @additional_details = StudentAdditionalDetails.find_all_by_student_id(@student)
    
    if @additional_details.empty?
      redirect_to :controller => "students",:action => "add_details" , :id => @student.id
    end
    if request.post?
   
      params[:student_additional_details].each_pair do |k, v|
        row_id=StudentAdditionalDetails.find_by_student_id_and_additional_field_id(@student.id,k)
        unless row_id.nil?
          additional_detail = StudentAdditionalDetails.find_by_student_id_and_additional_field_id(@student.id,k)
          StudentAdditionalDetails.update(additional_detail.id,:additional_info => v['additional_info'])
        else
          StudentAdditionalDetails.create(:student_id=>@student.id,:additional_field_id=>k,:additional_info=>v['additional_info'])
        end
      end
      flash[:notice] = "Student #{@student.first_name} additional details updated"
      redirect_to :action => "profile", :id => @student.id
    end
  end
  
  def search_ajax


      if params[:query].length>= 3

        @students = Student.find(:all,
          :conditions => "(first_name LIKE \"#{params[:query]}%\"
                       OR middle_name LIKE \"#{params[:query]}%\"
                       OR last_name LIKE \"#{params[:query]}%\"
                       OR (concat(first_name, \" \", middle_name) LIKE \"#{params[:query]}%\")
                       OR (concat(first_name, \" \", middle_name, \" \", last_name) LIKE \"#{params[:query]}%\")
                       OR admission_no = '#{params[:query]}'
                       OR (concat(first_name, \" \", last_name) LIKE \"#{params[:query]}%\"))",
          :order => "batch_id asc,first_name asc") unless params[:query] == ''
      else

        @students = Student.find(:all,
          :conditions => "(admission_no = '#{params[:query]}')",
          :order => "batch_id asc,first_name asc") unless params[:query] == ''
      end
      render :layout => false
    
  end

  def view_all
    @batches = Batch.all
  end
  def list_students_by_course
    @students = Student.find_all_by_batch_id(params[:batch_id], :order => 'first_name ASC')
    render(:update) { |page| page.replace_html 'students', :partial => 'students_by_course' }
  end
  def advanced_search
    @batches = Batch.all
    @search = Student.search(params[:search])
    if params[:search]
      unless params[:advv_search][:course_id].empty?
        if params[:search][:batch_id_equals].empty?
          batches = Batch.find_all_by_course_id(params[:advv_search][:course_id]).collect{|b|b.id}
        end
      end
      if batches.is_a?(Array)

        @students = []
        batches.each do |b|
          params[:search][:batch_id_equals] = b
          if params[:search][:is_active_equals]=="true"
            @search = Student.search(params[:search])
            @students+=@search.all
          elsif params[:search][:is_active_equals]=="false"
            @search = ArchivedStudent.search(params[:search])
            @students+=@search.all
          else
            @search1 = Student.search(params[:search]).all
            @search2 = ArchivedStudent.search(params[:search]).all
            @students+=@search1+@search2
          end
        end
        params[:search][:batch_id_equals] = nil
      else
        if params[:search][:is_active_equals]=="true"
          @search = Student.search(params[:search])
          @students = @search.all
        elsif params[:search][:is_active_equals]=="false"
          @search = ArchivedStudent.search(params[:search])
          @students = @search.all
        else
          @search1 = Student.search(params[:search]).all
          @search2 = ArchivedStudent.search(params[:search]).all
          @students = @search1+@search2
        end
      end
    end
  end
   def categories
     @student_categories = StudentCategory.find(:all,:active,:conditions => { :is_deleted => false})
    @student_category = StudentCategory.new(params[:student_category])
    if request.post? and @student_category.save
      flash[:notice] = "Student category has been saved."
      redirect_to :action => 'categories'
    end
  end
  def category_delete
    
    if Student.find_all_by_student_category_id(params[:id]).blank?
      
      StudentCategory.update(params[:id], :is_deleted=>true)
       @student_categories = StudentCategory.find(:all,:active,:conditions => { :is_deleted => false})
    else
   redirect_to :action=>'notdelete'
          end

  end

  def category_edit
    @student_category = StudentCategory.find(params[:id])
  end

  def category_update
    @student_category = StudentCategory.find(params[:id])
    @student_category.update_attribute(:name, params[:name])
    @student_categories = StudentCategory.find(:all,:active,:conditions => { :is_deleted => false})
  end
def notdelete
 end
  
end
