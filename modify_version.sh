#!/bin/bash
#修改1401版本号

PATHROOT=$(pwd)
PROJECT="Wi1401Q_S7AP_DEV"

function change_version_number(){
	pushd ${PATHROOT}/${PROJECT}/LINUX/android/build/tools
		Old_VER_NUM=$(grep -i "OEM_PRODUCT_VERSION_SHORT.*:=" "byd_buildinfo.mk" | awk '{print $NF}')
		echo $Old_VER_NUM
		TMP_VER_NUM=`expr ${Old_VER_NUM} + 1`
		echo $TMP_VER_NUM
		NEW_VER_NUM=`printf %06d ${TMP_VER_NUM}`
		echo $NEW_VER_NUM
		sed -i s/OEM_PRODUCT_VERSION_SHORT.*:=.*/OEM_PRODUCT_VERSION_SHORT\ :=\ ${NEW_VER_NUM}/g byd_buildinfo.mk
	popd
}

change_version_number
