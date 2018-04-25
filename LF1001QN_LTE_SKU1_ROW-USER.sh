#!/bin/bash -x
#!/usr/bin/expect

PATH=~/rar:$PATH

PATHROOT=$(pwd)
project=LF1001QN
git_branch=BasilN_r00140dev
#git_branch=BasilN_CTA
Date=`date +%Y%m%d`
Ftp_PATCH="./Qualcomm/8976/LF1001QN"
MOD_VER=true
LF1001QN_LTE_SKU1_ROW_USER=true

function clean_code(){
	if [ -d $project ];then
  		pushd $project
 	 	rm -rf SCM_COPY_FILES/
  		git clean -fd
  		git reset --hard HEAD
  		git checkout $git_branch
  		git pull origin $git_branch >>log.txt
  		#VAR=`strings log.txt | grep -i Already |awk -F' ' 'NR==1 {print $1}'` 
  		if [ "$VAR" = "Already" ] ; then
  			echo "**********git pull null**********"
         		exit
  		fi
  		if [ $? -ne 0 ] ; then
    			echo "**********git update error**********"
    			exit 1
  		fi
	else
  		git clone -b $git_branch ssh://maojialu@10.30.99.88:29418/$project
  		if [ $? -ne 0 ] ; then
    			echo "**********git clone error**********"
    			exit 2
  		fi
  		popd
	fi
}


function modify_version(){
	if [ ${MOD_VER} = "true" ] ; then
  	pushd ${PATHROOT}/${project}/LINUX/android/vendor/byd
  		Old_VER_NUM=`strings lenovo_buildinfo.mk | grep -i LENOVO_PRODUCT_VERSION_SHORT | awk -F'S' 'NR==1 {print $4}'`
  		echo ${Old_VER_NUM}
  		VER_TMP=S
  		Old_VER=${VER_TMP}${Old_VER_NUM}
  		echo ${Old_VER}
  		TMP_VER_NUM=`expr ${Old_VER_NUM} + 1`
  		NEXT_VER_NUM=`printf %06d ${TMP_VER_NUM}`
  		echo ${NEXT_VER_NUM}
  		NEXT_VER=${VER_TMP}${NEXT_VER_NUM}
  		echo ${NEXT_VER}
  		sed -i s/${Old_VER}/${NEXT_VER}/g lenovo_buildinfo.mk

  		git diff
  		git add ${PATHROOT}/${project}/LINUX/android/vendor/byd/lenovo_buildinfo.mk
  		git commit -m "Modfiy Version ${NEXT_VER}"
  		git status
  		git push origin ${git_branch}
	popd
	else
    		echo ---------Not Modify Version---------
	fi
}


function build_code(){
	pushd ${PATHROOT}/${project}/
		rm -rf build_target.cfg
		if [ ${LF1001QN_LTE_SKU1_ROW_USER} = "true" ];then
  			echo "target=msm8952_64-lte-row-sku1-user">>build_target.cfg
		else
  			echo  ""
		fi

		sed -i s/j8/j16/g mk
		./mk scm 2>&1 | tee build.log
  		if [ $? -ne 0 ] ; then
    			echo "**********make error**********"
    			exit 3
  		fi
	popd
}

function packing(){
	pushd ${PATHROOT}/${project}/LINUX/android/out/target/product/msm8952_64/system
		Pack_name=`strings build.prop | grep ro.build.lenovo.version.in | awk -F'=' 'NR==1 {print $2}'`
		echo ${Pack_name}
		EX_version=`strings build.prop | grep ro.build.lenovo.version.ex | awk -F'=' 'NR==1 {print $2}'`
		echo ${EX_version}
	popd
}

function make_zipfile(){
	packing
	if [ ${LF1001QN_LTE_SKU1_ROW_USER} = "true" ] ; then
		pushd ${PATHROOT}/${project}/SCM_COPY_FILES/msm8952_64_lte_row_sku1_user
  			zip -rq ${Pack_name}_OriginalFactory.zip sahara_images fuse_blow_data
  			zip -rq DEBUG_INFO.zip scm_debug_info dump_partitions_script
		popd
  		pushd ${PATHROOT}/${project}/SCM_COPY_FILES/msm8952_64_lte_row_sku1_user/multiflash_images
  			echo LTE_ROW_SKU1>version.txt
  			echo ${EX_version} >> version.txt
  			echo ${Pack_name} >> version.txt
  			zip -rq ${Pack_name}.zip ./*
		popd
  		pushd ${PATHROOT}/${project}/SCM_COPY_FILES/msm8952_64_lte_row_sku1_user/sd
  			mv msm8952_64-ota-*.zip ${Pack_name}_otafull.zip
  			mv msm8952_64-target_files-*.zip ${Pack_name}-target_files.zip
  		popd
	else
  		echo "goto next"
	fi
}


function ftpupload(){
packing
ftp -n 10.30.11.100 2>&1 <<EOC
  user sh@scm sh@scm
  binary
  cd ${Ftp_PATCH}
  mkdir ${Pack_name} 
  cd ${Pack_name}
  mkdir target
  cd target
  lcd ${PATHROOT}/${project}/SCM_COPY_FILES/msm8952_64_lte_row_sku1_user
  mkdir LTE_ROW_SKU1-USER
  cd LTE_ROW_SKU1-USER
  put ${Pack_name}_OriginalFactory.zip
  put DEBUG_INFO.zip
  lcd ${PATHROOT}/${project}/SCM_COPY_FILES/msm8952_64_lte_row_sku1_user/multiflash_images
  put ${Pack_name}.zip
  mkdir sd
  cd sd
  lcd ${PATHROOT}/${project}/SCM_COPY_FILES/msm8952_64_lte_row_sku1_user/sd
  put ${Pack_name}_otafull.zip
  put ${Pack_name}-target_files.zip
  bye
EOC

echo "Check ftp result"
  pushd ~
  ./mk_userdata_N_LTE_ROW_SKU1_USER.sh
echo "========== Image Already uploaded 99.100 ~(^_^)~"
}
##########################
function main(){
	clean_code
	modify_version
	build_code
	make_zipfile
	ftpupload
}

main "$@"
