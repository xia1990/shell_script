#!/bin/bash
#编译JA32_BSP

PATHROOT=$(pwd)
PROJECT="JA32_BSP"
DATE=`date +%Y%m%d`


function clean_code(){
	if [ -d "$PROJECT" ];then
		pushd ${PATHROOT}/$PROJECT
			repo forall -c 'git clean -fdx;git reset --hard HEAD'
			repo forall -c 'git status'
		popd

		pushd ${PATHROOT}/$PROJECT/linux
			rm -rf out
		popd
		
		pushd ${PATHROOT}/$PROJECT/L4_v2
			rm -rf LINUX/
			rm -rf QFILE_FLAT_*
			rm -rf kcbuild kcc_amss.sh
		popd

		pushd ${PATHROOT}/$PROJECT/
			repo sync -j4
		popd
	else
		repo init -u ssh://yinjigang@10.30.99.88:29418/JA32_BSP/android/manifest -b ja32_byd_bsp -m default.xml
		repo sync -j4		
	fi
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
			ln -s ../linux/vendor/kyocera/buildscm kcbuild
			cp ../linux/vendor/kyocera/buildscm/kcc_amss.sh .
			export HEXAGON_ROOT=/pkg/qct/software/hexagon/releases/tools
			
			cp ${PATHROOT}/kcc_amss_sub.sh ${PATHROOT}/${PROJECT}/L4_v2/kcbuild
			cp ${PATHROOT}/qfile_archive.xml ${PATHROOT}/${PROJECT}/L4_v2/kcbuild/Deploy
			./kcc_amss.sh -v userdebug 2>&1 | tee -a build_L4_v2.log
			echo "build L4_v2 END"
		popd
}

function make_zipfile(){
	pushd ${PATHROOT}/$PROJECT/L4_v2
		echo "begin packing"
		mkdir LINUX
		cd LINUX
		ln -s ../../linux android
		./kcc_amss.sh --rom common

		pushd deploy_$(date +%m%d_%H%M)/bin
			zip -r -9 deploy_$(date +%m%d_%H%M).zip ./*
		popd

		pushd QFILE_FLAT_img_$(date +%m%d_%H%M)
			pushd bin
				zip -r -9 JA32_BSP_$DATE.zip ./*
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
  put JA32_BSP_$DATE.zip 
  lcd ${PATHROOT}/$PROJECT/L4_v2/deploy_$(date +%m%d_%H%M)
  put deploy_$(date +%m%d_%H%M).zip
  bye
EOC
}
########################
#clean_code
#build_linux
build_L4_v2
make_zipfile
ftp_upload
