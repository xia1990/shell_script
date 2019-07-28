#!/bin/bash
#为了一个人可以发布更快的发布300版本
options="$1"
cid="$2"
user=$(whoami)
ver_no=`cat version | head -n 1 | awk -F 'B' '{print $2}'`
UL_NO=$(cat version | sed -n 2p | awk -F '_|-' '{print $3}')
build_type=$(grep 'ro.build.type' out/target/product/E300L_WW/system/build.prop | head -1 | awk -F '=' '{print $2}')
function do_300_fota(){
auto_cid=('ASUS' 'ACJ' 'TIM')
    for cid in "${auto_cid[@]}"
    do
        echo -e "\e[40;32m$cid\e[0m"
        sed -i "s/CID=[A-Za-z0-9_]*/CID=${cid}/g" Auto_MSM89XX_E300L_V1.0.sh
        for target_file in `ls [0-9]*.zip`
        do
            if [ "$target_file" == "99.zip" ] 
            then
                echo "do $ver_no to  $target_file fota"
                mv "$target_file" update_c.zip
            else
                echo "do $target_file to $ver_no fota"
                mv "$target_file" update_a.zip
            fi
            echo -e "4\nY" | ./Auto_MSM89XX_E300L_V1.0.sh > fota.log 2>&1
    
            target_no=`echo "$target_file" | awk -F '.'  '{print $1}'`
            if [ "$target_file" == "99.zip" ] 
            then
                mv update_c.zip "$target_file"
                if [ -f "updateB2C.zip" ]
                then
                    mkdir ${cid}_fota > /dev/null 2&>1
                    mv updateB2C.zip "${cid}_fota/${ver_no}-99-${cid}-fota.zip"
                fi
            else
                mv update_a.zip "$target_file"
                if [ -f "updateA2B.zip" ]
                then
                    mkdir ${cid}_fota > /dev/null 2&>1
                    mv updateA2B.zip "${cid}_fota/${target_no}-${ver_no}-${cid}-fota.zip"
                fi
            fi
        done
    done

    for cid in "${auto_cid[@]}"
    do
        cp "$cid"_fota/* /data/mine/test/MT6572/"$user"/
    done
}

function do_TIM_H3G_WIND_VF_IT_UL(){
    target_file=`ls out/target/product/E300L_WW/obj/PACKAGING/target_files_intermediates/E300L_WW-*.zip -t | head -1`
    target_file_long_dir=`dirname $target_file`
    target_file_dir=`basename $target_file | awk -F '.zip' '{print $1}'`
    target_file_real_dir="$target_file_long_dir"/"$target_file_dir"
    echo $target_file
    echo $target_file_real_dir
    ./build/tools/releasetools/ota_from_target_files -v -c "$cid" -m ASUS_X00P --block --extracted_input_target_files "$target_file_real_dir" -p out/host/linux-x86 -k build/target/product/security/wind/releasekey "$target_file" E300L_"$cid"-$ver_no-ota.zip
    mv E300L_"$cid"-$ver_no-ota.zip UL-ASUS_X00P-"$cid"-"$UL_NO"-"$build_type".zip
    cp UL-ASUS_X00P-"$cid"-"$UL_NO"-"$build_type".zip /data/mine/test/MT6572/"$user"/
}

function do_JP_UL(){

    local -r old_value="ASUS-ASUS_X00P-WW"
    local -r new_value="ACJ-ASUS_X00P-WW"
        UL=`ls out/target/product/E300L_WW/E300L_WW-ota-*.zip -t | head -1`
        if [ -s "$UL" ]
        then
            cp "$UL" .
            base_UL=`basename "$UL"`
            local UL_old_name="$base_UL"
            rm -rf META-INF/
            mkdir -p META-INF/com/google/android/
            unzip -j "$UL_old_name" 'META-INF/com/google/android/updater-script' -d "META-INF/com/google/android/"
            sed -i "s/$old_value/$new_value/g" "META-INF/com/google/android/updater-script"
            zip "$UL_old_name" -f 'META-INF/com/google/android/updater-script'
            cp "$UL_old_name" ..
        fi

        uid_name=`whoami`
        sign_tool=out/host/linux-x86/framework/signapk.jar
        sign_key1=build/target/product/security/wind/releasekey.x509.pem
        sign_key2=build/target/product/security/wind/releasekey.pk8
        echo "please wait..."
            file_name=$(echo $base_UL | sed -r 's/\.zip$//i')
            java -Djava.library.path=out/host/linux-x86/lib64 -jar $sign_tool -w $sign_key1 $sign_key2 $base_UL ${file_name}_signed.apk
            mv ${file_name}_signed.apk UL-ASUS_X00P-JP-"$UL_NO"-"$build_type".zip
            cp UL-ASUS_X00P-JP-"$UL_NO"-"$build_type".zip /data/mine/test/MT6572/$uid_name/
            echo "sign $base_UL to ${file_name}_signed.apk done"
        echo "All done."


}

if [ "$options" == "fota" ]
then
    do_300_fota
elif [ "$options" == "ul" ]
then
    echo CID : $cid
    sleep 3s
    if [ "$cid" != 'ACJ' ]
    then
        do_TIM_H3G_WIND_VF_IT_UL
    elif [ "$cid" == "ACJ" ]
    then
        do_JP_UL
    fi

fi
