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

install_gnupg() {
    $PKG_INSTALL gpg
}

install_git() {
    $PKG_INSTALL git
}

install_npm() {
    $PKG_INSTALL npm
}

install_commitizen() {
    npm install -g commitizen
}

setup_zshrc() {
    echo "Setting up ~/.zshrc..."
    echo "export XDG_CONFIG_HOME=\"$XDG_CONFIG_HOME\"" >> "$HOME/.zshrc"
    cat ".zshrc_addon" >> "$HOME/.zshrc"
}

copy_over_XDG() {
    echo "Copying over XDG Configs"
    /bin/cp -rv "git" "$XDG_CONFIG_HOME/"
}

install() {
    echo "Installing..."
    check_pkg_manager
    prepare_pkg_manager

    press_y_to_confirm "install oh-my-zsh"
    if [[ $? -ne 0 ]]; then
        install_oh_my_zsh
    fi

    press_y_to_confirm "install gnupg"
    if [[ $? -ne 0 ]]; then
        install_gnupg
    fi

    press_y_to_confirm "install git"
    if [[ $? -ne 0 ]]; then
        install_git
    fi

    press_y_to_confirm "install npm"
    if [[ $? -ne 0 ]]; then
	install_npm
    fi
    

    press_y_to_confirm "install commitizen (git cz)"
    if [[ $? -ne 0 ]]; then
	install_commitizen
    fi

    press_y_to_confirm "setup ~/.zshrc"
    if [[ $? -ne 0 ]]; then
        setup_zshrc
    fi

    press_y_to_confirm "copy over XDG_CONFIG_HOME files"
    if [[ $? -ne 0 ]]; then
        copy_over_XDG
    fi
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
            (setup_zshrc)
                setup_zshrc
                ;;
            (copy_over_XDG)
                copy_over_XDG
                ;;
        esac
    done
}

# Run in interactive mode when no argument is specified.
parse() {
    if [[ $# == 0 ]]; then
        echo "Enter a number to choose:"
        select action in install uninstall setup_zshrc copy_over_XDG; do
            parse_argument $action
	    break
	done
    else
        parse_argument $@
    fi
}

parse $@
