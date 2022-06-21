class AddColumnSearchConditions < ActiveRecord::Migration[6.1]
  def up
    add_column :search_conditions, :negative_keyword, :string
    add_column :search_conditions, :include_title_flag, :boolean
  end

  def down
    remove_column :search_conditions, :negative_keyword, :string
    remove_column :search_conditions, :include_title_flag, :boolean
  end
end
