# モジュールだよ
# frozen_string_literal: true

module ScrapingModule
  extend ActiveSupport::Concern
  require 'selenium-webdriver'

  def scrape(*search_conditions)
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    driver = Selenium::WebDriver.for :chrome, options: options
    base_url = 'https://www.mercari.com/jp/search/?sort_order=&keyword='
    # :timeoutオプションは秒数を指定している。この場合は100秒
    wait = Selenium::WebDriver::Wait.new(timeout: 100)
    search_conditions.each do |search_condition|
      driver.get(base_url + search_condition.keyword)
      # untilメソッドは文字通り「～するまで」を意味する
      wait.until { driver.find_element(:tag_name, 'mer-item-thumbnail').attribute('alt') }
      elements = driver.find_elements(:xpath, "//*[@data-testid='item-cell']")
      save_items(elements, search_condition)
    end
    driver.quit
  end

  def save_items(elements, search_condition)
    elements.each do |element|
      item = Item.new
      item.name = element.find_element(:tag_name, 'mer-item-thumbnail').attribute('alt').gsub('のサムネイル', '')
      item.price = element.find_element(:tag_name, 'mer-item-thumbnail').attribute('price')
      item.url = element.find_element(:tag_name, 'a').attribute('href')
      item.sold = element.find_element(:tag_name, 'mer-item-thumbnail').attribute('sticker').blank? ? :sale : :sold
      search_condition.items << item
    end
    search_condition.save
  end
end
