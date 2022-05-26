class ItemResource
  include Alba::Resource

  root_key :item
  attributes :name, :price, :sold, :url, :updated_at
end
