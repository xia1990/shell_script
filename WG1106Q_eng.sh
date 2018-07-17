#!/bin/sh -x
#!/usr/bin/expcet


DATE=`date +%Y%m%d`
PATHROOT=$(pwd)
PROJECTAP="WG1106Q_AP"
PROJECTBP="WG1106Q_BP"
BRANCHAP="wg1106q_ap_32_dev"
BRANCHBP="wg1106q_bp_dev"
MODIFY_VER=false
VARNT=ENG
printer="printer58"


function clean_apCode(){
	if [ -d "$PROJECTAP" ];then
		pushd ${PATHROOT}/$PROJECTAP
			git clean -fd
			git checkout ./*
			if [ $? -ne 0 ];then
				echo "No Projcet Directory,Please Clone Or Update!!!"
				exit 0
			fi
			git pull
		popd
	else 
		git clone ssh://wangfan@10.30.99.88:29418/$PROJECTAP -b $BRANCHAP
	fi
}


function clean_bpCode(){
	if [ -d "$PROJECTBP" ];then
		pushd ${PATHROOT}/$PROJECTAP
			git clean -fd
			git checkout ./*
			if [ $? -ne 0 ];then
				echo "No Projcet Directory,Please Clone Or Update!!!"
				exit 0
			fi
			git pull
    		popd
	else 
		git clone ssh://wangfan@10.30.99.88:29418/$PROJECTBP -b $BRANCHBP
	fi
}

####################Modify Version###################
function modify_version(){
	pushd ${PATHROOT}/$PROJECTAP/LINUX/android/build/tools/
		NOW_NUM=`strings byd_buildinfo.mk | grep -i OEM_PRODUCT_VERSION_SHORT | awk -F ' ' 'NR==1 {print $3}'`
		echo $NOW_NUM
		OLD_VER=S${NOW_NUM}
		if [ $MODIFY_VER = true ];then
  			TMP_NUM=`expr ${NOW_NUM} + 1`
			echo $TMP_NUM
			NEXT_NUM=`printf %06d ${TMP_NUM}`
			NEXT_VER=S${NEXT_NUM} 
    			sed -i s/${NOW_NUM}/${NEXT_NUM}/g byd_buildinfo.mk
			git add byd_buildinfo.mk
			git commit -m "Modify Version ${NEXT_VER}"
			git push origin $BRANCHAP
		else
			echo "Do Not Modify Version"
      	    		NEXT_VER=${OLD_VER}
		fi
	popd
}
######################################################
function building(){
	pushd ${PATHROOT}/$PROJECTBP
		if [ $VARNT = USER ];then
			echo "target=msm8916_32-t1host-global-${printer}-user">> build_target.cfg
		else
			echo "target=msm8916_32-t1host-global-${printer}-eng" >> build_target.cfg
		fi
	
		ln -s ${PATHROOT}/$PROJECTAP/LINUX LINUX
		./mk scm 2>&1 | tee buildlog.txt
		if [ $? -ne 0 ];then
			echo "Build Error,Please Check!!!"
		else
    			echo "Congratulations, Build Success!!!"
		fi
	popd
}

#######################
function packing(){
	pushd ${PATHROOT}/$PROJECTAP/LINUX/android/build/tools/
                NEXT_VER=S`strings byd_buildinfo.mk | grep -i OEM_PRODUCT_VERSION_SHORT | awk -F ' ' 'NR==1 {print $3}'`
                echo $NEXT_VER
	popd
}

###########################
function make_zipfile(){
	packing
	if [ $VARNT = USER ];then
		pushd ${PATHROOT}/$PROJECTBP/SCM_COPY_FILES/msm8916_32_t1host_global_${printer}_user
			zip -r9 WG1106Q_${VARNT}_${NEXT_VER}_${DATE}_OriginalFactory.zip fuse_blow_data sahara_images
			zip -r9 scm_integrated_for_3rd.zip scm_integrated_for_3rd
			zip -r9 DEBUGINFO.zip scm_debug_info
		popd
		
		pushd ${PATHROOT}/$PROJECTBP/SCM_COPY_FILES/msm8916_32_t1host_global_${printer}_user/multiflash_images
			zip -r9 WG1106Q_${VARNT}_${NEXT_VER}_${DATE}.zip ./*
		popd
	else
		pushd ${PATHROOT}/$PROJECTBP/SCM_COPY_FILES/msm8916_32_t1host_global_${printer}_eng
			zip -r9 WG1106Q_${VARNT}_${NEXT_VER}_${DATE}_OriginalFactory.zip fuse_blow_data sahara_images
			zip -r9 scm_integrated_for_3rd.zip scm_integrated_for_3rd
			zip -r9 DEBUGINFO.zip scm_debug_info
		popd
	
		pushd ${PATHROOT}/$PROJECTBP/SCM_COPY_FILES/msm8916_32_t1host_global_${printer}_eng/multiflash_images
			zip -r9 WG1106Q_${VARNT}_${NEXT_VER}_${DATE}.zip ./*
		popd
	fi
}

function ftp_upload(){
	Ftp_PATCH=Qualcomm/8039/WG1106Q
	packing

ftp -n 10.30.11.100 2>&1 <<EOC
  user sh@scm sh@scm
  binary
  cd ${Ftp_PATCH}
  mkdir WG1106Q_${VARNT}_${NEXT_VER}_${DATE}
  cd WG1106Q_${VARNT}_${NEXT_VER}_${DATE}
  mkdir target
  cd target
  mkdir $VARNT
  cd $VARNT
  lcd ${PATHROOT}/$PROJECTBP/SCM_COPY_FILES/msm8916_32_t1host_global_${printer}_eng/multiflash_images
  put WG1106Q_${VARNT}_${NEXT_VER}_${DATE}.zip
  lcd ${PATHROOT}/$PROJECTBP/SCM_COPY_FILES/msm8916_32_t1host_global_${printer}_eng
  put WG1106Q_${VARNT}_${NEXT_VER}_${DATE}_OriginalFactory.zip
  put scm_integrated_for_3rd.zip
  put DEBUGINFO.zip
bye
EOC

echo "11.100 Ftp upload complete"
}

############# MAIN ##################
function main(){
	#clean_apCode
	#clean_bpCode
	#modify_version
	#building
	#make_zipfile
	ftp_upload
}
main "$@"
