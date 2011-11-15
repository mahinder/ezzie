class NewsComment < ActiveRecord::Base
  belongs_to :news


  validates :content, :news_id,presence: true

end
