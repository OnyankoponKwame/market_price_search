class Item < ApplicationRecord
  belongs_to :search_condition

  enum sold: { sale: 0, sold: 1}
end
