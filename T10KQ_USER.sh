#!/bin/bash -x
#!/usr/bin/expect

PATH=~/rar:$PATH

PATHROOT=$(pwd)
PROJECT=T10KQ
BRANCH=FA85_r26000dev
DATE=`date +%Y%m%d`
Ftp_PATCH="./Qualcomm/8953/T10KQ/"
MOD_VER=false
TYPE=USERDEBUG

#cd ../../../../../tmp/
#rm -rf *
#cd -

function clean_code(){
	if [ -d $PROJECT ] ;then
     	pushd $PROJECT
	       	rm  -rf  SCM_COPY_FILES
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
     	popd 
	else
		git clone -b $BRANCH ssh://maojialu@10.30.99.88:29418/$PROJECT
	    	if [ $? -eq 0 ] ; then
	        	echo "git clone code  sucessfully"
		  	exit 1
	 	fi   
	fi
}

################ Modify Version 修改版本号函数 ######################
function change_version_number(){
	version_file="$1"
	if [ "$#" -eq 0 ];then
		echo "no arg"
		exit
	fi
	if [ -s "$version_file" ];then
		VER=$(grep -i "SUPPLIER_PRODUCT_VERSION_SHORT.*:=" $version_file | awk -F'S' '{print $NF}')
		echo $VER
		T=S
		OLD_VER=${T}${VER}
		echo $OLD_VER
		VER_1=`expr $VER + 1`
		NEXT_VER=`printf %03d ${VER_1}`
		echo $NEXT_VER
		NEW_VER=${T}${NEXT_VER}
		echo $NEW_VER
		sed -i s/${OLD_VER}/${NEW_VER}/g $version_file
	else
		echo "not modified version"
	fi
}

################ Modify Version #######################
function modify_versionNumber(){
	if [ ${MOD_VER} = "true" ] ; then
    	pushd  "$PATHROOT"/$PROJECT/LINUX/android/build/tools
    		change_version_number "supplier_buildinfo.mk"
    		NEXT_VER=$(grep -i "SUPPLIER_PRODUCT_VERSION_SHORT.*:=" supplier_buildinfo.mk  | awk '{print $NF}')
    		git diff
    		git add supplier_buildinfo.mk
    		git commit -m "Modfiy Version to ${NEXT_VER}"
  
    		git status
    		git push origin ${BRANCH}
    		git branch -av | tee -a push_branch.txt 
  	  	if [ $? -eq 0 ];then
        		echo "push version number sucessfull"
    		else
          		echo "push error"
    		fi
        popd
	else
      		echo ---------Not Modify Version---------
	fi
}
##################################
function build_code(){
	pushd "$PATHROOT"/$PROJECT
  	rm -rf build_target.cfg
  	if [ ${TYPE} = "USERDEBUG" ] ; then
     		echo "target=msm8953_64-userdebug" >> build_target.cfg
  	elif [ ${TYPE} = "USER" ];then
      		echo "target=msm8953_64-user" >> build_target.cfg
  	elif [ ${TYPE} = "ENG" ];then
      		echo "target=msm8953_64-eng" >> build_target.cfg
  	else
      		echo  "no type"
 	fi

  	sed -i s/j8/j16/g mk
  	./mk scm 2>&1 | tee build.log
    	if [ $? -ne 0 ] ; then
      		echo "**********make error**********"
      		exit 3
    	fi
  	echo "All Project Build success!"
	popd             
}



###############################
function package_name(){
	pushd  "$PATHROOT"/$PROJECT/LINUX/android/build/tools
	NEXT_VER=$(grep -i "SUPPLIER_PRODUCT_VERSION_SHORT.*:=" supplier_buildinfo.mk | awk '{print $NF}')
    	if [ $TYPE = "USER" ];then
        	Pack_name=FA85_USER_${NEXT_VER}_${DATE}
		echo ${Pack_name}
		PACK_NAME=FA85_${NEXT_VER}_${DATE}
		echo ${PACE_NAME}
	    elif [ $TYPE = "USERDEBUG" ];then
    		Pack_name=FA85_USERDEBUG_${NEXT_VER}_${DATE}
		echo ${Pack_name}
		PACK_NAME=FA85_${NEXT_VER}_${DATE}
		echo ${PACK_NAME}
    	elif [ $TYPE = "ENG" ];then
    		Pack_name=FA85_ENG_${NEXT_VER}_${DATE}
		echo ${Pack_name}
		PACK_NAME=FA85_${NEXT_VER}_${DATE}
		echo ${PACK_NAME}
    	else
    		echo ""
    	fi	
	popd
}

