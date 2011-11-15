class StudentAdditionalField < ActiveRecord::Base
  belongs_to :student
  belongs_to :student_additional_details
end
