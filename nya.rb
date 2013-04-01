# Scrape NYSE Composite Index Constituents
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'sqlite3'
require 'csv'

$db = SQLite3::Database.new('ic.sqlite')
$db.execute "CREATE TABLE IF NOT EXISTS IndexConstituents(
  [index] VARCHAR(16) NOT NULL,
  isin    VARCHAR(12), 
  ticker  VARCHAR(16),
  name    VARCHAR,
  wt      FLOAT,
  asof    DATE DEFAULT (date('now')))"

index = 'NYA'
isin = ''
wt = '0.0'
CSV.new(open("http://www.nyse.com/indexes/nyaindex.csv"), :headers => :first_row).each do |line|
  name = line[0].force_encoding('UTF-8').strip
  ticker = line[1].force_encoding('UTF-8').strip
  if name != 'NAME' and ticker != 'TICKER'
    puts "#{index},#{isin},#{name},#{ticker},#{wt}"
    $db.execute "INSERT INTO IndexConstituents 
      ([index], isin, ticker, name, wt) 
      VALUES 
      (?,?,?,?,?)", 
      [index, isin, ticker, name, wt.to_f]  
  end
end
