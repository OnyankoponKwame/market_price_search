class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.integer :price, null: false
      t.integer :sales_status, null: false
      t.string :url, null: false
      t.timestamps
      t.references :search_condition, foreign_key: true
    end
  end
end