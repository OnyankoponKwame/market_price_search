class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :title
      t.integer :price
      t.integer :sold
      t.string :url
      t.timestamps
      t.references :search_condition, foreign_key: true
    end
  end
end