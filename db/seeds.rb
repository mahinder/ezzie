# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake dbseed (or created alongside the db with dbsetup).
#
# Examples
#
#   cities = City.create([{ name 'Chicago' }, { name 'Copenhagen' }])
#   Mayor.create(name 'Emanuel', city cities.first)
Schooldatum.create config_key: "CurrencyType", config_value: "`"
EmployeeCategory.create([
  #  {:name => 'Fedena Admin',:prefix => 'Admin',:status => true},
  {:name => 'Management',:prefix => 'MGMT',:status => true},
  {:name => 'Teaching',:prefix => 'TCR',:status => true},
  {:name => 'Non-Teaching',:prefix => 'NTCR',:status => true}
])

#EmployeePosition.delete_all


#EmployeeDepartment.delete_all

StudentCategory.destroy_all
StudentCategory.create([
  {:name=>"OBC",:is_deleted=>false},
  {:name=>"General",:is_deleted=>false}
  ])

# EmployeeDepartment.create([
  # #  {:code => 'Admin',:name => 'Fedena Admin',:status => true},
  # {:code => 'MGMT',:name => 'Management',:status => true},
  # {:code => 'MAT',:name => 'Mathematics',:status => true},
  # {:code => 'OFC',:name => 'Office',:status => true},
# ])
# 
# #EmployeeGrade.delete_all
# EmployeeGrade.create([
  # #  {:name => 'Fedena Admin',:priority => 0 ,:status => true,:max_hours_day=>nil,:max_hours_week=>nil},
  # {:name => 'A',:priority => 1 ,:status => true,:max_hours_day=>1,:max_hours_week=>5},
  # {:name => 'B',:priority => 2 ,:status => true,:max_hours_day=>3,:max_hours_week=>15},
  # {:name => 'C',:priority => 3 ,:status => true,:max_hours_day=>4,:max_hours_week=>20},
  # {:name => 'D',:priority => 4 ,:status => true,:max_hours_day=>5,:max_hours_week=>25},
# ])