#!/bin/bash
#生成xml文件


function generate_xml(){
	for i in `cat project_name.txt`
	do
		#${i#*/}:在此处去掉仓库名称的前缀
		echo "<project name=\"$i\" path=\"${i#*/}\"/>" >> default.xml
	done
	#在第一行添加
	sed -i "1i <manifest>\n<remote fetch=\"ssh://192.168.56.101:29418//\" name=\"origin\" review=\"http://192.168.56.101:8081/\"/>\n<default remote=\"origin\" revision=\"master\"/>" default.xml
	#在第一行的前面添加一行
	sed -i "1i <?xml version=\"1.0\" encoding=\"UTF-8\"?>" default.xml
	#在最后一行添加
	sed -i '$a <\/manifest>' default.xml
}

generate_xml
