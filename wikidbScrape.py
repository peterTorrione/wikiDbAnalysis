# -*- coding: utf-8 -*-
"""
Created on Tue Nov 18 07:15:47 2014

@author: pete
"""


import re, string; pattern = re.compile('[\W_]+')

import time
import os
import sys


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
    links = list()
    while not (start == -1 or stop == -1):
        linkText = articleText[start:stop+2];
        linkText = linkText.replace("[[","")
        linkText = linkText.replace("]]","")
        pipeInd = linkText.find("|")
        if not pipeInd == -1:
            linkText = linkText[0:pipeInd]
            
        if not linkText.startswith("Category:") and not linkText.startswith("File:"):
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

    #print dbFileName
    #print indexFileName
    
    nBytes = -1;
    with open(indexFileName) as indexF:
        entryCount = 1;
        cLine = indexF.readline();
        cLine = cLine.lower();
        origTitle = origTitle.lower();
        while (not cLine == ""):
            if cLine.startswith(origTitle+"::"):
                line = cLine.replace(origTitle+"::","")
                nBytes = int(float(line))
                break
            
            cLine = indexF.readline()
            cLine = cLine.lower();
            entryCount+=1
    
    if nBytes == -1:
        article = "entry not found";
        return article
        
    #print "Looking for title: " + title
    #print "Entry found at entry: ", entryCount
    #print "Expected db bytes: " + cLine
            
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

def wikidbArticleAnalyze(articleText):
    
    isBand = "Infobox musical artist" in articleText;
    isLabel = "Infobox record label" in articleText;
    isAlbum = "Infobox album" in articleText;
    isSong = "Infobox song" in articleText;
    isGenre = "Infobox genre" in articleText or "Infobox music genre" in articleText;
    
    bandStrings = [' band',' musical group', ' composer', ' musician',' singer',' DJ',' rockband']
    albumStrings = [' album',' record',' EP ']
    songStrings = [' song ',' composition ',' single ']
    labelStrings = [' label']
    genreStrings = [' genre']
    bandFoundIndex = 100000;
    albumFoundIndex = 100000;
    songFoundIndex = 100000;
    labelFoundIndex = 100000;
    genreFoundIndex = 100000;
    
    outStr = "None";
    if isBand:
        outStr = "Band";
    if isLabel:
        outStr = "Label";
    if isAlbum:
        outStr = "Album";
    if isSong:
        outStr = "Song";
    if isGenre:
        outStr = "Genre";
        
    if not isBand and not isLabel and not isAlbum and not isSong:
        articleTextStart = articleText[0:1000]
        for theStr in bandStrings:
            foundIndex = articleTextStart.find(theStr)
            if foundIndex == -1:
                foundIndex = 100000;
                
            bandFoundIndex = min([bandFoundIndex, foundIndex])
        
        
        for theStr in albumStrings:
            foundIndex = articleTextStart.find(theStr)
            if foundIndex == -1:
                foundIndex = 100000;
                
            albumFoundIndex = min([albumFoundIndex, foundIndex])

        for theStr in songStrings:
            foundIndex = articleTextStart.find(theStr)
            if foundIndex == -1:
                foundIndex = 100000;
                
            songFoundIndex = min([songFoundIndex, foundIndex])
            
        for theStr in labelStrings:
            foundIndex = articleTextStart.find(theStr)
            if foundIndex == -1:
                foundIndex = 100000;
                
            labelFoundIndex = min([labelFoundIndex, foundIndex])
        
        for theStr in genreStrings:
            foundIndex = articleTextStart.find(theStr)
            if foundIndex == -1:
                foundIndex = 100000;
                
            genreFoundIndex = min([genreFoundIndex, foundIndex])
            
        isBand = False;
        isSong = False;
        isLabel = False;
        isAlbum = False;
        
        if bandFoundIndex < min([albumFoundIndex, songFoundIndex, labelFoundIndex, genreFoundIndex]):
            isBand = True;
            outStr = "Band"
        elif albumFoundIndex < min([songFoundIndex, labelFoundIndex, genreFoundIndex]):
            isAlbum = True;
            outStr = "Album"
        elif songFoundIndex < min([labelFoundIndex, genreFoundIndex]):
            isSong = True;
            outStr = "Song"
        elif labelFoundIndex < genreFoundIndex:
            isLabel = True;
            outStr = "Label"
        elif genreFoundIndex < 100000:
            isGenre = True;
            outStr = "Genre"
    
    myList = [isBand, isAlbum, isSong, isLabel, isGenre, outStr]
    
    return myList
            

startPage = "Screeching Weasel"
requiredText = ['band', 'musician','WikiProject_Musicians','Infobox musical artist']
articleFull = wikidbFindArticle(startPage)
articleText = wikidbArticleToArticleText(articleFull)
totalLinks = wikidbGetLinks(articleText)
isredir = wikiIsRedirect(articleText)
visitedLinks = []

linkCount = 0
myFile = open("linkfile_2014_11_22.txt","w")

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
    if not (linkCount % 5):
        print "Exploring page # " + str(linkCount) + " out of " + str(totalLinks.__len__()) + " : " + nextPage
        time.sleep(0.1)
        
    if nextPage in visitedLinks:
        print "  skipping already visited url: " + nextPage
    else:
        try:
            visitedLinks = visitedLinks + [nextPage] 
            
            articleFull = wikidbFindArticle(nextPage)
            if articleFull.startswith("entry not found"):
                print "WIkipedia page: " + nextPage + " not found"
                continue
            
            isredir = wikidbIsRedirect(articleFull)
            if isredir[0]:
                print "Redirect page!  Jumping to: " + isredir[1]
                articleFull = wikidbFindArticle(isredir[1])
                visitedLinks = visitedLinks + [isredir[1]]
                
            articleText = wikidbArticleToArticleText(articleFull)
            newLinks = wikidbGetLinks(articleText)
            articleAnalysis = wikidbArticleAnalyze(articleText)
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