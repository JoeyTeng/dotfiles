#!/usr/bin/env bash

git pull origin master

echo "Setting environment variables..."
source .exports
echo -e "Environment variables setted.\n"

press_y_to_confirm() {
    echo "$1(y/N)"
    read input
    if [ "$input" != "Y" ] && [ "$input" != "y" ]; then
        return 0
    else
        return 1
    fi
}

install_pkg_manager() {
    case `uname -s` in
        Darwin*)
            press_y_to_confirm "Install Homebrew on macOS"
            ret=$?
            if [ $ret -ne 0 ]; then
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                PATH=/usr/local/bin:/opt/homebrew/bin:$PATH
            else
                echo "Installation cannot proceed without package manager. Exiting..."
                exit -1
            fi
            ;;
        *)
            echo "This script cannot handle the installation of package manager on `uname -s`, exiting..."
            exit -1
            ;;
    esac
}

check_pkg_manager() {
    while [[ $PKG_MANAGER == "" ]]; do
        echo "Check package manager..."
        if [[ `which brew` ]]; then
            PKG_MANAGER="brew"
            PKG_INSTALL="brew install"
            PKG_UPDATE="brew update"
        elif [[ `which apt` ]] && [[ `uname -s` != "Darwin" ]]; then
            PKG_MANAGER="apt-get"
            PKG_INSTALL="apt-get install -y"
            PKG_UPDATE="apt-get update"
        else
            install_pkg_manager
        fi
    done

    echo "Package manager commands:"
    echo "- Manager $PKG_MANAGER"
    echo "- Install $PKG_INSTALL"
    echo "- Update $PKG_UPDATE"
    echo "Package manager checked"
}

prepare_pkg_manager() {
    echo "Prepare package manager..."
    echo "- Command: $PKG_UPDATE"
    $PKG_UPDATE
    echo "Package manager prepared"
}

install_zsh() {
    echo "installing zsh..."
    $PKG_INSTALL zsh
    echo "zsh installed"
}

install_oh_my_zsh() {
    if [[ ! `which zsh` ]]; then
        install_zsh
    fi
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
}

install() {
    echo "Installing..."
    check_pkg_manager
    prepare_pkg_manager
    install_oh_my_zsh
}

uninstall() {
    echo "Uninstalling..."
}

parse_argument() {
    for argument in "$@"; do
        case $argument in
            (install)
                install
                ;;
            (uninstall)
                uninstall
                ;;
        esac
    done
}

# Run in interactive mode when no argument is specified.
parse() {
    if [[ $# == 0 ]]; then
        echo "Enter a number to choose:"
        select action in install uninstall; do
            parse_argument $action
	    break
	done
    else
        parse_argument $@
    fi
}

parse $@
