::备份W1401Q版本
::从H:\swbackup\Qualcomm\8039\Wi1401Q\备份到F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\下

set target_file=Wi1401q_S000067_t1host_20161102
set version=S000067
set date=20161102

::t1host
set t1host_image_file_eng=Wi1401q_t1host_local_%version%_eng_%date%_image.zip
set t1host_modem_file_eng=Wi1401q_t1host_local_%version%_eng_%date%_modem_image.zip
set t1host_original_file_eng=Wi1401q_t1host_local_%version%_eng_%date%_OriginalFactory.zip
set t1host_image_file_user=Wi1401q_t1host_local_%version%_user_%date%_image.zip
set t1host_modem_file_user=Wi1401q_t1host_local_%version%_user_%date%_modem_image.zip
set t1host_original_file_user=Wi1401q_t1host_local_%version%_user_%date%_OriginalFactory.zip

::t1sub14
set t1sub14_image_file_eng=Wi1401q_t1sub14_local_%version%_eng_%date%_image.zip
set t1sub14_modem_file_eng=Wi1401q_t1sub14_local_%version%_eng_%date%_modem_image.zip
set t1sub14_original_file_eng=Wi1401q_t1sub14_local_%version%_eng_%date%_OriginalFactory.zip
set t1sub14_image_file_user=Wi1401q_t1sub14_local_%version%_user_%date%_image.zip
set t1sub14_modem_file_user=Wi1401q_t1sub14_local_%version%_user_%date%_modem_image.zip
set t1sub14_original_file_user=Wi1401q_t1sub14_local_%version%_user_%date%_OriginalFactory.zip

::t1host_global
set t1host_global_image_file_eng=Wi1401q_t1host_global_%version%_eng_%date%_image.zip
set t1host_global_modem_file_eng=Wi1401q_t1host_global_%version%_eng_%date%_modem_image.zip
set t1host_global_original_file_eng=Wi1401q_t1host_global_%version%_eng_%date%_OriginalFactory.zip
set t1host_global_image_file_user=Wi1401q_t1host_global_%version%_user_%date%_image.zip
set t1host_global_modem_file_user=Wi1401q_t1host_global_%version%_user_%date%_modem_image.zip
set t1host_global_original_file_user=Wi1401q_t1host_global_%version%_user_%date%_OriginalFactory.zip


CD H:\swbackup\Qualcomm\8039\Wi1401Q
MKDIR %target_file%
CD %target_file%
MKDIR Release
CD Release
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\Release\Wi1401q_t1host_local_000067_20161202_Release_Notes.doc .
CD ../
MKDIR target
CD target
MKDIR t1host
CD t1host
MKDIR ENG
CD ENG
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host\ENG\DEBUG_INFO.zip .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host\ENG\%t1host_image_file_eng% .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host\ENG\%t1host_modem_file_eng% .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host\ENG\%t1host_original_file_eng% .
MKDIR sd
CD sd
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host\ENG\sd\msm8916_64-ota-eng.yinjigang.zip .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host\ENG\sd\msm8916_64-target_files-eng.yinjigang.zip .
CD ../../
MKDIR USER
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host\USER\DEBUG_INFO.zip .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host\USER\%t1host_image_file_user% .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host\USER\%t1host_modem_file_user% .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host\USER\%t1host_original_file_user% .
MKDIR sd
CD sd
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host\ENG\sd\msm8916_64-ota-user.yinjigang.zip .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host\ENG\sd\msm8916_64-target_files-user.yinjigang.zip .
CD ../../../../

::::::::::::::::::::::::::::::::
MKDIR t1sub14
CD t1sub14
MKDIR ENG
CD ENG
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1sub14\ENG\DEBUG_INFO.zip .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1sub14\ENG\%t1sub14_image_file_eng% .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1sub14\ENG\%t1sub14_modem_file_eng% .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1sub14\ENG\%t1sub14_original_file_eng% .
MKDIR sd
CD sd
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1sub14\ENG\sd\msm8916_64-ota-eng.yinjigang.zip .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1sub14\ENG\sd\msm8916_64-target_files-eng.yinjigang.zip .

CD ../../
MKDIR USER
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1sub14\USER\DEBUG_INFO.zip .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1sub14\USER\%t1sub14_image_file_user% .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1sub14\USER\%t1sub14_modem_file_user% .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1sub14\USER\%t1sub14_original_file_user% .
MKDIR sd
CD sd
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1sub14\ENG\sd\msm8916_64-ota-user.yinjigang.zip .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1sub14\ENG\sd\msm8916_64-target_files-user.yinjigang.zip .
CD ../../../../

::::::::::::::::::::::::::::::::
MKDIR t1host_global
CD t1host_global
MKDIR ENG
CD ENG
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host_global\ENG\DEBUG_INFO.zip .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host_global\ENG\%t1host_global_image_file_eng% .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host_global\ENG\%t1host_global_modem_file_eng% .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host_global\ENG\%t1host_global_original_file_eng% .
MKDIR sd
CD sd
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host_global\ENG\sd\msm8916_64-ota-eng.yinjigang.zip .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host_global\ENG\sd\msm8916_64-target_files-eng.yinjigang.zip .
CD ../../
MKDIR USER
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host_global\USER\DEBUG_INFO.zip .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host_global\USER\%t1host_global_image_file_user% .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host_global\USER\%t1host_global_modem_file_user% .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host_global\USER\%t1host_global_original_file_user% .
MKDIR sd
CD sd
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host_global\ENG\sd\msm8916_64-ota-user.yinjigang.zip .
COPY F:\sw_public\Project_Release\Qualcomm\8039\Wi1401Q\%target_file%\target\t1host_global\ENG\sd\msm8916_64-target_files-user.yinjigang.zip .
CD ../../../../