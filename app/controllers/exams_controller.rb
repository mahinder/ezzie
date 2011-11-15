class ExamsController < ApplicationController
   before_filter :query_data
  before_filter :protect_other_student_data
  before_filter :restrict_employees_from_exam
  filter_access_to :all

  def new
    @exam = Exam.new
    @subjects = @batch.subjects
    if @current_user.employee? and  !@current_user.privileges.map{|m| m.id}.include?(1)
      @subjects= Subject.find(:all,:joins=>"INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id} ")
      if @subjects.blank?
        flash[:notice] = "Sorry, you are not allowed to access that page."
        redirect_to [@batch, @exam_group]
      end
    end
  end

  def create
    @exam = Exam.new(params[:exam])
    @exam.exam_group_id = @exam_group.id
    if @exam.save
      flash[:notice] = "New exam created successfully."
      redirect_to [@batch, @exam_group]
    else
      @subjects = @batch.subjects
      if @current_user.employee? and  !@current_user.privileges.map{|m| m.id}.include?(1)
        @subjects= Subject.find(:all,:joins=>"INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id} ")
      end
      render 'new'
    end
  end

  def edit
    @exam = Exam.find params[:id], :include => :exam_group
    @subjects = @exam_group.batch.subjects
    if @current_user.employee?  and !@current_user.privileges.map{|m| m.id}.include?(1)
      @subjects= Subject.find(:all,:joins=>"INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id} ")
      unless @subjects.map{|m| m.id}.include?(@exam.subject_id)
        flash[:notice] = "Sorry, you are not allowed to access that page."
        redirect_to [@batch, @exam_group]
      end
    end
  end

  def update
    @exam = Exam.find params[:id], :include => :exam_group

    if @exam.update_attributes(params[:exam])
      flash[:notice] = 'Updated exam details successfully.'
      redirect_to [@exam_group, @exam]
    else
      @subjects = @batch.subjects
      if @current_user.employee? and  !@current_user.privileges.map{|m| m.id}.include?(1)
        @subjects= Subject.find(:all,:joins=>"INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id} ")
      end
      render 'edit'
    end
  end

  def show
    @employee_subjects=[]
    @employee_subjects= @current_user.employee_record.subjects.map { |n| n.subject_id} if @current_user.employee?
    @exam = Exam.find params[:id], :include => :exam_group
    unless @employee_subjects.include?("#{@exam.subject_id}") or @current_user.admin? or @current_user.privileges.map{|p| p.id}.include?(1) or @current_user.privileges.map{|p| p.id}.include?(2)
      flash[:notice] = 'Access Denied.'
      redirect_to :controller=>"user", :action=>"dashboard"
    end
    exam_subject = Subject.find(@exam.subject_id)
    is_elective = exam_subject.elective_group_id
    if is_elective == nil
      @students = @batch.students
    else
      assigned_students = StudentsSubject.find_all_by_subject_id(exam_subject.id)
      @students = []
      assigned_students.each do |s|
        student = Student.find_by_id(s.student_id)
        @students.push student unless student.nil?
      end
    end
    @config = Configuration.get_config_value('ExamResultType') || 'Marks'

    @grades = @batch.grading_level_list
  end

  def destroy
    @exam = Exam.find params[:id], :include => :exam_group
    if @current_user.employee?  and !@current_user.privileges.map{|m| m.id}.include?(1)
      @subjects= Subject.find(:all,:joins=>"INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id} ")
      unless @subjects.map{|m| m.id}.include?(@exam.subject_id)
        flash[:notice] = "Sorry, you are not allowed to access that page."
        redirect_to [@batch, @exam_group] and return
      end
    end
    if @exam.destroy
      batch_id = @exam.exam_group.batch_id
      batch_event = BatchEvent.find_by_event_id_and_batch_id(@exam.event_id,batch_id)
      event = Event.find(@exam.event_id)
      event.destroy
      batch_event.destroy
    end
    redirect_to [@batch, @exam_group]
  end

  def save_scores
    @exam = Exam.find(params[:id])
    @error= false
    params[:exam].each_pair do |student_id, details|
      @exam_score = ExamScore.find(:first, :conditions => {:exam_id => @exam.id, :student_id => student_id} )
      if @exam_score.nil?
        if details[:marks].to_f <= @exam.maximum_marks.to_f
          ExamScore.create do |score|
            score.exam_id          = @exam.id
            score.student_id       = student_id
            score.marks            = details[:marks]
            score.grading_level_id = details[:grading_level_id]
            score.remarks          = details[:remarks]
          end
        else
          @error = true
        end
      else
        if details[:marks].to_f <= @exam.maximum_marks.to_f
          if @exam_score.update_attributes(details)
          else
            flash[:warn_notice] = 'Grading Levels are not set. Please set Grading Level'
            @error = nil
          end
        else
          @error = true
        end
      end
    end
    flash[:notice] = 'Exam score exceeds Maximum Mark.' if @error == true
    flash[:notice] = 'Exam scores updated.' if @error == false
    redirect_to [@exam_group, @exam]
  end

  private
  def query_data
    @exam_group = ExamGroup.find(params[:exam_group_id], :include => :batch)
    @batch = @exam_group.batch
    @course = @batch.course
  end
end
