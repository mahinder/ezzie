class TimetableController < ApplicationController
  
  def generate
    @batches = Batch.active
    if request.post?
      @batch = Batch.find params[:timetable][:batch_id]
      @config = Schooldatum.find_by_config_key('StudentAttendanceType')
      @start_date = @batch.start_date.to_date
      @end_date = @batch.end_date.to_date
      not_set_for_batch = Weekday.for_batch(@batch.id).empty?
      set = 0
      (@start_date..@end_date).each do |d|
        weekday = not_set_for_batch ? (Weekday.find_by_batch_id_and_weekday(nil,d.wday)) :  (Weekday.find_by_batch_id_and_weekday(@batch.id,d.wday))
        unless weekday.nil?
          @period = PeriodEntry.find_all_by_month_date_and_batch_id(d,@batch.id)
          if @period.empty?
            unless Event.is_a_holiday?(d)
              unless @config.config_value == 'Daily'
                entries = TimetableEntry.find_all_by_weekday_id_and_batch_id(weekday.id, @batch.id)
                entries.each do |tte|
                  if tte.subject.nil?
                    PeriodEntry.create(:month_date=> d, :batch_id => @batch.id,:class_timing_id => tte.class_timing_id, :employee_id => tte.employee_id)
                  elsif tte.subject.elective_group_id.nil?
                    PeriodEntry.create(:month_date=> d, :batch_id => @batch.id, :subject_id => tte.subject_id, :class_timing_id => tte.class_timing_id, :employee_id => tte.employee_id)
                  else
                    sub = Subject.find_all_by_elective_group_id_and_batch_id(tte.subject.elective_group_id, @batch.id)
                    sub.each do |s|
                      PeriodEntry.create(:month_date=> d, :batch_id => @batch.id, :subject_id => s.id, :class_timing_id => tte.class_timing_id, :employee_id => tte.employee_id)
                  end
                end
              end
              set = 2
            else
              PeriodEntry.create(:month_date=> d, :batch_id => @batch.id)
              set = 2
            end
          end
        else
          if @config.config_value == "SubjectWise"
            if d >= Date.today
              entries = TimetableEntry.find_all_by_weekday_id_and_batch_id(weekday.id, @batch.id)
              entries.each do |tte|
                @period.each do |p|
                  if tte.class_timing_id == p.class_timing_id
                    unless tte.subject_id == p.subject_id
                      PeriodEntry.update(p.id, :month_date=> d, :batch_id => @batch.id, :subject_id => tte.subject_id, :class_timing_id =>tte.class_timing_id, :employee_id => tte.employee_id)
                      set = 1
                    end
                  end
                end

              end
            end
          end
        end
      end
          
      if set == 0
        flash[:notice] = 'Timetable has already been published'
      elsif set == 1
        flash[:notice] = 'Timetable updated'
      else
        flash[:notice] = "Time table Published"
      end
    end
    
    @config = Schooldatum.available_modules
    if @config.include?('HR')
      redirect_to :action=>"edit2", :id => @batch.id
    else
      redirect_to :action=>"edit", :id => @batch.id
    end
  end
end

def extra_class
  @config = Schooldatum.available_modules
  unless   params[:extra_class].nil?
    puts params[:extra_class][:date].to_date
    puts params[:extra_class][:batch_id]
    @date = params[:extra_class][:date].to_date
    @batch = Batch.find(params[:extra_class][:batch_id])
    @period_entry = PeriodEntry.find_all_by_month_date_and_batch_id(@date,@batch.id)
    puts @batch.id
    puts @period_entry
    render (:update) do |page|
      if @period_entry.blank?
        flash[:notice] = 'No timetable entry for selected date'
        page.replace_html 'extra-class-form', :partial=>"no_period_entry"
      else
        page.replace_html 'extra-class-form', :partial => "extra_class_form"
      end
    end
  end
      
