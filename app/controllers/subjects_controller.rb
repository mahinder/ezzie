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

class SubjectsController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  def index
    @batches = Batch.active
  end

  def new
    puts "iam in new"
    @subject = Subject.new
    @batch = Batch.find params[:id] if request.xhr? and params[:id]
    puts "#{@batch}"
    @elective_group = ElectiveGroup.find params[:id2] unless params[:id2].nil?
    respond_to do |format|
      format.js { render :action => 'new' }
    end
  end

  def create
    @subject = Subject.new(params[:subject])
    puts "i am in subject create #{@subject}"
    @batch = @subject.batch
     puts "i am in subject create #{@batch}"
    if @subject.save
      if params[:subject][:elective_group_id] == ""
        @subjects = @subject.batch.normal_batch_subject
        @normal_subjects = @subject
        @elective_groups = ElectiveGroup.find_all_by_batch_id(@batch.id)
      else
        @elective_group = params[:subject][:elective_group_id].to_i
        @subjects = @subject.batch.elective_batch_subject(@elective_group)
      end
    else
      @error = true
    end
  end

  def edit
    @subject = Subject.find params[:id]
    @elective_group = ElectiveGroup.find params[:id2] unless params[:id2].nil?
    respond_to do |format|
      format.html { }
      format.js { render :action => 'edit' }
    end
  end

  def update
    @subject = Subject.find params[:id]
    @batch = @subject.batch
    if @subject.update_attributes(params[:subject])
      if params[:subject][:elective_group_id] == ""
        @subjects = @subject.batch.normal_batch_subject
      else
        elect_group = params[:subject][:elective_group_id].to_i
        @subjects = @subject.batch.elective_batch_subject(elect_group)
      end
    else
      @error = true
    end
  end

  def destroy
     @subject = Subject.find params[:id]
   @subject_exams= Exam.find_by_subject_id(@subject.id)
   if @subject_exams.nil?
    @subject.inactivate
   else
    @error_text = "Cannot delete subjects"
    end
  end

  def show
    puts "i am in show"
    if params[:batch_id] == ''
      @subjects = []
      puts "in if"
    else
      @batch = Batch.find params[:batch_id]
      puts " in else"
      @subjects = @batch.normal_batch_subject
     @elective_groups = ElectiveGroup.find_all_by_batch_id(params[:batch_id], :conditions =>{:is_deleted=>false})
    end
    respond_to do |format|
      format.js { render :action => 'show', }
    end
  end

end