#!/usr/bin/env bash
#NAME
#		Fedora Post Install
#
#options
#
#		update			Update the system. (dnf update)
#		apps			Install software listed in apps.txt
#		view-apps		View the apps.txt file
#		vscode			Install Visual Studio Code
#		chrome			Install Google Chrome Stable
#		power-fonts		Install Powerline Fonts
#		nerd-fonts		Install Nerd Fonts
#		omf-btf			Install oh-my-fish & bobthefish
#		all				Run all install LIBtions (complete reinstall)
#		repos			Set copr & rpmfusion repos
#		set-config		Set configuration files
#		backup-config	Backup configuration files
#		menu			View this menu
#		quit			Quit the script
#		help			View help
#
#FILES
#
#		apps.txt		Text file listing apps to install with one app per line
#		configs.txt		Text file listing file path of config files to save
#
#USAGE
#		./fedora-post-install.sh [COMMAND]
SCRIPT_ROOT=$(pwd)
SCRIPT_DIR="$(pwd)/scripts"
CONFIG_DIR="$(pwd)/config"
DATA_DIR="$(pwd)/data"
DOWNLOADS_DIR="$HOME/Downloads"
PROJECTS_DIR="$HOME/Projects"
OHMYFISH_DIR="$HOME/oh-my-fish"
NERDFONTS_DIR="$HOME/Fonts/nerd-fonts"
VSCODE_LOCAL_REPO="/etc/yum.repos.d/vscode.repo"
FONTS_DIR="$HOME/Fonts"
POWERLINE_DIR="$HOME/Fonts/fonts"
APPS_TXT="$DATA_DIR/apps.txt"
CONFIGS_TXT="$DATA_DIR/configs.txt"
HTTP_CHROME="https://sourceforge.net/projects/bashdb/files/bashdb/4.4-0.93/bashdb-4.4-0.93.tar.bz2/download"
HTTP_VSCODE_KEYS="https://packages.microsoft.com/keys/microsoft.asc"
HTTP_VSCODE_REPO="https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc"
HTTP_RPMFUSION_FREE="http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release"
HTTP_RPMFUSION_NONFREE="http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release"
HTTP_NERDFONT="https://github.com/ryanoasis/nerd-fonts.git"
HTTP_POWERLINE_FONT="https://github.com/powerline/fonts.git"
HTTP_OHMYFISH="https://github.com/oh-my-fish/oh-my-fish"
HTTP_BASHDB="https://sourceforge.net/projects/bashdb/files/bashdb/4.4-0.93/bashdb-4.4-0.93.tar.bz2/download"

. "$SCRIPT_DIR/LIBRARY.sh"

display_help() {
cat<<_EOF_
$(LIB_ECHO BOLD "NAME")
	Fedora Post Install
$(LIB_ECHO BOLD "OPTIONS")
	update			Update the system
	apps			Install software listed in apps.txt
	apps-confirm		Install software and require confirmation for each install
	view-apps		View the apps.txt file
	vscode			Install Visual Studio Code
	chrome			Install Google Chrome Stable
	power-fonts		Install Powerline Fonts
	nerd-fonts		Install Nerd Fonts
	omf-btf			Install oh-my-fish & bobthefish
	all			Run all install LIBtions (complete reinstall)
	repos			Set copr & rpmfusion repos
	set-config		Set configuration files
	backup-config		Backup configuration files
	options			View this menu
	quit			Quit the script
	sites			List URL adresses used in this script
	help			View help
$(LIB_ECHO BOLD "REQUIRED FILES")
	apps.txt		Text file listing apps to install with one app per line
	$(LIB_ECHO CYAN "$APPS_TXT")
	configs.txt		Text file listing file path of config files to save
	$(LIB_ECHO CYAN "$CONFIGS_TXT")
$(LIB_ECHO BOLD "USAGE")
	./fedora-post-install.sh [COMMAND]
_EOF_
}

