#!/bin/bash


function modified_version(){
	FILE=$1
	if [ -e "$FILE" ];then
		version1=$(grep "apps.setting.product.swversion =" $FILE | awk '{print $3}' | awk -F'_' '{print $2}' | awk -F'.' '{print $NF}')
		echo $version1
		version1_1=$((10#$version1+1))
		echo $version1_1
		new_version1=`printf %02d $version1_1`
		echo $new_version1

		version2=$(grep "apps.setting.product.outswver =" $FILE | awk '{print $3}' | awk -F'_' '{print $2}' | awk -F'.' '{print $NF}
')
		echo $version2
		version2_2=$((10#$version2+1))
		echo $version2_2
		new_version2=`printf %02d $version2_2`
		echo $new_version2
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
