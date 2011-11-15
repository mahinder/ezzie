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

class ElectiveGroupsController < ApplicationController
  before_filter :pre_load_objects
  def index
    @elective_groups = ElectiveGroup.for_batch(@batch.id)
  end

  def new
    @elective_group = @batch.elective_groups.build
  end

  def create
    @elective_group = ElectiveGroup.new(params[:elective_group])
    @elective_group.batch_id = @batch.id
    if @elective_group.save
      flash[:notice] = 'New elective group created.'
      redirect_to :action =>"index", :batch_id => @batch.id
     # redirect_to batch_elective_groups_path(@batch)
    else
      render :action=>'new'
    end
  end

  def edit
    @elective_group = ElectiveGroup.find(params[:id])
    render 'edit'
  end

  def update
    @elective_group = ElectiveGroup.find(params[:id])
    if @elective_group.update_attributes(params[:elective_group])
      flash[:notice] = 'Elective group updated.'
      #redirect_to [@batch, @elective_group]
      redirect_to batch_elective_groups_path(@batch)
    else
      render 'edit'
    end
  end

  def destroy
    @elective_group.inactivate
    flash[:notice] = 'Deleted elective group.'
    redirect_to :action => "index", :batch_id => @batch
  end

  def show
    @electives = Subject.find_all_by_batch_id_and_elective_group_id(@batch.id,@elective_group.id, :conditions=> ["is_deleted = false"])
  end

  private

  def pre_load_objects
    @batch = Batch.find(params[:batch_id], :include => :course)
    @course = @batch.course
    @elective_group = ElectiveGroup.find(params[:batch_id]) unless params[:batch_id].nil?
  end
end
