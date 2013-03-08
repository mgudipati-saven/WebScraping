# Scrape ASX Index Constituents

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

index_a = ["ASX20", "ASX50", "ASX100", "ASX200", "ASX300", "AORD"]
index_a.each do |index|
  url = "http://preview.papdan.com/papdan/data/get_index_tables_price.php?content=%27#{index}%27"
  page = Nokogiri::HTML(open(url))
  rows = page.css('table.borderIndex tr')[1..-1]
  puts "Number of rows: #{rows.length}"
  rows.each do |row|
    symbol = row.css('td span.indexSymbol').text.strip
    name = row.css('td span.indexName').text.strip
    if symbol
      puts "#{index},#{symbol},#{name}"
      $db.execute "INSERT INTO index_constituents VALUES (?,?,?,?,DATE('NOW'))", [index, "", symbol, name]
    end
  end
end
