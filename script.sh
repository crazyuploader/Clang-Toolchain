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
GIT_LFS_URL="https://github.com/git-lfs/git-lfs/releases/download/v3.5.1/git-lfs-linux-amd64-v3.5.1.tar.gz"
MIN_SIZE_MB=90 # Set the minimum size for Git LFS tracking (in MB)

# Function to check if running as root
is_root() {
	if [[ "$EUID" -eq 0 ]]; then
		SUDO=""
	else
		SUDO="sudo"
	fi
}

# Call the function to set $SUDO
is_root

# Install Git LFS if not installed
if ! command -v git-lfs &>/dev/null; then
	echo -e "${YELLOW}Installing Git LFS...${NC}"
	cd /tmp || exit
	curl -sLo git-lfs-linux.tar.gz "${GIT_LFS_URL}"
	tar xvf git-lfs-linux.tar.gz
	cd git-lfs-3.5.1 || exit
	$SUDO ./install.sh
	cd "$ROOT_DIR" || exit
else
	echo -e "${GREEN}Git LFS already installed${NC}"
fi

# Clone Clang Toolchain Repo from GitLab
echo -e "${YELLOW}Cloning GitLab Clang Toolchain Repo...${NC}"
git clone "https://${GL_REF}" -b master clang || {
	echo -e "${RED}GitLab clone failed${NC}"
	exit 1
}
cd clang || exit

# Clean Up
rm -r ./*
cd ..

# Clone AOSP Clang Toolchain from Google
echo -e "${YELLOW}Cloning AOSP Clang Toolchain from Google...${NC}"
git clone --depth=1 "${Android_Toolchain_Repo}" AOSP_REPO || {
	echo -e "${RED}Google clone failed${NC}"
	exit 1
}
echo -e "${GREEN}Clone successful${NC}"

# Find toolchain folder
TOOL_NAME=$(find AOSP_REPO -type d -name 'clang-r*' -print -quit)
if [[ -z "${TOOL_NAME}" ]]; then
	echo -e "${RED}No Clang Toolchain found${NC}"
	exit 1
fi
echo -e "${YELLOW}Using AOSP Clang Toolchain: ${TOOL_NAME}${NC}"

# Move toolchain to clang directory
echo -e "${YELLOW}Moving toolchain...${NC}"
mv "${TOOL_NAME}"/* ./clang || exit
rm -rf AOSP_REPO
cd clang || exit

# Display Clang version
CLANG_VERSION="$(./bin/clang --version)"
echo -e "${GREEN}Clang-Toolchain Version:${NC} ${CLANG_VERSION}"

# Create README.md with Clang version
echo -e "# AOSP Clang-Toolchain\n\n***Clang Version:***  ${CLANG_VERSION}" >README.md
echo -e "${GREEN}README.md created${NC}"

# Configure Git identity
echo -e "${YELLOW}Setting Git identity...${NC}"
git config --global user.email "4677226-crazyuploader@users.noreply.gitlab.com"
git config --global user.name "Jugal Kishore"

# Setup Git LFS
echo -e "${YELLOW}Setting up Git LFS...${NC}"
git lfs install

# Track files larger than specified size with Git LFS
find . -type f -size +"${MIN_SIZE_MB}M" ! -path "./.git/*" -exec git lfs track {} \;

# Push changes if any
if [[ -z $(git status --porcelain) ]]; then
	echo -e "${GREEN}Nothing to Commit${NC}"
else
	git add .
	git commit -m "CI Build"
	if [[ -n ${GITLAB_TOKEN-} ]]; then
 		git remote remove origin
		git remote add origin "https://oauth2:${GITLAB_TOKEN}@${GL_REF}"
		git push origin HEAD:master
		echo -e "${GREEN}Clang Toolchain Pushed${NC}"
	else
		echo -e "${RED}GITLAB_TOKEN not set. Cannot push changes.${NC}"
		exit 0
	fi
fi
