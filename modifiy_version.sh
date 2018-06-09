#!/bin/bash
#修改doro版本号
#此版本号的格式为：apps.setting.product.outswver = DSB0020_02.02.00_USER_20180416，只需要将00改为01即可


function modified_version(){
	FILE=$1
	#如果版本号文件存在
	if [ -e "$FILE" ];then
		#修改第一处版本号
		version1=$(grep "apps.setting.product.swversion =" $FILE | awk '{print $3}' | awk -F'_' '{print $2}' | awk -F'.' '{print $NF}')		
		echo $version1
		#此处会报：shell value too great for base错误
		#解决方法就是在变量前加上10#,告诉shell使用10进制
		version1_1=$((10#$version1+1))
		echo $version1_1
		#%2d表示把整型数据打印最低两位
		new_version1=`printf %02d $version1_1`
		echo $new_version1

		#修改第二处版本号
		version2=$(grep "apps.setting.product.outswver =" $FILE | awk '{print $3}' | awk -F'_' '{print $2}' | awk -F'.' '{print $NF}
')
		echo $version2
		#以10进制输出，版本号加1
		version2_2=$((10#$version2+1))
		echo $version2_2
		new_version2=`printf %02d $version2_2`
		echo $new_version2
		#全局替换版本号加一，进行修改
		sed -i "s/apps.setting.product.swversion = .*/apps.setting.product.swversion = DSB0020_02.02.${new_version1}_USER_20180416/g" $FILE
		sed -i "s/apps.setting.product.outswver = .*/apps.setting.product.outswver = DSB0020_02.02.${new_version2}_USER_20180416/g" $FILE
	else
		echo "file is not exists"
		exit 0	
	fi
}

if [ $# -eq 1 ];then
	modified_version "$1"
else
	echo "please input a filename"
fi
