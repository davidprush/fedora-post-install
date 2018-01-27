#!/usr/bin/env bash
# Fedora Post Installation copy configs & .dotfiles
# Overview:
#           1) 

pasteBashrc() {
	cp ../configs/bashrc ~/.bashrc
}

pasteCode() {
	cp ../configs/Code/settings.json ~/.config/Code/User/settings.json
	cp -a ../configs/Code/.vscode ~/.vscode
}

pasteLibinputGestures() {
	cp ../configs/libinput-gestures/libinput-gestures.conf ~/.config/libinput-gestures.conf
}

pasteFish() {
	cp -a ../configs/fish ~/.configs/fish
}

codeTest(){
    # Check for wget install
    if [ ! which code > /dev/null ]; then
        echo -e "Visual Studio Code not found! Install? (y/n) \c"
        read
		if "$REPLY" = "y"; then
			installVSCode
			return 0
		else
			return 1
		fi
	else
		return 0    
    fi
}

installVSCode() {
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
	sudo dnf check-update
	sudo dnf install code
}

fishTest(){
    # Check for fish install
    if [ ! which fish > /dev/null ]; then
        echo -e "fish not found! Install? (y/n) \c"
        read
		if "$REPLY" = "y"; then
			sudo dnf install fish
			return 0
		else
			return 1
		fi
	else
		return 0    
    fi
}

testNet() {
	# Test for internet connectivity by silently requesting page
	if [ wgetTest ]; then
		wget -q --spider http://www.google.com 
		if [ $? -eq 0 ]; then
			return 0
		else
			return 1
		fi
	else
		return 1
	fi
}

postInstall() {
	echo "Checking for updates...just to be safe!"
	sudo dnf check-update
	echo "Update system..."
	sudo dnf update -y
	echo "Config files copied to config directories!"
	exit 1
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
if [ testNet ]; then
	if [ checkDirCode ] && [ codeTest ]; then
		pasteCode
	fi
	pasteBashrc
	pasteFish
	pasteLibinputGestures
	postInstall
else
	echo "Internet connection required! Connect to internet and try again."
fi
