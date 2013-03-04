# Scrape S&P 500 list from wiki

require 'rubygems'
require 'nokogiri'
require 'open-uri'

$url = 'http://en.wikipedia.org/wiki/List_of_S%26P_500_companies'

rows = Nokogiri::HTML(open($url)).css('table.sortable tr')[1..-1]
puts "Number of rows: #{rows.length}"
rows.each do |row|
  tds = row.css('td').map{|td| td.text.strip}
  puts tds.join(", ")
end