class CreateSchooldata < ActiveRecord::Migration
 def self.up
    create_table :schooldata do |t|
      t.string :config_key
      t.string :config_value
    end
    create_default
  end

  def self.down
    drop_table :schooldata
  end

  def self.create_default
    Schooldatum.create config_key: "InstitutionName", config_value: ""
    Schooldatum.create config_key: "InstitutionAddress", config_value: ""
    Schooldatum.create config_key: "InstitutionPhoneNo", config_value: ""
    Schooldatum.create config_key: "StudentAttendanceType", config_value: "Daily"
    Schooldatum.create config_key: "CurrencyType", config_value: "$"
    #Schooldatum.create config_key : "ExamResultType", config_value : "Marks"
    Schooldatum.create config_key: "AdmissionNumberAutoIncrement", config_value: "1"
    Schooldatum.create config_key: "EmployeeNumberAutoIncrement", config_value: "1"
    Schooldatum.create config_key: "TotalSmsCount", config_value:"0"
    Schooldatum.create config_key: "AvailableModules", config_value:"HR"
    Schooldatum.create config_key: "AvailableModules", config_value:"Finance"


  end

end
