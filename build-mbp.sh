#!/bin/bash

setenforce 0

set -eu -o pipefail

runuser -l Eric_Vader -c "git clone git@github.com:eric-vader/Fedora-SoC.git ~/Workspace/mbp-fedora/Fedora-SoC"
rsync -av --exclude=".*" Fedora-SoC/ ./

KICKSTART_LBL=Fedora-SoC-Mac
FEDORA_KICKSTARTS_GIT_URL=https://pagure.io/fedora-kickstarts.git
FEDORA_KICKSTARTS_BRANCH_NAME=f32
FEDORA_KICKSTARTS_COMMIT_HASH=43675318443ff0b57fcc8b2b47b213126616c2d8        # https://pagure.io/fedora-kickstarts/commits/f32
LIVECD_CACHE_PATH=/var/cache/live

### Debug commands
echo "FEDORA_KICKSTARTS_BRANCH_NAME=${FEDORA_KICKSTARTS_BRANCH_NAME}"
echo "FEDORA_KICKSTARTS_COMMIT_HASH=${FEDORA_KICKSTARTS_COMMIT_HASH}"
pwd
ls
echo "CPU threads: $(nproc --all)"
grep 'model name' /proc/cpuinfo | uniq

### Dependencies
dnf install -y git livecd-tools zip

### Copy efibootmgr fix for anaconda
mkdir -p /tmp/kickstart_files/
cp -rfv files/* /tmp/kickstart_files/

### Clone Fedora kickstarts repo
git clone --single-branch --branch ${FEDORA_KICKSTARTS_BRANCH_NAME} ${FEDORA_KICKSTARTS_GIT_URL}
cd fedora-kickstarts
git checkout $FEDORA_KICKSTARTS_COMMIT_HASH

### Copy fedora-mbp kickstart file
cp -rfv ../fedora-mbp.ks ./
cp -rfv ../fedora-live-soc.ks ./
mkdir -p ${LIVECD_CACHE_PATH}

### Generate LiveCD iso
livecd-creator --verbose --config=fedora-mbp.ks --fslabel=${KICKSTART_LBL} --cache=${LIVECD_CACHE_PATH}
livecd_exitcode=$?

### Zip iso and split it into multiple parts - github max size of release attachment is 2GB, where ISO is sometimes bigger than that
mkdir -p ./output_zip
zip -s 1500m ./output_zip/livecd.zip ./*.iso

### Calculate sha256 sums of built ISO
sha256sum ./*.iso > ./output_zip/sha256

find ./ | grep ".iso"
find ./ | grep ".zip"
kill "$bgPID"

exit $livecd_exitcode
