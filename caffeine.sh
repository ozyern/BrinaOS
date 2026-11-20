#!/bin/bash

# caffeine.sh — the shared helper library for brina.sh
#
# "That's that me espresso."
# Everything in here is the caffeine: the little functions that keep the
# port awake through a very long build. Logging lives at the top, the
# actual heavy lifting lives below.

# ── Palette ───────────────────────────────────────────────────────────
# Short n' Sweet on the eyes. 256-colour, so it looks the same in every
# terminal that isn't stuck in 1989.
CAF_RESET=$'\033[0m'
CAF_GLOSS=$'\033[1;38;5;213m'   # bubblegum   -> success
CAF_LILAC=$'\033[1;38;5;147m'   # lilac       -> info / in progress
CAF_HONEY=$'\033[1;38;5;222m'   # honey blonde-> warning
CAF_CHERRY=$'\033[1;38;5;197m'  # cherry      -> error
CAF_DIM=$'\033[2;38;5;175m'     # dusty rose  -> timestamps

# Timestamp, but make it fashion.
_caf_stamp() {
    printf '%s[%s]%s' "${CAF_DIM}" "$(date +%m%d-%T)" "${CAF_RESET}"
}

# The four log levels keep their original names (error/yellow/blue/green)
# so every existing call site in brina.sh keeps working untouched --
# only the outfit changed.

# 💔 Something broke. Please please please don't prove me wrong.
error() {
    if [ "$#" -eq 2 ]; then
        if [[ "$LANG" == zh_CN* ]]; then
            echo -e "$(_caf_stamp) ${CAF_CHERRY}💔 $1${CAF_RESET}"
        else
            echo -e "$(_caf_stamp) ${CAF_CHERRY}💔 $2${CAF_RESET}"
        fi
    elif [ "$#" -eq 1 ]; then
        echo -e "$(_caf_stamp) ${CAF_CHERRY}💔 $1${CAF_RESET}"
    else
        echo "Usage: error <Message>"
    fi
}

# ✨ A warning. Not a dealbreaker, just a little bit of nonsense.
yellow() {
    if [ "$#" -eq 2 ]; then
        if [[ "$LANG" == zh_CN* ]]; then
            echo -e "$(_caf_stamp) ${CAF_HONEY}✨ $1${CAF_RESET}"
        else
            echo -e "$(_caf_stamp) ${CAF_HONEY}✨ $2${CAF_RESET}"
        fi
    elif [ "$#" -eq 1 ]; then
        echo -e "$(_caf_stamp) ${CAF_HONEY}✨ $1${CAF_RESET}"
    else
        echo "Usage: yellow <Message>"
    fi
}

# 🎀 Work in progress. We're in our building era.
blue() {
    if [ "$#" -eq 2 ]; then
        if [[ "$LANG" == zh_CN* ]]; then
            echo -e "$(_caf_stamp) ${CAF_LILAC}🎀 $1${CAF_RESET}"
        else
            echo -e "$(_caf_stamp) ${CAF_LILAC}🎀 $2${CAF_RESET}"
        fi
    elif [ "$#" -eq 1 ]; then
        echo -e "$(_caf_stamp) ${CAF_LILAC}🎀 $1${CAF_RESET}"
    else
        echo "Usage: blue <Message>"
    fi
}

# 💅 It worked. Is it that sweet? I guess so.
green() {
    if [ "$#" -eq 2 ]; then
        if [[ "$LANG" == zh_CN* ]]; then
            echo -e "$(_caf_stamp) ${CAF_GLOSS}💅 $1${CAF_RESET}"
        else
            echo -e "$(_caf_stamp) ${CAF_GLOSS}💅 $2${CAF_RESET}"
        fi
    elif [ "$#" -eq 1 ]; then
        echo -e "$(_caf_stamp) ${CAF_GLOSS}💅 $1${CAF_RESET}"
    else
        echo "Usage: green <Message>"
    fi
}

# ── Stage decoration ──────────────────────────────────────────────────

# sparkle <title> -- a section header for the big movements of the build.
sparkle() {
    echo
    echo -e "${CAF_GLOSS}  ✧ ･ﾟ: *✧･ﾟ:*  ${1}  *:･ﾟ✧*:･ﾟ✧${CAF_RESET}"
    echo
}

# banner -- the opening number. Purely cosmetic, safe to call anywhere.
banner() {
    local l1 l2 l3 l4 l5 l6
    l1=$'\033[1;38;5;225m'; l2=$'\033[1;38;5;218m'; l3=$'\033[1;38;5;219m'
    l4=$'\033[1;38;5;213m'; l5=$'\033[1;38;5;212m'; l6=$'\033[1;38;5;206m'
    echo
    echo -e "${CAF_DIM}  ╭───────────────────────────────────────────╮${CAF_RESET}"
    echo -e "   ${l1}██████╗ ██████╗ ██╗███╗   ██╗ █████╗ ${CAF_RESET}"
    echo -e "   ${l2}██╔══██╗██╔══██╗██║████╗  ██║██╔══██╗${CAF_RESET}"
    echo -e "   ${l3}██████╔╝██████╔╝██║██╔██╗ ██║███████║${CAF_RESET}"
    echo -e "   ${l4}██╔══██╗██╔══██╗██║██║╚██╗██║██╔══██║${CAF_RESET}"
    echo -e "   ${l5}██████╔╝██║  ██║██║██║ ╚████║██║  ██║${CAF_RESET}"
    echo -e "   ${l6}╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝${CAF_RESET}"
    echo -e "${CAF_DIM}  ╰───────────────────────────────────────────╯${CAF_RESET}"
    echo -e "   ${CAF_LILAC}a ColorOS porting toolkit, short n' sweet 🎀${CAF_RESET}"
    echo -e "   ${CAF_DIM}espresso in, ColorOS out.${CAF_RESET}"
    echo
}

#Check for the existence of the requirements command, proceed if it exists, or abort otherwise.
exists() {
    command -v "$1" > /dev/null 2>&1
}

abort() {
    error "--> Missing $1. Slim pickins -- please run ./willpower.sh first (sudo is required on Linux)"
    exit 1
}

check() {
    for b in "$@"; do
        exists "$b" || abort "$b"
    done
}

shopt -s expand_aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
    yellow "macOS detected,setting alias"
    alias sed=gsed
    alias tr=gtr
    alias grep=ggrep
    alias du=gdu
    alias date=gdate
    alias stat=gstat
    alias find=gfind
fi

# Replace Smali code in an APK or JAR file, without supporting resource patches.
# $1: Target APK/JAR file
# $2: Target Smali file (supports relative paths for Smali files)
# $3: Value to be replaced
# $4: Replacement value
patch_smali() {
    if [[ $is_eu_rom == "true" ]]; then
       SMALI_COMMAND="java -jar bin/apktool/smali-3.0.5.jar"
       BAKSMALI_COMMAND="java -jar bin/apktool/baksmali-3.0.5.jar" 
    else
       SMALI_COMMAND="java -jar bin/apktool/smali.jar"
       BAKSMALI_COMMAND="java -jar bin/apktool/baksmali.jar"
    fi
    targetfilefullpath=$(find build/portrom/images -type f -name $1)
    if [ -f $targetfilefullpath ];then
        targetfilename=$(basename $targetfilefullpath)
        yellow "Modifying $targetfilename"
        foldername=${targetfilename%.*}
        rm -rf tmp/$foldername/
        mkdir -p tmp/$foldername/
        cp -rf $targetfilefullpath tmp/$foldername/
        7z x -y tmp/$foldername/$targetfilename *.dex -otmp/$foldername >/dev/null
        for dexfile in tmp/$foldername/*.dex;do
            smalifname=${dexfile%.*}
            smalifname=$(echo $smalifname | cut -d "/" -f 3)
            ${BAKSMALI_COMMAND} d --api ${port_android_sdk} ${dexfile} -o tmp/$foldername/$smalifname 2>&1 || error "Baksmaling failed"
        done
        if [[ $2 == *"/"* ]];then
            targetsmali=$(find tmp/$foldername/*/$(dirname $2) -type f -name $(basename $2))
        else
            targetsmali=$(find tmp/$foldername -type f -name $2)
        fi
        if [ -f $targetsmali ];then
            smalidir=$(echo $targetsmali |cut -d "/" -f 3)
            yellow "Target ${smalidir} Found"
            search_pattern=$3
            replacement_pattern=$4
            if [[ $5 == 'regex' ]];then
                 sed -i "/${search_pattern}/c\\${replacement_pattern}" $targetsmali
            else
            sed -i "s/$search_pattern/$replacement_pattern/g" $targetsmali
            fi
            ${SMALI_COMMAND} a --api ${port_android_sdk} tmp/$foldername/${smalidir} -o tmp/$foldername/${smalidir}.dex > /dev/null 2>&1 || error "Smaling failed"
            pushd tmp/$foldername/ >/dev/null || exit
            7z a -y -mx0 -tzip $targetfilename ${smalidir}.dex  > /dev/null 2>&1 || error "Failed to modify $targetfilename"
            popd >/dev/null || exit
            yellow "Fix $targetfilename completed"
            if [[ $targetfilename == *.apk ]]; then
                yellow "APK file detected, initiating ZipAlign process..."
                rm -rf ${targetfilefullpath}

                # Align modified APKs, to avoid error "Targeting R+ (version 30 and above) requires the resources.arsc of installed APKs to be stored uncompressed and aligned on a 4-byte boundary" 
                zipalign -p -f -v 4 tmp/$foldername/$targetfilename ${targetfilefullpath} > /dev/null 2>&1 || error "zipalign error,please check for any issues"
                yellow "APK ZipAlign process completed."
                yellow "ApkSigner signing.."
                apksigner sign -v --key otatools/key/testkey.pk8 --cert otatools/key/testkey.x509.pem ${targetfilefullpath}
                apksigner verify -v ${targetfilefullpath}
                yellow "Copying APK to target ${targetfilefullpath}"
            else
                yellow "Copying file to target ${targetfilefullpath}"
                cp -rf tmp/$foldername/$targetfilename ${targetfilefullpath}
            fi
        fi
    else
        error "Failed to find $1,please check it manually".
    fi

}

#check if a property is available
is_property_exists () {
    if [ $(grep -c "$1" "$2") -ne 0 ]; then
        return 0
    else
        return 1
    fi
}

disable_avb_verify() {
    fstab=$1
    blue "Disabling avb_verify: $fstab"
    if [[ ! -f $fstab ]]; then
        yellow "$fstab not found, please check it manually"
    else
        sed -i "s/,avb_keys=.*avbpubkey//g" $fstab
        sed -i "s/,avb=vbmeta_system//g" $fstab
        sed -i "s/,avb=vbmeta_vendor//g" $fstab
        sed -i "s/,avb=vbmeta//g" $fstab
        sed -i "s/,avb//g" $fstab
    fi
}

extract_partition() {
    part_img=$1
    part_name=$(basename ${part_img})
    target_dir=$2
    if [[ -f ${part_img} ]];then 
        if [[ $($tools_dir/gettype -i ${part_img} ) == "ext" ]];then
            blue "Extracting ${part_name}"
            python3 bin/imgextractor/imgextractor.py ${part_img} ${target_dir}  || { error "Extracting ${part_name} failed."; exit 1; }
            green "${part_name} extracted."
            rm -rf ${part_img}      
        elif [[ $($tools_dir/gettype -i ${part_img}) == "erofs" ]]; then
            blue "Extracting ${part_name}"
            extract.erofs -x -i ${part_img}  -o $target_dir > /dev/null 2>&1 || { error "Extracting ${part_name} failed." ; exit 1; }
            green "${part_name} extracted."
            rm -rf ${part_img}
        else
            error "Unable to handle img, exit."
            exit 1
        fi
    fi    
}

disable_avb_verify() {
    fstab=$(find $1 -name "fstab*")
    if [[ $fstab == "" ]];then
        error "No fstab found!"
        sleep 5
    else
        blue "Disabling AVB verification...."
        for file in $fstab; do
            sed -i 's/,avb.*system//g' $file
            sed -i 's/,avb,/,/g' $file
            sed -i 's/,avb=.*a,/,/g' $file
            sed -i 's/,avb_keys.*key//g' $file
            if [[ "${pack_type}" == "EXT" ]];then
                sed -i "/erofs/d" $file
            fi
        done
        blue "AVB verification disabled successfully"
    fi
}
spoof_bootimg() {
    bootimg=$1
    mkdir -p ${work_dir}/tmp/boot_official
    cp $bootimg ${work_dir}/tmp/boot_official/boot.img
    pushd ${work_dir}/tmp/boot_official
    magiskboot unpack -h ${work_dir}/tmp/boot_official/boot.img > /dev/null 2>&1
    sed -i '/^cmdline=/ s/$/ androidboot.vbmeta.device_state=unlocked/' header
    magiskboot repack ${work_dir}/tmp/boot_official/boot.img  ${work_dir}/tmp/boot_official/new-boot.img
    popd
    cp ${work_dir}/tmp/boot_official/new-boot.img $bootimg
}


patch_kernel_to_bootimg() {
    kernel_file=$1
    dtb_file=$2
    bootimg_name=$3
    mkdir -p ${work_dir}/tmp/boot
    cd ${work_dir}/tmp/boot
    bootimg=$(find ${work_dir}/build/baserom/ -name boot.img)
    cp $bootimg ${work_dir}/tmp/boot/boot.img
    magiskboot unpack -h ${work_dir}/tmp/boot/boot.img > /dev/null 2>&1
    if [ -f ramdisk.cpio ]; then
    comp=$(magiskboot decompress ramdisk.cpio | grep -v 'raw' | sed -n 's;.*\[\(.*\)\];\1;p')
    if [ "$comp" ]; then
        mv -f ramdisk.cpio ramdisk.cpio.$comp
        magiskboot decompress ramdisk.cpio.$comp ramdisk.cpio > /dev/null 2>&1
        if [ $? != 0 ] && $comp --help; then
        $comp -dc ramdisk.cpio.$comp >ramdisk.cpio
        fi
    fi
    mkdir -p ramdisk
    chmod 755 ramdisk
    cd ramdisk
    EXTRACT_UNSAFE_SYMLINKS=1 cpio -d -F ../ramdisk.cpio -i
    disable_avb_verify ${work_dir}/tmp/boot/
    # #添加erofs文件系统fstab
    # if [[ ${pack_type} == "EROFS" ]];then
    #     blue "检查 ramdisk fstab.qcom是否需要添加erofs挂载点" "Check if ramdisk fstab.qcom needs to add erofs mount point."
    #     if ! grep -q "erofs" ${work_dir}/tmp/boot/ramdisk/fstab.qcom ; then
    #             for pname in ${super_list}; do
    #                 sed -i "/\/${pname}[[:space:]]\+ext4/{p;s/ext4/erofs/;s/ro,barrier=1,discard/ro/;}" ${work_dir}/tmp/boot/ramdisk/fstab.qcom
    #                 added_line=$(sed -n "/\/${pname}[[:space:]]\+erofs/p" ${work_dir}/tmp/boot/ramdisk/fstab.qcom)
    
    #                 if [ -n "$added_line" ]; then
    #                     yellow "添加${pname}成功" "Adding erofs mount point [$pname]"
    #                 else
    #                     error "添加失败，请检查" "Adding faild, please check."
    #                     exit 1 
    #                 fi
    #             done
    #       fi
    #   fi
    fi
    cp -f $kernel_file ${work_dir}/tmp/boot/kernel
    cp -f $dtb_file ${work_dir}/tmp/boot/dtb
    cd ${work_dir}/tmp/boot/ramdisk/
    find | sed 1d | cpio -H newc -R 0:0 -o -F ../ramdisk_new.cpio > /dev/null 2>&1
    cd ..
    if [ "$comp" ]; then
      magiskboot compress=$comp ramdisk_new.cpio
      if [ $? != 0 ] && $comp --help > /dev/null 2>&1; then
          $comp -9c ramdisk_new.cpio >ramdisk.cpio.$comp
      fi
    fi
    ramdisk=$(ls ramdisk_new.cpio* | tail -n1)
    if [ "$ramdisk" ]; then
      cp -f $ramdisk ramdisk.cpio
      case $comp in
      cpio) nocompflag="-n" ;;
      esac
      magiskboot repack $nocompflag ${work_dir}/tmp/boot/boot.img ${work_dir}/devices/$base_product_device/${bootimg_name} 
    fi
    rm -rf ${work_dir}/tmp/boot
    cd $work_dir
}

