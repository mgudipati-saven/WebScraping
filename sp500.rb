# Scrape S&P 500 list from wiki

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'sqlite3'

$db = SQLite3::Database.new('ic.sqlite')
$db.execute "CREATE TABLE IF NOT EXISTS index_constituents(
  `inx` VARCHAR(16) NOT NULL,
  `isin` VARCHAR(12) NOT NULL, 
  `symbol` VARCHAR(10) NOT NULL, 
  `name` VARCHAR,
  `date` DATE NOT NULL)"

index = "SP500"
url = "http://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
page = Nokogiri::HTML(open(url))
rows = page.css('table.sortable tr')[1..500]
puts "Number of rows: #{rows.length}"
rows.each do |row|
  symbol = row.css('td')[0].text.strip
  name = row.css('td')[1].text.strip
  if symbol
    puts "#{index},#{symbol},#{name}"
    $db.execute "INSERT INTO index_constituents VALUES (?,?,?,?,DATE('NOW'))", [index, "", symbol, name]
  end
end
