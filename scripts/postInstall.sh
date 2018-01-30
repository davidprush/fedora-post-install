#!/usr/bin/env bash
# postInstall.sh
# Fedora Post Installation Script & Setup
# Use apps.txt to add remove apps
# Overview:
#           1) Update the system
#           2) Install Initial Software
#           3) Setup Third-Party Repos & Install Software
#           4) Clone Git Repos
#           5) Setup Config (.dotfiles)
#           6) Clean up somethings
#           7) Finish

uidTest() {
	# Test if currently running as root
	if [ $EUID -ne 0 ]; then
		return 0
	else
		return 1
	fi
}

wgetTest(){
	# Check for wget install
	if [ ! which wget > /dev/null ]; then
		echo -e "wget not found! Install? (y/n) \c"
		read
		if "$ANSYN" = "y"; then
			sudo dnf install wget
			return 0
		else
			return 1
		fi
	else
		return 0    
	fi
}

fishTest(){
	# Check for fish install
	if [ ! which fish > /dev/null ]; then
	while true; do
		read -p "Install fish? (y/n)" ANSYN
		case $ANSYN in
			[Yy]* ) sudo dnf install fish
					return 0
					break;;
			[Nn]* ) return 1
					exit;;
			* ) echo "Please answer yes or no.";;
		esac
	done
else
	echo "fish installed, current version: " $(fish -v)
	return 0    
	fi
}

netTest() {
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
	sudo dnf check-update
	sudo dnf update -y
	sudo dnf clean all
	echo " "
	sudo dnf history userinstalled
	echo "postInstall done!"
	exit 1
}

doProjects() {
	PROJDIR = "$HOME/Projects"
	if [ ! -d "$PROJDIR" ]; then
		cd $HOME
  		mkdir $PROJDIR
		return 0;
	else
		return 0;
	fi
}

checkOMF() {
	OMFDIR = "$HOME/oh-my-fish"
	if [ ! -d "$OMFDIR" ]; then
		return 1;
	else
		return 0;
	fi
}

updateSystem() {
	# Update system
	sudo dnf update -y
}

instInit() {
	# Install initial apps
	sudo dnf install -y $(cat apps.txt)
}

# Maybe someday...still unsure about this bashdb thing
getBashDB() {
	wget https://sourceforge.net/projects/bashdb/files/bashdb/4.4-0.93/bashdb-4.4-0.93.tar.bz2/download
	cd bashdb*
	./configure
	make && make check
	su -c 'make install'
}

setCopr() {
	sudo dnf copr enable -y mhoeher/multitouch
	sudo dnf copr enable -y heliocastro/hack-fonts
}

instCode() {
  if [ ! which code > /dev/null ]; then
		sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
		sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
		sudo dnf check-update
		sudo dnf install code
	else
		echo "VS Installed with current version:" $(code --version)
	fi
}

instChrome() {
  if [ ! which google-chrome  > /dev/null ] && [ wgetTest ] && [ wgetTest ]; then
		cd $HOME/Downloads
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
		sudo rpm -i google-chrome-stable_current_x86_64.rpm
		sudo dnf update -y
		return 0
	else
		return 1
	fi	
}

getNerdFonts() {
	mkdir $HOME/Fonts
	cd $HOME/Fonts
	echo "nerd-fonts directory:=" $(pwd)
	while true; do
		read -p "Confirm nerd-fonts directory? (y/n)" ANSYN
		case $ANSYN in
			[Yy]* ) git clone https://github.com/ryanoasis/nerd-fonts.git 
					cd $HOME/Fonts/nerd-fonts
					chmod a+x install.sh
					./install.sh
					sudo fc-cache -vf
					return 0
					break;;
			[Nn]* ) exit;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

getPowerFonts() {
	mkdir $HOME/Fonts
	cd $HOME/Fonts
	echo "Powerline Fonts directory:=" $(pwd)
	while true; do
		read -p "Confirm Powerline Fonts directory? (y/n)" ANSYN
		case $ANSYN in
			[Yy]* ) git clone https://github.com/powerline/fonts.git 
					cd $HOME/Fonts/fonts
					chmod a+x install.sh
					./install.sh
					sudo fc-cache -vf
					return 0
					break;;
			[Nn]* ) exit;;
			* ) echo "Please answer yes or no.";;
		esac
	done		
}

cloneOMF() {
	if [ ! checkOMF ]; then
		cd $HOME
		echo "oh-my-fish directory:=" $(pwd)
		while true; do
			read -p "Confirm oh-my-fish directory? (y/n)" ANSYN
			case $ANSYN in
				[Yy]* ) git clone https://github.com/oh-my-fish/oh-my-fish
						cd $HOME/oh-my-fish
						chmod a+x bin/install
						bin/install --offline
						return 0
						break;;
				[Nn]* ) exit;;
				* ) echo "Please answer yes or no.";;
			esac
		done		
	else
		return 1
	fi
}

cloneBTF() {
	if [ fishTest ]; then
		cd $HOME/Downloads
		echo "bobthefish directory:=" $(pwd)
		while true; do
			read -p "Confirm bobthefish directory? (y/n)" ANSYN
			case $ANSYN in
				[Yy]* ) ./installBobTheFish.fish; break;;
				[Nn]* ) exit;;
				* ) echo "Please answer yes or no.";;
			esac
		done		
		return 0
	else
		return 1
	fi 
}

doAll() {
	updateSystem
	setCopr
	defDir $DEFDIR
	instInit
	defDir $DEFDIR
	instCode
	defDir $DEFDIR
	instChrome
	defDir $DEFDIR
	getNerdFonts
	defDir $DEFDIR
	getPowerFonts
	defDir $DEFDIR
	cloneOMF
	cloneBTF
	./pasteConfigs.sh
	postInstall
}

defDir() {
	cd $1
	# echo "pwd is: "$(pwd)
}

viewApps(){
	cat apps.txt
}

dispMenu() {
	echo "Fedora Post Install Script"
	echo "Menu options"
	echo "	1) Update System"
	echo "	2) Install from apps.txt"
	echo "	3) View apps.txt"
	echo " 	4) Install Visual Studio Code"
	echo "	5) Install Google Chrome"
	echo " 	6) Install Powerline Fonts"
	echo " 	7) Install Nerd Fonts"
	echo "	8) Install oh-my-fish & bobthefish"
	echo " 	9) Install All"
	echo "	C) Copy configurations"
	echo "  B) Backup configurations"
	echo "	M) Menu"
	echo "	Q) Quit"
}

getOption() {
	while true; do
		defDir $1
		read -p "Enter menu option (M-Menu):" ANSYN
		case $ANSYN in
			[1]* ) updateSystem;;
			[2]* ) setCopr
				   instInit;;
			[3]* ) viewApps;;
			[4]* ) instCode;;
			[5]* ) instChrome;;
			[6]* ) getPowerFonts;;
			[7]* ) getNerdFonts;;
			[8]* ) cloneOMF
				   cloneBTF;;
			[9]* ) doAll;;
			[cC]* )	./pasteConfigs.sh;;
			[bB]* ) ./backupConfigs.sh;;
			[mM]* ) dispMenu;;
			[Qq]* ) postInstall
					exit;;
			* ) echo "Please enter 1-0";;
		esac
	done
}

# Main Procedure
DEFDIR=$(pwd)
if [ netTest ]; then
	dispMenu
	getOption $DEFDIR
	postInstall
else
	echo "No internet connection! Connect to internet and try again."
fi