patch_kernel() {
    kernel_file=$1
    dtb_file=$2
    bootimg_name=$3
    echo ">> Starting patch_kernel() ..."
    local tmp_dir="${work_dir}/tmp/patch"
    mkdir -p "${tmp_dir}" || { error "Cannot create temp dir ${tmp_dir}"; exit 1; }
    cd "${tmp_dir}" || { error "Cannot enter ${tmp_dir}"; exit 1; }

    blue "Searching for boot.img in ${work_dir}/build/baserom/"
    local bootimg
    bootimg=$(find "${work_dir}/build/baserom/" -name boot.img | head -n 1)
    if [[ -z "$bootimg" ]]; then
        error "boot.img not found"
        exit 1
    fi
    cp "$bootimg" boot.img

    blue "Unpacking boot.img with magiskboot"
    magiskboot unpack -h boot.img > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        error "Failed to unpack boot.img"
        exit 1
    fi

    # Process ramdisk.cpio (if exists)
    if [ -f ramdisk.cpio ]; then
        local comp
        comp=$(magiskboot decompress ramdisk.cpio | grep -v 'raw' | sed -n 's;.*\[\(.*\)\];\1;p')
        if [ -n "$comp" ]; then
            mv -f ramdisk.cpio ramdisk.cpio."$comp"
            magiskboot decompress ramdisk.cpio."$comp" ramdisk.cpio > /dev/null 2>&1
            if [ $? -ne 0 ] && $comp --help > /dev/null 2>&1; then
                $comp -dc ramdisk.cpio."$comp" > ramdisk.cpio
            fi
        fi
        mkdir -p ramdisk
        chmod 755 ramdisk
        cd ramdisk || { error "Cannot enter ramdisk directory"; exit 1; }
        EXTRACT_UNSAFE_SYMLINKS=1 cpio -d -F ../ramdisk.cpio -i > /dev/null 2>&1
        cd ..
    fi

    disable_avb_verify "${tmp_dir}/"

    blue "Copying new kernel to temp directory"
    cp -f "$kernel_file" "${tmp_dir}/kernel"

    if [[ -f dtb ]] && [[ -n $dtb_file ]]; then
        blue "Replacing dtb file in boot.img"
        cp -fv "$dtb_file" "${tmp_dir}/dtb"
    fi

    if [ -d ramdisk ]; then
        for f in fstab.qcom fstab.default fstab.emmc; do
            if [ -f "ramdisk/${f}" ]; then
                yellow "Found ${tmp_dir}/ramdisk/${f}, no extra processing needed"
                if [[ $convert_to_aonly == true ]];then
                    yellow "Modifying ${f} for A-only"
                    sed -i "/,slotselect/d" ramdisk/${f}
                fi
            fi
        done
    fi

    if [ -d ramdisk ]; then
        cd ramdisk || { error "Cannot enter ramdisk directory"; exit 1; }
        find . | sed 1d | cpio -H newc -R 0:0 -o -F ../ramdisk_new.cpio > /dev/null 2>&1
        cd ..
        if [ -n "$comp" ]; then
            magiskboot compress=$comp ramdisk_new.cpio
            if [ $? -ne 0 ] && $comp --help > /dev/null 2>&1; then
                $comp -9c ramdisk_new.cpio > ramdisk.cpio."$comp"
            fi
        fi
        local ramdisk_file
        ramdisk_file=$(ls ramdisk_new.cpio* | tail -n1)
        [ -n "$ramdisk_file" ] && cp -f "$ramdisk_file" ramdisk.cpio
    fi

    local nocompflag=""
    case $comp in
        cpio) nocompflag="-n" ;;
    esac

    blue "Repacking boot.img to generate new boot image"
    magiskboot repack $nocompflag boot.img "${work_dir}/devices/${base_product_device}/${bootimg_name}"
    if [ $? -ne 0 ]; then
        error "Failed to repack boot.img"
        exit 1
    fi

    local vendor_boot
    vendor_boot=$(find "${work_dir}/build/baserom/" -name vendor_boot.img | head -n 1)
    if [ -n "$vendor_boot" ]; then
        blue "vendor_boot detected, patching..."
        vendor_boot_tmp=$tmp_dir/vendor_boot_tmp
        mkdir -p $vendor_boot_tmp || { error "Cannot create vendor_tmp directory"; exit 1; }
        cp "$vendor_boot" $vendor_boot_tmp/vendor_boot.img
        cd $vendor_boot_tmp
        magiskboot unpack -h vendor_boot.img > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            error "Failed to unpack vendor_boot.img"
            exit 1
        fi

        if [ -f ramdisk.cpio ]; then
            local vcomp
            vcomp=$(magiskboot decompress ramdisk.cpio | grep -v 'raw' | sed -n 's;.*\[\(.*\)\];\1;p')
            if [ -n "$vcomp" ]; then
                mv -f ramdisk.cpio ramdisk.cpio."$vcomp"
                magiskboot decompress ramdisk.cpio."$vcomp" ramdisk.cpio > /dev/null 2>&1
                if [ $? -ne 0 ] && $vcomp --help > /dev/null 2>&1; then
                    $vcomp -dc ramdisk.cpio."$vcomp" > ramdisk.cpio
                fi
            fi
            mkdir -p ramdisk
            chmod 755 ramdisk
            cd ramdisk || { error "Cannot enter vendor ramdisk directory"; exit 1; }
            EXTRACT_UNSAFE_SYMLINKS=1 cpio -d -F ../ramdisk.cpio -i > /dev/null 2>&1
            cd ..
        fi

        if [ -f dtb ]; then
            blue "Replacing dtb"
            cp -fv "$dtb_file" "${vendor_boot_tmp}/dtb"
        fi

        if [ -d ramdisk ]; then
            for f in fstab.qcom fstab.default fstab.emmc; do
                if [ -f "ramdisk/${f}" ]; then
                    yellow "Found ${vendor_boot_tmp}/ramdisk/${f}, no extra processing needed"
                fi
            done
        fi

        if [ -d ramdisk ]; then
            cd ramdisk || { error "Cannot enter vendor ramdisk directory"; exit 1; }
            find . | sed 1d | cpio -H newc -R 0:0 -o -F ../ramdisk_new.cpio > /dev/null 2>&1
            cd ..
            if [ -n "$vcomp" ]; then
                magiskboot compress=$vcomp ramdisk_new.cpio
                if [ $? -ne 0 ] && $vcomp --help > /dev/null 2>&1; then
                    $vcomp -9c ramdisk_new.cpio > ramdisk.cpio."$vcomp"
                fi
            fi
            local vramdisk
            vramdisk=$(ls ramdisk_new.cpio* | tail -n1)
            [ -n "$vramdisk" ] && cp -f "$vramdisk" ramdisk.cpio
        fi

        local v_nocompflag=""
        case $vcomp in
            cpio) v_nocompflag="-n" ;;
        esac
        blue "Repacking vendor_boot.img"
        magiskboot repack $v_nocompflag vendor_boot.img "${work_dir}/devices/${base_product_device}/vendor_boot.img"
        if [ $? -ne 0 ]; then
            error "Failed to repack vendor_boot.img"
            exit 1
        fi

        #rm -rf vendor_tmp
    else
        blue "vendor_boot.img not found, only processing boot.img"
    fi

    cd "${work_dir}" || exit 1
    #rm -rf "${tmp_dir}"
    blue "patching done"
}

add_feature() {
    feature=$1
    file=$2
    parent_node=$(xmlstarlet sel -t -m "/*" -v "name()" "$file")
    feature_node=$(xmlstarlet sel -t -m "/*/*" -v "name()" -n "$file" | head -n 1)
    found=0
    for xml in $(find build/portrom/images/my_product/etc/ -type f -name "*.xml");do
        if  grep -nq "$feature" $xml ; then
        blue "Feature $feature already exists, skipping..."
            found=1
        fi
    done
    if [[ $found == 0 ]] ; then
        blue "Adding feature $feature"
        sed -i "/<\/$parent_node>/i\\\t\\<$feature_node name=\"$feature\"\/>" "$file"
    fi
}

add_feature_v2() {
    type=$1
    shift # Remove first arg, rest are feature items

    case "$type" in
        oplus_feature)
            dir="build/portrom/images/my_product/etc/extension"
            base_file="com.oplus.oplus-feature"
            root_tag="oplus-config"
            node_tag="oplus-feature"
            attr_prefix='name='
            ;;
        app_feature)
            dir="build/portrom/images/my_product/etc/extension"
            base_file="com.oplus.app-features"
            root_tag="extend_features"
            node_tag="app_feature"
            attr_prefix='name=' # 后面拼上 args
            ;;
        permission_feature)
            dir="build/portrom/images/my_product/etc/permissions"
            base_file="com.oplus.android-features"
            root_tag="permissions"
            node_tag="feature"
            attr_prefix='name='
            ;;
        permission_oplus_feature)
            dir="build/portrom/images/my_product/etc/permissions"
            base_file="oplus.feature-android"
            root_tag="oplus-config"
            node_tag="oplus-feature"
            attr_prefix='name='
            ;;
        *)
            echo "❌ Invalid type: $type"
            return 1
            ;;
    esac

    output_file="$dir/${base_file}-ext-bruce.xml"
    mkdir -p "$dir"

    # If file does not exist, create it first
    if [[ ! -f "$output_file" ]]; then
        echo "Creating new file: $output_file"
        cat > "$output_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<$root_tag>
</$root_tag>
EOF
    fi

    for entry in "$@"; do
    IFS='^' read -r feature comment extra <<< "$entry"
    
    [[ "$feature" == "$comment" ]] && comment=""
    
    [[ -z "$extra" ]] && extra=""

found=0
for xml in $(find build/portrom/images/my_product/etc/ -type f -name "*.xml"); do
	if grep -n "$feature" "$xml" | grep -vq "<!--"; then
           blue "Feature $feature already exists, skipping..."
           found=1
           break
    fi
done

    if [[ $found == 0 ]]; then
        blue "✅ feature: $feature Added."

        if [[ "$type" == "app_feature" ]]; then
            attrs="name=\"$feature\""
            [[ -n "$extra" ]] && attrs="$attrs $extra"
        else
            attrs="name=\"$feature\""
            [[ -n "$extra" ]] && attrs="$attrs $extra"
        fi

        # Write comment
        if [[ -n "$comment" ]]; then
            sed -i "/<\/$root_tag>/i\\\    <!-- $comment -->" "$output_file"
        fi
        # Write feature node
        sed -i "/<\/$root_tag>/i\\\    <$node_tag $attrs\/>" "$output_file"
    fi
done
}

remove_feature() {
    feature=$1
    force=$2  # Second arg, can be "force"

    if [[ "$force" == "force" ]]; then
        blue "Force delete mode: ignoring base rom check, deleting $feature"
    else
        # Perform base rom check in non-force mode
        for file in $(find build/baserom/images/my_product/etc/ -type f -name "*.xml"); do
            if grep -nq "<!--.*$feature.*-->" "$file"; then
                blue "Deleting $feature from $(basename $file) as it is commented out..."
            elif grep -nq "$feature" "$file"; then
                blue "Skip deleting $feature from $(basename $file)..."
                return
            fi
        done 
    fi

    # Whether force mode or not, delete feature in portrom if we reach here
    for file in $(find build/portrom/images/my_product/etc/ -type f -name "*.xml"); do
        if grep -nq "$feature" "$file"; then
            sed -i "/$feature/d" "$file"
            blue "Deleted $feature in $(basename $file)"
        fi
    done
}

