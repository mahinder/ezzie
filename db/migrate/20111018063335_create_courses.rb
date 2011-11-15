class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string     :course_name
      t.string     :code
      t.string     :section_name
      t.boolean    :is_deleted, :default => false
      t.timestamps
    end
  end
 def self.down
     drop_table :courses
  end

end
