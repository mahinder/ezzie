class BankField < ActiveRecord::Base
  validates :name, presence: true
end