update_prop_from_base() {

    source_build_prop="build/baserom/images/my_product/build.prop"
    target_build_prop="build/portrom/images/my_product/build.prop"

    cp "$target_build_prop" tmp/$(basename $target_build_prop).port

    while IFS= read -r line; do
        if [[ -z "$line" || "$line" =~ ^# || "$line" =~ oplusrom || "$line" =~ date ]]; then
            continue
        fi
        key=$(echo "$line" | cut -d'=' -f1)
        value=$(echo "$line" | cut -d'=' -f2-)

        if grep -q "^$key=" "$target_build_prop"; then
            sed -i "s|^$key=.*|$key=$value|" "$target_build_prop"
        else
            echo "$key=$value" >> "$target_build_prop"
        fi
    done < "$source_build_prop"

}

add_prop(){
    prop=$1
    value=$2
    if ! grep -q "${prop}" build/portrom/images/my_product/build.prop;then
        blue "Adding prop: $prop=$value"
        echo "$prop=$value" >> build/portrom/images/my_product/build.prop
    elif grep -q "${prop}" build/portrom/images/my_product/build.prop;then
        blue "Editing prop: $prop=$value"
        sed -i "s/${prop}=.*/${prop}=${value}/g" build/portrom/images/my_product/build.prop

    fi
        
}

remove_prop(){
    prop=$1
    if ! grep -q "${prop}" build/baserom/images/my_product/build.prop;then
    blue "Remove prop: $prop"
    sed -i "/${prop}/d" build/portrom/images/my_product/build.prop
    fi
}

add_prop_v2(){
    prop=$1
    value=$2
    bruce_prop="build/portrom/images/my_product/etc/bruce/build.prop"
    portrom_prop="build/portrom/images/my_product/build.prop"

    # If neither file has this prop, add to bruce_prop
    if ! grep -q "^${prop}=" "$bruce_prop" && ! grep -q "^${prop}=" "$portrom_prop"; then
        blue "Adding prop: $prop=$value"
        echo "$prop=$value" >> "$bruce_prop"
        return
    fi

    if grep -q "^${prop}=" "$bruce_prop"; then
        blue "Editing prop (bruce): $prop=$value"
        sed -i "s|^${prop}=.*|${prop}=${value}|" "$bruce_prop"
    fi

    if grep -q "^${prop}=" "$portrom_prop"; then
        blue "Editing prop (portrom): $prop=$value"
        sed -i "s|^${prop}=.*|${prop}=${value}|" "$portrom_prop"
    fi
}

remove_prop_v2() {
    prop="${1}"
    force="${2}"
    escaped_prop=$(echo "${prop}" | sed 's/\./\\./g')
    
    if [[ -n ${force} ]]; then
        blue "Force remove prop: ${prop}"
        # Match full prop name OR prop prefix
        sed -i -E "/^(${escaped_prop}=|${escaped_prop}\.)/s/^/#/" build/portrom/images/my_product/etc/bruce/build.prop
        sed -i -E "/^(${escaped_prop}=|${escaped_prop}\.)/s/^/#/" build/portrom/images/my_product/build.prop
    else
        # Check if base rom has this prop (full name or prefix)
        if ! grep -q -E "^(${escaped_prop}=|${escaped_prop}\.)" build/baserom/images/my_product/build.prop; then
            blue "Remove prop: ${prop}"
            sed -i -E "/^(${escaped_prop}=|${escaped_prop}\.)/s/^/#/" build/portrom/images/my_product/etc/bruce/build.prop
        else
            blue "Keep prop (exists in base): ${prop}"
        fi
    fi
}
prepare_base_prop() {
    source_build_prop="build/baserom/images/my_product/build.prop"
    target_build_prop="build/portrom/images/my_product/build.prop"
    bruce_prop="build/portrom/images/my_product/etc/bruce/build.prop"

    mkdir -p "$(dirname "$target_build_prop")"
    mkdir -p "$(dirname "$bruce_prop")"

    # Backup current portrom build.prop
    [[ ! -d tmp ]] && mkdir tmp

    cp -f "$target_build_prop" tmp/build.prop.portrom.bak

    # Overwrite portrom build.prop with baserom's content
    cp -f "$source_build_prop" "$target_build_prop"

    # Clear and init bruce.build.prop
    echo "# Properties added by port" > "$bruce_prop"

    # Add import to new build.prop (avoid duplicates)
    if ! grep -q "^import /mnt/vendor/my_product/etc/bruce/build.prop" "$target_build_prop"; then
        echo "" >> "$target_build_prop"
        echo "import /mnt/vendor/my_product/etc/bruce/build.prop" >> "$target_build_prop"
    fi
}

add_prop_from_port() {
    base_build_prop="build/baserom/images/my_product/build.prop"
    old_portrom_prop="tmp/build.prop.portrom.bak"
    bruce_prop="build/portrom/images/my_product/etc/bruce/build.prop"
    
    # List of properties to force add
    force_keys=(
        ro.build.version.oplusrom
        ro.build.version.oplusrom.display
        ro.build.version.oplusrom.confidential
        ro.build.version.realmeui
    )

    declare -A base_props
    # Read baserom properties
    while IFS='=' read -r key value; do
        [[ -z "$key" || "$key" =~ ^# ]] && continue
        base_props["$key"]="$value"
    done < "$base_build_prop"

    # Create temp file for processing
    temp_file=$(mktemp)
    
    # Process normal properties
    while IFS='=' read -r key value; do
        [[ -z "$key" || "$key" =~ ^# ]] && continue
        
        # Skip force added properties (handled later)
        if [[ " ${force_keys[*]} " == *" $key "* ]]; then
            continue
        fi

        if [[ ! -v base_props["$key"] ]]; then
            echo "$key=$value" >> "$temp_file"
            blue "Added: $key=$value"
        fi
    done < "$old_portrom_prop"

    # Process force added properties
    for key in "${force_keys[@]}"; do
        # Safely get property value (handle newlines)
        value=$(grep -m1 "^${key}=" "$old_portrom_prop" | awk -F'=' '{print $2}' | tr -d '\n\r')
        
        if [[ -n "$value" ]]; then
            # Remove old value if exists
            sed -i "/^${key}=/d" "$temp_file" 2>/dev/null
            echo "$key=$value" >> "$temp_file"
            blue "Force update: $key=$value"
        fi
    done

    # Append to final file
    cat "$temp_file" >> "$bruce_prop"
    rm -f "$temp_file"
}

smali_wrapper() {
    source_dr=$(realpath $1)
    source_apk=$(realpath $2)
    if [[ $is_eu_rom == "true" ]]; then
       SMALI_COMMAND="java -jar bin/apktool/smali-3.0.5.jar"
       BAKSMALI_COMMAND="java -jar bin/apktool/baksmali-3.0.5.jar" 
    else
       SMALI_COMMAND="java -jar bin/apktool/smali.jar"
       BAKSMALI_COMMAND="java -jar bin/apktool/baksmali.jar"
    fi

    for classes_folder in $(find $source_dr -maxdepth 1 -type d -name "classes*");do
        classes=$(basename $classes_folder)
        ${SMALI_COMMAND} a --api ${port_android_sdk} $source_dr/${classes} -o $source_dr/${classes}.dex || error "Smaling failed"
    done

    pushd $source_dr >/dev/null || exit
    for classes_dex in $(find . -type f -name "*.dex"); do
        7z a -y -mx0 -tzip $(realpath $source_apk) $classes_dex >/dev/null || error "Failed to modify $source_apk"
    done
    popd >/dev/null || exit
    
    
    yellow "Fix $source_apk completed"
}

baksmali_wrapper() {
    if [[ $is_eu_rom == "true" ]]; then
       SMALI_COMMAND="java -jar bin/apktool/smali-3.0.5.jar"
       BAKSMALI_COMMAND="java -jar bin/apktool/baksmali-3.0.5.jar" 
    else
       SMALI_COMMAND="java -jar bin/apktool/smali.jar"
       BAKSMALI_COMMAND="java -jar bin/apktool/baksmali.jar"
    fi
    targetfilefullpath=$1
    if [ -f $targetfilefullpath ];then
        targetfilename=$(basename $targetfilefullpath)
        yellow "Modifying $targetfilename"
        foldername=${targetfilename%.*}
        rm -rf tmp/$foldername/
        mkdir -p tmp/$foldername/
        cp -rf $targetfilefullpath tmp/$foldername/
        cp tmp/$foldername/$foldername.apk tmp/$foldername/${foldername}_org.apk
        7z x -y tmp/$foldername/$targetfilename *.dex -otmp/$foldername >/dev/null
        for dexfile in tmp/$foldername/*.dex;do
            smalifname=${dexfile%.*}
            smalifname=$(echo $smalifname | cut -d "/" -f 3)
            ${BAKSMALI_COMMAND} d --api ${port_android_sdk} ${dexfile} -o tmp/$foldername/$smalifname 2>&1 || error "Baksmaling failed"
        done
    fi
}

fix_oldfaceunlock() {
    if [ ! -d tmp ]; then
        mkdir tmp
    fi
    blue "Fix FaceUnlock"
    SettingsAPK=$(find build/portrom/images/ -type f -name "Settings.apk" )
    baksmali_wrapper "$SettingsAPK"

    FaceUtilSmali=$(find tmp/Settings/ -type f -name "FaceUtils.smali")
    blue "Patching $FaceUtilSmali"
    sed -i '/^.method public static useOldFaceUnlock(Landroid\/content\/Context;)Z/,/^.end method/c\
    .method public static useOldFaceUnlock(Landroid\/content\/Context;)Z\
        .locals 1\
    \
        const-string v0, "com.oneplus.faceunlock"\
    \
        invoke-static {p0, v0}, Lcom\/oplus\/settings\/utils\/packages\/SettingsPackageUtils;->isPackageInstalled(Landroid\/content\/Context;Ljava\/lang\/String;)Z\
    \
        move-result p0\
    \
        return p0\
    .end method' "$FaceUtilSmali"

    CustomPkgConstantsSmali=$(find tmp/Settings/ -type f -name "CustomPkgConstants.smali")
    blue "Patching $CustomPkgConstantsSmali"
    sed -i 's/\.field public static final PACKAGE_FACEUNLOCK:Ljava\/lang\/String; = "unknown_pkg"/\.field public static final PACKAGE_FACEUNLOCK:Ljava\/lang\/String; = "com.oneplus.faceunlock"/' $CustomPkgConstantsSmali 
 
    for smali in $(find tmp/Settings/ -name "FaceSettings\$FaceSettingsFragment.smali" -o -name "OldFaceSettingsClient.smali" -o -name "OldFacePreferenceController.smali"); do
    blue "Patching $smali"
    sed -i "s/unknown_pkg/com\.oneplus\.faceunlock/g" "$smali" 
    done
    #java -jar bin/apktool/APKEditor.jar b -f -i tmp/Settings -o tmp/Settings.apk >/dev/null 2>&1
    smali_wrapper "tmp/Settings" tmp/Settings/Settings.apk
    zipalign -p -f -v 4 tmp/Settings/Settings.apk $SettingsAPK  > /dev/null 2>&1

    SystemUIAPK=$(find build/portrom/images/ -type f -name "SystemUI.apk" )
    #java -jar bin/apktool/APKEditor.jar d -i $SystemUIAPK -o tmp/SystemUI >/dev/null 2>&1
    baksmali_wrapper $SystemUIAPK
    OpUtilsSmali=$(find tmp/SystemUI -type f -name "OpUtils.smali")
    python3 bin/patchmethod.py $OpUtilsSmali "isUseOpFacelock"

    MiniCapsuleManagerImplSmali=$(find tmp/SystemUI -type f -name "MiniCapsuleManagerImpl.smali")

    findCode='invoke-static {}, Lcom/oplus/systemui/minicapsule/utils/MiniCapsuleUtils;->getPinholeFrontCameraPosition()Ljava/lang/String;'

    # Get line number containing findCode
    lineNum=$(grep -n "$findCode" "$MiniCapsuleManagerImplSmali" | cut -d ':' -f 1)

    # Start from lineNum, find first line with move-result-object
    lineContent=$(tail -n +"$lineNum" "$MiniCapsuleManagerImplSmali" | grep -m 1 -n "move-result-object")
    lineNumEnd=$(echo "$lineContent" | cut -d ':' -f 1)
    register=$(echo "$lineContent" | awk '{print $3}')

    # Calculate absolute line number
    lineNumEnd=$((lineNum + lineNumEnd - 1))

    if [ -n "$lineNumEnd" ]; then
        replace="    const-string $register, \"484,36:654,101\""
        sed -i "${lineNum},${lineNumEnd}d" "$MiniCapsuleManagerImplSmali"
        sed -i "${lineNum}i\\${replace}" "$MiniCapsuleManagerImplSmali"
        echo "Patched $file successfully"
    else
        echo "No 'move-result-object' found after $findCode in $MiniCapsuleManagerImplSmali"
    fi

    # white_list_xml=$(find tmp/systemui -name "app_music_capsule_white_list.xml")
    # if [[ -f $white_list_xml ]];then
    #     blue "Unlock mini capsule feature "
    #     music_apps=("com.tencent.qqmusic" "com.netease.cloudmusic" "com.heytap.music" "com.kugou.android" "com.tencent.karaoke" "cn.kuwo.player" "com.luna.music" "cmccwm.mobilemusic" "cn.missevan" "com.kugou.android.lite" "cn.wenyu.bodian" "com.duoduo.opera" "com.kugou.viper" "com.tencent.qqmusicpad" "com.aichang.yage" "com.blueocean.musicplayer" "com.tencent.blackkey" "com.e5837972.kgt" "com.android.mediacenter" "com.kugou.dj" "fm.xiami.main" "com.tencent.qqmusiclite" "com.blueocean.huoledj" "com.ting.mp3.android" "com.kk.xx.music" "ht.nct" "com.ximalaya.ting.android" "com.kuaiyin.player" "com.changba" "fm.qingting.qtradio" "com.yibasan.lizhifm" "com.shinyv.cnr" "app.podcast.cosmos" "com.tencent.radio" "com.kuaiyuhudong.djshow" "com.yusi.chongchong" "bubei.tingshu" "io.dushu.fandengreader" "com.tencent.weread" "com.soundcloud.android" "com.dywx.larkplayer" "com.shazam.android" "com.smule.singandroid" "com.andromo.dev445584.app545102" "com.anghami" "com.recorder.music.mp3.musicplayer" "com.atpc" "com.bandlab.bandlab" "com.gaana" "com.karaoke.offline.download.free.karaoke.music" "com.shaiban.audioplayer.mplayer" "com.jamendoandoutly.mainpakage" "com.spotify.music" "com.ezen.ehshig" "com.hiby.music" "com.tan8" "org.videolan.vlc" "video.player.videoplayer" "com.ted.android")
    #     for package in "${music_apps[@]}"; do
    #         # 检查包名是否已经存在
    #         if ! xmlstarlet sel -t -v "//packageInfo[@packageName='$package']" "$white_list_xml" | grep -q .; then
    #         xmlstarlet ed -L -s "/filter-conf" -t elem -n "packageInfo" -v "" -i "/filter-conf/packageInfo[not(@packageName)]" -t attr -n "packageName" -v "com.netease.music" $white_list_xml
    #         fi
    #     done
    # fi
    #java -jar bin/apktool/APKEditor.jar b -f -i tmp/SystemUI -o tmp/SystemUI.apk >/dev/null 2>&1
    smali_wrapper tmp/SystemUI tmp/SystemUI/SystemUI.apk
    zipalign -p -f -v 4 tmp/SystemUI/SystemUI.apk $SystemUIAPK  > /dev/null 2>&1
    apksigner sign -v --key otatools/key/testkey.pk8 --cert otatools/key/testkey.x509.pem  $SystemUIAPK
    apksigner verify -v  $SystemUIAPK
} 

patch_smartsidecar() {
    blue "Patching SmartSidecar APK"
    SmartSideBarAPK=$(find build/portrom/images/ -type f -name "SmartSideBar.apk" )
    #java -jar bin/apktool/APKEditor.jar d -i $SmartSideBarAPK -o tmp/SmartSideBar >/dev/null 2>&1
    baksmali_wrapper $SmartSideBarAPK
    RealmeUtilsSmali=$(find tmp/SmartSideBar -type f -name "RealmeUtils.smali")
    python3 bin/patchmethod.py $RealmeUtilsSmali "isRealmeBrand"
    #java -jar bin/apktool/APKEditor.jar b -f -i tmp/SmartSideBar -o tmp/SmartSideBar.apk >/dev/null 2>&1
    smali_wrapper tmp/SmartSideBar tmp/SmartSideBar/SmartSideBar.apk
    zipalign -p -f -v 4 tmp/SmartSideBar/SmartSideBar.apk $SmartSideBarAPK > /dev/null 2>&1
    apksigner sign -v --key otatools/key/testkey.pk8 --cert otatools/key/testkey.x509.pem $SmartSideBarAPK
    apksigner verify -v $SmartSideBarAPK
}

convert_version_to_number() {
    local version="$1"
    # Split version by dot
    IFS='.' read -ra parts <<< "$version"
    
    # Ensure at least 3 parts, pad with 0 if needed
    local major=${parts[0]:-0}
    local minor=${parts[1]:-0}
    local patch=${parts[2]:-0}
    
    # Convert to number: major*10000 + minor*100 + patch
    echo $((major * 10000 + minor * 100 + patch))
}

get_oplusrom_version() {
    # Which ROM to read: "portrom" (default) or "baserom"
    local rom="${1:-portrom}"

    # Priority order, most specific first. my_manifest carries the per-build
    # version (e.g. 16.0.10); my_product carries the marketing one (e.g. 16.1).
    # These are not comparable as numbers - picking the maximum let 16.1 beat
    # 16.0.10 and put "16.1" on the Settings OTA card. Take the first file that
    # declares a version instead.
    local prop_files=(
        "build/${rom}/images/my_manifest/build.prop"
        "build/${rom}/images/my_product/build.prop"
    )

    local prop_file version_value
    for prop_file in "${prop_files[@]}"; do
        [[ -f "$prop_file" ]] || continue
        version_value=$(grep -E "^ro\.build\.version\.oplusrom\.display=" "$prop_file" 2>/dev/null | cut -d'=' -f2 | tr -d '\r')
        if [[ -n "$version_value" ]]; then
            echo "$version_value" | sed 's/[^0-9.]//g'
            return
        fi
    done

    echo ""
}

trap 'error "Script interrupted! Exiting to prevent accidental deletion." ; exit 1' SIGINT


add_module() {
    # NOTE: the two `continue`s below do NOT work. bash only honours `continue`
    # inside a loop that is lexically part of the same function body, so it
    # prints "continue: only meaningful in a `for', `while', or `until' loop"
    # and falls through — every module runs regardless of
    # module_required_android_version / module_requires_experimental. Left as-is
    # on purpose: turning them into `return` would newly skip modules that
    # currently do run (Camera-5.0-fixes-ODM on Android 16 ports, for one), so
    # any module that really needs a version gate checks $port_android_version
    # inside its own script.sh instead.
    unset module_required_android_version module_requires_experimental
    source $1
    if [[ $port_android_version -ge $module_required_android_version ]]; then
        continue
    fi
    if [[ $module_requires_experimental -eq $experimental ]]; then
        continue
    fi
    blue "Module: ${module_display_name}"

    # Local payload wins over the GitHub one: a module whose files live in
    # devices/<device>/module_files/<module_name>/ is applied straight from the
    # repo, no download. Same contract as the remote form — script.sh is sourced
    # with $module_files pointing at the unpacked tree.
    module_local_dir="devices/${base_product_device}/module_files/${module_name}"
    if [[ -d "${module_local_dir}" ]] && [[ -f "${module_local_dir}/script.sh" ]]; then
        blue "  local payload: ${module_local_dir}"
        module_files="${module_local_dir}/files"
        source "${module_local_dir}/script.sh"
        unset module_local_dir
        return 0
    fi
    unset module_local_dir

    mkdir -p cache/${module_name}
    # -f: on a 404 curl must fail instead of saving GitHub's HTML error page,
    # which would otherwise be unzipped and then *sourced* as script.sh.
    if ! curl -fL ${module_repo}/raw/refs/heads/${module_repo_branch}/${module_name}/files.zip -o cache/${module_name}/files.zip \
        || ! curl -fL ${module_repo}/raw/refs/heads/${module_repo_branch}/${module_name}/script.sh -o cache/${module_name}/script.sh; then
        yellow "Module ${module_name} not available at ${module_repo} (${module_repo_branch}) -- skipping"
        rm -rf cache/${module_name}
        return 0
    fi
    module_files=cache/${module_name}/files
    unzip -o cache/${module_name}/files.zip -d ${module_files}
    source cache/${module_name}/script.sh
}

# Compiles a static RRO out of devices/common/rro/<name> (AndroidManifest.xml plus
# a res/ tree) and installs the signed APK into the port's product/overlay.
#
# An overlay rather than an edit to the target APK: Settings is signed with OPPO's
# release key, so swapping a drawable inside Settings.apk breaks that signature and
# the package stops parsing at scan time. An RRO sitting in a system partition is
# trusted by location, which is why the throwaway testkey in otatools/ is signature
# enough for it.
#
# No new host dependency - aapt2, apksigner and the key all ship in otatools/, and
# -I resolves the android: attributes against the port's own framework-res.apk.
build_static_rro() {
    local name="$1"
    local src="devices/common/rro/${name}"
    local dest="build/portrom/images/product/overlay"
    local fw="build/portrom/images/system/system/framework/framework-res.apk"
    local work="tmp/rro/${name}"

    if [[ ! -f "${src}/AndroidManifest.xml" ]];then
        yellow "RRO: ${src} has no AndroidManifest.xml, skipping ${name}"
        return 1
    fi
    if [[ ! -f "${fw}" ]];then
        yellow "RRO: framework-res.apk not found, skipping ${name}"
        return 1
    fi

    rm -rf "${work}" "${dest}/${name}.apk"
    mkdir -p "${work}" "${dest}"
    otatools/bin/aapt2 compile --dir "${src}/res" -o "${work}/res.zip"         && otatools/bin/aapt2 link -I "${fw}"                 --manifest "${src}/AndroidManifest.xml"                 --min-sdk-version 30 --target-sdk-version 35                 --version-code 1 --version-name 1.0                 -o "${work}/unsigned.apk" "${work}/res.zip"         && otatools/bin/apksigner sign                 --key otatools/key/testkey.pk8                 --cert otatools/key/testkey.x509.pem                 --v4-signing-enabled false                 --out "${dest}/${name}.apk" "${work}/unsigned.apk"
    local rc=$?
    rm -rf "${work}"
    if [[ $rc -ne 0 ]] || [[ ! -s "${dest}/${name}.apk" ]];then
        # Not fatal: a port without the overlay is just a port with stock artwork.
        rm -f "${dest}/${name}.apk"
        error "RRO: could not build ${name}, keeping the stock resources"
        return 1
    fi
    blue "RRO: installed ${dest}/${name}.apk"
    return 0
}

# Drops a set of ready-built overlay APKs from devices/common/rro/prebuilt/<name>
# into the port's product/overlay.
#
# Third-party theme packs ship as Magisk modules that mount their overlays over
# /system/vendor/overlay. Nothing about a static RRO needs Magisk though - it is
# trusted by whichever system partition it sits on - so a module that is only
# overlay APKs can be baked straight into the ROM instead. Anything else the
# module carries (system.prop, service.sh) is deliberately not brought along;
# see the README next to the APKs for what was dropped and why.
install_prebuilt_rro() {
    local name="$1"
    local src="devices/common/rro/prebuilt/${name}"
    local dest="build/portrom/images/product/overlay"
    local count=0

    if [[ ! -d "${src}" ]];then
        yellow "RRO: ${src} not found, skipping ${name}"
        return 1
    fi

    mkdir -p "${dest}"
    for apk in "${src}"/*.apk;do
        [[ -f "${apk}" ]] || continue
        cp -f "${apk}" "${dest}/" && count=$((count + 1))
    done

    if [[ ${count} -eq 0 ]];then
        # Not fatal, same as build_static_rro: a port without the theme still boots.
        error "RRO: ${name} had no APKs to install"
        return 1
    fi
    blue "RRO: installed ${count} prebuilt overlay(s) from ${name}"
    return 0
}

resolveDownloadCheck() {
    link=$1
    curl -Lsv -I --compressed -H "userId: oplus-ota|16002018" -H "User-Agent: okhttp/3.12.12" -H "Accept: */*" -H "Connection: Keep-Alive" "${link}" 2>&1 | grep -i "< location:" | awk '{print $3}' | tr -d '\r'
}

fetchOTA() {
    python tomboy_lite.py --anti 1 --mode taste $1 $2 | grep downloadCheck
}

# ── Android 16/17 compatibility ───────────────────────────────────────

install_property_compat_policy() {
    local source=""
    local candidate
    for candidate in \
        "devices/${base_product_device:-}/property_compat.json" \
        "devices/common/property_compat.json" \
        "resources/property_compat.json"; do
        if [[ -f "${candidate}" ]]; then
            source="${candidate}"
            break
        fi
    done
    [[ -n "${source}" ]] || return 0
    python3 -m json.tool "${source}" >/dev/null 2>&1 || {
        error "property_compat.json 格式无效: ${source}" \
            "Invalid property_compat.json syntax: ${source}"
        return 1
    }
    local destination="build/portrom/images/system_ext/etc/oplus/property_compat.json"
    mkdir -p "$(dirname "${destination}")" || return 1
    install -m 0644 "${source}" "${destination}" || return 1
    blue "已安装属性兼容策略: ${source}" \
        "Installed property compatibility policy: ${source}"
}

ensure_android_ext_shared_library() {
    local image_root="build/portrom/images"
    local target="${image_root}/my_bigball/non_overlay/app/GoogleExtShared/GoogleExtShared.apk"
    local source=""
    local candidate
    [[ -d "${image_root}/my_bigball" ]] || return 0
    if [[ ! -f "${target}" ]]; then
        for candidate in \
            "${image_root}/my_product/non_overlay/app/GoogleExtShared/GoogleExtShared.apk" \
            "build/baserom/images/my_product/non_overlay/app/GoogleExtShared/GoogleExtShared.apk"; do
            if [[ -f "${candidate}" ]]; then
                source="${candidate}"
                break
            fi
        done
        [[ -n "${source}" ]] || return 0
        mkdir -p "$(dirname "${target}")" || return 1
        mv -f -- "${source}" "${target}" || return 1
    fi

    local contexts="${image_root}/config/my_bigball_file_contexts"
    local fs_config="${image_root}/config/my_bigball_fs_config"
    if [[ -f "${contexts}" ]] && ! grep -qF '/my_bigball/non_overlay/app/GoogleExtShared' "${contexts}"; then
        printf '%s\tu:object_r:system_file:s0\n' \
            '/my_bigball/non_overlay/app/GoogleExtShared(/.*)?' >> "${contexts}"
    fi
    if [[ -f "${fs_config}" ]] && ! grep -qF 'my_bigball/non_overlay/app/GoogleExtShared' "${fs_config}"; then
        printf '%s\t0 0 755\n' 'my_bigball/non_overlay/app/GoogleExtShared' >> "${fs_config}"
    fi
}

# Android 17 ports that retain a Qualcomm/Oplus HIDL IMS declaration need the
# VNDK-30-compatible IMS APK.  Select it only for HIDL-only manifests; an AIDL
# declaration or a missing release asset leaves the donor stack untouched.
_port::vintf_ims_hal_matches() {
    local manifest="${1:-}"
    local expected_format="${2:-}"
    [[ -f "${manifest}" ]] || return 1
    awk -v expected_format="${expected_format}" '
        BEGIN { RS="</hal>"; found=0 }
        {
            block=tolower($0)
            format_token="<hal[^>]*format[[:space:]]*=[[:space:]]*\"" expected_format "\""
            if (block ~ format_token &&
                (block ~ /<name>[[:space:]]*vendor\.qti\.hardware\.radio\.ims[[:space:]]*<\/name>/ ||
                 block ~ /<name>[[:space:]]*vendor\.oplus\.hardware\.ims[[:space:]]*<\/name>/ ||
                 block ~ /iimsradio/ || block ~ /ioplusimsradio/)) found=1
        }
        END { exit(found ? 0 : 1) }
    ' "${manifest}"
}

_port::patch_ims_stack_for_vndk30() {
    [[ "${port_android_version:-}" == 17 ]] || return 0
    local image_root="build/portrom/images"
    local ims_patch="${work_dir:-${PWD}}/devices/common/ims-hidl-android17.apk"
    local vintf_root manifest target
    local -a vintf_roots=(
        "${image_root}/vendor/etc/vintf"
        "${image_root}/odm/etc/vintf"
    )
    local -a hidl_manifests=()
    local -a aidl_manifests=()
    local -a stale_oat=(
        "priv-app/ims/oat/arm64/ims.odex"
        "priv-app/ims/oat/arm64/ims.vdex"
        "priv-app/qcrilmsgtunnel/oat/arm64/qcrilmsgtunnel.odex"
        "priv-app/qcrilmsgtunnel/oat/arm64/qcrilmsgtunnel.vdex"
        "app/QtiTelephonyService/oat/arm64/QtiTelephonyService.odex"
        "app/QtiTelephonyService/oat/arm64/QtiTelephonyService.vdex"
        "framework/oat/arm64/qcrilhook.odex"
        "framework/oat/arm64/qcrilhook.odex.fsv_meta"
        "framework/oat/arm64/qcrilhook.vdex"
        "framework/oat/arm64/qcrilhook.vdex.fsv_meta"
    )

    [[ -f "${ims_patch}" ]] || return 0
    for vintf_root in "${vintf_roots[@]}"; do
        [[ -d "${vintf_root}" ]] || continue
        while IFS= read -r -d '' manifest; do
            _port::vintf_ims_hal_matches "${manifest}" hidl && hidl_manifests+=("${manifest}")
            _port::vintf_ims_hal_matches "${manifest}" aidl && aidl_manifests+=("${manifest}")
        done < <(find "${vintf_root}" -type f -name '*.xml' ! -iname '*compatibility*' -print0 2>/dev/null)
    done
    (( ${#hidl_manifests[@]} > 0 && ${#aidl_manifests[@]} == 0 )) || return 0

    target="${image_root}/system_ext/priv-app/ims/ims.apk"
    mkdir -p "$(dirname "${target}")" || return 1
    cp -p -- "${ims_patch}" "${target}" || return 1
    for manifest in "${stale_oat[@]}"; do
        rm -f -- "${image_root}/system_ext/${manifest}" || return 1
    done
    blue "已启用 Qualcomm HIDL IMS 兼容包并清理旧 oat" \
        "Enabled the Qualcomm HIDL IMS compatibility APK and removed stale oat files"
}

_port::selinux_find_compiler() {
    local candidate
    for candidate in \
        "${work_dir:-${PWD}}/tools/host/secilc-3.11" \
        "${work_dir:-${PWD}}/secilc"; do
        [[ -x "${candidate}" ]] && { printf '%s\n' "${candidate}"; return 0; }
    done
    command -v secilc 2>/dev/null || return 1
}

_port::selinux_policy_version() {
    local file="build/portrom/images/vendor/etc/selinux/plat_sepolicy_vers.txt"
    local value="30.0"
    [[ -f "${file}" ]] && value=$(tr -d '[:space:]' < "${file}")
    [[ "${value}" =~ ^[0-9]+\.[0-9]+$ ]] || return 1
    printf '%s\n' "${value}"
}

# Rebuild an ODM precompiled split policy from the extracted framework/vendor
# CIL set.  Callers append only type-checked rules before invoking this helper;
# when no compatible secilc is available, retaining the donor precompiled blob
# is safer than aborting a whole otherwise-valid port.
_port::selinux_compile_split_policy() {
    local output="$1"
    local vendor_policy="$2"
    local vendor_public="$3"
    local system_ext_policy="$4"
    local product_policy="$5"
    local policy_version="$6"
    local system_cil="build/portrom/images/system/system/etc/selinux/plat_sepolicy.cil"
    local system_map_dir="build/portrom/images/system/system/etc/selinux/mapping"
    local vendor_dir="build/portrom/images/vendor/etc/selinux"
    local system_ext_dir="build/portrom/images/system_ext/etc/selinux"
    local product_dir="build/portrom/images/product/etc/selinux"
    local odm_cil="build/portrom/images/odm/etc/selinux/odm_sepolicy.cil"
    local -a inputs=("${system_cil}" "${system_map_dir}/${policy_version}.cil" "${vendor_policy}")
    [[ -f "${vendor_public}" ]] && inputs+=("${vendor_public}")
    [[ -f "${system_map_dir}/${policy_version}.compat.cil" ]] && inputs+=("${system_map_dir}/${policy_version}.compat.cil")
    [[ -f "${system_ext_policy}" ]] && inputs+=("${system_ext_policy}")
    [[ -f "${system_ext_dir}/mapping/${policy_version}.cil" ]] && inputs+=("${system_ext_dir}/mapping/${policy_version}.cil")
    [[ -f "${product_policy}" ]] && inputs+=("${product_policy}")
    [[ -f "${product_dir}/mapping/${policy_version}.cil" ]] && inputs+=("${product_dir}/mapping/${policy_version}.cil")
    [[ -f "${odm_cil}" ]] && inputs+=("${odm_cil}")
    local compiler
    compiler="$(_port::selinux_find_compiler)" || return 2
    "${compiler}" -m -M true -G -N -c "${policy_version%%.*}" \
        -o "${output}" -f /dev/null "${inputs[@]}"
}

_port::patch_performance_sepolicy() {
    case "${port_android_version:-}" in 15|16|17) ;; *) return 0 ;; esac
    case "${base_device_family:-}" in OPSM8250|OPSM8350) ;; *) return 0 ;; esac

    local image_root="build/portrom/images"
    local vendor_dir="${image_root}/vendor/etc/selinux"
    local system_ext_dir="${image_root}/system_ext/etc/selinux"
    local product_dir="${image_root}/product/etc/selinux"
    local odm_dir="${image_root}/odm/etc/selinux"
    local vendor_cil="${vendor_dir}/vendor_sepolicy.cil"
    local vendor_debug_cil="${vendor_dir}/vendor_sepolicy_debug.cil"
    local system_ext_cil="${system_ext_dir}/system_ext_sepolicy.cil"
    local system_ext_debug_cil="${system_ext_dir}/system_ext_sepolicy_debug.cil"
    local product_cil="${product_dir}/product_sepolicy.cil"
    local product_debug_cil="${product_dir}/product_sepolicy_debug.cil"
    local vendor_public="${vendor_dir}/plat_pub_versioned.cil"
    local vendor_public_debug="${vendor_dir}/plat_pub_versioned_debug.cil"
    [[ -f "${vendor_cil}" && -f "${vendor_debug_cil}" ]] || return 0
    grep -qE '^\(type hal_oplus_performance_aidl\)$' "${vendor_cil}" || return 0
    grep -qE '^\(type hal_oplus_performance_aidl_service\)$' "${vendor_cil}" || return 0
    grep -qE '^\(type hal_oplus_performance_aidl\)$' "${vendor_debug_cil}" || return 0
    grep -qE '^\(type hal_oplus_performance_aidl_service\)$' "${vendor_debug_cil}" || return 0

    local -a rules=(
        '(allow oplus_phonemanager_app hal_oplus_performance_aidl_service (service_manager (find)))'
        '(allow oplus_phonemanager_app hal_oplus_performance_aidl (binder (call transfer)))'
        '(allow hal_oplus_performance_aidl oplus_phonemanager_app (binder (transfer)))'
        '(allow oplus_phonemanager_app hal_oplus_performance_aidl (fd (use)))'
    )
    local target rule
    # Only add the dedicated-domain relationship when the domain exists in
    # both policy variants.  Android 17 still receives the radio compatibility
    # rules below even when a donor uses generic priv_app for PhoneManager.
    local domain_prod=false domain_debug=false candidate
    for candidate in "${system_ext_cil}" "${product_cil}" "${vendor_public}"; do
        [[ -f "${candidate}" ]] && grep -qE '^\(type oplus_phonemanager_app\)$' "${candidate}" && domain_prod=true
    done
    for candidate in "${system_ext_debug_cil}" "${product_debug_cil}" "${vendor_public_debug}"; do
        [[ -f "${candidate}" ]] && grep -qE '^\(type oplus_phonemanager_app\)$' "${candidate}" && domain_debug=true
    done
    if [[ "${domain_prod}" == true && "${domain_debug}" == true ]]; then
        for target in "${vendor_cil}" "${vendor_debug_cil}"; do
            for rule in "${rules[@]}"; do
                grep -qF -- "${rule}" "${target}" || printf '%s\n' "${rule}" >> "${target}" || return 1
            done
        done
    fi

    if [[ "${port_android_version}" == 17 ]]; then
        local -a radio_rules=(
            '(allow rild system_prop (file (read getattr map open)))'
            '(allow rild oplus_nw_exported_system_prop (file (read getattr map open)))'
            '(allow rild system_oplus_radio_prop (file (read getattr map open)))'
            '(allow rild vendor_ims_prop (property_service (set)))'
            '(allow rild vendor_ims_prop (file (read getattr map open)))'
            '(allow rild system_data_root_file (dir (write add_name remove_name search getattr open)))'
            '(allow rild system_data_root_file (file (write create getattr open)))'
            '(allow rild cache_file (dir (read write add_name remove_name search getattr open)))'
            '(allow rild cache_file (file (read write create getattr open)))'
            '(allow rild cache_file (lnk_file (read getattr open)))'
        )
        for target in "${vendor_cil}" "${vendor_debug_cil}"; do
            for rule in "${radio_rules[@]}"; do
                grep -qF -- "${rule}" "${target}" || printf '%s\n' "${rule}" >> "${target}" || return 1
            done
        done
    fi

    local policy_version compiler prod_tmp debug_tmp
    policy_version="$(_port::selinux_policy_version)" || return 0
    compiler="$(_port::selinux_find_compiler 2>/dev/null)" || {
        yellow "未找到兼容 secilc，保留 donor 预编译策略" "Compatible secilc unavailable; keeping donor precompiled policy"
        return 0
    }
    mkdir -p "${odm_dir}" || return 1
    prod_tmp=$(mktemp "${odm_dir}/.precompiled_sepolicy.XXXXXX") || return 1
    debug_tmp=$(mktemp "${odm_dir}/.precompiled_sepolicy_debug.XXXXXX") || { rm -f "${prod_tmp}"; return 1; }
    if ! "${compiler}" -m -M true -G -N -c "${policy_version%%.*}" \
        -o "${prod_tmp}" -f /dev/null \
        "${image_root}/system/system/etc/selinux/plat_sepolicy.cil" \
        "${image_root}/system/system/etc/selinux/mapping/${policy_version}.cil" \
        "${vendor_cil}" "${vendor_public}" "${system_ext_cil}" "${product_cil}" \
        "${image_root}/odm/etc/selinux/odm_sepolicy.cil" 2>/dev/null; then
        rm -f "${prod_tmp}" "${debug_tmp}"
        yellow "性能策略预编译失败，保留 donor 策略" "Performance policy precompile failed; keeping donor policy"
        return 0
    fi
    if ! "${compiler}" -m -M true -G -N -c "${policy_version%%.*}" \
        -o "${debug_tmp}" -f /dev/null \
        "${image_root}/system/system/etc/selinux/plat_sepolicy.cil" \
        "${image_root}/system/system/etc/selinux/mapping/${policy_version}.cil" \
        "${vendor_debug_cil}" "${vendor_public_debug}" "${system_ext_debug_cil}" "${product_debug_cil}" \
        "${image_root}/odm/etc/selinux/odm_sepolicy.cil" 2>/dev/null; then
        rm -f "${prod_tmp}" "${debug_tmp}"
        yellow "性能 debug 策略预编译失败，保留 donor 策略" "Performance debug policy precompile failed; keeping donor policy"
        return 0
    fi
    mv -f "${prod_tmp}" "${odm_dir}/precompiled_sepolicy" || return 1
    mv -f "${debug_tmp}" "${odm_dir}/precompiled_sepolicy_debug" || return 1
}

_port::patch_display_panel_sepolicy() {
    [[ "${base_product_device:-}" == OP4E5D ]] || return 0
    case "${port_android_version:-}" in 15|16|17) ;; *) return 0 ;; esac
    local image_root="build/portrom/images"
    local vendor_dir="${image_root}/vendor/etc/selinux"
    local vendor_cil="${vendor_dir}/vendor_sepolicy.cil"
    local vendor_debug_cil="${vendor_dir}/vendor_sepolicy_debug.cil"
    [[ -f "${vendor_cil}" && -f "${vendor_debug_cil}" ]] || return 0
    grep -qE '^\(type oplus_hal_displaypanelfeature\)$' "${vendor_cil}" || return 0
    grep -qE '^\(type vendor_qdisplay_service\)$' "${vendor_cil}" || return 0
    grep -qE '^\(type hal_graphics_composer_default\)$' "${vendor_cil}" || return 0

    local -a rules=(
        '(allow oplus_hal_displaypanelfeature vendor_qdisplay_service (service_manager (find)))'
        '(allow oplus_hal_displaypanelfeature hal_graphics_composer_default (binder (call)))'
    )
    local target rule
    for target in "${vendor_cil}" "${vendor_debug_cil}"; do
        for rule in "${rules[@]}"; do
            grep -qF -- "${rule}" "${target}" || printf '%s\n' "${rule}" >> "${target}" || return 1
        done
    done

    local policy_version compiler prod_tmp debug_tmp
    policy_version="$(_port::selinux_policy_version)" || return 0
    compiler="$(_port::selinux_find_compiler 2>/dev/null)" || return 0
    local odm_dir="${image_root}/odm/etc/selinux"
    mkdir -p "${odm_dir}" || return 1
    prod_tmp=$(mktemp "${odm_dir}/.precompiled_sepolicy.XXXXXX") || return 1
    debug_tmp=$(mktemp "${odm_dir}/.precompiled_sepolicy_debug.XXXXXX") || { rm -f "${prod_tmp}"; return 1; }
    if ! _port::selinux_compile_split_policy "${prod_tmp}" "${vendor_cil}" \
        "${vendor_dir}/plat_pub_versioned.cil" \
        "${image_root}/system_ext/etc/selinux/system_ext_sepolicy.cil" \
        "${image_root}/product/etc/selinux/product_sepolicy.cil" "${policy_version}" || \
       ! _port::selinux_compile_split_policy "${debug_tmp}" "${vendor_debug_cil}" \
        "${vendor_dir}/plat_pub_versioned_debug.cil" \
        "${image_root}/system_ext/etc/selinux/system_ext_sepolicy_debug.cil" \
        "${image_root}/product/etc/selinux/product_sepolicy_debug.cil" "${policy_version}"; then
        rm -f "${prod_tmp}" "${debug_tmp}"
        return 0
    fi
    mv -f "${prod_tmp}" "${odm_dir}/precompiled_sepolicy" || return 1
    mv -f "${debug_tmp}" "${odm_dir}/precompiled_sepolicy_debug" || return 1
}
_port::postdata_badging_lines() {
    local apk="$1"
    "${PORT_POSTDATA_AAPT2}" dump badging "${apk}" 2>/dev/null \
        | sed -n -e '/^package: /p' -e '/^overlay: /p' \
            -e '/^sdkVersion:/p' -e '/^targetSdkVersion:/p'
}

_port::postdata_wifi_bool_true() {
    local apk="$1"
    "${PORT_POSTDATA_AAPT2}" dump resources "${apk}" 2>/dev/null | awk '
        /bool\/config_wifiChannelUtilizationOverrideEnabled/ { seen = 1; next }
        seen && /^[[:space:]]*resource / { exit }
        seen && /^[[:space:]]*\(\)[[:space:]]+true[[:space:]]*$/ { found = 1; exit }
        END { exit(found ? 0 : 1) }
    '
}

_port::postdata_backup_once() {
    local source_file="$1"
    local backup_file="$2"

    [[ -f "${source_file}" ]] || return 0
    if [[ ! -e "${backup_file}" ]]; then
        mkdir -p "$(dirname "${backup_file}")" || return 1
        cp -p -- "${source_file}" "${backup_file}" || return 1
    fi
}

_port::postdata_patch_selinux_context_file() {
    local contexts_file="$1"
    local temp_file

    [[ -f "${contexts_file}" ]] || return 1
    temp_file="${contexts_file}.postdata.$$"

    # The old vendor file-contexts generated by the base ROM explicitly label
    # several overlay APKs as vendor_file.  Android 17's zygote and
    # secure_element domains require vendor_overlay_file instead.  Match by
    # basename so both escaped (\.apk) and unescaped input formats work.
    awk '
        BEGIN {
            count = split("FrameworksResTarget_Vendor SecureElementResTarget_Vendor WifiResMainlineTarget WifiResMainlineTarget_spf WifiResTarget WifiResTarget_spf", names, " ");
        }
        {
            for (i = 1; i <= count; ++i) {
                if (index($0, "/vendor/overlay/" names[i]) == 1)
                    sub(/u:object_r:vendor_file:s0[[:space:]]*$/, "u:object_r:vendor_overlay_file:s0");
            }
            print;
        }
    ' "${contexts_file}" > "${temp_file}" || {
        rm -f -- "${temp_file}"
        return 1
    }
    mv -f -- "${temp_file}" "${contexts_file}" || return 1

    # A vendor-specific recursive rule is needed when the platform
    # plat_file_contexts is not consulted for this mixed-ROM vendor tree.
    if ! grep -Fq '/vendor/overlay(/.*)?' "${contexts_file}"; then
        printf '/vendor/overlay(/.*)? u:object_r:vendor_overlay_file:s0\n' >> "${contexts_file}" || return 1
    fi
    if ! grep -Eq '^/dev/ion[[:space:]]' "${contexts_file}"; then
        printf '/dev/ion u:object_r:ion_device:s0\n' >> "${contexts_file}" || return 1
    fi
}

_port::postdata_patch_selinux_contexts() {
    local images_root="$1"
    local backup_root="$2"
    local config_contexts="${images_root}/config/vendor_file_contexts"
    local runtime_contexts="${images_root}/vendor/etc/selinux/vendor_file_contexts"

    if [[ ! -f "${config_contexts}" ]]; then
        error "缺少 vendor_file_contexts，无法修复 EROFS 标签: ${config_contexts}" \
            "vendor_file_contexts is missing; cannot fix EROFS labels: ${config_contexts}"
        return 1
    fi
    _port::postdata_backup_once "${config_contexts}" \
        "${backup_root}/originals/selinux/config_vendor_file_contexts" || return 1
    _port::postdata_patch_selinux_context_file "${config_contexts}" || return 1

    # This file is consumed by later restorecon operations.  Some vendor
    # packages omit it because the platform copy normally supplies the rules;
    # keep that omission non-fatal while still fixing it when present.
    if [[ -f "${runtime_contexts}" ]]; then
        _port::postdata_backup_once "${runtime_contexts}" \
            "${backup_root}/originals/selinux/vendor_file_contexts" || return 1
        _port::postdata_patch_selinux_context_file "${runtime_contexts}" || return 1
    else
        yellow "未找到运行时 vendor_file_contexts，跳过运行时标签补丁" \
            "Runtime vendor_file_contexts is absent; skipping runtime label patch"
    fi
    green "Android 17 SELinux 标签已修复（vendor overlay、/dev/ion）" \
        "Android 17 SELinux labels fixed (vendor overlays and /dev/ion)"
}

_port::postdata_install_omapi_manifest() {
    local images_root="$1"
    local backup_root="$2"
    local source_file="devices/common/android17_compat/odm/etc/vintf/manifest/secure_element_omapi_service.xml"
    local target_file="${images_root}/odm/etc/vintf/manifest/secure_element_omapi_service.xml"

    if [[ ! -f "${source_file}" ]]; then
        error "缺少 Android 17 OMAPI VINTF 片段: ${source_file}" \
            "Android 17 OMAPI VINTF fragment is missing: ${source_file}"
        return 1
    fi
    mkdir -p "$(dirname "${target_file}")" || return 1
    if cmp -s "${source_file}" "${target_file}"; then
        green "android.se.omapi VINTF 声明已存在，保留当前文件" \
            "android.se.omapi VINTF declaration is already present"
        return 0
    fi
    _port::postdata_backup_once "${target_file}" \
        "${backup_root}/originals/odm/etc/vintf/manifest/secure_element_omapi_service.xml" || return 1
    cp -p -- "${source_file}" "${target_file}" || return 1
    if ! grep -Eq '<name>android\.se\.omapi</name>|<name>ISecureElementService</name>|<instance>default</instance>' \
        "${target_file}"; then
        error "安装后的 OMAPI VINTF 片段校验失败" \
            "Installed OMAPI VINTF fragment failed validation"
        return 1
    fi
    green "已补齐 android.se.omapi/ISecureElementService VINTF 声明" \
        "Added android.se.omapi/ISecureElementService VINTF declaration"
}

_port::postdata_disable_incompatible_loc_sys_service() {
    local images_root="$1"
    local backup_root="$2"
    local rc_file="${images_root}/system_ext/etc/init/loc_sys_service.rc"
    local temp_file

    [[ -f "${rc_file}" ]] || {
        yellow "未找到 loc_sys_service.rc，跳过旧 vendor GNSS AIDL 客户端修复" \
            "loc_sys_service.rc is absent; skipping the legacy-vendor GNSS AIDL client fix"
        return 0
    }

    # Android 17's loc_sys_service is only a client of the Qualcomm AIDL
    # extension vendor.qti.gnss.ILocAidlGnss/default.  The reused Android 11
    # vendor supplies the older HIDL services (ILocHidlGnss/gnss_vendor)
    # instead.  Leaving this client enabled makes servicemanager retry a
    # missing lazy service forever, once per second.  Keep the legacy HIDL
    # gnss_service untouched and disable only this optional A17 client.
    if ! grep -Eq '^[[:space:]]+disabled[[:space:]]*$' "${rc_file}" \
        || grep -Eq '^[[:space:]]*start[[:space:]]+loc_sys_service[[:space:]]*$' "${rc_file}" \
        || grep -Eq '^on[[:space:]]+early-boot[[:space:]]*$' "${rc_file}"; then
        _port::postdata_backup_once "${rc_file}" \
            "${backup_root}/originals/system_ext/etc/init/loc_sys_service.rc" || return 1
        temp_file="${rc_file}.postdata.$$"
        awk '
            /^service[[:space:]]+loc_sys_service[[:space:]]/ {
                print
                in_service = 1
                next
            }
            in_service && /^[[:space:]]+disabled[[:space:]]*$/ {
                have_disabled = 1
                print
                next
            }
            in_service && /^[[:space:]]+class[[:space:]]+main[[:space:]]*$/ {
                print
                if (!have_disabled) {
                    print "    disabled"
                    have_disabled = 1
                }
                next
            }
            /^[[:space:]]*on[[:space:]]+early-boot[[:space:]]*$/ {
                print "# Disabled: Android 11 vendor has no Qualcomm GNSS AIDL backend."
                next
            }
            /^[[:space:]]+start[[:space:]]+loc_sys_service[[:space:]]*$/ {
                print "# Disabled: loc_sys_service requires vendor.qti.gnss.ILocAidlGnss/default."
                next
            }
            { print }
            END { exit(have_disabled ? 0 : 1) }
        ' "${rc_file}" > "${temp_file}" || {
            rm -f -- "${temp_file}"
            error "无法禁用不兼容的 loc_sys_service" \
                "Could not disable the incompatible loc_sys_service"
            return 1
        }
        mv -f -- "${temp_file}" "${rc_file}" || return 1
    fi

    if ! grep -Eq '^[[:space:]]+disabled[[:space:]]*$' "${rc_file}" \
        || grep -Eq '^[[:space:]]*start[[:space:]]+loc_sys_service[[:space:]]*$' "${rc_file}" \
        || grep -Eq '^on[[:space:]]+early-boot[[:space:]]*$' "${rc_file}"; then
        error "loc_sys_service 禁用校验失败" \
            "loc_sys_service disable validation failed"
        return 1
    fi
    green "已禁用依赖 AIDL GNSS 的 loc_sys_service，保留旧 HIDL GNSS" \
        "Disabled the AIDL-dependent loc_sys_service; legacy HIDL GNSS remains enabled"
}

_port::postdata_patch_framework_vintf_compat() {
    local images_root="$1"
    local backup_root="$2"
    local matrix_dir="${images_root}/system/system/etc/vintf"
    local fcm5_target="${matrix_dir}/compatibility_matrix.5.xml"
    local device_matrix="${matrix_dir}/compatibility_matrix.device.xml"
    local system_ext_manifest="${images_root}/system_ext/etc/vintf/manifest.xml"
    local fcm5_source=""
    local candidate
    local temp_file
    local need_memtrack=0
    local need_gnss=0
    local -a fcm5_candidates=(
        "devices/common/android17_compat/system/etc/vintf/compatibility_matrix.5.xml"
        "build/ColorOS17_PLK110_17.0.0.1/extracted/system/system/etc/vintf/compatibility_matrix.5.xml"
        "build/portrom_16.0.8/images/system/system/etc/vintf/compatibility_matrix.5.xml"
    )

    [[ -d "${matrix_dir}" ]] || {
        error "缺少 framework VINTF 目录: ${matrix_dir}" \
            "Framework VINTF directory is missing: ${matrix_dir}"
        return 1
    }
    [[ -f "${device_matrix}" ]] || {
        error "缺少 device compatibility matrix: ${device_matrix}" \
            "Device compatibility matrix is missing: ${device_matrix}"
        return 1
    }

    # Android 11 vendor advertises target-level/FCM 5.  Android 17 no longer
    # installs compatibility_matrix.5.xml by default, so VintfObject rejects
    # the vendor before ActivityTaskManager can consider the build consistent.
    if [[ -f "${fcm5_target}" ]]; then
        if ! grep -Eq '<compatibility-matrix[^>]*level="5"' "${fcm5_target}"; then
            error "现有 compatibility_matrix.5.xml 不是 FCM 5 矩阵" \
                "Existing compatibility_matrix.5.xml is not an FCM 5 matrix"
            return 1
        fi
    else
        for candidate in "${fcm5_candidates[@]}"; do
            if [[ -f "${candidate}" ]] && \
                grep -Eq '<compatibility-matrix[^>]*level="5"' "${candidate}"; then
                fcm5_source="${candidate}"
                break
            fi
        done
        if [[ -z "${fcm5_source}" ]]; then
            error "找不到可信的 FCM 5 compatibility matrix 来源" \
                "Could not find a trusted FCM 5 compatibility matrix source"
            return 1
        fi
        _port::postdata_backup_once "${fcm5_target}" \
            "${backup_root}/originals/system/system/etc/vintf/compatibility_matrix.5.xml" || return 1
        mkdir -p "${matrix_dir}" || return 1
        cp -p -- "${fcm5_source}" "${fcm5_target}" || return 1
        if ! grep -Eq '<compatibility-matrix[^>]*level="5"' "${fcm5_target}"; then
            error "安装后的 FCM 5 compatibility matrix 校验失败" \
                "Installed FCM 5 compatibility matrix failed validation"
            return 1
        fi
        green "已补齐 FCM 5 framework compatibility matrix" \
            "Installed the FCM 5 framework compatibility matrix"
    fi

    # The reused vendor boots a 4.19.325 kernel.  A stock V17 FCM 5 matrix
    # only lists the Android R 5.4 kernel, so accepting FCM 5 alone is not
    # enough: VintfObject still rejects the build at boot.  Keep this narrow
    # 4.19.110 requirement alongside the stock entry; the running 4.19.325
    # kernel satisfies it.
    if ! grep -Fq '<kernel version="4.19.110" level="5"/>' "${fcm5_target}"; then
        _port::postdata_backup_once "${fcm5_target}" \
            "${backup_root}/originals/system/system/etc/vintf/compatibility_matrix.5.xml" || return 1
        temp_file="${fcm5_target}.postdata.$$"
        awk '
            !inserted && /<compatibility-matrix[^>]*level="5"/ {
                print
                print "    <!-- The reused Android 11 vendor boots a 4.19.325 kernel. -->"
                print "    <kernel version=\"4.19.110\" level=\"5\"/>"
                inserted = 1
                next
            }
            { print }
            END { exit(inserted ? 0 : 1) }
        ' "${fcm5_target}" > "${temp_file}" || {
            rm -f -- "${temp_file}"
            error "无法在 FCM 5 matrix 中加入 4.19 内核兼容项" \
                "Could not add the 4.19 kernel compatibility entry to FCM 5"
            return 1
        }
        mv -f -- "${temp_file}" "${fcm5_target}" || return 1
    fi

    # The V17 framework matrix omitted the policy version used by this Android
    # 11 vendor.  Keep all newer entries and add only the compatible 30.0 line.
    if ! grep -Fq '<sepolicy-version>30.0</sepolicy-version>' "${device_matrix}"; then
        _port::postdata_backup_once "${device_matrix}" \
            "${backup_root}/originals/system/system/etc/vintf/compatibility_matrix.device.xml" || return 1
        temp_file="${device_matrix}.postdata.$$"
        awk '
            {
                print
                if (!inserted && index($0, "<kernel-sepolicy-version>30</kernel-sepolicy-version>")) {
                    print "        <sepolicy-version>30.0</sepolicy-version>"
                    inserted = 1
                }
            }
            END { exit(inserted ? 0 : 1) }
        ' "${device_matrix}" > "${temp_file}" || {
            rm -f -- "${temp_file}"
            error "无法在 framework matrix 中加入 sepolicy 30.0" \
                "Could not add sepolicy 30.0 to the framework matrix"
            return 1
        }
        mv -f -- "${temp_file}" "${device_matrix}" || return 1
    fi

    [[ -f "${system_ext_manifest}" ]] || {
        error "缺少 system_ext framework manifest: ${system_ext_manifest}" \
            "system_ext framework manifest is missing: ${system_ext_manifest}"
        return 1
    }
    if ! awk '
        /<vendor-ndk>/ { in_ndk = 1 }
        in_ndk && /<version>30<\/version>/ { found = 1 }
        in_ndk && /<\/vendor-ndk>/ { in_ndk = 0 }
        END { exit(found ? 0 : 1) }
    ' "${system_ext_manifest}"; then
        _port::postdata_backup_once "${system_ext_manifest}" \
            "${backup_root}/originals/system_ext/etc/vintf/manifest.xml" || return 1
        temp_file="${system_ext_manifest}.postdata.$$"
        awk '
            !inserted && index($0, "<vendor-ndk>") {
                print "    <vendor-ndk>"
                print "        <version>30</version>"
                print "    </vendor-ndk>"
                inserted = 1
            }
            { print }
            END { exit(inserted ? 0 : 1) }
        ' "${system_ext_manifest}" > "${temp_file}" || {
            rm -f -- "${temp_file}"
            error "无法在 system_ext manifest 中加入 vendor-ndk 30" \
                "Could not add vendor-ndk 30 to the system_ext manifest"
            return 1
        }
        mv -f -- "${temp_file}" "${system_ext_manifest}" || return 1
    fi

    # The reused Android 11 vendor manifest still exposes these HIDL HALs.
    # They are harmless compatibility declarations; the running services stay
    # supplied by the vendor image and are not replaced by an AIDL stub.
    grep -Fq '<name>android.hardware.memtrack</name>' "${device_matrix}" || need_memtrack=1
    grep -Fq '<name>ILocHidlGnss</name>' "${device_matrix}" || need_gnss=1
    if [[ "${need_memtrack}" -eq 1 || "${need_gnss}" -eq 1 ]]; then
        _port::postdata_backup_once "${device_matrix}" \
            "${backup_root}/originals/system/system/etc/vintf/compatibility_matrix.device.xml" || return 1
        temp_file="${device_matrix}.postdata.$$"
        awk -v add_memtrack="${need_memtrack}" -v add_gnss="${need_gnss}" '
            {
                print
                if (!inserted && index($0, "<name>vendor.qti.esepowermanager</name>")) {
                    in_anchor = 1
                }
                if (in_anchor && !inserted && index($0, "</hal>")) {
                    if (add_memtrack == 1) {
                        print "    <hal format=\"hidl\" optional=\"true\">"
                        print "        <name>android.hardware.memtrack</name>"
                        print "        <version>1.0</version>"
                        print "        <interface>"
                        print "            <name>IMemtrack</name>"
                        print "            <instance>default</instance>"
                        print "        </interface>"
                        print "    </hal>"
                    }
                    if (add_gnss == 1) {
                        print "    <hal format=\"hidl\">"
                        print "        <name>vendor.qti.gnss</name>"
                        print "        <version>1.0-2</version>"
                        print "        <version>2.0-1</version>"
                        print "        <version>3.0</version>"
                        print "        <version>4.0-3</version>"
                        print "        <interface>"
                        print "            <name>ILocHidlGnss</name>"
                        print "            <instance>gnss_vendor</instance>"
                        print "        </interface>"
                        print "    </hal>"
                    }
                    inserted = 1
                }
            }
            END { exit(inserted ? 0 : 1) }
        ' "${device_matrix}" > "${temp_file}" || {
            rm -f -- "${temp_file}"
            error "无法在 device compatibility matrix 中加入旧 HAL 兼容项" \
                "Could not add legacy HAL compatibility entries to the device matrix"
            return 1
        }
        mv -f -- "${temp_file}" "${device_matrix}" || return 1
    fi

    if ! grep -Fq '<kernel version="4.19.110" level="5"/>' "${fcm5_target}" \
        || ! grep -Fq '<sepolicy-version>30.0</sepolicy-version>' "${device_matrix}" \
        || ! grep -Fq '<name>android.hardware.memtrack</name>' "${device_matrix}" \
        || ! grep -Fq '<name>ILocHidlGnss</name>' "${device_matrix}"; then
        error "framework VINTF 兼容项最终校验失败" \
            "Final framework VINTF compatibility validation failed"
        return 1
    fi
    green "已加入 Android 11 vendor 的 FCM5/VNDK30 与旧 HAL 兼容项" \
        "Added FCM5/VNDK30 and legacy HAL compatibility for the Android 11 vendor"
}

