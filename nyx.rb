# Scrape NYSE EURONEXT Indices from https://indices.nyx.com/en/products/indices/?

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

index_h = {
  "AEX" => "https://indices.nyx.com/en/products/indices/NL0000000107-XAMS",
  "AAX" => "https://indices.nyx.com/en/products/indices/NL0000249100-XAMS",
  "ASCX" => "https://indices.nyx.com/en/products/indices/NL0000249142-XAMS",
  "AMX" => "https://indices.nyx.com/en/products/indices/NL0000249274-XAMS",
  "BEL20" => "https://indices.nyx.com/en/products/indices/BE0389555039-XBRU",
  "BELM" => "https://indices.nyx.com/en/products/indices/BE0389856130-XBRU",
  "BELS" => "https://indices.nyx.com/en/products/indices/BE0389857146-XBRU",
  "CACMS" => "https://indices.nyx.com/en/products/indices/QS0010989133-XPAR",
  "CACMD" => "https://indices.nyx.com/en/products/indices/QS0010989117-XPAR",
  "CN20" => "https://indices.nyx.com/en/products/indices/QS0010989109-XPAR",
  "CACS" => "https://indices.nyx.com/en/products/indices/QS0010989125-XPAR",
  "CACLG" => "https://indices.nyx.com/en/products/indices/QS0011213657-XPAR",
  "N100" => "https://indices.nyx.com/en/products/indices/FR0003502079-XPAR",
  "N150" => "https://indices.nyx.com/en/products/indices/FR0003502087-XPAR",
  "SBF120" => "https://indices.nyx.com/en/products/indices/FR0003999481-XPAR",
  "PSI20" => "https://indices.nyx.com/en/products/indices/PTING0200002-XLIS"
  }
index_h.each do |index, url|
  mic = url[-4..-1]
  page = Nokogiri::HTML(open(url))
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
