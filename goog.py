import urllib2
from bs4 import BeautifulSoup
import re
import csv

with open('tickers.csv', 'rb') as f:
    reader = csv.reader(f)
    tickers = list(reader)

#tickers = ['AAADX', 'AAAGX']
for ticker in tickers:
    while True:
        try:
            #Query the website and return the html to the variable 'page'
            page = urllib2.urlopen('https://www.google.com/finance/fund_purchase?q=MUTF:'+ticker[0]+'&ei=IxPJV_jvIcjXuASrnJmwBQ')
            break
        except urllib2.HTTPError:
            print "HTTP Error"
            continue

    soup = BeautifulSoup(page, 'lxml')
    name = soup.find(string=re.compile('Initial'))
    #print name
    x = 999999999
    if name:
        data = name.findNext()
        #print data
    
        if data:
          amount = data.string.strip()[1:].replace(',', '')
          x = int(amount)
    
    print("%s, %d" % (ticker[0], x))