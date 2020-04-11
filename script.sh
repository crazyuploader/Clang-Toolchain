#!/usr/bin/env bash

# Clang Toolchain Pusher

# Colors
NC="\033[0m"
RED="\033[0;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"

# Getting AOSP Clang Toolchain from Google
git clone --depth=1 "${Android_Toolchain_Repo}" AOSP_REPO
cd AOSP_REPO || exit
for f in clang-r*; do
	echo "${f}"
done


# Getting my Clang Toolchain Repo from GitLab
git clone https://"${GL_REF}" -b master clang
cd clang || exit

# Clean Up
rm -r ./*

echo ""
CLANG_VERSION="$(./bin/clang --version | grep 'clang version' | cut -c 37-)"
echo -e "${GREEN}Clang-Toolchain Version:${NC} ${CLANG_VERSION}"
echo ""
echo "Creating 'README.md'"
echo -e "# AOSP Clang-Toolchain\n\n***Clang Version:***  ${CLANG_VERSION}">> README.md

# Setting Git Identity
git config --global user.email "travis@travis-ci.com"
git config --global user.name "Travis CI"

# Pushing to GitLab Repo at https://gitlab.com/crazyuploader/clang-toolchain
echo ""
if [[ -z $(git status --porcelain) ]]; then
    echo -e "${GREEN}Nothing to Commit${NC}"
else
    # git add .
    # git commit -m "Travis CI Build ${TRAVIS_BUILD_NUMBER}"
    # git push https://crazyuploader:"${GITLAB_TOKEN}"@"${GL_REF}" HEAD:master
    echo ""
    # echo -e "${GREEN}Clang Toolchain Pushed${NC}"
fi
