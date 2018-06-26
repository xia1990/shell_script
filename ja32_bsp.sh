#!/bin/bash
#编译JA32_BSP

PATHROOT=$(pwd)
PROJECT="JA32_BSP"
DATE=`date +%Y%m%d`

function build_code(){
	if [ -d "$PROJECT" ];then
		pushd ${PATHROOT}/$PROJECT
			pushd linux
				echo "begin build linux"
				./kcc.sh -variant userdebug 
			popd

			pushd L4_v2
				echo "begin build L4_v2"
				ln -s ${PATHROOT}/$PROJECT/linux/vendor/kyocera/buildscm kcbuild
				cp ${PATHROOT}/$PROJECT/linux/vendor/kyocera/buildscm/kcc_amss.sh .
				export HEXAGON_ROOT=/pkg/qct/software/hexagon/releases/tools
				./kcc_amss.sh -v userdebug
			popd

			pushd L4_v2
				echo "begin packing"
				mkdir LINUX
				ln -s ../linux LINUX/android
				./kcc_amss.sh --rom common
			popd
		popd
	else
		repo init -u ssh://gaoyuxia@10.30.99.88:29418/JA32_BSP/android/manifest -b ja32_byd_bsp -m JA32_KC.BSP_V0.00_180625.xml
		repo sync -j4
	fi
}


function make_zipfile(){
	pushd L4_v2
		pushd QFILE_FLAT_img_$(date +%m%d_%H%M)
			pushd bin
				zip -r -9 JA32_BSP_$DATE_img.zip ./*
			popd
		popd
	popd
}

function ftp_upload(){
Ftp_PATCH="./Qualcomm/SDM630/JA32_BSP"
Pack_name=JA32_BSP_$DATE
ftp -n 10.30.11.100 2>&1 <<EOC
  user sh@scm sh@scm
  binary
  cd ${Ftp_PATCH}
  mkdir ${Pack_name} 
  cd ${Pack_name}
  mkdir target
  cd target
  lcd ${PATHROOT}/$PROJECT/L4_v2/QFILE_FLAT_img_$(date +%m%d_%H%M)/bin
  put JA32_BSP_$DATE_img.zip 
  bye
EOC
}
########################
build_code
make_zipfile
ftp_upload