display_sites() {
cat<<_EOF_
$(LIB_ECHO BOLD "WEBSITES")
$(LIB_ECHO BOLD "Google Chrome")
$(LIB_ECHO PINK "$HTTP_CHROME")
$(LIB_ECHO BOLD "VS Code Keys")
$(LIB_ECHO PINK "$HTTP_VSCODE_KEYS")
$(LIB_ECHO BOLD "VS Code Repo")
$(LIB_ECHO PINK "$HTTP_VSCODE_REPO")
$(LIB_ECHO BOLD "RPMFusion Free")
$(LIB_ECHO PINK "$HTTP_RPMFUSION_FREE")
$(LIB_ECHO BOLD "RPMFusion NonFree")
$(LIB_ECHO PINK "$HTTP_RPMFUSION_NONFREE")
$(LIB_ECHO BOLD "Nerd Fonts")
$(LIB_ECHO PINK "$HTTP_NERDFONT")
$(LIB_ECHO BOLD "Powerline Fonts")
$(LIB_ECHO PINK "$HTTP_POWERLINE_FONT")
$(LIB_ECHO BOLD "Oh-My_Fish")
$(LIB_ECHO PINK "$HTTP_OHMYFISH")
$(LIB_ECHO BOLD "BashDB")
$(LIB_ECHO PINK "$HTTP_BASHDB")
_EOF_
}

display_options() {
cat<<_EOF_
$(LIB_ECHO BOLD "COMMANDS (use help for details):")
[update]	[apps]		[apps-confirm] 		[view-apps]		[vscode] 	
[chrome] 	[power-fonts]	[nerd-fonts]		[omf-btf] 		[all]
[repos]		[set-config]	[backup-config] 	[pia-nm]		[options]
[quit]		[sites] 	[help]
_EOF_
}

got_fish() {
	# Check for fish install
	if [ ! $(LIB_TEST_APP fish) ]; then
		return $(LIB_INSTALL_APP fish)
	fi
}

make_dir_projects() {
	PROJDIR = PROJECTS_DIR
	if [ ! -d "$PROJDIR" ]; then
		cd $HOME
  		mkdir $PROJDIR
		return 0;
	else
		return 0;
	fi
}

got_OMF() {
	OMFDIR = OHMYFISH_DIR
	if [ ! -d "$OMFDIR" ]; then
		return 1;
	else
		return 0;
	fi
}

# Maybe someday...still unsure about this bashdb thing
get_bashdb() {
	wget "$HTTP_BASHDB"
	cd bashdb*
	./configure
	make && make check
	su -c 'make install'
}

set_repos() {
	dnf copr enable -y mhoeher/multitouch
	dnf copr enable -y heliocastro/hack-fonts
	dnf install -y "$HTTP_RPMFUSION_FREE-$(rpm -E %fedora).noarch.rpm"
	dnf install -y "$HTTP_RPMFUSION_NONFREE-$(rpm -E %fedora).noarch.rpm"
}

install_vscode() {
  if [ $(LIB_TEST_APP vscode) ]; then
		rpm --import "$HTTP_VSCODE_KEYS"
		sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=$HTTP_VSCODE_REPO" > $VSCODE_LOCAL_REPO'
		dnf check-update
		dnf install code
		return 0
	else
		LIB_ECHO GREEN "VS Code installed, current version: $(code --version)"
		return 1
	fi
}

install_chrome() {
  if [ $(LIB_TEST_APP google-chrome) ]; then
		cd $HOME/Downloads
		wget "$HTTP_CHROME"
		rpm -i google-chrome-stable_current_x86_64.rpm
		dnf update -y
		return 0
	else
		LIB_ECHO GREEN "Google Chrome installed, current version: $(google-chrome --version)"
		return 1
	fi	
}

install_nerdfonts() {
	mkdir $FONTS_DIR
	cd $FONTS_DIR
	echo "nerd-fonts directory:=" $(pwd)
	while true; do
		read -p "Confirm nerd-fonts directory? (y/n)" OPT
		case $OPT in
			[Yy]* ) git clone "$HTTP_NERDFONT" 
					cd $NERDFONTS_DIR
					chmod a+x install.sh
					./install.sh
					fc-cache -vf
					return 0
					break;;
			[Nn]* ) exit;;
			* ) LIB_INVALID_YN $OPT;;
		esac
	done
}

