class AddColumnsSearchCondition < ActiveRecord::Migration[6.1]
  def change
    add_column :search_conditions, :negative_keyword, :string
    add_column :search_conditions, :include_title_flag, :boolean, default: false
    add_column :search_conditions, :cron_flag, :boolean, default: false
  end
end
