class IndividualPayslipCategory < ActiveRecord::Base
   validates_numericality_of :amount, :allow_nil=>true
end
