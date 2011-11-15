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

class WeekdayController < ApplicationController
  
  def index
    @batches = Batch.active
    @weekdays = Weekday.default
    @day = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    @days = ["0", "1", "2", "3", "4", "5", "6"]
  end

  def week
    @batch = nil
    @days = ["0", "1", "2", "3", "4", "5", "6"]
    @day = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    if params[:batch_id] == ''
      @weekdays = Weekday.default
    else
      @weekdays = Weekday.for_batch(params[:batch_id])
      @b  = Batch.find params[:batch_id]
    end
    render :update do |page|
      page.replace_html "weekdays", :partial => "weekdays"
    end
  end

  

  def create
    @day = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    batch = params[:weekday][:batch_id]
    if request.post?
      new_weekdays = params[:weekdays]||[]
      batch = params[:weekday][:batch_id].empty??  nil:params[:weekday][:batch_id]
      old = Weekday.find_all_by_batch_id(batch)
      
      old_weekdays = old.map{|w| w.weekday}
      flash[:notice]  = ""
      (new_weekdays-old_weekdays).each do |new|
        Weekday.create(:batch_id =>batch, :weekday=>new.to_s)
      end
      (old_weekdays-new_weekdays).each do |week|
        weekday = Weekday.find_by_weekday(week.to_s,:conditions=>{:batch_id=>batch})
        batches = batch.nil?? (Batch.active.reject {|b| !Weekday.for_batch(b.id).empty?} ): Batch.find_all_by_id(batch)
        batches.each do |b|
          (Date.today.to_date..b.end_date.to_date).each do |d|
            if d.wday.to_s == weekday.weekday.to_s
              period =PeriodEntry.find_all_by_month_date_and_batch_id(d,b.id)
              period.each do |p| p.destroy  end
            end
          end
    end
        weekday.destroy
      end
    flash[:notice] = "Weekdays modified "
    end
    redirect_to :action => "index"
  end
end