_port::postdata_patch_nfc_defaults() {
    local images_root="$1"
    local backup_root="$2"
    local prop_file="${images_root}/my_product/build.prop"
    local temp_file

    if [[ ! -f "${prop_file}" ]]; then
        yellow "缺少 my_product/build.prop，跳过 NFC 默认值修复" \
            "my_product/build.prop is missing; skipping NFC default properties"
        return 0
    fi

    _port::postdata_backup_once "${prop_file}" \
        "${backup_root}/originals/my_product/build.prop" || return 1
    temp_file="${prop_file}.postdata.$$"
    awk '
        /^persist\.nfc\.smartcard\.recorder\.enable=/ {
            if (!smartcard_seen++) print "persist.nfc.smartcard.recorder.enable=false"
            next
        }
        /^persist\.nfc\.vendor_debug_enabled=/ {
            if (!vendor_seen++) print "persist.nfc.vendor_debug_enabled=false"
            next
        }
        /^persist\.nfc\.snoop_log_mode=/ {
            if (!snoop_seen++) print "persist.nfc.snoop_log_mode=filtered"
            next
        }
        { print }
        END {
            if (!smartcard_seen) print "persist.nfc.smartcard.recorder.enable=false"
            if (!vendor_seen) print "persist.nfc.vendor_debug_enabled=false"
            if (!snoop_seen) print "persist.nfc.snoop_log_mode=filtered"
        }
    ' "${prop_file}" > "${temp_file}" || {
        rm -f -- "${temp_file}"
        return 1
    }
    mv -f -- "${temp_file}" "${prop_file}" || return 1

    if [[ "$(grep -cFx 'persist.nfc.smartcard.recorder.enable=false' "${prop_file}")" -ne 1 ]] \
        || [[ "$(grep -cFx 'persist.nfc.vendor_debug_enabled=false' "${prop_file}")" -ne 1 ]] \
        || [[ "$(grep -cFx 'persist.nfc.snoop_log_mode=filtered' "${prop_file}")" -ne 1 ]]; then
        error "NFC 默认属性最终校验失败" "Final NFC default property validation failed"
        return 1
    fi
    green "已关闭 NFC 调试/智能卡记录默认值" \
        "Disabled NFC debug and smart-card recording by default"
}

