class CountryState < ActiveRecord::Base

 def state_name
   "#{name}"
 end
end
