require 'rails_helper'

include MakeDataModule

RSpec.describe 'make_data_module' do
  it '商品名全角大文字、キーワードが半角の場合で正しく比較されること' do
    include_title_flag = 'true'
    result = satisfy_conditions?('ブラッキー　Ｓａ　さま専用', 'ブラッキー sa', '', include_title_flag)
    expect(result).to eq true
  end

  it '商品名半角、キーワードが全角大文字の場合で正しく比較されること' do
    include_title_flag = 'true'
    result = satisfy_conditions?('ブラッキー　sa　さま専用', 'ブラッキー Ｓａ', '', include_title_flag)
    expect(result).to eq true
  end
end