end
def extra_class_edit
  @config = Schooldatum.available_modules
  @period_id = params[:id]
  @period_entry = PeriodEntry.find(@period_id)
  @subjects = Subject.find_all_by_batch_id(@period_entry.batch_id,:conditions=>'is_deleted=false')
  @employee = EmployeesSubject.find_all_by_subject_id(@period_entry.subject_id)
end
def list_employee_by_subject
  @period_id = params[:period_id]
  @subject = Subject.find(params[:subject_id])
  @employee = EmployeesSubject.find_all_by_subject_id(@subject.id)
  render (:update) do |page|
    page.replace_html "employee-update-#{@period_id}", :partial => "list_employee_by_subject"
  end
end
def save_extra_class
  @period = PeriodEntry.find(params[:period_entry][:period_id])
  PeriodEntry.update(@period.id, :subject_id => params[:period_entry][:subject_id], :employee_id => params[:period_entry][:employee_id])
  @period = PeriodEntry.find(params[:period_entry][:period_id])
  render (:update) do |page|
    page.replace_html "tr-extra-class-#{@period.id}", :partial => 'extra_class_update'
  end
end

def timetable
  @config = Schooldatum.available_modules
  @batches = Batch.active
  unless params[:next].nil?
    @today = params[:next].to_date
    render (:update) do |page|
      page.replace_html "timetable", :partial => 'table'
    end
  else
    @today = Date.today
  end
end

def delete_subject
  @weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  @errors = {"messages" => []}
  tte = TimetableEntry.update(params[:id], :subject_id => nil)
  @timetable = TimetableEntry.find_all_by_batch_id(tte.batch_id)
  render :partial => "edit_tt_multiple", :with => @timetable
end

def edit
  @weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  @errors = {"messages" => []}
  @batch = Batch.find(params[:id])
  @timetable = TimetableEntry.find_all_by_batch_id(params[:id])
  @class_timing = ClassTiming.find_all_by_batch_id(@batch.id, :conditions => "is_break = false")
  if @class_timing.empty?
    @class_timing = ClassTiming.default
  end
  @day = Weekday.find_all_by_batch_id(@batch.id)
  if @day.empty?
    @day = Weekday.default
  end
  @subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>["elective_group_id IS NULL AND is_deleted = false"])
end

def select_class
  @batches = Batch.active
  if request.post?
    unless params[:timetable_entry][:batch_id].empty?
      @batch = Batch.find(params[:timetable_entry][:batch_id])
      @class_timings = ClassTiming.find_all_by_batch_id(@batch.id)
      if @class_timings.empty?
        @class_timings = ClassTiming.default
      end
      @days = Weekday.find_all_by_batch_id(@batch.id)
      if @days.empty?
        @days = Weekday.default
      end
      @days.each do |d|
        @class_timings.each do |p|
          TimetableEntry.create(:batch_id=>@batch.id, :weekday_id => d.id, :class_timing_id => p.id) \
            if TimetableEntry.find_by_batch_id_and_weekday_id_and_class_timing_id(@batch.id, d.id, p.id).nil?
        end
      end

      redirect_to :action => "edit", :id => @batch.id
    else
      flash[:notice]="Select a batch to continue"
      redirect_to :action => "select_class"
    end
  end
end

def weekdays
  @batches = Batch.active
end

def tt_entry_update
  @weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  @errors = {"messages" => []}
  subject = Subject.find(params[:sub_id])
  TimetableEntry.update(params[:tte_id], :subject_id => params[:sub_id])
  @timetable = TimetableEntry.find_all_by_batch_id(subject.batch_id)
  render :partial => "edit_tt_multiple", :with => @timetable
end

def tt_entry_noupdate
  render do |page|
    page.Cancelled  
  end
end

