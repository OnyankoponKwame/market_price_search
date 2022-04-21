class CreateSearchConditions < ActiveRecord::Migration[6.1]
  def change
    create_table :search_conditions do |t|
      t.string :keyword
      t.integer :item_condition
      t.integer :price_min
      t.integer :price_max

      t.timestamps
    end
  end
end
