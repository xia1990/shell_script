#!/bin/bash -x
#!/usr/bin/expect

PATH=~/rar:$PATH

PATHROOT=$(pwd)
Date=`date +%Y%m%d`
PROJECT=T10_LA1.1.1_Branch
#BRANCH=t10_LA1.1.1_dev
BRANCH=t10_LA1.1.1_dev_nj
#FTP_PATCH="./Qualcomm/8976/T10_LA1.1.1_Branch/"
FTP_PATCH="./Qualcomm/8976/T10_LA1.1.1_Branch/t10_LA1.1.1_dev_nj/"
MOD_VER=false
T10_LA1_Branch_USER=true

#cd ../../../../../tmp/
#rm -rf *
#cd -

function clean_code(){
if [ -d $PROJECT ];then
	pushd $PROJECT 
    	rm -rf SCM_COPY_FILES/
   	git clean -fd
    	git reset --hard HEAD
    	git checkout $BRANCH
    	git pull origin $BRANCH >>log.txt
    	if [ $? -ne 0 ];then
        	git pull origin $BRANCH >>log.txt
    	fi  
    	VAR=`strings log.txt | grep -i Already |awk -F' ' 'NR==1 {print $1}'` 
    	if [ "$VAR" = "Already" ] ; then
        	echo "**********git pull null**********"
        	exit 
    	fi
    	if [ $? -ne 0 ] ; then
      		echo "**********git update error**********"
      		exit 1
    	fi
else
  	git clone -b $git_branch ssh://gaoyuxia@10.30.99.88:29418/$project
  	if [ $? -ne 0 ] ; then
    		echo "**********git clone error**********"
    		exit 2
  	fi
  	popd $PROJECT
fi
}

################ Modify Version ######################
change_version_number(){
	if [ "$#" -eq 0 ];then
		echo "no args"
		exit 1
	fi
	version_number_file="$1"	
	if [ -s "$version_number_file" ];then
		gw=$(grep -i "PRODUCT_POINT_VERSION.*:=" "$version_number_file" | awk '{print $NF}')
		gw_1=$((gw+1))
		sed -i "s/PRODUCT_POINT_VERSION.*:=.*/PRODUCT_POINT_VERSION\ :=\ ${gw_1}/g" "$version_number_file"
	else
		echo "$version_number_file not found"
		exit 1
	fi    
}
################ Modify Version #######################

function modify_version(){
	if [ ${MOD_VER} = "true" ] ; then
  		pushd "$PATHROOT"/$PROJECT/LINUX/android/build/tools
  		change_version_number "supplier_buildinfo.mk"
  		PRODUCT_MAJOR_VERSION=$(grep -i "PRODUCT_MAJOR_VERSION.*:=" "supplier_buildinfo.mk" | awk '{print $NF}')
  		PRODUCT_MINOR_VERSION=$(grep -i "PRODUCT_MINOR_VERSION.*:=" "supplier_buildinfo.mk" | awk '{print $NF}')
  		PRODUCT_POINT_VERSION=$(grep -i "PRODUCT_POINT_VERSION.*:=" "supplier_buildinfo.mk" | awk '{print $NF}')
  		PRODUCT_STAGE=$(grep -i "PRODUCT_STAGE.*:=" "supplier_buildinfo.mk" | awk '{print $NF}')
  		Date=`date +%Y%m%d`
  		SUPPLIER_VERSION_EXTERNAL=${PRODUCT_MAJOR_VERSION}.${PRODUCT_MINOR_VERSION}.${PRODUCT_POINT_VERSION}.${Date}_${PRODUCT_STAGE}
  		echo ${SUPPLIER_VERSION_EXTERNAL}
  		NEXT_VER=${SUPPLIER_VERSION_EXTERNAL}
  		echo ${NEXT_VER}
		popd
  	
  		git diff
 		git add "$PATHROOT"/$PROJECT/LINUX/android/build/tools/supplier_buildinfo.mk
  		git commit -m "Modfiy Version ${NEXT_VER}"

  		git status
  		git push origin ${BRANCH}
 	 	if [ $? -eq 0 ];then
  			echo "push version number sucessfull"
 	 	else
  			echo "push error"
 		fi
	else
 		echo ---------Not Modify Version---------
	fi
}

function building(){
	pushd "$PATHROOT"/$PROJECT
	rm -rf build_target.cfg
	if [ ${T10_LA1_Branch_USER} = "true" ] ; then
		echo "target=msm8952_64-lte-prc-none-user" >> build_target.cfg
	else
		echo  "No LTE PRC ENG Version"
	fi

	sed -i s/j8/j16/g mk
	./mk scm 2>&1 | tee build.log
	if [ $? -ne 0 ] ; then
		echo "**********make error**********"
    		exit 3
	fi

	echo "All Project Build success!"
}


function packing(){
	pushd "$PATHROOT"/$PROJECT/LINUX/android/out/target/product/msm8952_64/system
	Pack_name=`strings build.prop | grep ro.build.supplier.version.in | awk -F'=' 'NR==1 {print $2}'`
	echo ${Pack_name}
	EX_version=`strings build.prop | grep ro.build.supplier.version.ex | awk -F'=' 'NR==1 {print $2}'`
	echo ${EX_version}
	popd
}


function make_zipfile(){
	packing
	echo "Ready to pack"
	if [ ${T10_LA1_Branch_USER} = "true" ] ; then
	pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8952_64_lte_prc_none_user
  		zip -9 -r ${Pack_name}_OriginalFactory.zip sahara_images fuse_blow_data
  		zip -9 -r DEBUG_INFO.zip scm_debug_info 
	popd
	pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8952_64_lte_prc_none_user/multiflash_images
  		echo "LTE_PRC_USER" >> version.txt
		echo ${EX_version} >> version.txt
 		echo ${Pack_name} >> version.txt
  		zip -9 -r ${Pack_name}.zip ./*  
	popd
	pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8952_64_lte_prc_none_user/sd
  		mv msm8952_64-ota-*.zip ${Pack_name}_otafull.zip
 		mv msm8952_64-target_files-*.zip ${Pack_name}-target_files.zip
	popd
	else
  		echo "goto next"
	fi
}

function ftp_upload(){
packing
ftp -n 10.30.11.100 2>&1 <<EOC
  user sh@scm sh@scm
  binary
  cd ${FTP_PATCH}
  mkdir ${Pack_name} 
  cd ${Pack_name}
  mkdir target
  cd target
  lcd  "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8952_64_lte_prc_none_user
  mkdir LTE_PRC
  cd LTE_PRC
  mkdir USER
  cd USER
  put ${Pack_name}_OriginalFactory.zip
  put DEBUG_INFO.zip
  lcd   "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8952_64_lte_prc_none_user/multiflash_images
  put ${Pack_name}.zip
  mkdir sd
  cd sd
  lcd   "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8952_64_lte_prc_none_eng/sd
  put ${Pack_name}_otafull.zip
  put ${Pack_name}-target_files.zip
  bye
EOC

echo
echo "11.100 Ftp upload complete"
echo
}

############################
function main(){
	#clean_code
   	#modify_version
    	#building
	make_zipfile
    	#ftp_upload
}
main "$@"
