class CreateMetrics < ActiveRecord::Migration[5.1]
  def change
    create_table :metrics do |t|

      t.timestamps
    end
  end
end
