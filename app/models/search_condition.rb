class SearchCondition < ApplicationRecord
  has_many :items, dependent: :destroy
  validates :keyword, uniqueness: { scope: %i[price_min price_max] }
end
