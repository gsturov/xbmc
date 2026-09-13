#!/usr/bin/bash
cd $HOME/local-dev/kodi/tools/depends
./bootstrap
#read -p "Press enter to continue"

./configure --with-tarballs=$HOME/android-tools/xbmc-tarballs --host=aarch64-linux-android --with-sdk-path=$HOME/android-tools/android-sdk-linux --prefix=$HOME/android-tools/xbmc-depends
#read -p "Press enter to continue"

make -j$(getconf _NPROCESSORS_ONLN)
#read -p "Press enter to continue"

cd $HOME/local-dev/kodi
make -j$(getconf _NPROCESSORS_ONLN) -C tools/depends/target/binary-addons
#read -p "Press enter to continue"

make -C tools/depends/target/cmakebuildsys
#read -p "Press enter to continue"

mkdir $HOME/kodi-build
#read -p "Press enter to continue"

make -C tools/depends/target/cmakebuildsys BUILD_DIR=$HOME/kodi-build
#read -p "Press enter to continue"

cd $HOME/kodi-build
make -j$(getconf _NPROCESSORS_ONLN)
#read -p "Press enter to continue"

make apk
#read -p "Press enter to continue"

#if packaging is failing, refresh debug.keystore:
#cd /home/gleb/.android
#keytool -genkey -v -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000


cd /home/gleb/kodi-build/tools/android/packaging/xbmc/build/outputs/apk/debug
