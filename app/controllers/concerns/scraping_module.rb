# モジュールだよ
module ScrapingModule
  extend ActiveSupport::Concern
  require 'selenium-webdriver'

  BASE_URL = 'https://www.mercari.com/jp/search/?sort_order=&keyword='
  BASE_URL.freeze

  def init
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    # Selenium::WebDriver.for :remote, url: 'http://chrome:4444/wd/hub', capabilities: [options]
    Selenium::WebDriver.for :chrome, capabilities: [options]
  end

  def scrape(search_condition)
    driver = init
    wait = Selenium::WebDriver::Wait.new(timeout: 15)
    nothing_flag = get(driver, wait, search_condition)
    [true, nothing_flag]
  rescue Selenium::WebDriver::Error::TimeoutError => e
    Rails.logger.debug "Timeout検索キーワード：#{search_condition.keyword}"
    Rails.logger.error e
    [false, false]
  rescue StandardError => e
    Rails.logger.error e
    [false, false]
  ensure
    driver.quit
  end

  def scrape_rake(search_conditions)
    driver = init
    wait = Selenium::WebDriver::Wait.new(timeout: 15)
    print(Time.current)
    search_conditions.each do |search_condition|
      print("検索:#{search_condition.keyword}\n")
      get(driver, wait, search_condition)
    rescue Selenium::WebDriver::Error::TimeoutError => e
      print("Timeout検索キーワード：#{search_condition.keyword}\n")
      Rails.logger.debug "Timeout検索キーワード：#{search_condition.keyword}"
      Rails.logger.error e
      next
    rescue StandardError => e
      Rails.logger.error e
      next
    end
    driver.quit
  end

  # 出品無しの時はtrue,それ以外はfalse
  def get(driver, wait, search_condition)
    driver.get(BASE_URL + search_condition.keyword)
    sleep 2
    text = '出品された商品がありません'
    nothing_flag = driver.find_elements(:xpath, "//p[contains(.,'#{text}')]").present?
    if nothing_flag
      Rails.logger.debug "出品無し検索キーワード：#{search_condition.keyword}"
      return true
    end
    # untilメソッドは文字通り「～するまで」を意味する
    wait.until { driver.find_element(:tag_name, 'mer-item-thumbnail').attribute('alt') }
    elements = driver.find_elements(:xpath, "//*[@data-testid='item-cell']")
    save_items(elements, search_condition)
    search_condition.touch
    false
  end

  def save_items(elements, search_condition)
    elements.each do |element|
      item = Item.new
      item.name = element.find_element(:tag_name, 'mer-item-thumbnail').attribute('alt').gsub('のサムネイル', '')
      item.price = element.find_element(:tag_name, 'mer-item-thumbnail').attribute('price')
      item.url = element.find_element(:tag_name, 'a').attribute('href')
      item.sales_status = element.find_element(:tag_name, 'mer-item-thumbnail').attribute('sticker').blank? ? :sale : :sold
      search_condition.items << item
    end
    search_condition.save
  end
end
