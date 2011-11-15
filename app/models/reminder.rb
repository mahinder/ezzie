class Reminder < ActiveRecord::Base
validates :body, presence: true

  cattr_reader :per_page
  @@per_page = 12
end
