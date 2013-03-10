# Scrape S&P 500 list from wiki

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'sqlite3'

$db = SQLite3::Database.new('ic.sqlite')
$db.execute "CREATE TABLE IF NOT EXISTS IndexConstituents(
  [index] VARCHAR(16) NOT NULL,
  isin    VARCHAR(12), 
  ticker  VARCHAR(16),
  name    VARCHAR,
  wt      FLOAT,
  asof    DATE DEFAULT (date('now')))"

index = "SP500"
url = "http://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
page = Nokogiri::HTML(open(url))
rows = page.css('table.sortable tr')[1..500]
puts "Number of rows: #{rows.length}"
rows.each do |row|
  col = row.css('td')[0]
  if col then ticker = col.text.strip end
  
  col = row.css('td')[1]
  if col then name = col.text.strip end

  isin = ''
  wt = '0.0'
  puts "#{index},#{isin},#{name},#{ticker},#{wt}"
  $db.execute "INSERT INTO IndexConstituents ([index], isin, ticker, name, wt) VALUES (?,?,?,?,?)", [index, isin, ticker, name, wt.to_f]
end
