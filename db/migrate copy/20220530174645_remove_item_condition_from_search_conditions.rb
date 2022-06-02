class RemoveItemConditionFromSearchConditions < ActiveRecord::Migration[6.1]
  def up
    remove_column :search_conditions, :item_condition
  end

  def down
    add_column :search_conditions, :item_condition, :string
  end
end
