#!/bin/bash

ROOTPATH=`pwd`
MY_NAME=`whoami`
PROJECT=P118F-Factory

MY_PATTERN=$1
NEED_BUILD_VERSION=$2
PLALFORM_LIBRARY=$3

DATE=`date +%Y%m%d`

function main()
{
    pull_code
    update_version
    build_ap
    build_NOHLOS
}

function update_version()
{
    pushd $ROOTPATH/$PROJECT
        sed -i 's/CPUCORE=8/CPUCORE=32/' quick_build.sh
        #"修改dailybuild版本号"
        DAILYBUILD_NUMBER=TYC-P118F-U000C_V1.0B01_Daily_$DATE
        echo $DAILYBUILD_NUMBER
        #修改内部版本号
        sed -i "s/TYC-P118F-U000C_V1.0B01_SMT_L0906/$DAILYBUILD_NUMBER/" ./wind/custom_files/device/qcom/P118F/version
        #修改外部版本号
        sed -i "s/tye100.1.00.00.01_SMT_L0906/tye100.1.00.00.01/" ./wind/custom_files/device/qcom/P118F/version
	echo "修改版本号成功"
    popd
}

function build_ap(){
    pushd $ROOTPATH/$PROJECT
	./quick_build.sh P118F user fc new
    popd
}

function update_name(){
    pushd $ROOTPATH/$PROJECT/.repo/manifests
	sed -i "s/itadmin/$MY_NAME/" manifest.xml
    popd
}

function pull_code()
{
    if [ -d $PROJECT ];then
        pushd $ROOTPATH/$PROJECT
	    rm -rf out
	    repoc forall -c 'git clean -fd;git reset --hard HEAD;git status'
	    update_name
  	    repoc sync -j4
            repoc start Stable_P118F_Factory_BRH --all
 	popd
    else
        pushd $ROOTPATH/$PROJECT
    	    #--no-repoc-verify:不进行校验
    	    repoc init -u ssh://$MY_NAME@10.0.30.10:29418/$PLALFORM_LIBRARY/Manifest -m manifest.xml -b Stable_P118F_Factory_BRH --no-repoc-verify
	    update_name
            repoc sync -j4
            repoc start Stable_P118F_Factory_BRH --all
        popd
    fi
}

function build_NOHLOS(){
    pushd $ROOTPATH/$PROJECT/NOHLOS
        ./build_n.sh all fc 2>&1 | tee build_nohlos.log
        ./cpn P118F
        echo "切片完成"
    popd
}

main $1 $2 $3
