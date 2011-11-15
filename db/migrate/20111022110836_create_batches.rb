class CreateBatches < ActiveRecord::Migration
  def self.up
       create_table :batches do |t|
      t.string     :name
      t.references :course
      t.datetime   :start_date
      t.datetime   :end_date
      t.boolean    :is_active, :default => true
      t.boolean    :is_deleted, :default => false
      t.string     :employee_id
    end
  end

  def self.down
    drop_table :batches
   
  end
end
