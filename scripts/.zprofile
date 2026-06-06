# =============================================================================
# ZPROFILE - Shell environment
# =============================================================================

# -----------------------------------------------------------------------------
# PATH — Homebrew (load first so other tools can use it)
# -----------------------------------------------------------------------------
eval "$(/opt/homebrew/bin/brew shellenv)"

# -----------------------------------------------------------------------------
# ANDROID
# -----------------------------------------------------------------------------
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:/usr/local/bin/node

# -----------------------------------------------------------------------------
# Bun / Yarn
# -----------------------------------------------------------------------------
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$PATH:$HOME/.yarn/bin"

# -----------------------------------------------------------------------------
# Version managers (NVM, rbenv)
# -----------------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# -----------------------------------------------------------------------------
# Shell helpers
# -----------------------------------------------------------------------------
alias zprofile="source ~/.zprofile"
alias cat-zprofile="cat ~/.zprofile"
alias clean-mac="$HOME/quyen-scripts/cleanup.sh"

# -----------------------------------------------------------------------------
# Java version (java8 / java11 / java17; lựa chọn lưu cho tab mới)
# -----------------------------------------------------------------------------
_java_use() {
  local version="$1"
  local fallback="$2"
  export JAVA_HOME=$(/usr/libexec/java_home -v "$version" 2>/dev/null || /usr/libexec/java_home -v "$fallback" 2>/dev/null)
  echo "$JAVA_HOME" > ~/.java_home_current
  echo "JAVA_HOME=$JAVA_HOME"
  java -version
}

_java_default() {
  /usr/libexec/java_home -v 17.0.11 2>/dev/null || /usr/libexec/java_home -v 17 2>/dev/null
}

if [ -f ~/.java_home_current ]; then
  export JAVA_HOME=$(cat ~/.java_home_current)
  [ -z "$JAVA_HOME" ] || [ ! -d "$JAVA_HOME" ] && export JAVA_HOME=$(_java_default) && echo "$JAVA_HOME" > ~/.java_home_current
else
  export JAVA_HOME=$(_java_default)
  echo "$JAVA_HOME" > ~/.java_home_current
fi

java11() { _java_use "11.0.17" "11"; }
java17() { _java_use "17.0.11" "17"; }

alias check-javas="/usr/libexec/java_home -V"
alias check-java="java --version"

# -----------------------------------------------------------------------------
# Flutter SDK version (flutter305 / flutter3710 / flutter3293; lựa chọn lưu cho tab mới)
# -----------------------------------------------------------------------------
_FLUTTER_SDK_DIR="$HOME/FlutterSDK"

_path_without_flutter() {
  echo "$PATH" | tr ':' '\n' | grep -v FlutterSDK | tr '\n' ':' | sed 's/:$//'
}

_apply_flutter_path() {
  export PATH="$(_path_without_flutter):$_FLUTTER_SDK_DIR/${1}/bin:$HOME/.pub-cache/bin"
}

if [ -f ~/.flutter_sdk_version ]; then
  flutterSDKVer=$(cat ~/.flutter_sdk_version)
  [ -z "$flutterSDKVer" ] || [ ! -d "$_FLUTTER_SDK_DIR/$flutterSDKVer" ] && flutterSDKVer="3.29.3" && echo "$flutterSDKVer" > ~/.flutter_sdk_version
else
  flutterSDKVer="3.29.3"
  echo "$flutterSDKVer" > ~/.flutter_sdk_version
fi

export flutterSDKVer
export PATH=$PATH:$_FLUTTER_SDK_DIR/${flutterSDKVer}/bin:$HOME/.pub-cache/bin

flutter305() {
  export flutterSDKVer="3.0.5"
  echo "$flutterSDKVer" > ~/.flutter_sdk_version
  _apply_flutter_path "$flutterSDKVer"
  echo "flutterSDKVer=$flutterSDKVer"
  flutter --version
}

flutter3710() {
  export flutterSDKVer="3.7.10"
  echo "$flutterSDKVer" > ~/.flutter_sdk_version
  _apply_flutter_path "$flutterSDKVer"
  echo "flutterSDKVer=$flutterSDKVer"
  flutter --version
}

flutter3293() {
  export flutterSDKVer="3.29.3"
  echo "$flutterSDKVer" > ~/.flutter_sdk_version
  _apply_flutter_path "$flutterSDKVer"
  echo "flutterSDKVer=$flutterSDKVer"
  flutter --version
}

alias check-flutter-sdk="ls -la $_FLUTTER_SDK_DIR"

# Flutter commands

alias ft-apk="flutter build apk --flavor staging -t lib/main.dart"

