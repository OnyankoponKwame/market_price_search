class CreateLineGraphData < ActiveRecord::Migration[6.1]
  def change
    create_table :line_graph_data do |t|
      t.integer :average, null: false
      t.integer :median, null: false
      t.integer :mode, null: false
      t.timestamps
      t.references :search_condition, foreign_key: true
    end
  end
end