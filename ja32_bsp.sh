#!/bin/bash
#编译JA32_BSP

PATHROOT=$(pwd)
PROJECT="JA32_BSP"
DATE=`date +%Y%m%d`
OLD_BRANCH="ja32_byd_bsp"
NEW_BRANCH="ja32_byd_bsp_factory"
VERSION=$1


function clean_code(){
	if [ -d "$PROJECT" ];then
		pushd ${PATHROOT}/$PROJECT
			repo abandon $OLD_BRANCH
			repo init -b $NEW_BRANCH
			rm -rf *
			repo sync -j4
			repo start $NEW_BRANCH --all
		popd
	else
		repo init -u ssh://yinjigang@10.30.99.88:29418/JA32_BSP/android/manifest -b ja32_byd_bsp -m default.xml
		repo sync -j4		
	fi
	popd
}

function build_linux(){
	pushd ${PATHROOT}/$PROJECT
		pushd linux
			echo "begin build linux"
			./kcc.sh -variant userdebug 2>&1 | tee -a build_linux.log 
		popd
	popd
}

function build_L4_v2(){
		pushd ${PATHROOT}/$PROJECT/L4_v2
			echo "begin build L4_v2"
			ln -s ${PATHROOT}/$PROJECT/linux/vendor/kyocera/buildscm kcbuild
			cp ${PATHROOT}/$PROJECT/linux/vendor/kyocera/buildscm/kcc_amss.sh .
			export HEXAGON_ROOT=/pkg/qct/software/hexagon/releases/tools
			
			cp ${PATHROOT}/kcc_amss_sub.sh ${PATHROOT}/${PROJECT}/L4_v2/kcbuild
			cp ${PATHROOT}/qfile_archive.xml ${PATHROOT}/${PROJECT}/L4_v2/kcbuild/Deploy
			
			mkdir LINUX
			cd LINUX
			ln -s ../../linux android
			cd -

			./kcc_amss.sh -v userdebug 2>&1 | tee -a build_L4_v2.log
			echo "build L4_v2 END"
		popd
}

function make_zipfile(){
	pushd ${PATHROOT}/$PROJECT/L4_v2
	NEW_VERSION=V$VERSION
	echo ${NEW_VERSION}
		echo "begin packing"
		./kcc_amss.sh --rom common

		pushd deploy_$DATE/bin
			zip -r -9 deploy_${NEW_VERSION}_$DATE.zip ./*
		popd

		pushd QFILE_FLAT_img_$DATE
			pushd bin
				zip -r -9 JA32_BSP_${NEW_VERSION}_$DATE.zip ./*
			popd
		popd
	popd
}

function ftp_upload(){
Ftp_PATCH="./Qualcomm/SDM630/JA32_BSP"
Pack_name=JA32_BSP_${NEW_VERSION}_$DATE
ftp -n 10.30.11.100 2>&1 <<EOC
  user sh@scm sh@scm
  binary
  cd ${Ftp_PATCH}
  mkdir ${Pack_name} 
  cd ${Pack_name}
  mkdir target
  cd target
  lcd ${PATHROOT}/$PROJECT/L4_v2/QFILE_FLAT_img_$DATE/bin
  put JA32_BSP_${NEW_VERSION}_$DATE.zip 
  lcd ${PATHROOT}/$PROJECT/L4_v2/deploy_$DATE/bin
  put deploy_${NEW_VERSION}_$DATE.zip
  bye
EOC
}
########################
if [ $# -eq 1 ];then
        clean_code
        build_linux
        build_L4_v2
        make_zipfile
        ftp_upload
else    
        echo "请输入版本号"
fi

