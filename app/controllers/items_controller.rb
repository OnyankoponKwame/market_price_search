class ItemsController < ApplicationController
  require 'selenium-webdriver'
  require "json"
  def index
    # scrape

    items = Item.all

    # @hash = items.map { |item| Hash[item.updated_at.strftime("%Y-%m-%d"), item.price] }
    @hash = items.sale.map { |item|  Array[item.updated_at.strftime("%Y-%m-%d"), item.price] }.to_json
    @hash2 = items.sold.map { |item|  Array[item.updated_at.strftime("%Y-%m-%d"), item.price] }.to_json
    

  end

  def scrape
    agent = Mechanize.new
    agent.follow_meta_refresh = true
    
    driver = Selenium::WebDriver.for :chrome
    

    url = 'https://jp.mercari.com/search?keyword=%E3%83%96%E3%83%A9%E3%83%83%E3%82%AD%E3%83%BC%20SA&sort_order='
    base_url = 'https://www.mercari.com/jp/search/?sort_order=&keyword='
    search_words = "ブラッキー SA"
    # :timeoutオプションは秒数を指定している。この場合は100秒
    wait = Selenium::WebDriver::Wait.new(:timeout => 100) 

    driver.get(base_url + search_words)
    # untilメソッドは文字通り「～するまで」を意味する
    wait.until {driver.find_element(:tag_name,'mer-item-thumbnail').attribute('alt')}


    elements = driver.find_elements(:xpath, "//*[@data-testid='item-cell']")
    word = Word.new(name:search_words)
    for element in elements
      item = Item.new     
      item.title = element.find_element(:tag_name,'mer-item-thumbnail').attribute('alt').gsub('のサムネイル','')
      item.price = element.find_element(:tag_name,'mer-item-thumbnail').attribute('price')
      item.url = element.find_element(:tag_name,'a').attribute('href')
      item.sold = element.find_element(:tag_name,'mer-item-thumbnail').attribute('sticker').blank? ? :sale : :sold
      word.items << item
    end
    word.save

  end



end