def update_multiple_timetable_entries
  @weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  subject = Subject.find(params[:subject_id])
  tte_ids = params[:tte_ids].split(",").each {|x| x.to_i}
  course = subject.batch
  @validation_problems = {}

  tte_ids.each do |tte_id|
    errors = { "info" => {"sub_id" => subject.id, "tte_id" => tte_id},
      "messages" => [] }

    # check for weekly subject limit.
    errors["messages"] << "Weekly subject limit reached." \
      if subject.max_weekly_classes <= TimetableEntry.count(:conditions => "subject_id = #{subject.id}")

    if errors["messages"].empty?
      TimetableEntry.update(tte_id, :subject_id => subject.id)
    else
      @validation_problems[tte_id] = errors
    end
  end

  @timetable = TimetableEntry.find_all_by_batch_id(course.id)
  render :partial => "edit_tt_multiple", :with => @timetable
end

def view
  @courses = Batch.active
end

def student_view
  @weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  student = Student.find(params[:id])
  @batch = student.batch
  @timetable = TimetableEntry.find_all_by_batch_id(@batch.id)
  @class_timing = ClassTiming.find_all_by_batch_id(@batch.id, :conditions => "is_break = false")
  if @class_timing.empty?
    @class_timing = ClassTiming.default
  end
  @day = Weekday.find_all_by_batch_id(@batch.id)
  if @day.empty?
    @day = Weekday.default
  end
  @subjects = Subject.find_all_by_batch_id(@batch.id)
end

def update_timetable_view
  if params[:course_id] == ""
    render :update do |page|
      page.replace_html "timetable_view", :text => ""
    end
    return
  end
  @batch = Batch.find(params[:course_id])
  @timetable = TimetableEntry.find_all_by_batch_id(@batch.id)
  @class_timing = ClassTiming.find_all_by_batch_id(@batch.id, :conditions => "is_break = false")
  if @class_timing.empty?
    @class_timing = ClassTiming.default
  end
  @day = Weekday.find_all_by_batch_id(@batch.id)
  if @day.empty?
    @day = Weekday.default
  end

  @subjects = Subject.find_all_by_batch_id(@batch.id)
  @weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  render :update do |page|
    page.replace_html "timetable_view", :partial => "view_timetable"
  end
end

#methods given below are for timetable with HR module connected

def select_class2
  @weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  @batches = Batch.active
  if request.post?
    unless params[:timetable_entry][:batch_id].empty?
      @batch = Batch.find(params[:timetable_entry][:batch_id])
      @class_timings = ClassTiming.find_all_by_batch_id(@batch.id, :conditions => "is_break = false")
      if @class_timings.empty?
        @class_timings = ClassTiming.default
      end
      @day = Weekday.find_all_by_batch_id(@batch.id)
      
      if @day.empty?
        @day = Weekday.default
      end
      @day.each do |d|
        @class_timings.each do |p|
          TimetableEntry.create(:batch_id=>@batch.id, :weekday_id => d.id, :class_timing_id => p.id) \
            if TimetableEntry.find_by_batch_id_and_weekday_id_and_class_timing_id(@batch.id, d.id, p.id).nil?
            
        end
      end
      
      redirect_to :action => "edit2", :id => @batch.id
    else
      flash[:notice]="Select a batch to continue"
      redirect_to :action => "select_class2"
    end
  end
end

def edit2
  @weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  @errors = {"messages" => []}
  @batch = Batch.find(params[:id])
  @timetable = TimetableEntry.find_all_by_batch_id(params[:id])
 
  @class_timing = ClassTiming.find_all_by_batch_id(@batch.id, :conditions =>[ "is_break = false"], :order =>'start_time ASC')
  if @class_timing.empty?
    @class_timing = ClassTiming.default
  end
  @day = Weekday.find_all_by_batch_id(@batch.id)
  if @day.empty?
    @day = Weekday.default
  end
  @subjects = Subject.find_all_by_batch_id(@batch.id)
 
end

def update_employees
  @weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  if params[:subject_id] == ""
    render :text => ""
    return
  end
  @employees_subject = EmployeesSubject.find_all_by_subject_id(params[:subject_id])
  render :partial=>"employee_list"
end

