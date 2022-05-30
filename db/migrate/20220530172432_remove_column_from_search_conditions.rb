class RemoveColumnFromSearchConditions < ActiveRecord::Migration[6.1]
  def up
    remove_column :search_conditions, :negative_keyword
    remove_column :search_conditions, :include_title_flag
  end

  def down
    add_column :search_conditions, :negative_keyword, :string
    add_column :search_conditions, :include_title_flag, :boolean, default: false
  end
end