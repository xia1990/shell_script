#!/bin/bash -x
#!/usr/bin/expect

#########################################
#$PROJECT:项目名称						
#$BRANCH:分支名称						
#$$LUNCH:编译生成的lunch
#$TYPE:要编译的版本类型					
#########################################

PATH=~/rar:$PATH
PATHROOT=$(pwd)
Date=`date +%Y%m%d`
PROJECT=IVI-820A
Ftp_PATCH="./Qualcomm/8996/IVI820A/"
BRANCH=ivi820a_7.1_dev
#传入当前版本号
old_version=$1

#cd ../../../../../tmp/
#rm -rf *
#cd -

function arg_parse(){
	if [ "$PROJECT" == "IVI-820A" ];then
 		echo ""
	else
		echo "项目名称错误！"
		exit
	fi

	if [ "$BRANCH" == "ivi820a_7.1_dev" ];then
		echo ""
	else
		echo "分支名称错误！"
		exit
	fi

	if [ "$Ftp_PATCH" == "./Qualcomm/8996/IVI820A/" ];then
		echo ""
	else
		echo "FTP路径错误！"
		exit
	fi
}

function clean_code(){
	if [ -d $PROJECT ] ;then
        pushd $PROJECT
        	rm  -rf  SCM_COPY_FILES
            	git clean -fd
           	git reset --hard HEAD 
            	git checkout $BRANCH
            	git pull origin $BRANCH >>log.txt
		if [ -s log.txt ] && [ -z log.txt ];then
			git pull origin $git_branch >>log.txt
		fi
            	#VAR=`strings log.txt | grep -i Already |awk -F' ' 'NR==1 {print $1}'` 
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
		git clone -b $BRANCH ssh://wangfan@10.30.99.88:29418/$PROJECT
	    	if [ $? -eq 0 ] ; then
			echo "git clone code  sucessfully"
		  	exit 1
	    	fi   
	fi
}


function build_code(){
	pushd "$PATHROOT"/$PROJECT
		#rm -rf build_target.cfg
		#if [ ${TYPE} = "USER" ] ; then
			#echo "target=msm8996-user" >> build_target.cfg
		#elif [ ${TYPE} = "USERDEBUG" ];then
			#echo "target=msm8996-userdebug" >> build_target.cfg
		#else
			#echo "No Version--"
		#fi

 	       #sed -i s/j8/j16/g mk
       	       	./mk scm 2>&1 | tee -a build.log
        	if [ "$?" -eq 0 ];then
            		echo "All Project Build success!"
        	fi	
    	popd
}


function packing(){
	echo $old_version
	up_version=$old_version
	new_version=`expr $up_version + 1`
	VERSION=`printf %03d $new_version`
	echo $VERSION
	Pack_name=IVI820A_V${VERSION}_${TYPE}_$Date
	echo $Pack_name
	Target_name=IVI820A_V${VERSION}_$Date
	echo $Target_name
}


function make_zipfile(){
	packing
	echo $Pack_name
	echo "Ready to pack"
	if [ $TYPE = "USERDEBUG" ] ; then
		pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/$LUNCH
			zip -9 -r ${Pack_name}_OriginalFactory.zip sahara_images fuse_blow_data
			zip -9 -r DEBUG_INFO.zip scm_debug_info
			pushd "$PATHROOT"/images/
                                rm -rf *.bin
                                rm -rf *.elf
                                rm -rf *.mbn
                                rm -rf *.img
								rm -rf *.zip
                        popd
			pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/$LUNCH/multiflash_images
				cp *.bin "$PATHROOT"/images/
				cp *.elf "$PATHROOT"/images/
				cp *.mbn "$PATHROOT"/images/
				cp *.img "$PATHROOT"/images/
				pushd "$PATHROOT"/images/
					zip -9 -r ${Pack_name}.zip ./*  
				popd
			popd
		popd
	elif [ $TYPE = "USER" ] ; then
		pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/$LUNCH
			zip -9 -r ${Pack_name}_OriginalFactory.zip sahara_images fuse_blow_data
			zip -9 -r DEBUG_INFO.zip scm_debug_info
			pushd "$PATHROOT"/images/
				rm -rf *.bin
				rm -rf *.elf
				rm -rf *.mbn
				rm -rf *.img
				rm -rf *.zip
			popd
			pushd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/$LUNCH/multiflash_images
				cp *.bin "$PATHROOT"/images/
				cp *.elf "$PATHROOT"/images/
				cp *.mbn "$PATHROOT"/images/
				cp *.img "$PATHROOT"/images/
				pushd "$PATHROOT"/images/
					zip -9 -r ${Pack_name}.zip ./*  
				popd
			popd
		  popd
	else	
		echo "goto next-------"
	fi
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
	lcd "$PATHROOT"/$PROJECT/SCM_COPY_FILES/$LUNCH
	mkdir $TYPE
	cd $TYPE
	put ${Pack_name}_OriginalFactory.zip
	put DEBUG_INFO.zip
	lcd "$PATHROOT"/images/
	put ${Pack_name}.zip
	bye
EOC
echo "11.100 Ftp upload complete"
}


################## main #################
function main(){
	arg_parse
	if [ $# -eq 1 ];then
		clean_code
		build_code
    		make_zipfile
		ftp_upload    
	else
		echo "请输入版本号"
	fi
}

main "$@"
