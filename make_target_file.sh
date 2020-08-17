#!/bin/bash -x
#!/usr/bin/expect
#制作差分包

PATH=~/rar:$PATH
PATHROOT=$(pwd)
PROJECT=T10_LA1.1.1_Branch
Date=`date +%Y%m%d`
Ftp_PATCH="./Qualcomm/8976/$PROJECT/"
BRANCH=t10_LA1.1.1_dev
LUNCH=msm8952_64_lte_prc_none_user
#参数一
UP_PATH1="./Qualcomm/8976/T10_LA1.1.1_Branch/80008_USR_1.0.198_1712271009_R6.0_PRC/target/LTE_PRC/USER/sd/"
UP_PATH2="./Qualcomm/8976/T10_LA1.1.1_Branch/80008_USR_1.0.199_1801040950_R6.0_PRC/target/LTE_PRC/USER/sd/"
#参数二
FILENAME1=80008_USR_1.0.198_1712271009_R6.0_PRC-target_files.zip
FILENAME2=80008_USR_1.0.199_1801040950_R6.0_PRC-target_files.zip


function make_target(){
pushd "$PATHROOT"/$PROJECT/LINUX/android/
ftp -n 10.30.11.100 2>&1 <<EOC
user sh@scm sh@scm
binary
cd ${UP_PATH1}
get ${FILENAME1}
cd -
bye
EOC

ftp -n 10.30.11.100 2>&1 <<EOC
user sh@scm sh@scm
binary
cd ${UP_PATH2}
get ${FILENAME2}
cd -
bye
EOC
popd

pushd "$PATHROOT"/$PROJECT/LINUX/android/build/tools
	PRODUCT_MAJOR_VERSION=$(grep -i "PRODUCT_MAJOR_VERSION.*:=" "supplier_buildinfo.mk" | awk '{print $NF}')
	PRODUCT_MINOR_VERSION=$(grep -i "PRODUCT_MINOR_VERSION.*:=" "supplier_buildinfo.mk" | awk '{print $NF}')
	PRODUCT_POINT_VERSION=$(grep -i "PRODUCT_POINT_VERSION.*:=" "supplier_buildinfo.mk" | awk '{print $NF}')
	PRODUCT_STAGE=$(grep -i "PRODUCT_STAGE.*:=" "supplier_buildinfo.mk" | awk '{print $NF}')
	TEMP=`expr $PRODUCT_POINT_VERSION - 1`
	NEW_VERSION=${PRODUCT_MAJOR_VERSION}.${PRODUCT_MINOR_VERSION}.${PRODUCT_POINT_VERSION}
	echo $NEW_VERSION
	OLD_VERSION=${PRODUCT_MAJOR_VERSION}.${PRODUCT_MINOR_VERSION}.${TEMP}
	echo $OLD_VERSION
popd

pushd "$PATHROOT"/$PROJECT/LINUX/android/
	source build/envsetup.sh
	lunch 2
	./build/tools/releasetools/ota_from_target_files --block -i  ${FILENAME1}  ${FILENAME2} 80008_USR_PRC_${OLD_VERSION}_to_${NEW_VERSION}.zip
popd

pushd pushd "$PATHROOT"/$PROJECT/LINUX/android
ftp -n 10.30.11.100 2>&1 <<EOC
user sh@scm sh@scm
binary
cd ${UP_PATH2}
put 80008_USR_PRC_${OLD_VERSION}_to_${NEW_VERSION}.zip
bye
EOC
popd
}
make_target