_port::postdata_install_vendor_ueventd_compat() {
    local images_root="$1"
    local backup_root="$2"
    local target_file="${images_root}/vendor/etc/ueventd.rc"
    local legacy_file="${images_root}/vendor/ueventd.rc"
    local target_size=0

    # Android 17's system/etc/ueventd.rc imports /vendor/etc/ueventd.rc.
    # The SM8250 Android 11 vendor keeps the actual rules at /vendor/ueventd.rc
    # instead, so without this tiny bridge all legacy /dev permissions and
    # firmware_directories rules are silently skipped by ueventd.
    if [[ ! -f "${legacy_file}" ]]; then
        yellow "缺少 legacy vendor/ueventd.rc，跳过 ueventd 兼容桥" \
            "Legacy vendor/ueventd.rc is missing; skipping the ueventd bridge"
        return 0
    fi

    if [[ -f "${target_file}" ]]; then
        if grep -Eq '^[[:space:]]*import[[:space:]]+/vendor/ueventd\.rc[[:space:]]*$' \
            "${target_file}"; then
            green "vendor ueventd 兼容桥已存在" \
                "Vendor ueventd compatibility bridge already exists"
            return 0
        fi
        target_size="$(stat -c '%s' "${target_file}" 2>/dev/null || printf '0')"
        # Do not replace a complete modern vendor ueventd file.  Only replace
        # the old empty/short stub; a full file already contains its own rules.
        if [[ "${target_size}" -gt 1024 ]]; then
            yellow "保留现有完整 vendor/etc/ueventd.rc（${target_size} bytes）" \
                "Keeping existing complete vendor/etc/ueventd.rc (${target_size} bytes)"
            return 0
        fi
    fi

    _port::postdata_backup_once "${target_file}" \
        "${backup_root}/originals/vendor/etc/ueventd.rc" || return 1
    mkdir -p "$(dirname "${target_file}")" || return 1
    printf '%s\n' \
        '# Android 17 reads vendor uevent rules from /vendor/etc/ueventd.rc.' \
        '# Import the legacy vendor layout used by this Android 11 device image.' \
        'import /vendor/ueventd.rc' > "${target_file}" || return 1
    chmod 0644 "${target_file}" || return 1
    if ! grep -Eq '^import /vendor/ueventd\.rc$' "${target_file}"; then
        error "vendor ueventd 兼容桥写入失败" \
            "Failed to install vendor ueventd compatibility bridge"
        return 1
    fi
    green "已补齐 vendor/etc/ueventd.rc → /vendor/ueventd.rc 兼容桥" \
        "Added vendor/etc/ueventd.rc -> /vendor/ueventd.rc compatibility bridge"
}

