# -*- coding: utf-8 -*-
"""
Created on Thu Sep 11 19:18:00 2014

@author: pete
"""
import re, string; pattern = re.compile('[\W_]+')

import time
import os

def readNextPage(file,fileStr):
    endPageText = '</page>'
    nLines = fileStr.count('\n')
    cLine = fileStr;
    while (not (endPageText in cLine or cLine == "")):
        cLine = file.readline();
        fileStr+=cLine;
        nLines+=1
        if "<ns>" in cLine:
            cLine = string.lstrip(cLine)
            ns = int(float(cLine[4]))
    
    result = [fileStr,nLines,ns]
    return result
    

baseDir = '/home/pete/wikiDb/'
try:
    os.remove(baseDir + '__covarErrorFile')
except:
    pass

wikiFile = '/home/pete/Desktop/testWikiZip/enwiki-20140811-pages-articles.xml'
f = open(wikiFile,'r')
startPageText = '<page>'
endPageText = '</page>'

count = 0;
inPage = False
line = 'temp'
indexDict = {}

while (not line == ""):
    line = f.readline();
    
    if startPageText in line:
        
        startLine = line;
        titleLine = f.readline();
        title = titleLine.replace('<title>','')
        title = title.replace('</title>','')
        title = title.replace('\n','')
        title = title.strip();
        origTitle = title;
        title = title.replace(' ','')
        title = re.sub(r'\W+', '', title)
        
        if (title.__len__() >= 2):
            subPath = title[:2].lower()
        else:
            subPath = 'shortName'
            
        dbFileName = baseDir + subPath + "/" + subPath + ".db"
        indexFileName = baseDir + subPath + "/" + subPath + ".index"
        
        result = readNextPage(f,startLine+titleLine)
        
        if not result[2] == 0:  #OR 14!
            continue
        
        directory = os.path.dirname(dbFileName)
        if not os.path.exists(directory):
            os.makedirs(directory)
            
        if not indexFileName in indexDict:
            indexDict[indexFileName] = 0
        
        if not os.path.exists(indexFileName):
            findex = open(indexFileName,'w')
        else:
            findex = open(indexFileName,'a')

        findex.write(origTitle + "::" + str(indexDict[indexFileName]) + "\n")
        findex.close()
                    
        try:
            if os.path.exists(dbFileName):
                f2 = open(dbFileName,'a')
            else:
                f2 = open(dbFileName,'w')
        except:
            inPage = False
            print "Could not open file: " + fileName + " from WIKI: " + titleLine
            time.sleep(0.02)
            f2 = open(baseDir + '__covarErrorFile','a')
            
        f2.write(result[0])
        indexDict[indexFileName]+=len(result[0])

        count+=1;
        if not (count % 500):
            print "DB File: " + dbFileName + "Article: " + title + "(" + origTitle + "), #" + str(count)
        if not(count % 10000):
            time.sleep(0.02)
           
    
f.close()