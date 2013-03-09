=begin
  Scrape Budapest Stock Exchange Indices - BUX, BUMIX

  Page layout:
    L1: name = page.css('table.InsAdat_table tr a')[0..-1].text
        link = page.css('table.InsAdat_table tr a')[0..-1]['href']
    L2: ticker = page.css('td.container_basic tr td')[0].text
        isin = page.css('td.container_basic tr td')[1].text
  
  Redis layout:
    key => "SecuritiesMaster"
    val => hashtable of json objects, isin => {...}
    
    key => "Index:#{id}:Constituents:#{date}"
    val => set of json objects of index constituents given a day
=end

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'redis'
require 'json'

# redis db connection
$redisdb = Redis.new
$redisdb.select 0

# urls
$url_h = {
  "BUX" => "http://bse.hu/menun_kivuli/dinportl/buxindexbasketen",
  "BUMIX" => "http://bse.hu/menun_kivuli/dinportl/bumixindexbasketen"
}

# loop through the index urls...
$url_h.each do |index, url|
  puts "#{index}:"
  # fetch the constituents page...
  page = Nokogiri::HTML(open(url))
  rows = page.css('table.InsAdat_table tr a')[0..-1]
  rows.each do |row|
    # constituent name...
    name = row.text.strip
    
    # fetch the detail page...
    link = row['href']
    if link
      page = Nokogiri::HTML(open(link))
      ticker = page.css('td.container_basic tr td')[0].text.strip
      isin = page.css('td.container_basic tr td')[1].text.strip
      puts "#{name},#{isin},#{ticker}"
      if isin
        # add to the index constituents set...
        $redisdb.zadd "Index:#{index}:Constituents:#{Date.today.strftime("%Y%m%d")}", 0, isin
        
        # update the constituent in securities master...
        hash = {:Name => name, :ISIN => isin, :Ticker => ticker}
        json = JSON.generate hash
        $redisdb.hset "SecuritiesMaster", isin, json
      end
    end
  end  
end
