class SearchCondition < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :line_graph_data, dependent: :destroy
  validates :keyword, presence: true, uniqueness: { scope: %i[price_min price_max] }
  validates :price_min, numericality: { allow_blank: true, only_integer: true, greater_than_or_equal_to: 0 }
  validates :price_max, numericality: { allow_blank: true, only_integer: true, greater_than_or_equal_to: 0 }
end
