class RenameSoldColumnToItems < ActiveRecord::Migration[6.1]
  def change
    rename_column :items, :sold, :sales_status
  end
end
