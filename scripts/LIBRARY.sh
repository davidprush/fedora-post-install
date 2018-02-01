#!/bin/bash
set -eu
# Add this LIBtion script to script using next line ...
#   . ./scripts/LIBtions.sh
# Bash text colors
BOLD="\033[0;1m"
BOLDRED="\033[0;1;31m"			
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[34m"
PINK="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"
NORMAL="\033[0;39m"
NC="\033[0m" # no colour

LIB_ECHO() {
    FCOLOR=$1
    FTEXT=$2
    case "$FCOLOR" in
        RED|red|r|R) 
            echo -e "${RED}$FTEXT${NC}"
            ;;
        GREEN|green|g|G) 
            echo -e "${GREEN}$FTEXT${NC}"
            ;;
        YELLOW|yellow|y|Y)
            echo -e "${YELLOW}$FTEXT${NC}"
            ;;
        NONE|none|n|N)
            echo -e "${NC}$FTEXT${NC}"
            ;;
        BOLD|bold|b|B)
            echo -e "${BOLD}$FTEXT${NC}"
            ;;
        BOLDRED|boldred|br|BR)
            echo -e "${BOLDRED}$FTEXT${NC}"
            ;;
        BLUE|blue|b|B) 
            echo -e "${BLUE}$FTEXT${NC}"
            ;;
        PINK|pink|p|P) 
            echo -e "${RED}$FTEXT${NC}"
            ;;
        CYAN|cyan|c|C)
            echo -e "${CYAN}$FTEXT${NC}"
            ;;
        WHITE|white|w|W) 
            echo -e "${WHITE}$FTEXT${NC}"
            ;;
        NORMAL|normal|n|N) 
            echo -e "${NORMAL}$FTEXT${NC}"
            ;;
    esac
}

LIB_BANNER_BEGIN() {
    LIB_ECHO YELLOW "\n-------------------------->>BEGIN:$1<<--------------------------"
}

LIB_BANNER_END() {
    LIB_ECHO GREEN "\n-------------------------->>END:$1<<--------------------------"
}

LIB_OK() {
    LIB_ECHO GREEN "--> [ OK ]"
}

LIB_FAIL() {
    LIB_ECHO RED "--> [ FAIL ]"
}

LIB_INVALID_INPUT() {
    LIB_ECHO RED "\n'${1}' is invalid command ..."
}

LIB_INVALID_YN() {
    LIB_ECHO RED "\n'${1}' is not valid enter y/Y or n/N ..."
}

LIB_NOTIFY() {
local NOTICE=$1
if [ $? -eq 0 ]; then
cat<<_EOF_
<<!#!>>
_EOF_
else    
cat<<_EOF_
<<! $NOTICE !>>
_EOF_
fi
}

LIB_TEST_NOTIFY() {
    echo -e "\n$( LIB_NOTIFY ) .: Tests starting ..."
}

LIB_TEST_FILE() {
    local FILETEST=$1
    if [[ ! -f "$FILETEST" ]]; then
        return 1
    else
        return 0
    fi
}

LIB_TEST_REQ_DIR() {
    local REQDIR=$1
    local ERR="ERROR-->file '$REQDIR' required but not found."
    if [[ ! -f "$REQDIR" ]]; then
        LIB_ECHO RED "\n$( LIB_NOTIFY ) .: $ERR"
        return 1
    fi
}

LIB_TEST_ROOT() {
    local ERR="ERROR-->Script requires root!"
    if (( EUID != 0 )); then
        LIB_ECHO RED "\n$( LIB_NOTIFY ) .: $ERR"
        exit 1
    fi
}

LIB_TEST_HOME() {
    local USERNAME=$1
    local ERR="ERROR-->no USERNAME provided."
    if [[ "$#" -eq 0 ]]; then
        LIB_ECHO RED "\n$( LIB_NOTIFY ) .: $ERR"
        return 1
    elif [[ ! -d "/home/$USERNAME" ]]; then
        local ERR1="ERROR-->a home directory for '$USERNAME' not found."
        LIB_ECHO RED "\n$( LIB_NOTIFY ) .: $ERR1"
        return 1
    fi
}

LIB_TEST_NET() {
    local ERR="ERROR-->Script requires internet."
    wget -q --spider http://www.google.com 
    if [ $? -eq 0 ]; then
        LIB_ECHO RED "\n$( LIB_NOTIFY ) .: $ERR"
        return 1
    fi
}

LIB_TEST_APP(){
    local APPTEST=$1
    if [ -z "$APPTEST" ]; then
        return 1
    else
        if [ "$(command -v $APPTEST)" > /dev/null ]; then
            return 1
        else
            return 0   
        fi
    fi
}

LIB_SET_DIR() {
    local SETDIR=$1
	cd $SETDIR
	LIB_ECHO YELLOW "Directory changed to: $(pwd)"
}

LIB_INSTALL() {
    local FILE=$1
    local ERR="ERROR-->Missing file: $FILE"
    if [[ -f "$FILE" ]]; then
	    sudo dnf install -y $(cat "$1")
    else
        LIB_ECHO RED "\n$(LIB_NOTIFY $ERR)"
    fi
}

LIB_INSTALL_APP() {
    local APP=$1
    while true; do
        read -p "Install $APP? (y/n)" USR_OPT
        case $USR_OPT in
            [Yy]* ) sudo dnf install $APP
                    break;;
            [Nn]* ) return 1;;
            * ) LIB_INVALID_YN $USR_OPT;;
        esac
    done
    return 0
}

LIB_INSTALL_CONFIRM() {
    local APPFILE=$1
    declare -a arrAPPS
    readarray -t arrAPPS < $APPFILE
    for i in "${arrAPPS[@]}"; do 
        if [[ $(LIB_TEST_APP "$i") ]]; then
            LIB_INSTALL_APP $i
        else
            echo "$(LIB_ECHO GREEN $i) is already installed ... "
        fi
    done 
}

LIB_GET_COMMAND() {
    read -p "$(LIB_ECHO BOLD '\nEnter command: ')" USER_COMMAND
    echo "$USER_COMMAND"
    return 0
}

LIB_VIEW_FILE() {
    local VIEWFILE=$1
    LIB_BANNER_BEGIN $VIEWFILE
    cat $VIEWFILE
    LIB_BANNER_END $VIEWFILE
}

LIB_BAK_FILE() {
    for f in "$@"; do cp "$f" "$f.$(date +%FT%H%M%S).bak"; done
}

LIB_UPDATE() {
    LIB_ECHO YELLOW "Update packages and upgrade ..."
    sudo dnf update -y
    LIB_OK
}

LIB_CLEANUP() {
    sudo dnf update -y
    sudo dnf clean all
    sudo dnf history userinstalled
    echo "\n$( LIB_NOTIFY ) .: Cleaned up system ..."
    return 0
}

LIB_FINISHED() {
    local FINITO="All finished!"
    echo FINITO 
    exit 1
}