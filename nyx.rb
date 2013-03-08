# Scrape NYSE EURONEXT Indices from 

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
    name = row.css('td')[0].text.strip
    isin = row.css('td')[1].text.strip
    if isin
      page = Nokogiri::HTML(open("https://europeanequities.nyx.com/en/nyx_eu_listings/real-time/quote?isin=#{isin}&mic=#{mic}"))
      symbol = page.css('div.first-row div.first-column.box-column').text.strip
      puts "#{name},#{isin},#{symbol}"
      if symbol
        $db.execute "INSERT INTO index_constituents VALUES (?,?,?,?,DATE('NOW'))", [index, isin, symbol, name]
      end
    end
  end
end

#
# Recursive function to go through each page and scrape out constituents table
#
def navigate(index, mic, base_url, rel_url)
  url = base_url+rel_url
  puts "Page=>#{url}"
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
