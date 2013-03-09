# Scrape ATX Index Constituents

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'sqlite3'

$db = SQLite3::Database.new('ic.sqlite')
$db.execute "CREATE TABLE IF NOT EXISTS index_constituents(
  `index` VARCHAR(16) NOT NULL,
  `isin` VARCHAR(12) NOT NULL, 
  `symbol` VARCHAR(10) NOT NULL, 
  `name` VARCHAR,
  `date` DATE NOT NULL)"

index_a = ["ATX", "ATF", "ATPX", "WBI", "IAX"]
index_a.each do |index|
  url = "http://en.indices.cc/indices/details/#{index}/composition/"
  page = Nokogiri::HTML(open(url))
  rows = page.css('div.col100 table tbody tr')[1...-1]
  puts "Number of rows: #{rows.length}"
  rows.each do |row|
    name = row.css('th')[0].text.strip
    isin = row.css('th')[1].text.strip
    if isin
      puts "#{index},#{isin},#{name}"
      $db.execute "INSERT INTO index_constituents VALUES (?,?,?,?,DATE('NOW'))", [index, isin, "", name]
    end
  end
end
