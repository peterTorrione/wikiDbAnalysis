# -*- coding: utf-8 -*-
"""
Created on Thu Nov 27 08:29:11 2014

@author: pete
"""

sys.path.append('/home/pete/Documents/wikiDbCode')
from wikidbUtil import *

startPage = "World War II"
outFile = "linkfile_2014_11_27_ww2.txt"

articleFull = wikidbFindArticle(startPage)
articleText = wikidbArticleToArticleText(articleFull)
totalLinks = wikidbGetLinks(articleText)
isredir = wikiIsRedirect(articleText)
visitedLinks = []

linkCount = 0
myFile = open(outFile,"w")

line = startPage + ":" + str(totalLinks) + "\n";
line = line.encode('ascii','ignore')
filter(lambda x: x in string.printable, line)
myFile.write(line)

while True:
        
    if not (linkCount % 100):
        print "removing duplicates..."
        del_dups(totalLinks)
        time.sleep(0.1)
        
    if linkCount >= totalLinks.__len__():
        break
    
    nextPage = totalLinks[linkCount];
    if not (linkCount % 50):
        print "Exploring page # " + str(linkCount) + " out of " + str(totalLinks.__len__()) + " : " + nextPage
        time.sleep(0.1)
        
    if nextPage in visitedLinks:
        print "  skipping already visited url: " + nextPage
    else:
        try:
            visitedLinks = visitedLinks + [nextPage] 
            
            articleFull = wikidbFindArticle(nextPage)
            if articleFull.startswith("entry not found"):
                print "Wikipedia page: " + nextPage + " not found"
                continue
            
            isredir = wikidbIsRedirect(articleFull)
            if isredir[0]:
                print "Redirect page!  Jumping to: " + isredir[1]
                articleFull = wikidbFindArticle(isredir[1])
                visitedLinks = visitedLinks + [isredir[1]]
                
            articleText = wikidbArticleToArticleText(articleFull)
            newLinks = wikidbGetLinks(articleText)
            isRelevant = "World War II" in articleText[0:1000]
            if not (linkCount % 50):
                print nextPage, isRelevant;
            
            if isRelevant:
                line = nextPage + ":" + str(newLinks) + "\n";
                line = line.encode('ascii','ignore')
                filter(lambda x: x in string.printable, line)
                myFile.write(line)
                totalLinks+=newLinks;
            
        except:
            print "<-->Unexpected error processing URL: " + nextPage, sys.exc_info()[0]
            time.sleep(2)
            
    linkCount = linkCount + 1
    #print links[0]

myFile.close()