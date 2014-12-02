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
wikiFileSmall = '/home/pete/Desktop/testWikiZip/enwiki-20140811-pages-articles.small.xml'
f = open(wikiFile,'r')
f2 = open(wikiFileSmall,'w')

count = 0;
while (count < 1000):
    line = f.readline();    
    f2.write(line)
    count+=1
    if not(count % 1000):
        print(count)
   

f2.close()    
f.close()