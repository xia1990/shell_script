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
  		pushd ${PATHROOT}/${project}/SCM_COPY_FILES/msm8952_64_lte_row_sku1_user/sd
  			mv msm8952_64-target_files-*.zip ${Pack_name}-target_files.zip
			cp ${Pack_name}-target_files.zip ~/Target_FILES
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
  mkdir LTE_ROW_SKU1-USER
  cd LTE_ROW_SKU1-USER
  mkdir sd
  cd sd
  mkdir fake
  cd fake
  lcd ${PATHROOT}/${project}/SCM_COPY_FILES/msm8952_64_lte_row_sku1_user/sd
  put ${Pack_name}-target_files.zip
  bye
EOC

echo "假包上传成功"
echo "========== Image Already uploaded 11.100 ~(^_^)~"
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
