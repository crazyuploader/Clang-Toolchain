#!/usr/bin/env bash

# Clang Toolchain Pusher

# Colors
NC="\033[0m"
RED="\033[0;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"

# Getting my Clang Toolchain Repo from GitLab
git clone https://"${GL_REF}" -b master clang
cd clang || exit

# Downloading latest Clang AOSP Toolchain from Google
echo ""
echo "Getting Clang AOSP Toolchain From Google"
echo ""
wget -nv https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master/"${clang_ver}".tar.gz>> /dev/null 2>&1
exit_code="$(echo $?)"
if [[ ${exit_code} != "0" ]]; then
    echo -e "${RED}Invalid Link, Exiting${NC}"
    exit 1
else
    echo -e "${YELLOW}Link OK${NC}"
fi
tar -xf "${clang_ver}".tar.gz
rm "${clang_ver}".tar.gz

# Setting Git Identity
git config --global user.email "travis@travis-ci.com"
git config --global user.name "Travis CI"

# Pushing to GitLab Repo at https://gitlab.com/crazyuploader/clang-toolchain
echo ""
if [[ -z $(git status --porcelain) ]]; then
    echo -e "${GREEN}Nothing to Commit${NC}"
else
    echo git add .
    git commit -m "Travis CI Build ${TRAVIS_BUILD_NUMBER}"
    git push https://crazyuploader:"${GITLAB_TOKEN}"@"${GL_REF}" HEAD:master
    echo ""
    echo -e "${GREEN}Clang Toolchain Pushed${NC}"
    echo ""
    echo "Version: $(./bin/clang --version)"
fi
