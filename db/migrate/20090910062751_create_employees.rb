class CreateEmployees < ActiveRecord::Migration
  def self.up
    create_table :employees do |t|
      t.references :employee_category
      t.string     :employee_number
      t.date       :joining_date
      t.string     :first_name
      t.string     :middle_name
      t.string     :last_name
      t.boolean    :gender
      t.string     :job_title
      t.references :employee_position
      t.references :employee_department
      t.integer    :reporting_manager_id
      t.references :employee_grade
      t.string     :qualification
      t.text       :experience_detail
      t.integer    :experience_year
      t.integer    :experience_month
      t.boolean    :status
      t.string     :status_description
      t.references :user
      t.date       :date_of_birth
      t.string     :marital_status
      t.integer    :children_count
      t.string     :father_name
      t.string     :mother_name
      t.string     :husband_name
      t.string     :blood_group
      t.references :nationality

      t.string     :home_address_line1
      t.string     :home_address_line2
      t.string     :home_city
      t.string     :home_state
      t.integer    :home_country_id
      t.string    :home_pin_code

      t.string     :office_address_line1
      t.string     :office_address_line2
      t.string     :office_city
      t.string     :office_state
      t.integer    :office_country_id
      t.string    :office_pin_code

      t.string     :office_phone1
      t.string     :office_phone2
      t.string     :mobile_phone
      t.string     :home_phone
      t.string     :email
      t.string     :fax

      t.column   :photo_filenamecreate,       :string
      t.column   :photo_content_type,   :string
      t.column   :photo_data,           :binary,
      :limit => 5.megabytes

      t.timestamps
    end
    create_default
  end

  def self.down
    drop_table :employees
  end

  def self.create_default
    Employee.create :employee_number => 'admin',:joining_date => Date.today,:first_name => 'Fedena',:last_name => 'Administrator',
    :employee_department_id => 1,:employee_grade_id => 1,:employee_position_id => 1,:employee_category_id => 1,:status => true,:nationality_id =>'76', :date_of_birth => Date.today-365
    User.first.update_attributes(:role=>"Admin")
  end

end
