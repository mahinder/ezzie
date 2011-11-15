class CreateArchivedEmployees < ActiveRecord::Migration
  def change
    create_table :archived_employees do |t|

      t.timestamps
    end
  end
end
