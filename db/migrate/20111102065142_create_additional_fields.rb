class CreateAdditionalFields < ActiveRecord::Migration
  def self.up
    create_table :additional_fields do |t|
      t.string :name
      t.boolean :status
      t.timestamps
    end
  end
  def self.down
    drop_table :additional_fields
  end
end
