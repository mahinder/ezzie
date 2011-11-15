class News < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  has_many :comments, :class_name => 'NewsComment'
  
  validates :title, :content,presence: true
# 
  default_scope :order => 'created_at DESC'
# 
  cattr_reader :per_page
   # xss_terminate :except => [:content]
   @@per_page = 12
end
