class CreateBankFields < ActiveRecord::Migration
  def self.up
    create_table :bank_fields do |t|
      t.string :name
      t.boolean :status
      t.timestamps
    end
  end
  def self.down
    drop_table :bank_fields
  end
end
