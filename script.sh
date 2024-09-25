#!/usr/bin/env bash

# Clang Toolchain Pusher

# Colors
NC="\033[0m"
RED="\033[0;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"

# Variables
Android_Toolchain_Repo="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86"
GL_REF="gitlab.com/crazyuploader/clang-toolchain.git"
ROOT_DIR="$(pwd)"

# Install Git LFS
cd /tmp
curl -sLo git-lfs-linux.tar.gz https://github.com/git-lfs/git-lfs/releases/download/v3.5.1/git-lfs-linux-amd64-v3.5.1.tar.gz
tar xvf git-lfs-linux.tar.gz
cd git-lfs-3.5.1
./install.sh
cd $ROOT_DIR

# Getting my Clang Toolchain Repo from GitLab
git clone https://"${GL_REF}" -b master clang
cd clang || exit

# Getting AOSP Clang Toolchain from Google
git clone --depth=1 "${Android_Toolchain_Repo}" AOSP_REPO
exit_code="$(echo $?)"
if [[ ${exit_code} == "0" ]]; then
	echo ""
	echo -e "${YELLOW}Clone OK${NC}"
	cd AOSP_REPO || exit
else
	echo -e "${RED}Clone Failure${NC}"
	exit 1
fi
for f in clang-r*; do
	echo "${f}" >> /dev/null 2>&1
done
TOOL_NAME="${f}"
echo ""
echo "Choosing AOSP Clang Toolchain ---> ${TOOL_NAME}"
echo ""
echo "Getting things ready..."
echo ""
mv ${TOOL_NAME}/* ../clang
cd ..
cd clang || exit
CLANG_VERSION="$(./bin/clang --version)"
echo -e "${GREEN}Clang-Toolchain Version:${NC} ${CLANG_VERSION}"
echo ""
echo "Creating 'README.md'"
echo -e "# AOSP Clang-Toolchain\n\n***Clang Version:***  ${CLANG_VERSION}">> README.md

# Setting Git Identity
git config --global user.email "4677226-crazyuploader@users.noreply.gitlab.com"
git config --global user.name "Jugal Kishore"

# Install Git LFS
git lfs install
git lfs track "*.so"
git lfs track "bin/clang-*"

# Pushing to GitLab Repo at https://gitlab.com/crazyuploader/clang-toolchain
echo ""
if [[ -z $(git status --porcelain) ]]; then
    echo -e "${GREEN}Nothing to Commit${NC}"
else
    git add .
    git commit -m "CI Build"
    if [[ -z ${GITLAB_TOKEN} ]]; then
    	git push https://crazyuploader:"${GITLAB_TOKEN}"@"${GL_REF}" HEAD:master
    	echo ""
    	echo -e "${GREEN}Clang Toolchain Pushed${NC}"
     fi
fi
