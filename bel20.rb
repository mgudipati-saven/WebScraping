# Scrape BEL 20 from https://indices.nyx.com/en/products/indices/BE0389555039-XBRU

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'sqlite3'

$dbname = 'bel20.sqlite'
File.delete($dbname) if File.exists?$dbname
$db = SQLite3::Database.new($dbname)
$db.execute "CREATE TABLE BEL20_INDEX(`isin` VARCHAR, `symbol` VARCHAR, `name` VARCHAR)"

page = Nokogiri::HTML(open('https://indices.nyx.com/en/products/indices/BE0389555039-XBRU'))
rows = page.css('div.index-composition-block table tr')[1..-1]
#puts "Number of rows: #{rows.length}"
rows.each do |row|
  #tds = row.css('td').map{|td| td.text.strip}
  #puts tds.join(", ")
  name = row.css('td')[0].text.strip
  isin = row.css('td')[1].text.strip
  if isin
    url = 
    page = Nokogiri::HTML(open("https://europeanequities.nyx.com/en/nyx_eu_listings/real-time/quote?isin=#{isin}&mic=XBRU"))
    symbol = page.css('div.first-row div.first-column.box-column').text.strip
    puts "#{name},#{isin},#{symbol}"
    $db.execute "INSERT INTO BEL20_INDEX VALUES (?,?,?)", [isin, symbol, name]
  end
end
