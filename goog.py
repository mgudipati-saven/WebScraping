import mysql.connector
import urllib2
import re
from bs4 import BeautifulSoup

#database connection parameters
config = {
  'user': 'root',
  'password': 'l3tm3in',
  'host': '127.0.0.1',
  'database': 'matching_data',
  'raise_on_warnings': True,
}

# Connect to the database and obtain a cursor
db = mysql.connector.connect(**config)
cur=db.cursor()

# If Min Investment Table exist then destroy the table
cur.execute("SHOW TABLES")
if "MinInvestment" in zip(*cur.fetchall())[0]: 
    cur.execute("DROP TABLE MinInvestment")

# Create table as per requirement
cur.execute("CREATE TABLE MinInvestment(Fund_Ticker CHAR(5), Min_Invest INT)")

# Fetch fund tickers
cur.execute("SELECT * FROM FundTickers")
table = cur.fetchall()
for row in table:
    #Open the website
    while True:
        try:
            #Query the website and return the html to the variable 'page'
            page = urllib2.urlopen('https://www.google.com/finance/fund_purchase?q=MUTF:'+row[0]+'&ei=IxPJV_jvIcjXuASrnJmwBQ')
            break
        except urllib2.HTTPError:
            continue

    #Parse the html in the 'page' variable, and store it in Beautiful Soup format
    soup = BeautifulSoup(page, 'lxml')
    
    #Find the tag with text 'Initial'
    name = soup.find(string=re.compile('Initial'))
    
    #Find its next tag. It contains the amount of initial investment
    x = 999999999
    if name:
        data = name.findNext()
        
        if data:
            amount = data.string.strip()
            if amount.startswith('$'):
                x = int(amount[1:].replace(',', ''))

    #Show value on the screen.
    print [row[0], x]

    # Insert Row ony by one into Table
    try:
        cur.execute("INSERT INTO MinInvestment(Fund_Ticker, Min_Invest) VALUES('"+ row[0] +"', "+str(x) + ")")
        db.commit()
    except:
        db.rollback()
db.close()