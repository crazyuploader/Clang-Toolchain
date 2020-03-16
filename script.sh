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

# Clean Up
rm -r ./*

# Downloading latest Clang AOSP Toolchain from Google
echo ""
echo "Getting Clang AOSP Toolchain From Google"
echo ""
wget -nv ${TOOL_LINK}>> /dev/null 2>&1
exit_code="$(echo $?)"
if [[ ${exit_code} != "0" ]]; then
    echo -e "${RED}Invalid Link, Exiting${NC}"
    exit 1
else
    echo -e "${YELLOW}Link OK${NC}"
fi
TAR="$(ls *.tar.gz)"
tar -xf "${TAR}"
rm "${TAR}"
echo ""
CLANG_VERSION="$(./bin/clang --version | grep 'clang version' | cut -c 37-)"
echo -e "${GREEN}Version:${NC} $(./bin/clang --version)"
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
    git add .
    git commit -m "Travis CI Build ${TRAVIS_BUILD_NUMBER}"
    git push https://crazyuploader:"${GITLAB_TOKEN}"@"${GL_REF}" HEAD:master
    echo ""
    echo -e "${GREEN}Clang Toolchain Pushed${NC}"
fi
