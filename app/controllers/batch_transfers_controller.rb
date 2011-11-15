class BatchTransfersController < ApplicationController
   def index
    @batches = Batch.active
  end

  def show
    @batch = Batch.find params[:id], :include => [:students],:order => "students.first_name ASC"
   
    @batches = Batch.active - [*@batch]

  
  end

  def transfer
    unless params[:transfer][:students].nil?
      students = Student.find(params[:transfer][:students])
      students.each do |s|
        s.graduated_batches << s.batch
        s.update_attribute(:batch_id, params[:transfer][:to])
        s.update_attribute(:has_paid_fees,0)
      end
    end
    batch = Batch.find(params[:id])
    @stu = Student.find_all_by_batch_id(batch.id)
    if @stu.empty?
      batch.update_attribute :is_active, false
      Subject.find_all_by_batch_id(batch.id).each do |sub|
          sub.employees_subjects.each do |emp_sub|
            emp_sub.delete
          end
      end
    end
    flash[:notice] = 'Trasferred students successfully.'
    redirect_to :controller => 'batch_transfers'
  end

  def graduation
    @batch = Batch.find params[:id], :include => [:students]
    unless params[:ids].nil?
      @ids = params[:ids]
      @id_lists = @ids.map { |st_id| ArchivedStudent.find_by_admission_no(st_id) }
    end
    if request.post?
      student_id_list = params[:graduate][:students]
        @student_list = student_id_list.map { |st_id| Student.find(st_id) }
        @admission_list = []
        @student_list.each do |s|
          @admission_list.push s.admission_no
        end
        @student_list.each { |s| s.archive_student(params[:graduate][:status_description]) }
        @stu = Student.find_all_by_batch_id(@batch.id)
        if @stu.empty?
          @batch.update_attribute :is_active, false
