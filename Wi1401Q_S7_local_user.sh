#!/bin/bash -x
#!/usr/bin/expect

PATH=~/rar:$PATH

PATHROOT=$(pwd)
PROJECTAP="Wi1401Q_S7AP_DEV"
PROJECTBP="Wi1401Q_S7BP"
BranchAP=wi1401q_s7r01339_dev
BranchBP=wi1401q_s7r01339dev
date=`date +%Y%m%d`
M_Version=true
Ftp_PATCH="./Qualcomm/8039/Wi1401Q_S7/"
echo ${Ftp_PATCH}


function clean_APcode(){
	if [ -d $PROJECTAP ];then
  		cd $PROJECTAP
  		git clean -f -d
  		git reset --hard HEAD
  		git pull origin $BranchAP >> update.log
  		VAR=`strings update.log | grep -i Already |awk -F' ' 'NR==1 {print $1}'` 
  		if [ "$VAR" = "Already" ] ; then
  		echo "**********git pull null**********"
        		exit
  		fi
  		if [ $? -ne 0 ] ; then
    			echo "**********git update error**********"
    			exit 1
  		fi
	else
  		git clone -b $BranchAP ssh://gaoyuxia@10.30.99.88:29418/$PROJECT
  		if [ $? -ne 0 ] ; then
			echo "********git clone ap error******"
    			exit 2
  		fi
		echo
	fi
}


function modify_version(){
	pushd ${PATHROOT}/$PROJECTAP
	if [ ${M_Version} = "true" ] ; then
  		pushd ${PATHROOT}/$PROJECTAP/LINUX/android/build/tools
		Old_VER_NUM=$(grep -i "OEM_PRODUCT_VERSION_SHORT.*:=" "byd_buildinfo.mk" | awk '{print $NF}')
		echo $Old_VER_NUM
		TMP_VER_NUM=`expr ${Old_VER_NUM} + 1`
		echo $TMP_VER_NUM
		NEW_VER_NUM=`printf %06d ${TMP_VER_NUM}`
		echo $NEW_VER_NUM
		sed -i s/OEM_PRODUCT_VERSION_SHORT.*:=.*/OEM_PRODUCT_VERSION_SHORT\ :=\ ${NEW_VER_NUM}/g byd_buildinfo.mk

  		git diff
  		#git add byd_buildinfo.mk
  		#git commit -m "Modify Version SUB7_LOCAL_S${NEXT_VER}_${date}"
  		#git status
  		#git push origin ${BranchAP}
	else
    		echo --------- Not Modify Version ---------
	fi
	popd
}


function clean_BPcode(){
	pushd ${PATHROOT}
	if [ -d $PROJECTBP ];then
		cd $PROJECTBP
  		git clean -f -d
 		git reset --hard HEAD
  		git pull origin $BranchBP
	else
  		git clone -b $BranchBP ssh://gaoyuxia@$10.30.99.88:29418/$PROJECTBP
  		if [ $? -ne 0 ] ; then
    			echo "********** git clone bp error **********"
    			exit 3
  		fi
	fi
}

function building(){
	pushd ${PATHROOT}/$PROJECTBP
	rm -rf LINUX/
	ln -s ${PATHROOT}/$PROJECTAP/LINUX LINUX
	echo "target=msm8909-local-user" >> build_target.cfg
	sed -i s/j32/j64/g mk
	./mk scm 2>&1 | tee build.log
  	if [ $? -ne 0 ] ; then
    		echo "**********make error**********"
		exit
  	fi
	popd
	echo "All Project Build success!"
}


function packing(){
	echo "Ready to pack"
	pushd ${PATHROOT}/$PROJECTAP/LINUX/android/build/tools
		VERSION=$(grep -i "OEM_PRODUCT_VERSION_SHORT :=" byd_buildinfo.mk | awk '{print $NF}')
		echo $VERSION
		Target_name=SUB7_LOCAL_S${VERSION}_${date}
		MVersion=${VERSION}_user
		Pack_name=SUB7_LOCAL_${MVersion}_${date}
		echo ${Pack_name}
	popd
}


function make_zipfile(){
	packing
	pushd ${PATHROOT}/$PROJECTBP/SCM_COPY_FILES/msm8909_local_user
		zip -9 ${Pack_name}_OriginalFactory.zip sahara_images/*
		zip -9 DEBUG_INFO.zip scm_debug_info/*
		zip -9 -r ${Pack_name}_modem_image.zip scm_integrated_for_3rd/*
	popd
	pushd ${PATHROOT}/$PROJECTBP/SCM_COPY_FILES/msm8909_local_user/multiflash_images
		zip -9 ${Pack_name}_image.zip ./*
	popd
}

function ftp_upload(){
  packing
  ftp -n 10.30.11.100 2>&1 <<EOC
  user sh@scm sh@scm
  binary
  cd ${Ftp_PATCH}
  mkdir ${Target_name}
  cd ${Target_name}
  mkdir target
  cd target
  mkdir local
  cd local
  mkdir USER
  cd USER
  lcd ${PATHROOT}/$PROJECTBP/SCM_COPY_FILES/msm8909_local_user
  put ${Pack_name}_OriginalFactory.zip
  put DEBUG_INFO.zip
  put ${Pack_name}_modem_image.zip
  lcd ${PATHROOT}/$PROJECTBP/SCM_COPY_FILES/msm8909_local_user/multiflash_images
  put ${Pack_name}_image.zip
  mkdir sd
  cd sd
  lcd ${PATHROOT}/$PROJECTBP/SCM_COPY_FILES/msm8909_local_user/sd
  put msm8909-ota-user.yinjigang.zip
  lcd ${PATHROOT}/$PROJECTBP/SCM_COPY_FILES/msm8909_local_user/sd
  put msm8909-target_files-user.yinjigang.zip
  bye
EOC

echo
echo "11.10 Ftp upload complete"
echo
}

############Main##########
function main(){
	#clean_APcode
	#clean_BPcode
	modify_version
	#building
	#make_zipfile
	#ftp_upload
}

main "$@"
