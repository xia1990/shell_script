#!/bin/bash
#制作LF1001QN差分包

PATHROOT=$(pwd)
PROJECT="LF1001QN"
DATE=`date +%Y%m%d`
FTP_PATH="./Qualcomm/8976/LF1001QN/"
#原始差分包
Old_FILE=$1
#目标差分包
NEW_FILE=$2
#升级差分包
Update_FILE=$3

function make_target(){
	pushd ${PATHROOT}/$PROJECT/LINUX/android
		#考贝原文件到当前目录
		cp ~/Target_FILES/$Old_FILE .
		#考贝目标文件到当前目录
		cp ~/Target_FILES/$NEW_FILE .
		source build/envsetup.sh
		lunch msm8952_64-lte-row-sku1-user
		./build/tools/releasetools/ota_from_target_files --block -i $Old_FILE $NEW_FILE $Update_FILE
	popd	
}

function ftp_upload(){
pushd ${PATHROOT}/${PROJECT}/LINUX/android/out/target/product/msm8952_64/system
	Pack_name=`strings build.prop | grep ro.build.lenovo.version.in | awk -F'=' 'NR==1 {print $2}'`
        echo ${Pack_name}
popd

pushd ${PATHROOT}/$PROJECT/LINUX/android
  ftp -n 10.30.11.100 2>&1 <<EOC
  user sh@scm sh@scm
  binary
  cd ${FTP_PATH}
  cd ${Pack_name}
  cd target
  cd LTE_ROW_SKU1-USER
  cd sd
  lcd ${PATHROOT}/${PROJECT}/LINUX/android
  put $Update_FILE
  bye
EOC
popd
}

###########MAIN#########
function main(){
	make_target
	#ftp_upload
}
main "$@"
