#!/bin/bash -x
#!/usr/bin/expect
#编译w1506q临时USER版本

PATH=~/rar:$PATH

PATHROOT=$(pwd)
date=`date +%Y%m%d`
PROJECTAP=W1506Q_AP
PROJECTBP=W1506Q_BP
BRANCHBP=w1506q_bp_dev
BRANCHAP=w1506q_ap_32_new_dev
PATCHFILE=$1
Ftp_PATCH="./Qualcomm/8039/W1506Q/32_DEV/NEW_DEV/TEMP/"

#cd ../../../../../tmp/
#rm -rf *
#cd -

function building(){
	pushd "$PATHROOT"/$PROJECTBP/
	rm -rf LINUX/
	ln -s "$PATHROOT"/$PROJECTAP/LINUX LINUX
	echo "target=msm8916_32-t1host-global-user">>build_target.cfg

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

function packing(){
	pushd "$PATHROOT"/$PROJECTBP/LINUX/android/build/tools
	NEW_VER_NUM=`strings byd_buildinfo.mk | grep -i OEM_PRODUCT_VERSION_SHORT | awk -F ' ' 'NR==1 {print $3}'`
	Target_name=W1506q_S${NEW_VER_NUM}_t1host_${date}
	MVersion=S${NEW_VER_NUM}_user
	Pack_name=W1506q_t1host_global_${MVersion}_${date}
	echo ${Pack_name}
	popd
    
	echo "Ready to pack"
	pushd "$PATHROOT"/$PROJECTBP/SCM_COPY_FILES/msm8916_32_t1host_global_user/
		zip -r -9 ${Pack_name}_OriginalFactory.zip sahara_images/*
		zip -r -9 DEBUG_INFO.zip scm_debug_info/*
		zip -r -9 ${Pack_name}_modem_image.zip scm_integrated_for_3rd  
	popd
	pushd "$PATHROOT"/$PROJECTBP/SCM_COPY_FILES/msm8916_32_t1host_global_user/multiflash_images
		zip -r -9 ${Pack_name}_image.zip ./*
	popd
}

function ftp_upload(){
pushd "$PATHROOT"/$PROJECTBP/LINUX/android/build/tools
        NEW_VER_NUM=`strings byd_buildinfo.mk | grep -i OEM_PRODUCT_VERSION_SHORT | awk -F ' ' 'NR==1 {print $3}'`
        Target_name=W1506q_S${NEW_VER_NUM}_t1host_${date}
        MVersion=S${NEW_VER_NUM}_user
        Pack_name=W1506q_t1host_global_${MVersion}_${date}
        echo ${Pack_name}
popd

ftp -n 10.30.11.100 2>&1 <<EOC
  user sh@scm sh@scm
  binary
  cd ${Ftp_PATCH}
  mkdir $date
  cd $date
  lcd "$PATHROOT"/$PROJECTBP/SCM_COPY_FILES/msm8916_32_t1host_global_user
  put ${Pack_name}_OriginalFactory.zip
  put DEBUG_INFO.zip
  put ${Pack_name}_modem_image.zip
  lcd ./multiflash_images
  put ${Pack_name}_image.zip
  mkdir sd
  cd sd
  lcd "$PATHROOT"/$PROJECTBP/SCM_COPY_FILES/msm8916_32_t1host_global_user/sd
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
	packing
	ftp_upload
}
main "$@"

