# -*- coding: utf-8 -*-
"""
Created on Thu Sep 11 19:18:00 2014

@author: pete
"""
import re, string; pattern = re.compile('[\W_]+')

import time
import os

baseDir = '/home/pete/wikiExtract/'
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
while (True):
    line = f.readline();
    
    if inPage:
        f2.write(line)
        
    if startPageText in line:
        inPage = True
        startLine = line;
        titleLine = f.readline();
        title = titleLine.replace('<title>','')
        title = title.replace('</title>','')
        title = title.replace(' ','')
        title = title.replace('\n','')
        title = re.sub(r'\W+', '', title)
        
        if (title.__len__() > 3):
            subPath = title[:3].lower()
        else:
            subPath = 'shortName'
            
        fileName = baseDir + subPath + "/" + title
        if os.path.exists(fileName):
            inPage = False
            continue
        
        directory = os.path.dirname(fileName)
        if not os.path.exists(directory):
            os.makedirs(directory)
            
        try:
            f2 = open(fileName,'w')
        except:
            print "Could not open file: " + fileName + " from WIKI: " + titleLine
            time.sleep(0.02)
            f2 = open(baseDir + '__covarErrorFile','a')
            
        f2.write(line)
        f2.write(titleLine)
        count+=1;
        print fileName + " file: " + str(count)
        if not(count % 1000):
            time.sleep(0.02)
        
    if endPageText in line:
        inPage = False
        f2.close()
   

    
f.close()