install_powerfonts() {
	mkdir $FONTS_DIR
	cd $FONTS_DIR
	echo "Powerline Fonts directory:=" $(pwd)
	while true; do
		read -p "Confirm Powerline Fonts directory? (y/n)" OPT
		case $OPT in
			[Yy]* ) git clone "$HTTP_POWERLINE_FONT" 
					cd $POWERLINE_DIR
					chmod a+x install.sh
					./install.sh
					fc-cache -vf
					return 0
					break;;
			[Nn]* ) exit;;
			* ) LIB_INVALID_YN $OPT;;
		esac
	done		
}

clone_OMF() {
	if [ ! got_OMF ]; then
		cd $HOME
		echo "oh-my-fish directory:=" $(pwd)
		while true; do
			read -p "Confirm oh-my-fish directory? (y/n)" OPT
			case $OPT in
				[Yy]* ) git clone "$HTTP_OHMYFISH"
						cd $OHMYFISH_DIR
						chmod a+x bin/install
						bin/install --offline
						return 0
						break;;
				[Nn]* ) exit;;
				* ) echo LIB_INVALID_YN $OPT;;
			esac
		done		
	else
		return 1
	fi
}

clone_BTF() {
	if [ got_fish ]; then
		cd $DOWNLOADS_DIR
		echo "bobthefish directory:=" $(pwd)
		while true; do
			read -p "Confirm bobthefish directory? (y/n)" OPT
			case $OPT in
				[Yy]* ) ./install-bobthefish.fish; break;;
				[Nn]* ) exit;;
				* ) LIB_INVALID_YN $OPT;;
			esac
		done		
		return 0
	else
		return 1
	fi 
}

set_configs() {
	if [ LIB_TEST_NET ]; then
		if [ $(LIB_TEST_APP fish) ]; then
			cp -a ../configs/fish ~/.config/fish
		fi
			cp ../configs/bashrc ~/.bashrc
			cp ../configs/Code/settings.json ~/.config/Code/User/settings.json
			cp -a ../configs/Code/.vscode ~/.vscode
			cp ../configs/libinput-gestures/libinput-gestures.conf ~/.config/libinput-gestures.conf
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
	LIB_UPDATE
	set_repos
	LIB_SET_DIR $SCRIPT_DIR
	install_apps
	LIB_SET_DIR $SCRIPT_DIR
	install_vscode
	LIB_SET_DIR $SCRIPT_DIR
	install_chrome
	LIB_SET_DIR $SCRIPT_DIR
	install_nerdfonts
	LIB_SET_DIR $SCRIPT_DIR
	install_powerfonts
	LIB_SET_DIR $SCRIPT_DIR
	clone_OMF
	clone_BTF
	set_configs
	. $SCRIPT_DIR/pia-nm.sh
	LIB_CLEANUP
}

get_option() {
	if [ $# -eq 0 ]; then
		OPT=$(LIB_GET_COMMAND)
	else
		OPT=$1
	fi
	LIB_SET_DIR $SCRIPT_DIR
	while true; do		
		case "$OPT" in
			'update')
				LIB_UPDATE
				;;
			'apps')
				set_repos
				LIB_INSTALL $APPS_TXT
				;;
			'apps-confirm')	
				set_repos
				LIB_INSTALL_CONFIRM $APPS_TXT
				;;
			'view-apps')
				LIB_VIEW_FILE $APPS_TXT
				;;
			'vscode')
				install_vscode
				;;
			'chrome')
				install_chrome
				;;
			'power-fonts')
				install_powerfonts
				;;
			'nerd-fonts')
				install_nerdfonts
				;;
			'omf-btf')
				clone_OMF
				clone_BTF
				;;
			'all')
				do_everything
				;;
			'repos')
				set_repos
				;;
			'set-config')
				set_configs
				;;
			'backup-config')
				backup_configs
				;;
			'pia-nm')
				. $SCRIPT_DIR/pia-nm.sh
				;;
			'options')
				display_options
				;;
			'quit')
				exit
				;;
			'sites')
				display_sites
				;;
			'help')echo 
				display_help
				;;
			* )
				LIB_INVALID_INPUT $OPT
				display_options
		esac
		OPT=""
		OPT=$(LIB_GET_COMMAND)
	done
}

# Main Procedure
LIB_TEST_ROOT
if [ LIB_TEST_NET ]; then
	if [ $# -eq 0 ]; then
		get_option 
	else
		OPTARG=$1
		get_option $OPTARG
	fi
fi