# -*- coding: utf-8 -*-
"""
Created on Thu Nov 27 08:29:11 2014

@author: pete
"""

import sys
sys.path.append('/home/pete/Documents/wikiDbCode')
from wikidbUtil import *

startPage = "Screeching Weasel"
outFile = "linkfile_2014_11_29_music_weasel.txt"
redirFileName = outFile + ".redirLog"

articleFull = wikidbFindArticle(startPage)
articleText = wikidbArticleToArticleText(articleFull)
totalLinks = wikidbGetLinks(articleText)
isredir = wikidbIsRedirect(articleText)
visitedLinks = []

linkCount = 0
myFile = open(outFile,"w")
redirFile = open(redirFileName,"w")

line = startPage + ":" + "Band" + ":" + str(totalLinks) + "\n";
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
    if not (linkCount % 100):
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
                #print "Redirect page!  Jumping to: " + isredir[1]
                redirFile.write(nextPage + "-->" + isredir[1] + "\n")
                articleFull = wikidbFindArticle(isredir[1])
                visitedLinks = visitedLinks + [isredir[1]]
                
            articleText = wikidbArticleToArticleText(articleFull)
            newLinks = wikidbGetLinks(articleText)
            articleAnalysis = wikidbArticleAnalyze_music(articleText)
            if not (linkCount % 20): 
                print nextPage, articleAnalysis[5];
            
            if articleAnalysis[0]:
                line = nextPage + ":" + articleAnalysis[5] + ":" + str(newLinks) + "\n";
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
redirFile.close()