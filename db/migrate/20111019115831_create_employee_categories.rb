class CreateEmployeeCategories < ActiveRecord::Migration
  def self.up
    create_table :employee_categories do |t|
      t.string :name
      t.string :prefix
      t.boolean :status

      t.timestamps
    end
    create_default
  end

  def self.down
    drop_table :employee_categories
  end

  def self.create_default
    EmployeeCategory.create([
      {:name => "Mount Carmel Admin",:prefix => "Admin",:status => true }
    ])

  end
end
