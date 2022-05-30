class SearchCondition < ApplicationRecord
  has_many :items, dependent: :destroy
  validates :keyword, presence: true, uniqueness: true
end
