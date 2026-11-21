# !/bin/bash
# Camera 7.0 fixes for ColorOS 17 ports on the OnePlus 9 Pro.
#
# 1) Port ships the camera as an APEX (ColorOS 17 CN: com.oplus.camera.app.apex)
#    The APEX never works on our odm: inside its linker namespace libstdc++.so,
#    libAlgo* and friends can't be resolved (UnsatisfiedLinkError
#    libCombineLutJni.so). Its contents work fine as a normal system app, so
#    unpack it at build time and install:
#      app/OplusCamera/OplusCamera.apk  -> my_product/app/OplusCamera/        (7.012.x, ColorOS flavor:
#                                                                             thumbnail opens com.coloros.gallery3d)
#      lib64/*.so (40 libs)             -> my_product/app/OplusCamera/lib/arm64/  (app native lib dir)
#      javalib/com.oplus.camera.unit.sdk.jar -> my_product/product_overlay/framework/
#    and register the SDK from my_product/product_overlay/etc/permissions.
#    Verified on device: the 40 APEX libs in the camera's lib dir fix the
#    UnsatisfiedLinkErrors, and product_overlay/etc/permissions is where the
#    SDK registration has to live (my_product/etc/permissions is never read).
#
# 2) No camera APEX (e.g. a OnePlus/global port)
#    Payload from the OnePlus 15 CPH2747 EEA build (release camera-7.0-fixes):
#    OplusCamera 17.0.16 (7.006.x, OnePlus flavor: thumbnail opens
#    com.oneplus.gallery), its unit SDK jars, JNI libs and the SDK registration.
#
# The odm side stays the 9 Pro's own (Camera-5.0-fixes-ODM): its camera configs
# describe the 9 Pro sensors.
camera7_url=https://github.com/ozyern/BrinaOS/releases/download/camera-7.0-fixes/Camera-7.0-fixes-COS.zip
camera7_sha256=1f1adf512ba801b52a9e87d6108d6d20f5702cd8bf13e736bfe6b5ecc696ac3b

if [[ ${port_android_version:-0} -lt 17 ]];then
    yellow "Camera 7.0 fixes are for ColorOS 17 ports -- skipping on Android ${port_android_version}"
    return 0
fi

camera7_img=build/portrom/images
camera7_app=${camera7_img}/my_product/app/OplusCamera
camera7_fw=${camera7_img}/my_product/product_overlay/framework
camera7_perm=${camera7_img}/my_product/product_overlay/etc/permissions
camera7_apex=$(find ${camera7_img} -path "*/apex/*" \( -name "com.oplus.camera.app*.apex" -o -name "com.oplus.camera.app*.capex" \) 2>/dev/null | head -n1)

camera7_write_perm() {
    # $1 = 1 when the adapter jar is shipped
    mkdir -p ${camera7_perm}
    rm -f ${camera7_perm}/com.oplus.camera.unit.sdk_product.xml \
          ${camera7_img}/my_product/etc/permissions/com.oplus.camera.unit.sdk.xml
    {
        echo '<?xml version="1.0" encoding="utf-8"?>'
        echo '<!-- Camera 7.0 unit SDK (Camera-7.0-fixes-COS). Must live in product_overlay/etc/permissions. -->'
        echo '<permissions>'
        if [[ "$1" == 1 ]];then
            echo '    <library name="com.oplus.camera.unit.sdk.adapter" file="/product/framework/com.oplus.camera.unit.sdk.adapter.jar" />'
            echo '    <library name="com.oplus.camera.unit.sdk" file="/product/framework/com.oplus.camera.unit.sdk.jar" dependency="com.oplus.camera.unit.sdk.adapter" />'
            echo '    <library name="com.oppo.camera.unit.sdk" file="/product/framework/com.oplus.camera.unit.sdk.jar" dependency="com.oplus.camera.unit.sdk.adapter" />'
        else
            echo '    <library name="com.oplus.camera.unit.sdk" file="/product/framework/com.oplus.camera.unit.sdk.jar" />'
            echo '    <library name="com.oppo.camera.unit.sdk" file="/product/framework/com.oplus.camera.unit.sdk.jar" />'
        fi
        echo '    <library name="androidx.camera.extensions.impl" file="/system_ext/framework/androidx.camera.extensions.impl.jar" />'
        echo '</permissions>'
    } > ${camera7_perm}/com.oplus.camera.unit.sdk.xml
}

if [[ -n "${camera7_apex}" ]];then
    # ---- 1) unpack the port's own camera APEX ----
    camera7_tmp=tmp/camera7_apex
    rm -rf ${camera7_tmp}; mkdir -p ${camera7_tmp}
    if ! unzip -oq "${camera7_apex}" apex_payload.img -d ${camera7_tmp} || \
       ! extract.erofs -x -i ${camera7_tmp}/apex_payload.img -o ${camera7_tmp}/out >/dev/null 2>&1;then
        error "Camera 7.0: could not unpack $(basename ${camera7_apex}) -- leaving the camera as it is"
        rm -rf ${camera7_tmp}
        return 0
    fi
    camera7_payload=$(find ${camera7_tmp}/out -type f -path "*/app/OplusCamera/OplusCamera.apk" | head -n1)
    camera7_payload=${camera7_payload%/app/OplusCamera/OplusCamera.apk}
    if [[ -z "${camera7_payload}" || ! -d "${camera7_payload}/lib64" || ! -f "${camera7_payload}/javalib/com.oplus.camera.unit.sdk.jar" ]];then
        error "Camera 7.0: unexpected APEX layout -- leaving the camera as it is"
        rm -rf ${camera7_tmp}
        return 0
    fi

    rm -rf ${camera7_app}
    mkdir -p ${camera7_app}/lib/arm64 ${camera7_fw}
    cp -f ${camera7_payload}/app/OplusCamera/OplusCamera.apk ${camera7_app}/
    cp -f ${camera7_payload}/lib64/*.so ${camera7_app}/lib/arm64/
    rm -f ${camera7_fw}/com.oplus.camera.*.jar ${camera7_fw}/oat/*/com.oplus.camera.*
    cp -f ${camera7_payload}/javalib/com.oplus.camera.unit.sdk.jar ${camera7_fw}/
    camera7_write_perm 0
    find ${camera7_img} -path "*/apex/*" \( -name "com.oplus.camera.app*.apex" -o -name "com.oplus.camera.app*.capex" \) -delete
    green "Camera 7.0: installed the port's own camera ($(ls ${camera7_app}/lib/arm64 | wc -l) libs) from $(basename ${camera7_apex}) as a system app"
    rm -rf ${camera7_tmp}
else
    # ---- 2) OnePlus 15 payload ----
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

    rm -rf ${camera7_app}
    rm -f ${camera7_fw}/com.oplus.camera.*.jar ${camera7_fw}/oat/*/com.oplus.camera.*
    cp -rf "${camera7_cache}/files/"* ${camera7_img}/
    camera7_write_perm 1
    green "Camera 7.0 (OplusCamera 17.0.16, OnePlus 15) installed with its unit SDK and JNI libs"
fi

# Same as the Camera 5.0 (OOS) fix, which is proven on the 9 Pro.
camera7_prop=${camera7_img}/my_product/etc/bruce/build.prop
if [[ -f "${camera7_prop}" ]] && ! grep -q "^ro.vendor.oplus.camera.isSupportLumo=" "${camera7_prop}";then
    echo "ro.vendor.oplus.camera.isSupportLumo=1" >> "${camera7_prop}"
fi
unset -f camera7_write_perm
