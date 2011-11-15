class CreateStudentPreviousData < ActiveRecord::Migration
  def self.up
    create_table :student_previous_data do |t|
      t.references :student
      t.string     :institution
      t.string     :year
      t.string     :course
      t.string     :total_mark
    end
  end

  def self.down
    drop_table :student_previous_data
  end
end
