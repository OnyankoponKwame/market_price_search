class AddIndexToSearchConditions < ActiveRecord::Migration[6.1]
  def change
    add_index :search_conditions, :keyword, unique: true
    change_column_null :search_conditions, :keyword, false
  end
end
