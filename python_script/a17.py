#!/usr/bin/python
#_*_ coding:utf-8 _*_

import commands
import json
import xlwt
import re
import time

branch="master"
date_today="2020-02-17"

filename=commands.getoutput('ssh -p 29418 10.80.30.10 gerrit query after:%s status:merged --format=JSON | grep "subject"> message.txt' % (date_today))
def set_style(name,height,bold=False):
    style=xlwt.XFStyle()
    pattern=xlwt.Pattern()
    pattern.pattern=xlwt.Pattern.SOLID_PATTERN
    #设置背景颜色
    pattern.pattern_fore_colour=7
    style.pattern=pattern
    #设置边框(为实线)
    borders=xlwt.Borders()
    borders.left=xlwt.Borders.THIN
    borders.right=xlwt.Borders.THIN
    borders.top=xlwt.Borders.THIN
    borders.bottom=xlwt.Borders.THIN
    style.borders=borders
    return style
	
commit_msg=[]
pname_list=[]

def write_excel():
    f=xlwt.Workbook(encoding="utf-8")
    sheet1=f.add_sheet('修改点',cell_overwrite_ok=True)
    row0=[u'序号',u'BUG号',u'调试单元',u'软件确认状态',u'软件确认时间',u'备注']

    for i in range(0,len(row0)):
        sheet1.write(0,i,row0[i],set_style('Times New Roman',220,True))

    with open("message.txt") as f1:
        for line in f1.readlines():
            dict1=json.loads(line)
            #项目名称
            p_name=dict1["project"]
            #项目名称列表
            pname_list.append(p_name)
            msg=dict1["commitMessage"]
            #提交信息
            b=re.findall(r'^\[Subject\](.*)\[Bug Number',msg,re.S)
            cmsg=b[0].split(']')[1]
            print(cmsg)
            #提交信息列表
            commit_msg.append(cmsg)
            for i in range(len(commit_msg)):
                sheet1.write(i+1,0,i+1)
                #第2列写入提交信息
                sheet1.write(i+1,2,commit_msg[i])
                sheet1.write(i+1,3,"OK")
                sheet1.write(i+1,4,time.strftime("%Y%m%d"))
                #第5列写入项目名称
                sheet1.write(i+1,5,pname_list[i])
    f.save(time.strftime("WAI0017_"+"%Y%m%d"+"修改问题点.xls"))

if __name__=="__main__":
    write_excel()
