#!/bin/bash -x
#!/usr/bin/expect

PATH=~/rar:$PATH

PATHROOT=$(pwd)
date=`date +%Y%m%d`
M_Version=false
PROJECTAP=W1506Q_AP
PROJECTBP=W1506Q_BP
BRANCHAP=w1506q_ap_32_new_dev
BRANCHBP=w1506q_bp_dev
w1506q_bp_dev=t1host
FTP_PATCH=./Qualcomm/8039/W1506Q/32_DEV/NEW_DEV/


function clean_AP_code(){
	if [ -d $PROJECTAP ];then
  		pushd $PROJECTAP
 	 	git clean -f -d
  		git reset --hard HEAD
  		git checkout $BRANCHAP
  		git pull origin $BRANCHAP >> update.log
 	 	if [ $? -ne 0 ];then
        		git pull origin $BRANCH >>update.log
  		fi
  		VAR=`strings update.log | grep -i Already |awk -F' ' 'NR==1 {print $1}'` 
  		if [ "$VAR" = "Already" ] ; then
  			echo "git pull null"
          		exit
  		fi
  		if [ $? -ne 0 ] ; then
    			echo "**********git update error**********"
    			exit 1
  		fi
		popd
	else
  		git clone -b $BRANCHAP ssh://gaoyuxia@10.30.99.88:29418/$PROJECTAP
  		if [ $? -ne 0 ] ; then
    			echo "git clone ap error"
		    	exit 2
 		 fi
	fi
}

function modify_version(){
	pushd "$PATHROOT"/$PROJECTAP/
	if [ ${M_Version} = "true" ] ; then
  		pushd "$PATHROOT"/$PROJECTAP/LINUX/android/build/tools
  		Old_VER_NUM=`strings byd_buildinfo.mk | grep -i OEM_PRODUCT_VERSION_SHORT | awk -F ' ' 'NR==1 {print $3}'`
  		echo ${Old_VER_NUM}
  		VER_TMP=
  		Old_VER=${VER_TMP}${Old_VER_NUM}
  		echo ${Old_VER}
  		TMP_VER_NUM=`expr ${Old_VER_NUM} + 1`
  		NEXT_VER_NUM=`printf %06d ${TMP_VER_NUM}`
  		echo ${NEXT_VER_NUM}
  		NEXT_VER=${VER_TMP}${NEXT_VER_NUM}
  		echo ${NEXT_VER}
  		sed -i s/${Old_VER}/${NEXT_VER}/g byd_buildinfo.mk
		popd

 		git diff
  		git add "$PATHROOT"/$PROJECTAP/LINUX/android/build/tools/byd_buildinfo.mk
        git commit -m "Modify Version W1506Q_${NEXT_VER}_${TYPE}_${date}"
  		git status
  		git push origin ${BRANCHAP}
 	 	if [ $? -eq 0 ];then
  			print "push version number sucessfull"
  		fi
	else
    		echo --------- Not Modify Version ---------
	fi
}

##################### Modify Version ######################

function clean_BP_code(){
	if [ -d $PROJECTBP ];then
  		pushd $PROJECTBP
 	 	git clean -f -d
  		git reset --hard
  		git checkout $BRANCHBP
  		git pull origin $BRANCHBP
	else
  		git clone -b $BRANCHBP ssh://gaoyuxia@10.30.99.88:29418/$PROJECTBP
  		if [ $? -ne 0 ] ; then
    			echo "********** git clone bp error **********"
    			exit 3
		fi
	fi
}

function building(){
	pushd "$PATHROOT"/$PROJECTBP/
	rm -rf LINUX/
	ln -s "$PATHROOT"/$PROJECTAP/LINUX LINUX
	echo "target=msm8916_32-t1host-global-eng">build_target.cfg

	sed -i s/j8/j16/g mk
	./mk scm 2>&1 | tee build.log
 	if [ $? -ne 0 ] ; then
  		echo "**********make error**********"
    		exit 4
  	fi
	echo
		echo "All Project Build success!"
	echo
}

function pack_name(){
	pushd "$PATHROOT"/$PROJECTBP/LINUX/android/build/tools
        NEW_VER_NUM=`strings byd_buildinfo.mk | grep -i OEM_PRODUCT_VERSION_SHORT | awk -F ' ' 'NR==1 {print $3}'`	
        MVersion=S${NEW_VER_NUM}_eng
        Target_name=W1506q_S${NEW_VER_NUM}_${TYPE}_${date} 
        echo ${Target_name}
        Pack_name=W1506q_${TYPE}_global_${MVersion}_${date}	  
        echo ${Pack_name}
   popd
}

function packing(){
    pack_name
	echo "Ready to pack"
	pushd "$PATHROOT"/$PROJECTBP/SCM_COPY_FILES/msm8916_32_t1host_global_eng
		zip -r -9 ${Pack_name}_OriginalFactory.zip sahara_images/*
		zip -r -9 DEBUG_INFO.zip scm_debug_info/*
		zip -r -9 ${Pack_name}_modem_image.zip scm_integrated_for_3rd  
	popd
	pushd "$PATHROOT"/$PROJECTBP/SCM_COPY_FILES/msm8916_32_t1host_global_eng/multiflash_images
		zip -r -9 ${Pack_name}_image.zip ./*
	popd
}

function ftp_upload(){
pack_name
ftp -n 10.30.11.100 2>&1 <<EOC
  user sh@scm sh@scm
  binary
  cd ${FTP_PATCH}
  mkdir ${Target_name}
  cd ${Target_name}
  mkdir target
  cd target
  mkdir t1host_global
  cd t1host_global
  mkdir ENG
  cd ENG
  lcd "$PATHROOT"/$PROJECTBP/SCM_COPY_FILES/msm8916_32_t1host_global_eng
  put ${Pack_name}_OriginalFactory.zip
  put DEBUG_INFO.zip
  put ${Pack_name}_modem_image.zip
  lcd ./multiflash_images
  put ${Pack_name}_image.zip
  mkdir sd
  cd sd
  lcd "$PATHROOT"/$PROJECTBP/SCM_COPY_FILES/msm8916_32_t1host_global_eng/sd
  put msm8916_32-ota-*.zip
  put msm8916_32-target_files-*.zip
  bye
EOC

echo
echo "11.100 Ftp upload complete"
echo
}

##################
function main(){
	clean_AP_code
	clean_BP_code
	modify_version
	building
	packing
	ftp_upload
}
main "$@"
