# Fedora Post Install

This git repo consists of Fedora (27) system/software configuration files and install scripts.

## Getting Started

Post install of a Fedora system, clone to user home directory and run scripts.

## Instructions
                #### Clone this repo and run the script in the repo's root directory directory.
### NAME
                #### Fedora Post Install
### OPTIONS
                update...............Update the system

                apps...............Install software listed in apps.txt

                apps-confirm...............Install software and require confirmation for each install

                view-apps...............View the apps.txt file

                vscode...............Install Visual Studio Code

                chrome...............Install Google Chrome Stable

                power-fonts...............Install Powerline Fonts

                nerd-fonts...............Install Nerd Fonts

                omf-btf...............Install oh-my-fish & bobthefish

                all...............Run all install LIBtions (complete reinstall)

                repos...............Set copr & rpmfusion repos

                set-config...............Set configuration files

                backup-config...............Backup configuration files

                pia-nm...............Install PIA openvpn configuration files

                options...............View this menu

                quit...............Quit the script

                sites...............List URL adresses used in this script

                help...............View help
### FILES
                apps.txt>>>>>>Text file listing apps to install with one app per line

                configs.txt>>>>>>Text file listing file path of config files to save

### USAGE

                sudo bash fedora-post-install.sh [OPTIONAL COMMAND]

## Installing

Clone it! Run scripts! Do whatever you want with it!

## Repo Structure
### Requirements (Directory structure)

This script requires the following directories and files:

    fedora-post-install/
            |---->configs/
                    |---->Code/
                            |---->cloudSettings
                            |---->extensions.json
                            |---->keybindings.json
                            |---->keybindingsMac.json
                            |---->settins.json
                            |---->vsicons.settings.json
                    |---->fish/
                            |---->conf.d/
                                    |---->omf.fish
                            |---->functions/
                                    |---->fish_prompt.fish
                            |---->config.fish
                            |---->fishd.localhost.localdomain
                    |---->libinput-gestures/
                            |---->libinput-gestures.conf
                    |---->bashrc
            |---->data/
                    |---->apps.txt
                    |---->configs.txt
            |---->scripts/
                    |---->install-bobthefish.fish
                    |---->LIBRARY.sh
                    |---->pia-nm.sh
            |---->fedora-post-install.sh
            |---->LICENSE.md
            |---->README.md

## License

[MIT License](https://github.com/davidprush/FedoraPostInstall/blob/master/LICENSE.md)