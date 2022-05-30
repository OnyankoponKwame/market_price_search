class Item < ApplicationRecord
  belongs_to :search_condition

  enum sales_status: { sale: 0, sold: 1 }
  scope :price_filtered, lambda { |price_min, price_max|
    if price_min.present? && price_max.present?
      where(price: price_min..price_max)
    elsif price_min.present?
      where(price: price_min..)
    elsif price_max.present?
      where(price: ..price_max)
    end
  }
  # scope :negative_keyword_excluded, ->(word) { where.not('name like ?', "%#{word}%") if word.present? }
end
