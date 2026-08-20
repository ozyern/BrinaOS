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
    curl -L ${module_repo}/raw/refs/heads/${module_repo_branch}/${module_name}/files.zip -o cache/${module_name}/files.zip
    curl -L ${module_repo}/raw/refs/heads/${module_repo_branch}/${module_name}/script.sh -o cache/${module_name}/script.sh
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
