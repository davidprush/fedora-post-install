#!/usr/bin/env bash
# backupConfigs.sh
# Fedora Post Installation copy configs & .dotfiles

backupBashrc() {
	cp ~/.bashrc ../configs/bashrc
}

backupCode() {
	cp ~/.config/Code/User/settings.json ../configs/Code/settings.json
	cp -a ~/.vscode ../configs/Code/.vscode
}

backupLibinputGestures() {
	cp ~/.config/libinput-gestures.conf ../configs/libinput-gestures/libinput-gestures.conf
}

backupFish() {
	cp -a ~/.configs/fish ../configs/fish
}

codeTest(){
    # Check for wget install
    if [ which code > /dev/null ]; then
		return 0
	else
		return 1
	fi
}

fishTest(){
    # Check for fish install
    if [ which fish > /dev/null ]; then
		return 0
	else
		return 1
	fi
}


postBackup() {
	echo "Checking for updates...just to be safe!"
	sudo dnf check-update
	echo "Update system..."
	sudo dnf update -y
	echo "Config files backuped to git repo directory!"
	exit 0
}

checkDirCode() {
	DIRECTORY = "~/.config/Code"
	if [ ! -d "$DIRECTORY" ]; then
		return 1;
	else
		return 0;
	fi
}

# Main function
if [ checkDirCode && codeTest ]; then
	backupCode
fi
backupBashrc
if [ fishTest ]; then
	backupFish
fi
backupLibinputGestures
postBackup
