class CoursesController < ApplicationController
def index
    @courses = Course.find(:all,:active,:conditions => { :is_deleted => false})
end

  def new
    @course = Course.new
  end

  def manage_course
    @courses = Course.find(:all,:active,:conditions => { :is_deleted => false})
   @hhj = current_user
    puts "i m in manage#{@hhj}"
  end

  def manage_batches

  end

  def update_batch
    puts "i am in india"
    @batch = Batch.find_all_by_course_id(params[:course_name], :conditions => { :is_deleted => false, :is_active => true })

    render(:update) do |page|
      page.replace_html 'update_batch', :partial=>'update_batch'
    end

  end

  def create
    @course = Course.new params[:course]
    if @course.save
      flash[:notice] = 'Created course successfully.'
      redirect_to :action=>'manage_course'
    else
      render 'new'
    end
  end

  def edit
     @course = Course.find(params[:course])
  end

  def update
    @course = Course.find(params[:id])
    if @course.update_attributes(params[:course])
      flash[:notice] = 'Updated course details successfully.'
      redirect_to :action=>'manage_course'
    else
      render 'edit'
    end
  end

  def destroy
    @course = Course.find(params[:course])
    if @course.batches.active.empty?
      @course.inactivate
       flash[:notice]="Course deleted successfully."
      redirect_to :action=>'manage_course'
    else
      flash[:warn_notice]="<p>Unable to Delete. Please remove existing batches and students.</p>"
      redirect_to :action=>'manage_course'
    end
end
  def show
     @course = Course.find(params[:course])
    @batches = @course.batches.find(:all,:active,:conditions =>{:is_deleted => false})
  end

  private
  def find_course
    @course = Course.find params[:id]
  end

end