class ItemResource
  include Alba::Resource

  root_key :item
  attributes :name, :price, :sales_status, :url, :updated_at
end