# -----------------------------------------------------------------------------
# React Native / NPM
# -----------------------------------------------------------------------------
alias rn-devmenu="adb shell input keyevent 82"
alias rn-reset="watchman watch-del-all && npm run start -- --reset-cache"
alias rn-rm-pod="rm -rf ios/Pods ios/Podfile.lock ios/build"
alias rn-clean-all="
  watchman watch-del-all
  rm -rf ios/Pods ios/Podfile.lock ios/build
  rm -rf ~/Library/Developer/Xcode/DerivedData/*
  rm -rf node_modules
  npm ci --force
  rm -rf android/app/build android/.gradle
  cd android && ./gradlew clean && cd ..
  cd ios && pod install && cd ..
  npm start -- --reset-cache
"
alias npm-i-legacy="npm install --legacy-peer-deps"

# Clear dev caches (Xcode, Android, Node, etc.)
export CACHE_PATH="$HOME/Library/Caches"
export LOG_PATH="$HOME/Library/Logs"
export XCODE_BUILD_PATH="$HOME/Library/Developer/Xcode/DerivedData"
export XCODE_ARCHIVE_PATH="$HOME/Library/Developer/Xcode/Archives"
export XCODE_BUILD_FILE_PATH="$HOME/Desktop/WORKSPACE/Build files"
export ANDROID_BUILD_CACHE_PATH="$HOME/.android/cache"
export ANDROID_GRADLE_CACHE_PATH="$HOME/.gradle"

unalias clear-mem 2>/dev/null
clear-mem() {
  local dirs=(
    "$CACHE_PATH"
    "$LOG_PATH"
    "$XCODE_BUILD_PATH"
    "$XCODE_ARCHIVE_PATH"
    "$XCODE_BUILD_FILE_PATH"
    "$ANDROID_BUILD_CACHE_PATH"
    "$ANDROID_GRADLE_CACHE_PATH"
  )
  for d in "${dirs[@]}"; do
    if [ -d "$d" ]; then
      # Remove only the contents of the directory, keep the directory itself
      find "$d" -mindepth 1 -maxdepth 1 -exec /bin/rm -rf -- {} + 2>/dev/null || true
    fi
  done
}

# -----------------------------------------------------------------------------
# Project shortcuts (cd to workspace)
# -----------------------------------------------------------------------------

# Flutter
alias ft-study="cd $HOME/Desktop/WORKSPACE/QUYEN/0_FLUTTER/Flutter-Study-App"
alias ft-base="cd $HOME/Desktop/WORKSPACE/QUYEN/0_FLUTTER/base-flutter"

# React Native base
alias rn-base="cd $HOME/Desktop/WORKSPACE/QUYEN/0_REACT_NATIVE/base-react-native/"
alias expo-base="cd $HOME/Desktop/WORKSPACE/QUYEN/0_REACT_NATIVE/base-expo/0_source-base-expo"

# Frameworks
alias next-base="cd $HOME/Desktop/WORKSPACE/QUYEN/0_NEXTJS/next-base"
alias nest-base="cd $HOME/Desktop/WORKSPACE/QUYEN/0_NESTJS/nest-base"
alias node-base="cd $HOME/Desktop/WORKSPACE/QUYEN/0_NODEJS/node-base"

########## GMO projects ##########
alias rn-shinhan="cd $HOME/Desktop/WORKSPACE/GMO/DEV/shinhan/0_src_shinhan"
alias rn-fp="cd $HOME/Desktop/WORKSPACE/GMO/DEV/fintech/0_src_fintech"

# Tenbin
alias metis-localenv="cd $HOME/Desktop/WORKSPACE/GMO/DEV/tenbin/METIS/0_src_local-env-metis"
alias metis-client="cd $HOME/Desktop/WORKSPACE/GMO/DEV/tenbin/METIS/0_src_metis-client"
alias metis-server="cd $HOME/Desktop/WORKSPACE/GMO/DEV/tenbin/METIS/0_src_metis-server"
alias metis-admin-client="cd $HOME/Desktop/WORKSPACE/GMO/DEV/tenbin/METIS/0_src_metis-admin-client"

alias sophia-localenv="cd $HOME/Desktop/WORKSPACE/GMO/DEV/tenbin/SOPHIA/0_src_local-env-sophia"
alias sophia-client="cd $HOME/Desktop/WORKSPACE/GMO/DEV/tenbin/SOPHIA/0_src_sophia-client"
alias sophia-server="cd $HOME/Desktop/WORKSPACE/GMO/DEV/tenbin/SOPHIA/0_src_sophia-server"
alias sophia-admin-client="cd $HOME/Desktop/WORKSPACE/GMO/DEV/tenbin/SOPHIA/0_src_sophia-admin-client"

alias tenbin-common="cd $HOME/Desktop/WORKSPACE/GMO/DEV/tenbin/0_src_common"
alias tenbin-lambda="cd $HOME/Desktop/WORKSPACE/GMO/DEV/tenbin/0_src_lambda"

alias bff-localenv="cd $HOME/Desktop/WORKSPACE/GMO/DEV/tenbin/BFF/0_src_local-env-bff"
alias bff-server="cd $HOME/Desktop/WORKSPACE/GMO/DEV/tenbin/BFF/0_src_bff"

# CDI
alias rn-tap="cd $HOME/Desktop/WORKSPACE/GMO/DEV/CDI/taprica-app/0_src_taprica-app/remoconApp"
alias node-tap="cd $HOME/Desktop/WORKSPACE/GMO/DEV/CDI/taprica-server/0_src_taprica-server/remoconServer"
alias rn-cpap="cd $HOME/Desktop/WORKSPACE/GMO/DEV/CDI/cpap/0_src_cpap"