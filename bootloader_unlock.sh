#!/bin/bash

#
#    This file is create by liunianliang
#    For download all img by fastboot
#    2018/01/17
#

# set path
if [ -z "`which fastboot`" ] && [ -e "fastboot" ];then
    for i in `echo $PATH | sed -e 's/:/ /g'`;do
        cp -rf fastboot $i/fastboot > /dev/null
    done
    export PATH=`pwd`:$PATH
fi

# check fastboot tool
if [ -z "`which fastboot`" ];then
    echo -e "Error: No fastboot tool found !!!"
    exit 1
fi

# default platform
default_platform="sdm636"

# default buildtype
default_buildtype="eng"

# default slot
default_slot="a"

# get platform from fastboot command
platform=`fastboot getvar platform 2>&1 | grep platform | awk '{print $NF}'`

# get build-type from fastboot command
buildtype=`fastboot getvar build-type 2>&1 | grep build-type | awk '{print $NF}'`

# get slot from fastboot command
slot=`fastboot getvar current-slot 2>&1 | grep current-slot | awk '{print $NF}'`

secret_key=`fastboot getvar secret-key-opt 2>&1 | grep secret-key-opt | awk '{print $NF}'`
secret_partition=`fastboot oem get_random_partition 2>&1 | grep bootloader | awk '{print $NF}'`

if [ -z "$platform" ];then
    platform="$default_platform"
fi

if [ -z "$buildtype" ];then
    buildtype="$default_buildtype"
fi

if [ -z "$slot" ];then
    slot="$default_slot"
fi

if [ "$buildtype" = "user" ];then
    echo $secret_key > default_key.bin
    fastboot flash $secret_partition default_key.bin
    fastboot flashing unlock
    fastboot flashing unlock_critical
fi

# function of download
split=$(printf "%-60s" "-")
function flash_one_image() {
    echo -e "\n${split// /-}"
    if [ -e "${platform}_$2" ];then
        echo -e "\E[0;32mbegin fastboot download ${platform}_$2\E[00m\n"
        fastboot flash $1 ${platform}_$2
    elif [ -e "$2" ];then
        echo -e "\E[0;32mbegin fastboot download $2\E[00m\n"
        fastboot flash $1 $2
    else
        echo -e "\E[1;31mCan't find file: $2 or ${platform}_$2, Skip!\E[00m\n"
    fi
}

echo -e "\nAll is download,do you want to reboot(y/n) ?"
read x
if [ "$x" == "y" ] || [ "$x" == "Y" ];then
    fastboot oem recovery_and_reboot
fi

