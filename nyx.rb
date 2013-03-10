# Scrape NYSE EURONEXT Indices from 

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

$base_url = "https://indices.nyx.com"
$index_h = {
  "AEX" => "/en/products/indices/NL0000000107-XAMS",
  "AAX" => "/en/products/indices/NL0000249100-XAMS",
  "ASCX" => "/en/products/indices/NL0000249142-XAMS",
  "AMX" => "/en/products/indices/NL0000249274-XAMS",
  "BEL20" => "/en/products/indices/BE0389555039-XBRU",
  "BELM" => "/en/products/indices/BE0389856130-XBRU",
  "BELS" => "/en/products/indices/BE0389857146-XBRU",
  "CACMS" => "/en/products/indices/QS0010989133-XPAR",
  "CACMD" => "/en/products/indices/QS0010989117-XPAR",
  "CN20" => "/en/products/indices/QS0010989109-XPAR",
  "CACS" => "/en/products/indices/QS0010989125-XPAR",
  "CACLG" => "/en/products/indices/QS0011213657-XPAR",
  "N100" => "/en/products/indices/FR0003502079-XPAR",
  "N150" => "/en/products/indices/FR0003502087-XPAR",
  "SBF120" => "/en/products/indices/FR0003999481-XPAR",
  "PSI20" => "/en/products/indices/PTING0200002-XLIS"
  }

#
# Function to scrape the constituents table given the page...
#
def scrape(index, mic, page)
  rows = page.css('div.index-composition-block table tr')[1..-1]
  puts "Number of rows: #{rows.length}"
  rows.each do |row|
    col = row.css('td')[0]
    if col then name = col.text.strip end

    # wt. replace ',' with '.'
    col = row.css('td')[3]
    if col then wt = col.text.strip.gsub(',','.') end

    col = row.css('td')[1]
    if col then isin = col.text.strip end
    #if isin
      # fetch the quote page for ticker symbol...
      #page = Nokogiri::HTML(open("https://europeanequities.nyx.com/en/nyx_eu_listings/real-time/quote?isin=#{isin}&mic=#{mic}"))
      #col = page.css('div.first-row div.first-column.box-column')
      #if col then ticker = col.text.strip end
    #end
    ticker = ''
    puts "#{index},#{isin},#{name},#{ticker},#{wt}"
    $db.execute "INSERT INTO IndexConstituents ([index], isin, ticker, name, wt) VALUES (?,?,?,?,?)", [index, isin, ticker, name, wt.to_f]
  end
end

#
# Recursive function to go through each page and scrape out constituents table
#
def navigate(index, mic, base_url, rel_url)
  url = base_url+rel_url
  puts "Page=>#{url}"
  # fetch the constituents page...
  page = Nokogiri::HTML(open(url))

  # scrape...
  scrape(index, mic, page)
  
  # check for pagination...
  links = page.css('li.pager-next a')
  if !links.empty?
    rel_url = links[0]['href']

    # recursion, go to next page and scrape...
    navigate(index, mic, base_url, rel_url)
  end
end

# loop through the index list...
$index_h.each do |index, rel_url|
  mic = rel_url[-4..-1]
  puts "#{index}:"
  
  # navigate and scrape...
  navigate(index, mic, $base_url, rel_url)
end