_port::postdata_replace_audio_effect_center() {
    local images_root="$1"
    local backup_root="$2"
    local source_img=""
    local source_type=""
    local extract_root=""
    local source_dir=""
    local target_dir="${images_root}/my_product/app/AudioEffectCenter"
    local candidate
    local source_file
    local relative_file
    local target_file
    local -a source_candidates=()
    local gettype_tool="${tools_dir:-bin/Linux/x86_64}/gettype"
    local erofs_tool="${tools_dir:-bin/Linux/x86_64}/extract.erofs"
    local imgextractor="${work_dir:-.}/bin/imgextractor/imgextractor.py"

    # stage 30 keeps the unmodified port image in the cache/version directory;
    # the copy in images/ is also available before stage 50 repacks it.
    [[ -n "${portrom_cache_dir:-}" ]] && \
        source_candidates+=("${portrom_cache_dir%/}/my_product.img")
    [[ -n "${version_name:-}" ]] && \
        source_candidates+=("build/${version_name}/my_product.img")
    source_candidates+=("${images_root}/my_product.img")
    for candidate in "${source_candidates[@]}"; do
        if [[ -f "${candidate}" ]]; then
            source_img="${candidate}"
            break
        fi
    done
    if [[ -z "${source_img}" ]]; then
        yellow "找不到原始 Android 17 my_product.img，跳过 AudioEffectCenter 修复" \
            "Original Android 17 my_product.img is unavailable; skipping AudioEffectCenter fix"
        return 0
    fi
    if [[ ! -x "${gettype_tool}" || ! -x "${erofs_tool}" ]]; then
        error "缺少 EROFS 提取工具，无法恢复 Android 17 AudioEffectCenter" \
            "EROFS extraction tools are missing; cannot restore Android 17 AudioEffectCenter"
        return 1
    fi

    extract_root="$(mktemp -d "${TMPDIR:-/tmp}/a17-audio-effect.XXXXXX")" || return 1
    source_type="$(${gettype_tool} -i "${source_img}" 2>/dev/null || true)"
    case "${source_type}" in
        erofs)
            if ! "${erofs_tool}" -X /app/AudioEffectCenter -i "${source_img}" \
                -o "${extract_root}" >/dev/null 2>&1; then
                rm -rf -- "${extract_root}"
                error "提取 Android 17 AudioEffectCenter 失败: ${source_img}" \
                    "Failed to extract Android 17 AudioEffectCenter: ${source_img}"
                return 1
            fi
            ;;
        ext)
            if [[ ! -f "${imgextractor}" ]] || ! python3 "${imgextractor}" \
                "${source_img}" "${extract_root}" >/dev/null 2>&1; then
                rm -rf -- "${extract_root}"
                error "提取 ext my_product.img 失败: ${source_img}" \
                    "Failed to extract ext my_product.img: ${source_img}"
                return 1
            fi
            ;;
        *)
            rm -rf -- "${extract_root}"
            error "无法识别 my_product.img 文件系统: ${source_type:-unknown}" \
                "Unknown my_product.img filesystem: ${source_type:-unknown}"
            return 1
            ;;
    esac

    source_dir="${extract_root}/my_product/app/AudioEffectCenter"
    # imgextractor/extract.erofs versions in older tool bundles differ on
    # whether the partition basename is included in the output root.
    if [[ ! -d "${source_dir}" && -d "${extract_root}/app/AudioEffectCenter" ]]; then
        source_dir="${extract_root}/app/AudioEffectCenter"
    fi
    if [[ ! -f "${source_dir}/AudioEffectCenter.apk" ]]; then
        rm -rf -- "${extract_root}"
        yellow "Android 17 my_product 未提供 AudioEffectCenter，保留移植包当前版本" \
            "Android 17 my_product has no AudioEffectCenter; keeping the port version"
        return 0
    fi

    # Preserve every old file before replacing the directory, including stale
    # odex/vdex files that could otherwise be paired with the wrong APK.
    if [[ -d "${target_dir}" ]]; then
        while IFS= read -r -d '' source_file; do
            relative_file="${source_file#${target_dir}/}"
            _port::postdata_backup_once "${source_file}" \
                "${backup_root}/originals/my_product/app/AudioEffectCenter/${relative_file}" || {
                rm -rf -- "${extract_root}"
                return 1
            }
        done < <(find "${target_dir}" -type f -print0)
    fi
    rm -rf -- "${target_dir}" || { rm -rf -- "${extract_root}"; return 1; }
    mkdir -p "$(dirname "${target_dir}")" || { rm -rf -- "${extract_root}"; return 1; }
    cp -a -- "${source_dir}" "${target_dir}" || { rm -rf -- "${extract_root}"; return 1; }
    target_file="${target_dir}/AudioEffectCenter.apk"
    if ! cmp -s "${source_dir}/AudioEffectCenter.apk" "${target_file}"; then
        rm -rf -- "${extract_root}"
        error "AudioEffectCenter APK 替换后校验失败" \
            "AudioEffectCenter APK failed verification after replacement"
        return 1
    fi
    rm -rf -- "${extract_root}"
    green "已恢复 Android 17 AudioEffectCenter APK/vdex（来源 ${source_img}）" \
        "Restored Android 17 AudioEffectCenter APK/vdex from ${source_img}"
}

