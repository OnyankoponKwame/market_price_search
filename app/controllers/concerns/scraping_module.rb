# モジュールだよ
module ScrapingModule
  extend ActiveSupport::Concern
  require 'selenium-webdriver'

  def init
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-gpu')
    options.add_argument('--disable-infobars')
    options.add_argument('--disable-extensions')
    # Selenium::WebDriver.for :remote, url: 'http://chrome:4444/wd/hub', capabilities: [options]
    Selenium::WebDriver.for :chrome, capabilities: [options]
  end

  def scrape(search_condition)
    driver = init
    wait = Selenium::WebDriver::Wait.new(timeout: 15)
    nothing_flag = get(driver, wait, search_condition)
    [true, nothing_flag]
  rescue Selenium::WebDriver::Error::TimeoutError => e
    Rails.logger.debug "Timeout検索キーワード：#{search_condition}"
    Rails.logger.error e
    [false, false]
  rescue StandardError => e
    Rails.logger.error e
    [false, false]
  ensure
    driver.quit
  end

  # 出品無しの時はtrue,それ以外はfalse
  def get(driver, wait, search_condition)
    url = "https://jp.mercari.com/search?keyword=#{search_condition.keyword}&price_min=#{search_condition.price_min}&price_max=#{search_condition.price_max}&sort=created_time&order=desc"
    driver.get(url)
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
    elements.each_with_index do |element, i|
      item = Item.new
      item.name = element.find_element(:tag_name, 'mer-item-thumbnail').attribute('alt').gsub('のサムネイル', '')
      item.price = element.find_element(:tag_name, 'mer-item-thumbnail').attribute('price')
      item.url = element.find_element(:tag_name, 'a').attribute('href')
      item.sales_status = element.find_element(:tag_name, 'mer-item-thumbnail').attribute('sticker').blank? ? :sale : :sold
      item.pos = i + 1
      search_condition.items << item
    end
    search_condition.save
  end
end
