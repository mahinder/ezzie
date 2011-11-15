class FinanceTransactionCategory < ActiveRecord::Base
  has_many :finance_transactions
  has_one  :trigger, :class_name => "FinanceTransactionTrigger", :foreign_key => "category_id"
  
  scope :expense_categories, :conditions => "is_income = false AND name NOT LIKE 'Salary'and deleted = 0"
  scope :income_categories, :conditions => "is_income = true AND name NOT LIKE 'Fee' AND name NOT LIKE 'Donation' and deleted = 0"

end
