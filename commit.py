#!/usr/bin/python
# -*- coding: UTF-8 -*-

from pyExcelerator import *
import os
import re
import sys
w=Workbook()
ws = w.add_sheet('version message')

f=open('result.txt')
l=list(f)
lenth=len(l)
j=0
for i in l:
    line_list=i.split('####')
    change_id = line_list[0]
    ws.write(j,0,change_id)
    message = line_list[1]
    ws.write(j,1,message)
    modefied_files = line_list[2]
    file_list=re.split(' ',modefied_files)
    s=""
    for k in range(0,len(file_list)-1,2):
        a=file_list[k]+" "+file_list[k+1]
        if s:
            s=s+os.linesep+a
        else:
            s=a
    print str(s)
    #ws.write(j,2,str(s))
    ws.write(j,2,s)
    j=j+1
w.save('test.xls')
