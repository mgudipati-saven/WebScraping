# Scrape ASX Index Constituents

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

index_a = ["ASX20", "ASX50", "ASX100", "ASX200", "ASX300", "AORD"]
index_a.each do |index|
  puts "#{index}:"
  # fetch constituents page...
  url = "http://preview.papdan.com/papdan/data/get_index_tables_price.php?content=%27#{index}%27"
  page = Nokogiri::HTML(open(url))
  rows = page.css('table.borderIndex tr')[1..-1]
  puts "Number of rows: #{rows.length}"
  rows.each do |row|
    col = row.css('td span.indexSymbol')
    if col then ticker = col.text.strip end
    
    col = row.css('td span.indexName')
    if col then name = col.text.strip end

    isin = ''
    wt = '0.0'
    puts "#{index},#{isin},#{name},#{ticker},#{wt}"
    $db.execute "INSERT INTO IndexConstituents ([index], isin, ticker, name, wt) VALUES (?,?,?,?,?)", [index, isin, ticker, name, wt.to_f]
  end
end
