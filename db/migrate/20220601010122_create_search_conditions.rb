class CreateSearchConditions < ActiveRecord::Migration[6.1]
  def change
    create_table :search_conditions do |t|
      t.string :keyword, null: false
      t.integer :price_min
      t.integer :price_max
      t.boolean :cron_flag, default: false, null: false
      t.timestamps
    end
    add_index :search_conditions, %i[keyword price_min price_max], unique: true
  end
end
