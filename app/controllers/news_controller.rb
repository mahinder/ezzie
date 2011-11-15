class NewsController < ApplicationController
  # GET /news
  # GET /news.json
   def add
    @news = News.new(params[:news])
    # @news.author = current_user
    if request.post? and @news.save
      # sms_setting = SmsSetting.new()
      # if sms_setting.application_sms_active
        # students = Student.find(:all,:select=>'phone2',:conditions=>'is_sms_enabled = true')
      # end
      flash[:notice] = 'News added!'
      redirect_to :controller => 'news', :action => 'view', :id => @news.id
    end
  end

  def add_comment
    @cmnt = NewsComment.new(params[:comment])
    if @cmnt.save
      puts ("I am saved")
    end
    else
      puts ("I am not saved")
  end

  def all
    @news = News.paginate :page => params[:page]
  end

  def delete
    @news = News.find(params[:id]).destroy
    flash[:notice] = 'News item deleted successfully!'
    redirect_to :controller => 'news', :action => 'index'
  end

  def delete_comment
    @comment = NewsComment.find(params[:id])
    NewsComment.destroy(params[:id])
  end

  def edit
    @news = News.find(params[:id])
    if request.post? and @news.update_attributes(params[:news])
      flash[:notice] = 'News updated!'
      redirect_to :controller => 'news', :action => 'view', :id => @news.id
    end
  end

  def index
    # @current_user = current_user
    @news = []
    if request.get?
    conditions = ["title LIKE ?", "%#{params[:query]}%"]
    @news = News.find(:all, :conditions => conditions) unless params[:query] == ''
    end
  end

  def search_news_ajax
    @news = nil
    conditions = ["title LIKE ?", "%#{params[:query]}%"]
    @news = News.find(:all, :conditions => conditions) unless params[:query] == ''
    render :layout => false
  end

  def view
    # @current_user = current_user
    @news = News.find(params[:id])
    @comments = @news.comments   
  end
end
