# Scrape BEL 20 from https://indices.nyx.com/en/products/indices/BE0389555039-XBRU

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

index = "BEL20"
page = Nokogiri::HTML(open('https://indices.nyx.com/en/products/indices/BE0389555039-XBRU'))
rows = page.css('div.index-composition-block table tr')[1..-1]
#puts "Number of rows: #{rows.length}"
rows.each do |row|
  #tds = row.css('td').map{|td| td.text.strip}
  #puts tds.join(", ")
  name = row.css('td')[0].text.strip
  isin = row.css('td')[1].text.strip
  if isin
    page = Nokogiri::HTML(open("https://europeanequities.nyx.com/en/nyx_eu_listings/real-time/quote?isin=#{isin}&mic=XBRU"))
    symbol = page.css('div.first-row div.first-column.box-column').text.strip
    puts "#{name},#{isin},#{symbol}"
    if symbol
      $db.execute "INSERT INTO index_constituents VALUES (?,?,?,?,DATE('NOW'))", [index, isin, symbol, name]
    end
  end
end
