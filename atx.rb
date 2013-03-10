# Scrape ATX Index Constituents

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

index_a = ["ATX", "ATF", "ATPX", "WBI", "IAX"]
index_a.each do |index|
  puts "#{index}:"
  # fetch constituents page...
  url = "http://en.indices.cc/indices/details/#{index}/composition/"
  page = Nokogiri::HTML(open(url))
  rows = page.css('div.col100 table tbody tr')[0...-1]
  puts "Number of rows: #{rows.length}"
  rows.each do |row|
    col = row.css('th')[0]
    if col then name = col.text.strip end
    
    col = row.css('th')[1]
    if col then isin = col.text.strip end
    
    col = row.css('td')[5]
    if !col then col = row.css('td')[2] end # WBI
    if col then wt = col.text.strip.chop end
    
    # fetch profile page for ticker...
    #if isin
      #url = "http://en.wienerborse.at/issuer/profile/?isin=#{isin}"
      #page = Nokogiri::HTML(open(url))
      #col = page.css('div.col50 tr td')[1]
      #if col then ticker = col.text.strip end
    #end
    ticker = ''
    puts "#{index},#{isin},#{name},#{ticker},#{wt}"
    $db.execute "INSERT INTO IndexConstituents ([index], isin, ticker, name, wt) VALUES (?,?,?,?,?)", [index, isin, ticker, name, wt.to_f]
  end
end

