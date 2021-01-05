install_python() {
    $PKG_INSTALL python
}

install_flutter() {
    FLUTTER_PATH="$HOME/Program/SDK"
    FLUTTER_BIN_PATH="$FLUTTER_PATH/flutter/bin"
    echo "Installing Flutter SDK in $FLUTTER_PATH"
    CURRENT_DIR="`pwd`"

    cd "$FLUTTER_PATH"
    git clone https://github.com/flutter/flutter.git -b stable
    cd "$CURRENT_DIR"

    echo "# for Flutter SDK" >>"$HOME/.zshrc"
    echo "export PATH=\"\$PATH:$FLUTTER_BIN_PATH\"" >>"$HOME/.zshrc"
    PATH="$PATH:$FLUTTER_BIN_PATH"

    flutter doctor
    flutter precache

    if [[ `uname -s` == "Darwin" ]]; then
        echo "Setup Flutter for iOS"
        sudo gem install cocoapods
    fi
}

install_mongodb() {
    echo "Install MongoDB using $PKG_MANAGER"
    if [[ "$PKG_MANAGER" == "brew" ]]; then
        brew tap mongodb/brew
        $PKG_INSTALL mongodb-community@4.4
    else
        echo "This script cannot handle installation with $PKG_MANAGER, returning..."
        return -1
    fi
}

