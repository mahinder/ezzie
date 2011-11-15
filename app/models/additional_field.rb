class AdditionalField < ActiveRecord::Base
  validates :name, presence: true
end