_port::postdata_map_dir() {
    local root="$1"
    local partition="$2"
    local candidate

    case "${partition}" in
        system)
            for candidate in \
                "${root}/system/system/etc/selinux/mapping" \
                "${root}/system/etc/selinux/mapping" \
                "${root}/system" \
                "${root}/etc/selinux/mapping" \
                "${root}"; do
                [[ -d "${candidate}" ]] && { printf '%s\n' "${candidate}"; return 0; }
            done
            ;;
        system_ext|product)
            for candidate in \
                "${root}/${partition}/etc/selinux/mapping" \
                "${root}/${partition}" \
                "${root}/etc/selinux/mapping"; do
                [[ -d "${candidate}" ]] && { printf '%s\n' "${candidate}"; return 0; }
            done
            ;;
    esac
    return 1
}

_port::postdata_map_file_valid() {
    local file="$1"
    [[ -s "${file}" ]] || return 1
    grep -Eq '^\((type|typeattribute|typeattributeset|expandtypeattribute|roletype|allow|neverallow)[[:space:]]' "${file}"
}

_port::postdata_map_pair_valid() {
    local dir="$1"
    _port::postdata_map_file_valid "${dir}/30.0.cil" \
        && _port::postdata_map_file_valid "${dir}/30.0.compat.cil"
}

