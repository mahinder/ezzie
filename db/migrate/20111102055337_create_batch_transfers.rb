class CreateBatchTransfers < ActiveRecord::Migration
  def change
    create_table :batch_transfers do |t|

      t.timestamps
    end
  end
end
