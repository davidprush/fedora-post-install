#!/usr/bin/env bash
# postInstall.sh
# Fedora Post Installation Script & Setup
# Overview:
#           1) Update the system
#           2) Install Initial Software
#           3) Setup Third-Party Repos & Install Software
#           4) Clone Git Repos
#           5) Setup Config (.dotfiles)
#           6) Clean up somethings
#           7) Finish

testRoot() {
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
		if "$REPLY" = "y"; then
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
	sudo dnf check-update
	sudo dnf update -y
	sudo dnf clean all
	echo " "
	sudo dnf history userinstalled
	echo "Script Completed!"
	exit 1
}

mkdirProjects() {
	DIRECTORY = "~/Projects"
	if [ ! -d "$DIRECTORY" ]; then
  		mkdir ~/Projects
		return 0;
	else
		return 0;
	fi
}

mkdirFonts() {
	DIRECTORY = "~/Fonts"
	if [ ! -d "$DIRECTORY" ]; then
  		mkdir ~/Fonts
		return 0;
	else
		return 0;
	fi
}

mkdirOhMyFish() {
	DIRECTORY = "~/oh-my-fish"
	if [ ! -d "$DIRECTORY" ]; then
		return 1;
	else
		return 0;
	fi
}

updateSystem() {
	# Update system
	sudo dnf update -y
}

initialInstall() {
	# Install initial apps
	sudo dnf install -y nano inxi powerline tlp htop
	sudo dnf install -y gcc make nodejs npm fish
	sudo dnf install -y youtube-dl gnome-tweak-tool
	sudo dnf install -y gcc vlc patch autoconf gcc-c++ 
	sudo dnf install -y patch libffi-devel automake 
	sudo dnf install -y libtool bison sqlite-devel 
	sudo dnf install -y ImageMagick-devel git gitg 
	sudo dnf install -y python2 python2-pip python3
	sudo dnf install -y python3-pip java-9-openjdk
	sudo dnf install -y icedtea-web go rust docker 
	sudo dnf install -y docker-compose terminator
	sudo dnf install -y dnf-plugins-core
	sudo dnf install -y automake gcc kernel-devel
	sudo dnf install -y openssl-devel ncurses-devel 
	sudo dnf install -y wxBase3 wxGTK3-devel m4
	sudo dnf install -y libinput-gestures hack-fonts
	sudo dnf install -y vim-enhanced vim-X11 gimp
	sudo dnf install -y corebird httpd mariadb-server
	sudo dnf install -y php php-common php-mysqlnd 
	sudo dnf install -y php-gd php-imap php-xml 
	sudo dnf install -y php-cli php-opcac oxygen-icon-theme
}

enableCoprRepos() {
	sudo dnf copr enable mhoeher/multitouch
	sudo dnf copr enable heliocastro/hack-fonts
}

installVSCode() {
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
	sudo dnf check-update
	sudo dnf install code
}

installChrome() {
	cd ~/Downloads
	if [ wgetTest ]; then
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
		sudo rpm -i google-chrome-stable_current_x86_64.rpm
		sudo dnf update -y
		return 0
	else
		return 1
	fi	
}

cloneNerdFonts() {
	if [ mkdirFonts ]; then
		cd ~/Fonts
		git clone https://github.com/ryanoasis/nerd-fonts.git
		cd ~/Fonts/nerd-fonts
		chmod a+x install.sh
		./install.sh
		sudo fc-cache -vf
		return 0		
	else
		return 1
	fi
}

clonePowerlineFonts() {
	if [ mkdirFonts ]; then
		cd ~/Fonts
		git clone https://github.com/powerline/fonts.git
		cd ~/Fonts/fonts
		chmod a+x install.sh
		./install.sh
		sudo fc-cache -vf
		return 0		
	else
		return 1
	fi
}

cloneOhMyFish() {
	if [ checkOhMyFish ]; then
		cd ~
		git clone https://github.com/oh-my-fish/oh-my-fish
		cd ~/oh-my-fish
		chmod a+x bin/install
		bin/install --offline
		return 0		
	else
		return 1
	fi
}

cloneBobTheFish() {
	if [ fishTest ]; then
		cd ~/Projects/FedoraPostInstall
		./installBobTheFish.fish
		return 1
	else
		return 0
	fi 
}

# Main function
if [ testNet ]; then
	updateSystem
	enableCoprRepos
	initialInstall
	installVSCode
	installChrome
	cloneNerdFonts
	clonePowerlineFonts
	cloneOhMyFish
	cloneBobTheFish
	./pasteConfigs.sh
	postInstall
else
	echo "No internet connection! Connect to internet and try again."
fi
