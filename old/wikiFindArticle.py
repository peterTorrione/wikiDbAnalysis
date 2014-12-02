# -*- coding: utf-8 -*-
"""
Created on Tue Nov 18 07:15:47 2014

@author: pete
"""


import re, string; pattern = re.compile('[\W_]+')

import time
import os


baseDir = '/home/pete/wikiDb/'

def wikidbGetLinks(articleText):
    start = articleText.find("[[");
    stop = articleText.find("]]")
    print start
    links = list()
    print articleText.__len__()
    while not (start == -1 or stop == -1):
        links.append(articleText[start:stop+2])
        articleText = articleText[stop+2:]
        start = articleText.find("[[");
        stop = articleText.find("]]")
        #print start, stop
        #print articleText.__len__()
        #time.sleep(1)
        
    return links

def wikiIsRedirect(articleText):
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

t0 = time.time()
articleText = wikidbFindArticle("Radio head")
etime = time.time()-t0
print articleText
print etime

links = wikidbGetLinks(articleText)
print links

isredir = wikiIsRedirect(articleText)
print isredir
                
        

