require 'open-uri'
require 'nokogiri'

module Yodobashi
  class Item
    include Mem

    URL_BASE = 'http://www.yodobashi.com/x/pd/'
    CHARSET = 'UTF-8'

    attr_reader :id

    def initialize(id)
      @id = id
    end

    def url
      File.join(URL_BASE, id)
    end
    memoize :url

    def price
      parse_price(document.css('#pinfo_table #js_kakakuTD #js_scl_unitPrice').inner_text)
    end
    memoize :price

    private

    def parse_price(price_text)
      price_text = price_text[/￥([\d,]+)/, 1]
      price_text && price_text.tr(',', '_').to_i
    end

    def document
      Nokogiri::HTML.parse(content, nil, CHARSET)
    end

    def content
      fetch(url) do |charset, content|
        content
      end
    end
    memoize :content

    def fetch(url, &block)
      open(url) do |io|
        block.(io.charset, io.read)
      end
    end
  end
end
