# -*- coding: utf-8 -*-
"""
Created on Tue Nov 18 07:15:47 2014

@author: pete
"""


import re, string; pattern = re.compile('[\W_]+')

import time
import os


baseDir = '/home/pete/wikiDb/'

def del_dups(seq):
    seen = {}
    pos = 0
    for item in seq:
        if item not in seen:
            seen[item] = True
            seq[pos] = item
            pos += 1
    del seq[pos:]
    
def wikidbArticleToArticleText(articleText):
    start = articleText.find("<text xml:space=\"preserve\">")
    stop = articleText.find("</text>")
    articleText = articleText[start:stop]
    return articleText

def wikidbGetLinks(articleText):
    start = articleText.find("[[");
    stop = articleText.find("]]")
    print start
    links = list()
    while not (start == -1 or stop == -1):
        linkText = articleText[start:stop+2];
        linkText = linkText.replace("[[","")
        linkText = linkText.replace("]]","")
        pipeInd = linkText.find("|")
        if not pipeInd == -1:
            linkText = linkText[0:pipeInd]
            
        if not linkText.startswith("Category"):
            links.append(linkText)
            
        articleText = articleText[stop+2:]
        start = articleText.find("[[");
        stop = articleText.find("]]")
        #print start, stop
        #print articleText.__len__()
        #time.sleep(1)
        
    return links

def wikidbIsRedirect(articleText):
    myList = list()
    startIndex = articleText.find("<redirect title=")
    if startIndex == -1:
        myList.append(False)
        return myList
    
    articleText = articleText[startIndex:]
    stopIndex = articleText.find("\" />")
    redirectTarget = articleText[17:stopIndex]
    myList.append(True)
    myList.append(redirectTarget)
    return myList
    

def wikidbFindArticle(articleTitle):
    #title = articleTitle.replace(' ','')
    title = articleTitle.replace('\n','')
    origTitle = title;
    title = re.sub(r'\W+', '', title) 
    
    if (title.__len__() >= 2):
        subPath = title[:2].lower()
    else:
        subPath = 'shortName'
            
    dbFileName = baseDir + subPath + "/" + subPath + ".db"
    indexFileName = baseDir + subPath + "/" + subPath + ".index"

    print dbFileName
    print indexFileName
    
    nBytes = -1;
    with open(indexFileName) as indexF:
        entryCount = 1;
        cLine = indexF.readline();
        while (not cLine == ""):
            if cLine.startswith(origTitle+"::"):
                line = cLine.replace(origTitle+"::","")
                nBytes = int(float(line))
                break
            
            cLine = indexF.readline()
            entryCount+=1
    
    if nBytes == -1:
        article = "entry not found";
        return article
        
    print "Looking for title: " + title
    print "Entry found at entry: ", entryCount
    print "Expected db bytes: " + cLine
            
    with open(dbFileName) as dbF:
        #for x in range(0, lineNum):
        #    cLine = dbF.readline();
        dbF.seek(nBytes)
        article = ""
        while True:
            cLine = dbF.readline();
            article += cLine
            if '</page>' in cLine:
                break
        
    return article

startPage = "Screeching Weasel (album)"

articleFull = wikidbFindArticle(startPage)
articleText = wikidbArticleToArticleText(articleFull)
currentLinks = wikidbGetLinks(articleText)
isredir = wikiIsRedirect(articleText)
                
        

