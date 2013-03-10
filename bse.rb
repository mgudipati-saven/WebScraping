#Scrape Budapest Stock Exchange Indices - BUX, BUMIX

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
  rows = page.css('table.InsAdat_table tr')[1..-1]
  rows.each do |row|
    col = row.css('td')[0]
    if col then name = col.text.strip end
    
    col = row.css('td')[1]
    if col then isin = col.text.strip end

    col = row.css('td')[7]
    if col then wt = col.text.strip end

    # fetch the detail page...
    #col = row.css('a')[0]
    #if col then link = col['href'] end
    #if link
      #page = Nokogiri::HTML(open(link))
      #col = page.css('td.container_basic tr td')[0]
      #if col then ticker = col.text.strip end
      
      #col = page.css('td.container_basic tr td')[1]
      #if col then isin = col.text.strip end
    #end
    ticker = ''
    puts "#{index},#{isin},#{name},#{ticker},#{wt}"
    $db.execute "INSERT INTO IndexConstituents ([index], isin, ticker, name, wt) VALUES (?,?,?,?,?)", [index, isin, ticker, name, wt.to_f]
  end  
end
