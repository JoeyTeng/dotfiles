#!/usr/bin/env bash

git pull origin master

echo "Setting environment variables..."
source .exports
echo -e "Environment variables setted.\n"

install() {
    echo "Installing..."
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