_port::postdata_map_source_root() {
    local explicit_source="${PORT_SELINUX_MAP_SOURCE:-}"
    local candidate
    local system_dir
    local system_ext_dir
    local product_dir

    if [[ -n "${explicit_source}" ]]; then
        system_dir="$(_port::postdata_map_dir "${explicit_source}" system 2>/dev/null || true)"
        system_ext_dir="$(_port::postdata_map_dir "${explicit_source}" system_ext 2>/dev/null || true)"
        product_dir="$(_port::postdata_map_dir "${explicit_source}" product 2>/dev/null || true)"
        if [[ -n "${system_dir}" ]] && _port::postdata_map_pair_valid "${system_dir}" \
            && [[ -n "${system_ext_dir}" && -f "${system_ext_dir}/30.0.cil" ]] \
            && [[ -n "${product_dir}" && -f "${product_dir}/30.0.cil" ]]; then
            printf '%s\n' "${explicit_source}"
            return 0
        fi
        return 1
    fi

    # The common mapping is the local default; it belongs in a separately
    # provenance-reviewed device resource bundle. Workspace locations below
    # are only migration fallbacks. Never rename the Android 17 31.0 mapping
    # to 30.0 or guess the ABI from an unverified A17 system policy.
    local -a candidates=(
        "devices/common/selinux_mapping/android11_vendor"
    )
    shopt -s nullglob
    candidates+=(devices/common/selinux_mapping/android16)
    candidates+=(devices/*/selinux_mapping/android16)
    shopt -u nullglob

    for candidate in "${candidates[@]}"; do
        system_dir="$(_port::postdata_map_dir "${candidate}" system 2>/dev/null || true)"
        system_ext_dir="$(_port::postdata_map_dir "${candidate}" system_ext 2>/dev/null || true)"
        product_dir="$(_port::postdata_map_dir "${candidate}" product 2>/dev/null || true)"
        if [[ -n "${system_dir}" ]] && _port::postdata_map_pair_valid "${system_dir}" \
            && [[ -n "${system_ext_dir}" && -f "${system_ext_dir}/30.0.cil" ]] \
            && [[ -n "${product_dir}" && -f "${product_dir}/30.0.cil" ]]; then
            printf '%s\n' "${candidate}"
            return 0
        fi
    done
    return 1
}

_port::postdata_install_mapping() {
    local source_root="$1"
    local images_root="$2"
    local backup_root="$3"
    local partition="$4"
    local required="$5"
    local source_dir
    local target_dir
    local name
    local source_file
    local target_file
    local backup_file
    local installed=0
    local file_required

    source_dir="$(_port::postdata_map_dir "${source_root}" "${partition}" 2>/dev/null || true)"
    case "${partition}" in
        system) target_dir="${images_root}/system/system/etc/selinux/mapping" ;;
        system_ext|product) target_dir="${images_root}/${partition}/etc/selinux/mapping" ;;
        *) return 1 ;;
    esac

    for name in 30.0.cil 30.0.compat.cil; do
        file_required="${required}"
        [[ "${name}" == "30.0.compat.cil" && "${partition}" != "system" ]] && file_required="false"
        target_file="${target_dir}/${name}"
        if _port::postdata_map_file_valid "${target_file}"; then
            blue "已存在有效 ${partition}/${name}，保留当前文件" \
                "Keeping existing valid ${partition}/${name}"
            continue
        fi

        source_file="${source_dir}/${name}"
        if [[ -z "${source_dir}" || ! -f "${source_file}" ]] \
            || ! _port::postdata_map_file_valid "${source_file}"; then
            if [[ "${file_required}" == "true" ]]; then
                error "缺少可信 SELinux mapping: ${partition}/${name}" \
                    "Missing trusted SELinux mapping: ${partition}/${name}"
                return 1
            fi
            yellow "来源没有可用 ${partition}/${name}，跳过可选文件" \
                "No usable ${partition}/${name} in source; skipping optional file"
            continue
        fi

        backup_file="${backup_root}/originals/${partition}/${name}"
        _port::postdata_backup_once "${target_file}" "${backup_file}" || return 1
        mkdir -p "${target_dir}" || return 1
        cp -p -- "${source_file}" "${target_file}" || return 1
        if ! _port::postdata_map_file_valid "${target_file}"; then
            error "安装后 SELinux mapping 校验失败: ${target_file}" \
                "SELinux mapping validation failed after install: ${target_file}"
            return 1
        fi
        installed=1
        blue "补齐 ${partition}/${name}（来源 ${source_root}）" \
            "Installed ${partition}/${name} from ${source_root}"
    done

    return 0
}

# SHA-256 of a file (from upstream functions.sh; used to log SELinux mapping hashes).
port_sha256_file() {
    local file="${1:-}"
    local output=""
    [[ -f "${file}" ]] || return 1
    if command -v sha256sum >/dev/null 2>&1; then
        output=$(sha256sum -- "${file}") || return 1
    elif command -v shasum >/dev/null 2>&1; then
        output=$(shasum -a 256 "${file}") || return 1
    else
        return 1
    fi
    printf '%s\n' "${output%% *}"
}

_port::postdata_prepare_mapping() {
    local images_root="$1"
    local backup_root="$2"
    local source_root

    source_root="$(_port::postdata_map_source_root 2>/dev/null || true)"
    if [[ -z "${source_root}" ]]; then
        error "找不到可信 Android 16/30.0 SELinux mapping 来源" \
            "Could not find a trusted Android 16/30.0 SELinux mapping source"
        return 1
    fi
    blue "使用 SELinux 30.0 mapping 来源: ${source_root}" \
        "Using SELinux 30.0 mapping source: ${source_root}"

    _port::postdata_install_mapping "${source_root}" "${images_root}" "${backup_root}" system true || return 1
    _port::postdata_install_mapping "${source_root}" "${images_root}" "${backup_root}" system_ext true || return 1
    _port::postdata_install_mapping "${source_root}" "${images_root}" "${backup_root}" product true || return 1

    for _postdata_map in \
        "${images_root}/system/system/etc/selinux/mapping/30.0.cil" \
        "${images_root}/system/system/etc/selinux/mapping/30.0.compat.cil"; do
        if ! _port::postdata_map_file_valid "${_postdata_map}"; then
            error "最终 system 30.0 mapping 无效: ${_postdata_map}" \
                "Final system 30.0 mapping is invalid: ${_postdata_map}"
            return 1
        fi
        _postdata_map_hash="$(port_sha256_file "${_postdata_map}")" || return 1
        blue "SELinux mapping SHA-256: ${_postdata_map_hash}" \
            "SELinux mapping SHA-256: ${_postdata_map_hash}"
    done
}

_port::stage_postdata_compat() {
    local images_root="build/portrom/images"
    local backup_root="build/diagnostics/boot-postdata-compat-pipeline"
    local qspm_policy="${images_root}/vendor/etc/seccomp_policy/qspm.policy"
    local wifi_rro="${images_root}/system_ext/overlay/OplusWifiResource.apk"
    local framework_res="${images_root}/system/system/framework/framework-res.apk"
    local oplus_framework_res="${images_root}/system_ext/framework/oplus-framework-res.apk"
    local apkeditor_jar="bin/apktool/APKEditor.jar"
    local aapt2="otatools/bin/aapt2"
    local apksigner="otatools/bin/apksigner"
    local signing_key="otatools/key/testkey.pk8"
    local signing_cert="otatools/key/testkey.x509.pem"
    local private_tmp=""
    local decoded_dir=""
    local unsigned_apk=""
    local signed_apk=""
    local original_meta=""
    local rebuilt_meta=""
    local bool_file=""
    local qspm_tmp=""

    case "${port_android_version:-}" in
        16|17) ;;
        *)
            blue "跳过 Android 16/17 开机后兼容修复（当前 Android ${port_android_version:-unknown}）" \
                "Skipping Android 16/17 post-data compatibility fixes (Android ${port_android_version:-unknown})"
            return 0
            ;;
    esac

    PORT_POSTDATA_AAPT2="${aapt2}"
    export PORT_POSTDATA_AAPT2
    mkdir -p "${backup_root}/originals" || return 1

    # The mapping, VINTF, seccomp, SELinux, NFC, and AudioEffectCenter changes
    # are Android-17-only.  Android 16 needs only the isolated Wi-Fi RRO
    # compatibility flag below, so it keeps its original vendor/framework
    # compatibility surface.
    if [[ "${port_android_version:-}" == "17" ]]; then
        _port::postdata_prepare_mapping "${images_root}" "${backup_root}" || return 1

        # These fixes must happen before stage 50 runs fspatch.py/contextpatch.py
        # and repacks the EROFS images.
        _port::postdata_install_omapi_manifest "${images_root}" "${backup_root}" || return 1
        _port::postdata_disable_incompatible_loc_sys_service "${images_root}" "${backup_root}" || return 1
        _port::postdata_patch_framework_vintf_compat "${images_root}" "${backup_root}" || return 1
        _port::postdata_patch_nfc_defaults "${images_root}" "${backup_root}" || return 1
        _port::postdata_install_vendor_ueventd_compat "${images_root}" "${backup_root}" || return 1
        _port::postdata_patch_selinux_contexts "${images_root}" "${backup_root}" || return 1
        _port::postdata_replace_audio_effect_center "${images_root}" "${backup_root}" || return 1

        # Modify the qspm policy only when the target file exists; its absence
        # means this vendor has no such policy file.
        if [[ -f "${qspm_policy}" ]]; then
            _port::postdata_backup_once "${qspm_policy}" "${backup_root}/originals/qspm.policy" || return 1
            if ! grep -qxF 'renameat2: 1' "${qspm_policy}"; then
                qspm_tmp="${qspm_policy}.postdata.$$"
                if grep -qxF 'renameat: 1' "${qspm_policy}"; then
                    awk '{ print; if ($0 == "renameat: 1") print "renameat2: 1" }' \
                        "${qspm_policy}" > "${qspm_tmp}" || return 1
                else
                    cat "${qspm_policy}" > "${qspm_tmp}" || return 1
                    printf '\nrenameat2: 1\n' >> "${qspm_tmp}"
                fi
                mv -f -- "${qspm_tmp}" "${qspm_policy}" || return 1
            fi
            if [[ "$(grep -cFx 'renameat2: 1' "${qspm_policy}")" -ne 1 ]]; then
                error "qspm.policy 中 renameat2: 1 数量异常" "qspm.policy has an invalid renameat2 rule count"
                return 1
            fi
            green "Android 17 qspm 已放行 renameat2" "Android 17 qspm allows renameat2"
        else
            yellow "未找到 ${qspm_policy}，跳过 qspm 修复" \
                "${qspm_policy} not found; skipping qspm fix"
        fi
    fi

    # The Wi-Fi resource guard is shared by Android 16 and Android 17.  It is
    # intentionally the only compatibility edit applied to Android 16 here.
    if [[ ! -f "${wifi_rro}" ]]; then
        yellow "未找到 OplusWifiResource.apk，跳过 Wi-Fi RRO 修复" \
            "OplusWifiResource.apk not found; skipping Wi-Fi RRO fix"
        return 0
    fi
    if [[ ! -f "${framework_res}" || ! -f "${oplus_framework_res}" ]]; then
        yellow "缺少 Android 17 framework 资源，跳过 Wi-Fi RRO 修复" \
            "Android 17 framework resources are incomplete; skipping Wi-Fi RRO fix"
        return 0
    fi
    for _postdata_tool in "${apkeditor_jar}" "${aapt2}" "${apksigner}" "${signing_key}" "${signing_cert}"; do
        if [[ ! -f "${_postdata_tool}" ]]; then
            error "缺少 Android 17 RRO 工具或签名材料: ${_postdata_tool}" \
                "Missing Android 17 RRO tool or signing material: ${_postdata_tool}"
            return 1
        fi
    done

    _port::postdata_backup_once "${wifi_rro}" "${backup_root}/originals/OplusWifiResource.apk" || return 1
    original_meta="$(_port::postdata_badging_lines "${wifi_rro}")"
    if [[ -z "${original_meta}" ]]; then
        error "无法读取 OplusWifiResource.apk 的 manifest 元数据" \
            "Could not read OplusWifiResource.apk manifest metadata"
        return 1
    fi

    # An already-fixed APK is verified directly to avoid repeated decode and
    # re-sign; keeps the stage idempotent.
    if _port::postdata_wifi_bool_true "${wifi_rro}"; then
        if ! "${apksigner}" verify --verbose "${wifi_rro}" >/dev/null 2>&1; then
            error "现有 OplusWifiResource.apk 签名验证失败" \
                "Existing OplusWifiResource.apk failed signature verification"
            return 1
        fi
        green "OplusWifiResource.apk 已是兼容配置，跳过重编译" \
            "OplusWifiResource.apk already has the compatibility flag"
        return 0
    fi

    private_tmp="$(mktemp -d "${TMPDIR:-/tmp}/postdata-compat.XXXXXX")" || return 1
    decoded_dir="${private_tmp}/OplusWifiResource"
    unsigned_apk="${private_tmp}/OplusWifiResource-unsigned.apk"
    signed_apk="${private_tmp}/OplusWifiResource-signed.apk"

    if ! java -jar "${apkeditor_jar}" d -f -t xml \
        -i "${wifi_rro}" -o "${decoded_dir}" \
        -framework "${framework_res}" -framework "${oplus_framework_res}"; then
        error "使用 APKEditor 解码 OplusWifiResource.apk 失败" \
            "APKEditor failed to decode OplusWifiResource.apk"
        return 1
    fi

    bool_file="$(grep -R -l --include='bools.xml' 'config_wifiChannelUtilizationOverrideEnabled' \
        "${decoded_dir}" 2>/dev/null | head -n 1)"
    if [[ -z "${bool_file}" ]]; then
        error "RRO 中不存在 config_wifiChannelUtilizationOverrideEnabled" \
            "RRO does not contain config_wifiChannelUtilizationOverrideEnabled"
        return 1
    fi
    sed -E -i \
        's#(<bool[[:space:]]+name="config_wifiChannelUtilizationOverrideEnabled">)[^<]*(</bool>)#\1true\2#' \
        "${bool_file}"
    if ! grep -Eq '<bool[[:space:]]+name="config_wifiChannelUtilizationOverrideEnabled">true</bool>' "${bool_file}"; then
        error "写入 Wi-Fi channel utilization 兼容值失败" \
            "Failed to set the Wi-Fi channel utilization compatibility value"
        return 1
    fi

    if ! java -jar "${apkeditor_jar}" b -f \
        -i "${decoded_dir}" -o "${unsigned_apk}" \
        -framework "${framework_res}" -framework "${oplus_framework_res}"; then
        error "使用 APKEditor 重编译 OplusWifiResource.apk 失败" \
            "APKEditor failed to rebuild OplusWifiResource.apk"
        return 1
    fi
    if ! "${apksigner}" sign --in "${unsigned_apk}" --out "${signed_apk}" \
        --key "${signing_key}" --cert "${signing_cert}" \
        --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true; then
        error "OplusWifiResource.apk 签名失败" "Failed to sign OplusWifiResource.apk"
        return 1
    fi
    if ! "${apksigner}" verify --verbose "${signed_apk}"; then
        error "重编译后的 OplusWifiResource.apk 签名验证失败" \
            "Rebuilt OplusWifiResource.apk failed signature verification"
        return 1
    fi
    if ! _port::postdata_wifi_bool_true "${signed_apk}"; then
        error "重编译 APK 的 Wi-Fi 兼容值不是 true" \
            "Rebuilt APK does not contain the Wi-Fi compatibility value"
        return 1
    fi
    rebuilt_meta="$(_port::postdata_badging_lines "${signed_apk}")"
    if [[ "${original_meta}" != "${rebuilt_meta}" ]]; then
        error "RRO manifest/overlay 元数据发生变化，拒绝替换" \
            "RRO manifest/overlay metadata changed; refusing replacement"
        return 1
    fi

    chmod --reference="${wifi_rro}" "${signed_apk}" 2>/dev/null || true
    cp -p -- "${signed_apk}" "${wifi_rro}" || return 1
    green "Android 17 OplusWifiResource.apk 修复并签名完成" \
        "Android 17 OplusWifiResource.apk rebuilt and signed"
    return 0
}
