class CreateEmployeeGrades < ActiveRecord::Migration
  def change
    create_table :employee_grades do |t|
      t.string :name
      t.integer :priority
      t.boolean :status
      t.integer :max_hours_day
      t.integer :max_hours_week

      t.timestamps
    end
  end
end
