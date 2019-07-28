#!/bin/bash
function 260_sign_UL(){
    local -r old_value="$1"
    local -r new_value="$2"
    pushd back_up_version_temp_*
        local UL_COUNT=$(ls UL* | wc -l)
        if [ "$UL_COUNT" -eq 1 ]
        then
            local UL_old_name=$(ls UL*)
            rm -rf META-INF/
            mkdir -p META-INF/com/google/android/
            unzip -j "$UL_old_name" 'META-INF/com/google/android/updater-script' -d "META-INF/com/google/android/"
            sed -i "s/$old_value/$new_value/g" "META-INF/com/google/android/updater-script"
            zip "$UL_old_name" -f 'META-INF/com/google/android/updater-script'
            cp "$UL_old_name" ..
        else
            return 0
        fi
    popd
    sign_tool=out/host/linux-x86/framework/signapk.jar
    sign_key1=device/mediatek/common/security/E260L/releasekey.x509.pem
    sign_key2=device/mediatek/common/security/E260L/releasekey.pk8
    echo "please wait..."
        file_name=$(echo "$UL_old_name" | sed -r 's/\.zip$//i')
        java -Djava.library.path=out/host/linux-x86/lib64 -jar $sign_tool -w $sign_key1 $sign_key2 $UL_old_name ${file_name}_signed.zip
#        cp ${file_name}_signed.zip /data/mine/test/$USER/
        echo "sign $file to ${file_name}_signed.zip done"
    echo "All done."
}

260_sign_UL "ASUS-ASUS_X018DC-CN" "CMCC-ASUS_X018DC-CN"
