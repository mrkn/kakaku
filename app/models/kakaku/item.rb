require 'open-uri'
require 'nokogiri'

module Kakaku
  class Item
    include Mem

    URL_BASE = 'http://kakaku.com/item/'
    CHARSET = 'Shift_JIS'

    attr_reader :id, :url, :name, :initial_price, :minimum_price, :average_price

    def initialize(id)
      @id = id
    end

    def url
      File.join(URL_BASE, id)
    end
    memoize :url

    def name
      document.css('#titleBox').inner_text
    end
    memoize :name

    def pricehistory_url
      File.join(url, 'pricehistory')
    end
    memoize :pricehistory_url

    def initial_price
      parse_price(pricehistory_document.css('#diffTbl table tr:nth-child(2) td:first-child').inner_text)
    end
    memoize :initial_price

    def minimum_price
      prices.min
    end
    memoize :minimum_price

    def average_price
      (prices.inject(:+) / prices.size.to_f).round
    end
    memoize :average_price

    def maximum_price
      prices.max
    end
    memoize :maximum_price

    def prices
      document.css('#mainLeft table tr').map {|tr|
        parse_price(tr.css('td:nth-child(2)').inner_text)
      }.select(&:present?).tap {|x| p x }
    end
    memoize :prices

    private

    def parse_price(price_text)
      price_text = price_text[/¥([\d,]+)/, 1]
      price_text && price_text.tr(',', '_').to_i
    end

    def document
      Nokogiri::HTML.parse(content, nil, CHARSET)
    end
    memoize :document

    def content
      fetch(url) do |charset, content|
        content
      end
    end
    memoize :content

    def pricehistory_document
      Nokogiri::HTML.parse(pricehistory_content, nil, CHARSET)
    end
    memoize :pricehistory_document

    def pricehistory_content
      fetch(pricehistory_url) do |charset, content|
        content
      end
    end
    memoize :pricehistory_content

    def fetch(url, &block)
      open(url) do |io|
        block.(io.charset, io.read)
      end
    end
  end
end
