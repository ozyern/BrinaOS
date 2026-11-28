# !/bin/bash
# Camera 5.0 fixes (ODM) for the OnePlus 9 Pro: the ColorOS camera libs and
# configs for the 9 Pro's odm (112 files: odm/lib*/, odm/etc/camera/...).
#
# Among them is odm/etc/camera/config/oplus_camera_config with the
# com.oplus.feature.master.mode.* vendor tags: without it the camera has no
# Master mode (only Pro), and the odm keeps the stock OxygenOS 14 camera libs.
#
# The upstream copy (blahajcoding/coloros_port-modules) is no longer served, and
# an EEA 17.0.0.102 build silently shipped without this module because of that.
# The payload is kept next to this script as files.zip (proprietary blobs, so it
# is gitignored: copy it in from an earlier build's cache/Camera-5.0-fixes-ODM/).
odm50_zip="devices/OnePlus9Pro/module_files/Camera-5.0-fixes-ODM/files.zip"
odm50_sha256=f79d38daeec9caeb8f5b319525f06c936b4bd2647feaae5a8a34e9edbbcf2fa9

if [[ ! -f "${odm50_zip}" && -f cache/Camera-5.0-fixes-ODM/files.zip ]];then
    odm50_zip=cache/Camera-5.0-fixes-ODM/files.zip
fi
if [[ ! -f "${odm50_zip}" ]];then
    error "Camera-5.0-fixes-ODM payload missing (${odm50_zip}): the camera will have no Master mode and stock odm camera libs"
    return 0
fi
if [[ "$(sha256sum "${odm50_zip}" | cut -d' ' -f1)" != "${odm50_sha256}" ]];then
    yellow "Camera-5.0-fixes-ODM: ${odm50_zip} differs from the verified payload (sha256 ${odm50_sha256}), using it anyway"
fi

rm -rf tmp/Camera-5.0-fixes-ODM
mkdir -p tmp/Camera-5.0-fixes-ODM
unzip -o -q "${odm50_zip}" -d tmp/Camera-5.0-fixes-ODM || { error "Camera-5.0-fixes-ODM: could not unzip ${odm50_zip}"; return 0; }
cp -rf tmp/Camera-5.0-fixes-ODM/* build/portrom/images/
rm -rf tmp/Camera-5.0-fixes-ODM
green "Camera 5.0 fixes (ODM) applied ($(grep -c 'master.mode' build/portrom/images/odm/etc/camera/config/oplus_camera_config 2>/dev/null) master-mode tags)"
unset odm50_zip odm50_sha256