#          flash[:notice]="Graduated selected students successfully."
#          redirect_to :controller=>'batch_transfers' and return
        end
        flash[:notice]="Graduated selected students successfully."
        redirect_to :action=>"graduation", :id=>params[:id], :ids => @admission_list
      end
    end

  def subject_transfer
    @batch = Batch.find(params[:id])
    @elective_groups = @batch.elective_groups
    @normal_subjects = @batch.normal_batch_subject
    @elective_subjects = Subject.find_all_by_batch_id(@batch.id,:conditions=>["elective_group_id IS NOT NULL AND is_deleted = false"])
  end

  def get_previous_batch_subjects
    @batch = Batch.find(params[:id])
    course = @batch.course
    all_batches = course.batches
    all_batches.reject! {|b| b.is_deleted?}
    all_batches.reject! {|b| b.subjects.empty?}
    @previous_batch = all_batches[all_batches.size-2]
    @previous_batch_normal_subject = @previous_batch.normal_batch_subject
    @elective_groups = @previous_batch.elective_groups
    @previous_batch_electives = Subject.find_all_by_batch_id(@previous_batch.id,:conditions=>["elective_group_id IS NOT NULL AND is_deleted = false"])
    render(:update) do |page|
      page.replace_html 'previous-batch-subjects', :partial=>"previous_batch_subjects"
    end
  end

  def update_batch
    @batches = Batch.find_all_by_course_id(params[:course_name], :conditions => { :is_deleted => false, :is_active => true })

    render(:update) do |page|
      page.replace_html 'update_batch', :partial=>'list_courses'
    end

  end

  def assign_previous_batch_subject
    subject = Subject.find(params[:id])
    batch = Batch.find(params[:id2])
    sub_exists = Subject.find_by_batch_id_and_name(batch.id,subject.name)
    if sub_exists.nil?
      if subject.elective_group_id == nil
        Subject.create(:name=>subject.name,:code=>subject.code,:batch_id=>batch.id,:no_exams=>subject.no_exams,
          :max_weekly_classes=>subject.max_weekly_classes,:elective_group_id=>subject.elective_group_id,:is_deleted=>false)
      else
        elect_group_exists = ElectiveGroup.find_by_name_and_batch_id(ElectiveGroup.find(subject.elective_group_id).name,batch.id)
        if elect_group_exists.nil?
          elect_group = ElectiveGroup.create(:name=>ElectiveGroup.find(subject.elective_group_id).name,
            :batch_id=>batch.id,:is_deleted=>false)
          Subject.create(:name=>subject.name,:code=>subject.code,:batch_id=>batch.id,:no_exams=>subject.no_exams,
            :max_weekly_classes=>subject.max_weekly_classes,:elective_group_id=>elect_group.id,:is_deleted=>false)
        else
          Subject.create(:name=>subject.name,:code=>subject.code,:batch_id=>batch.id,:no_exams=>subject.no_exams,
            :max_weekly_classes=>subject.max_weekly_classes,:elective_group_id=>elect_group_exists.id,:is_deleted=>false)
        end
      end
      render(:update) do |page|
        page.replace_html "prev-subject-name-#{subject.id}", :text=>""
        page.replace_html "errors", :text=>"#{subject.name}  has been added to batch:#{batch.name}"
      end
    else
      render(:update) do |page|
        page.replace_html "prev-subject-name-#{subject.id}", :text=>""
        page.replace_html "errors", :text=>"<div class=\"errorExplanation\" ><p>#{batch.name} Already has the subject with name #{subject.name}</p></div>"
      end
    end
  end

  def assign_all_previous_batch_subjects
    msg = ""
    err = ""
    batch = Batch.find(params[:id])
    course = batch.course
    all_batches = course.batches
    @previous_batch = all_batches[all_batches.size-2]
    subjects = Subject.find_all_by_batch_id(@previous_batch.id,:conditions=>'is_deleted=false')
    subjects.each do |subject|
      sub_exists = Subject.find_by_batch_id_and_name(batch.id,subject.name)
      if sub_exists.nil?
        if subject.elective_group_id.nil?
          Subject.create(:name=>subject.name,:code=>subject.code,:batch_id=>batch.id,:no_exams=>subject.no_exams,
            :max_weekly_classes=>subject.max_weekly_classes,:elective_group_id=>subject.elective_group_id,:is_deleted=>false)
        else
          elect_group_exists = ElectiveGroup.find_by_name_and_batch_id(ElectiveGroup.find(subject.elective_group_id).name,batch.id)
          if elect_group_exists.nil?
            elect_group = ElectiveGroup.create(:name=>ElectiveGroup.find(subject.elective_group_id).name,
              :batch_id=>batch.id,:is_deleted=>false)
            Subject.create(:name=>subject.name,:code=>subject.code,:batch_id=>batch.id,:no_exams=>subject.no_exams,
              :max_weekly_classes=>subject.max_weekly_classes,:elective_group_id=>elect_group.id,:is_deleted=>false)
          else
            Subject.create(:name=>subject.name,:code=>subject.code,:batch_id=>batch.id,:no_exams=>subject.no_exams,
              :max_weekly_classes=>subject.max_weekly_classes,:elective_group_id=>elect_group_exists.id,:is_deleted=>false)
          end
        end
        msg += "<li> The subject #{subject.name}  has been added to Batch #{batch.name}</li>"
      else
        err +=   "<li>Batch #{batch.name} already has a subject with name #{subject.name}" + "</li>"
      end
    end
    @batch = batch
    course = batch.course
    all_batches = course.batches
    @previous_batch = all_batches[all_batches.size-2]
    @previous_batch_normal_subject = @previous_batch.normal_batch_subject
    @elective_groups = @previous_batch.elective_groups
    @previous_batch_electives = Subject.find_all_by_batch_id(@previous_batch.id,:conditions=>["elective_group_id IS NOT NULL AND is_deleted = false"])
    render(:update) do |page|
      page.replace_html 'previous-batch-subjects', :text=>"<p>Subjects have been assigned.</p> "
      unless msg.empty?
        page.replace_html "msg", :text=>"<div class=\"flash-msg\"><ul>" +msg +"</ul></p>"
      end
      unless err.empty?
        page.replace_html "errors", :text=>"<div class=\"errorExplanation\" ><p>Following errors were found :</p><ul>" +err + "</ul></div>"
      end
    end

  end



  def new_subject
    @subject = Subject.new
    @batch = Batch.find params[:id] if request.xhr? and params[:id]
    @elective_group = ElectiveGroup.find params[:id2] unless params[:id2].nil?
    respond_to do |format|
      format.js { render :action => 'new_subject' }
    end
  end

  def create_subject
    @subject = Subject.new(params[:subject])
    @batch = @subject.batch
    if @subject.save
      @subjects = @subject.batch.normal_batch_subject
      @normal_subjects = @subjects
      @elective_groups = ElectiveGroup.find_all_by_batch_id(@batch.id)
      @elective_subjects = Subject.find_all_by_batch_id(@batch.id,:conditions=>["elective_group_id IS NOT NULL AND is_deleted = false"])
    else
      @error = true
    end
  end

end
