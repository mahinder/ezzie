class GradingLevelsController < ApplicationController
 def index
    @batches = Batch.find(:all,:conditions => { :is_deleted => false, :is_active => true })
    @grading_levels = GradingLevel.find(:all,:conditions => { :batch_id => nil, :is_deleted => false })
  end

  def new
    puts("uiyhfdjkfhdj")
    puts("#{params}")
    @grading_level = GradingLevel.new
    @batch = Batch.find params[:id] if request.xhr? and params[:id]
    puts @grading_level
    respond_to do |format|
      format.js { render :action => 'new'}
    end
    
  end

  def create
    puts params
    puts params[:batch_id]
    @grading_level = GradingLevel.new(params[:grading_level])
    @batch = Batch.find params[:grading_level][:batch_id] unless params[:grading_level][:batch_id].empty?
  
    respond_to do |format|
      if @grading_level.save
        @grading_level.batch.nil? ?
          @grading_levels = GradingLevel.default :
          @grading_levels = GradingLevel.for_batch(@grading_level.batch_id)
        #flash[:notice] = 'Grading level was successfully created.'
        format.html { redirect_to :action=> "index" ,:grading_level =>@grading_level ,:batch_id =>@batch.id }
        format.js { render :action => 'create' }
      else
        @error = true
        format.html { render :action => "new" }
        format.js { render :action => 'create' }
      end
    end
  end

  def edit
    puts "edit"
    @grading_level = GradingLevel.find params[:id]
    
        respond_to do |format|
      format.html { }
      format.js { render :action => 'edit' }
    end
  end

  def update
    @grading_level = GradingLevel.find params[:id]
    respond_to do |format|
      if @grading_level.update_attributes(params[:grading_level])
        @grading_level.batch.nil? ? 
          @grading_levels = GradingLevel.default :
          @grading_levels = GradingLevel.for_batch(@grading_level.batch_id)
        #flash[:notice] = 'Grading level update successfully.'
        format.html { redirect_to :action => "index",:grading_level => @grading_level }
        format.js { render :action => 'update' }
      else
        @error = true
        format.html { render :action => "new" }
        format.js { render :action => 'create' }
      end
    end
  end

  def destroy
    @grading_level = GradingLevel.find params[:id]
    @grading_level.inactivate
  end

  def show
    puts params[:batch_id]
    @batch = nil
    if params[:batch_id] == ''
      @grading_levels = GradingLevel.default
    else
      
      @grading_levels = GradingLevel.for_batch(params[:batch_id])
      @batch = Batch.find params[:batch_id] unless params[:batch_id] == ''
      puts("#{params[:batch_id]}")
    end
    respond_to do |format|
      format.js { render :action => 'show' ,:batch=> @batch   }
    end
  end


end
