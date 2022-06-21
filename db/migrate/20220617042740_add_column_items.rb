class AddColumnItems < ActiveRecord::Migration[6.1]
  def up
    add_column :items, :pos, :integer
  end

  def down
    remove_column :items, :pos, :integer
  end
end