def update_multiple_timetable_entries2
  @weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  employees_subject = EmployeesSubject.find(params[:emp_sub_id])
  tte_ids = params[:tte_ids].split(",").each {|x| x.to_i}
  @batch = employees_subject.subject.batch
  subject = employees_subject.subject
  employee = employees_subject.employee
  @validation_problems = {}

  tte_ids.each do |tte_id|
    tte = TimetableEntry.find(tte_id)
    errors = { "info" => {"sub_id" => employees_subject.subject_id, "emp_id"=> employees_subject.employee_id,"tte_id" => tte_id},
      "messages" => [] }

    # check for weekly subject limit.
    errors["messages"] << "Weekly subject limit reached." \
      if subject.max_weekly_classes <= TimetableEntry.count(:conditions => "subject_id = #{subject.id}") unless subject.max_weekly_classes.nil?

    #check for overlapping classes
    overlap = TimetableEntry.find(:first,
      :conditions => "weekday_id = #{tte.weekday_id} AND
                                               class_timing_id = #{tte.class_timing_id} AND
                                               employee_id = #{employee.id}")
    unless overlap.nil?
      errors["messages"] << "Class overlap occured with Batch: #{overlap.batch.full_name}."
    end

    # check for max_hour_day exceeded
    errors["messages"] << "Max hours per day exceeded." \
      if employee.max_hours_per_day <= TimetableEntry.count(:conditions => "employee_id = #{employee.id} AND weekday_id = #{tte.weekday_id}") unless employee.max_hours_per_day.nil?

    # check for max hours per week
    errors["messages"] << "Max hours per week exceeded." \
      if employee.max_hours_per_week <= TimetableEntry.count(:conditions => "employee_id = #{employee.id}") unless employee.max_hours_per_week.nil?

    if errors["messages"].empty?
      TimetableEntry.update(tte_id, :subject_id => subject.id, :employee_id=>employee.id)
    else
      @validation_problems[tte_id] = errors
    end
  end

  @timetable = TimetableEntry.find_all_by_batch_id(@batch.id)
  render :partial => "edit_tt_multiple2"
end

def delete_employee2
  @weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  @errors = {"messages" => []}
  tte=TimetableEntry.update(params[:id], :subject_id => nil, :employee_id => nil)
  @timetable = TimetableEntry.find_all_by_batch_id(tte.batch_id)
  render :partial => "edit_tt_multiple2", :with => @timetable
end

def tt_entry_update2
  @weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  @errors = {"messages" => []}
  subject = Subject.find(params[:sub_id])
  tte = TimetableEntry.find(params[:tte_id])
  overlapped_tte = TimetableEntry.find_by_weekday_id_and_class_timing_id_and_employee_id(tte.weekday_id,tte.class_timing_id,params[:emp_id])
  if overlapped_tte.nil?
    TimetableEntry.update(params[:tte_id], :subject_id => params[:sub_id], :employee_id => params[:emp_id])
  else
    TimetableEntry.update(overlapped_tte.id,:subject_id => nil, :employee_id => nil )
    TimetableEntry.update(params[:tte_id], :subject_id => params[:sub_id], :employee_id => params[:emp_id])
  end
  @timetable = TimetableEntry.find_all_by_batch_id(subject.batch_id)
  render :partial => "edit_tt_multiple2", :with => @timetable
end

def tt_entry_noupdate2
  render do |page|
    page.Cancelled  
  end
   end
#PDF Reports
def timetable_pdf
  @batch = Batch.find(params[:course_id])
  @timetable = TimetableEntry.find_all_by_batch_id(@batch.id)
  @class_timing = ClassTiming.find_all_by_batch_id(@batch.id, :conditions => "is_break = false")
  if @class_timing.empty?
    @class_timing = ClassTiming.default
  end
  @day = Weekday.find_all_by_batch_id(@batch.id)
  if @day.empty?
    @day = Weekday.default
  end
  @subjects = Subject.find_all_by_batch_id(@batch.id)
  @weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  render :pdf=>'timetable_pdf'
          

  #  respond_to do |format|
  #    format.pdf { render :layout => false }
  #  end
end
end
