#!/usr/bin/env bash
# cleanup.sh
# Fedora Post Installation Script & Setup
# Use apps.txt to add remove apps

test_su() {
	# Test if currently running as root
	if [ $EUID -ne 0 ]; then
		return 0
	else
		return 1
	fi
}

test_wget(){
	# Check for wget install
	if [ ! which wget > /dev/null ]; then
		echo -e "wget not found! Install? (y/n) \c"
		read
		if "$USER_OPTION" = "y"; then
			sudo dnf install wget
			return 0
		else
			return 1$RUNDIR
		fi
	else
		return 0    
	fi
}

got_fish() {
	# Check for fish install
	if [ ! which fish > /dev/null ]; then
	while true; do
		read -p "Install fish? (y/n)" USER_OPTION
		case $USER_OPTION in
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

test_internet() {
	# Test for internet connectivity by silently requesting page
	if [ test_wget ]; then
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

cleanup() {
	sudo dnf check-update
	sudo dnf update -y
	sudo dnf clean all
	echo " "
	sudo dnf history userinstalled
	echo "cleanup done!"
	exit 1
}

make_dir_projects() {
	PROJDIR = "$HOME/Projects"
	if [ ! -d "$PROJDIR" ]; then
		cd $HOME
  		mkdir $PROJDIR
		return 0;
	else
		return 0;
	fi
}

got_OMF() {
	OMFDIR = "$HOME/oh-my-fish"
	if [ ! -d "$OMFDIR" ]; then
		return 1;
	else
		return 0;
	fi
}

update_system() {
	# Update system
	sudo dnf update -y
}

install_apps() {
	# Install initial apps
	sudo dnf install -y $(cat apps.txt)
}

# Maybe someday...still unsure about this bashdb thing
get_bashdb() {
	wget https://sourceforge.net/projects/bashdb/files/bashdb/4.4-0.93/bashdb-4.4-0.93.tar.bz2/download
	cd bashdb*
	./configure
	make && make check
	su -c 'make install'
}

set_copr_repos() {
	sudo dnf copr enable -y mhoeher/multitouch
	sudo dnf copr enable -y heliocastro/hack-fonts
}

install_vscode() {
  if [ ! which code > /dev/null ]; then
		sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
		sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
		sudo dnf check-update
		sudo dnf install code
	else
		echo "VS Installed with current version:" $(code --version)
	fi
}

install_chrome() {
  if [ ! which google-chrome  > /dev/null ] && [ test_wget ] && [ test_wget ]; then
		cd $HOME/Downloads
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
		sudo rpm -i google-chrome-stable_current_x86_64.rpm
		sudo dnf update -y
		return 0
	else
		return 1
	fi	
}

install_nerdfonts() {
	mkdir $HOME/Fonts
	cd $HOME/Fonts
	echo "nerd-fonts directory:=" $(pwd)
	while true; do
		read -p "Confirm nerd-fonts directory? (y/n)" USER_OPTION
		case $USER_OPTION in
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

install_powerfonts() {
	mkdir $HOME/Fonts
	cd $HOME/Fonts
	echo "Powerline Fonts directory:=" $(pwd)
	while true; do
		read -p "Confirm Powerline Fonts directory? (y/n)" USER_OPTION
		case $USER_OPTION in
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

clone_OMF() {
	if [ ! got_OMF ]; then
		cd $HOME
		echo "oh-my-fish directory:=" $(pwd)
		while true; do
			read -p "Confirm oh-my-fish directory? (y/n)" USER_OPTION
			case $USER_OPTION in
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

clone_BTF() {
	if [ got_fish ]; then
		cd $HOME/Downloads
		echo "bobthefish directory:=" $(pwd)
		while true; do
			read -p "Confirm bobthefish directory? (y/n)" USER_OPTION
			case $USER_OPTION in
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

set_configs() {
	if [ testNet ]; then
		if [ which fish > /dev/null ]; then
			cp -a ../configs/fish ~/.config/fish
		fi
			cp ../configs/bashrc ~/.bashrc
			cp ../configs/Code/settings.json ~/.config/Code/User/settings.json
			cp -a ../configs/Code/.vscode ~/.vscode
			cp ../configs/libinput-gestures/libinput-gestures.conf ~/.config/libinput-gestures.conf
		else
			echo "Internet connection required! Connect to internet and try again."
	fi
}

backup_configs() {
	if [ checkDirCode && codeTest ]; then
		cp ~/.config/Code/User/settings.json ../configs/Code/settings.json
		cp -a ~/.vscode ../configs/Code/.vscode
	fi
	if [ fishTest ]; then
		cp -a ~/.config/fish ../configs/fish
	fi
		cp ~/.config/libinput-gestures.conf ../configs/libinput-gestures/libinput-gestures.conf
	cp ~/.bashrc ../configs/bashrc
}

do_everything() {
	update_system
	set_copr_repos
	set_pwd $RUNDIR
	install_apps
	set_pwd $RUNDIR
	install_vscode
	set_pwd $RUNDIR
	install_chrome
	set_pwd $RUNDIR
	install_nerdfonts
	set_pwd $RUNDIR
	install_powerfonts
	set_pwd $RUNDIR
	clone_OMF
	clone_BTF
	./pasteConfigs.sh
	cleanup
}

set_pwd() {
	cd $1
	echo "pwd is: "$(pwd)
}

view_apps(){
	cat apps.txt
}

display_menu() {
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
	echo " 	9) Do everything!"
	echo "	S) Set configurations"
	echo "	B) Backup configurations"
	echo "	M) Menu"
	echo "	Q) Quit"
}

get_option() {
	while true; do
		set_pwd $1
		read -p "Enter menu option (M-Menu):" USER_OPTION
		case $USER_OPTION in
			[1]* ) update_system;;
			[2]* ) set_copr_repos
				   install_apps;;
			[3]* ) view_apps;;
			[4]* ) install_vscode;;
			[5]* ) install_chrome;;
			[6]* ) install_powerfonts;;
			[7]* ) install_nerdfonts;;
			[8]* ) clone_OMF
				   clone_BTF;;
			[9]* ) do_everything;;
			[sS]* )	set_configs;;
			[bB]* ) backup_configs;;
			[mM]* ) display_menu;;
			[Qq]* ) exit;;
			* ) echo "Please enter option from menu!";;
		esac
	done
}

# Main Procedure
RUNDIR=$(pwd)
if [ test_internet ]; then
	display_menu
	get_option $RUNDIR
else
	echo "No internet connection! Connect to internet and try again."
fi
