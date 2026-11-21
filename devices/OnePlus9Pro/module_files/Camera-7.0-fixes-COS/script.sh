# !/bin/bash
# Camera 7.0 fixes for ColorOS 17 ports on the OnePlus 9 Pro.
#
# Payload (taken from the OnePlus 15 CPH2747 EEA ColorOS 17 build):
#   my_product/app/OplusCamera/OplusCamera.apk        OplusCamera 17.0.16 (camera 7.0)
#   my_product/product_overlay/framework/*.jar         com.oplus.camera.unit.sdk(.adapter) 7.0
#   my_product/lib64/                                  JNI libs the camera loads that the
#                                                      port lacks (+ their deps)
#   my_product/etc/permissions/com.oplus.camera.unit.sdk.xml
#                                                      registers the SDK and
#                                                      androidx.camera.extensions.impl;
#                                                      product_overlay/etc is not merged
# The odm side stays the 9 Pro's own (Camera-5.0-fixes-ODM): its camera configs
# describe the 9 Pro sensors, the OnePlus 15 odm describes other hardware.
# The APK is 191 MB, over GitHub's 100 MB file limit, so the payload lives in a
# release and is downloaded + checksummed here.
camera7_url=https://github.com/ozyern/BrinaOS/releases/download/camera-7.0-fixes/Camera-7.0-fixes-COS.zip
camera7_sha256=1f1adf512ba801b52a9e87d6108d6d20f5702cd8bf13e736bfe6b5ecc696ac3b

if [[ ${port_android_version:-0} -lt 17 ]];then
    yellow "Camera 7.0 fixes are for ColorOS 17 ports -- skipping on Android ${port_android_version}"
    return 0
fi

camera7_cache=cache/Camera-7.0-fixes-COS
mkdir -p "${camera7_cache}"
if [[ ! -f "${camera7_cache}/files.zip" ]] || ! echo "${camera7_sha256}  ${camera7_cache}/files.zip" | sha256sum -c --status;then
    if ! curl -fL "${camera7_url}" -o "${camera7_cache}/files.zip" || \
       ! echo "${camera7_sha256}  ${camera7_cache}/files.zip" | sha256sum -c --status;then
        error "Camera 7.0 payload download failed or checksum mismatch -- skipping"
        rm -f "${camera7_cache}/files.zip"
        return 0
    fi
fi
rm -rf "${camera7_cache}/files"
unzip -oq "${camera7_cache}/files.zip" -d "${camera7_cache}/files"

# CN ColorOS 17 ships the camera as an APEX (my_product/apex, or system_ext/apex
# after the apexd scan fix). Same package name as the APK, so drop it.
find build/portrom/images -path "*/apex/*" \( -name "com.oplus.camera.app*.apex" -o -name "com.oplus.camera.app*.capex" \) -print -delete

rm -rf build/portrom/images/my_product/app/OplusCamera
rm -f build/portrom/images/my_product/product_overlay/framework/com.oplus.camera.*.jar
rm -f build/portrom/images/my_product/product_overlay/framework/oat/*/com.oplus.camera.*
cp -rf "${camera7_cache}/files/"* build/portrom/images/
green "Camera 7.0 (OplusCamera 17.0.16) installed with its unit SDK and JNI libs"