function pack_code(){
	package_name
	echo "Ready to pack"
	if [ $TYPE = "USER" ];then
		pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_user
			zip -9 -r ${Pack_name}_OriginalFactory.zip sahara_images fuse_blow_data
			zip -9 -r DEBUG_INFO.zip scm_debug_info 
		popd
		pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_user/multiflash_images			
			zip -9 -r ${Pack_name}.zip ./*  
		popd
		pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_user/sd
			mv msm8953_64-ota-*.zip ${Pack_name}_otafull.zip
			mv msm8953_64-target_files-*.zip ${Pack_name}-target_files.zip
		popd
	elif [ $TYPE = "USERDEBUG" ];then
     		pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_userdebug
			zip -9 -r ${Pack_name}_OriginalFactory.zip sahara_images fuse_blow_data
			zip -9 -r DEBUG_INFO.zip scm_debug_info 
		popd
		pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_userdebug/multiflash_images			
			zip -9 -r ${Pack_name}.zip ./*  
		popd
		pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_userdebug/sd
			mv msm8953_64-ota-*.zip ${Pack_name}_otafull.zip
			mv msm8953_64-target_files-*.zip ${Pack_name}-target_files.zip
		popd
	elif [ $TYPE = "ENG" ];then
     		pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_eng
			zip -9 -r ${Pack_name}_OriginalFactory.zip sahara_images fuse_blow_data
			zip -9 -r DEBUG_INFO.zip scm_debug_info 
		popd
		pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_eng/multiflash_images			
			zip -9 -r ${Pack_name}.zip ./*  
		popd
		pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_eng/sd
			mv msm8953_64-ota-*.zip ${Pack_name}_otafull.zip
			mv msm8953_64-target_files-*.zip ${Pack_name}-target_files.zip
		popd
     	else
		echo "goto next-------"
	fi
}


#######################################
function ftp_upload(){
package_name
if [ $TYPE = "USER" ];then
ftp -n 10.30.11.100 2>&1 <<EOC
	user sh@scm sh@scm
	binary
	cd ${Ftp_PATCH}
	mkdir ${Pack_name} 
	cd ${Pack_name}
	mkdir target
	cd target
	lcd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_user
	mkdir USER
	cd USER
	put ${PACK_NAME}_OriginalFactory.zip
	put DEBUG_INFO.zip
	lcd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_user/multiflash_images
	put ${PACK_NAME}.zip
	mkdir sd
	cd sd
	lcd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_user/sd
	put ${PACK_NAME}_otafull.zip
	put ${PACK_NAME}-target_files.zip
	bye
EOC
elif [ $TYPE = "USERDEBUG" ];then
ftp -n 10.30.11.100 2>&1 <<EOC
	user sh@scm sh@scm
	binary
	cd ${Ftp_PATCH}
	mkdir ${Pack_name} 
	cd ${Pack_name}
	mkdir target
	cd target
	lcd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_userdebug
	mkdir USERDEBUG
	cd USERDEBUG
	put ${PACK_NAME}_OriginalFactory.zip
	put DEBUG_INFO.zip
	lcd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_userdebug/multiflash_images
	put ${PACK_NAME}.zip
	mkdir sd
	cd sd
	lcd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_userdebug/sd
	put ${PACK_NAME}_otafull.zip
	put ${PACK_NAME}-target_files.zip
	bye
EOC
elif [ $TYPE = "ENG" ];then
ftp -n 10.30.11.100 2>&1 <<EOC
	user sh@scm sh@scm
	binary
	cd ${Ftp_PATCH}
	mkdir ${Pack_name} 
	cd ${Pack_name}
	mkdir target
	cd target
	lcd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_eng
	mkdir ENG
	cd ENG
	put ${PACK_NAME}_OriginalFactory.zip
	put DEBUG_INFO.zip
	lcd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_eng/multiflash_images
	put ${PACK_NAME}.zip
	mkdir sd
	cd sd
	lcd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/msm8953_64_eng/sd
	put ${PACK_NAME}_otafull.zip
	put ${PACK_NAME}-target_files.zip
	bye
EOC
else
	go to next-------
fi
echo "11.100 Ftp upload complete"
}

################## main #################
function main(){
	clean_code
        modify_versionNumber
   	build_code
        pack_code  
	ftp_upload
}
main "$@"
