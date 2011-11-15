class CreatePayrolls < ActiveRecord::Migration
  def change
    create_table :payrolls do |t|

      t.timestamps
    end
  end
end
