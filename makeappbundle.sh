#!/bin/bash

if [ "$(which convert)" == "" ] ; then
    echo "[Abort] Please install imagemagick"
    exit 1
fi
cd $(dirname $0)

# parameters
namespace=bellbind
name=DisplayModeSwitcher
cmd=displaymode
version=1.1.0
id="$namespace.$name"

#NOTE: Developer ID Application certificate name in "Keychain Access"
#cert="Developer ID Application: ..."

[ -e config.sh ] && source config.sh

svg=icon.svg
swiftopts=""
pngopts="-fuzz 15% -transparent white"

# build bin

swiftc $swiftopts "$name.swift"
swiftc $swiftopts "$cmd.swift"

# build icns from svg
iconset="$name.iconset"
png="$svg.png"
mkdir -p "$iconset"
qlmanage -x -t -s 1024 -o . "$svg"
convert "$png" $pngopts -resize 16x16 "$iconset/icon_16x16.png"
convert "$png" $pngopts -resize 32x32 "$iconset/icon_16x16@2x.png"
convert "$png" $pngopts -resize 32x32 "$iconset/icon_32x32.png"
convert "$png" $pngopts -resize 64x64 "$iconset/icon_32x32@2x.png"
convert "$png" $pngopts -resize 128x128 "$iconset/icon_128x128.png"
convert "$png" $pngopts -resize 256x256 "$iconset/icon_128x128@2x.png"
convert "$png" $pngopts -resize 256x256 "$iconset/icon_256x256.png"
convert "$png" $pngopts -resize 512x512 "$iconset/icon_256x256@2x.png"
convert "$png" $pngopts -resize 512x512 "$iconset/icon_512x512.png"
convert "$png" $pngopts -resize 1024x1024 "$iconset/icon_512x512@2x.png"
iconutil -c icns "$iconset"

# build app bundle
app="$name.app"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS"
mkdir -p "$app/Contents/Resources"
sed -e "s/%name%/$name/g;s/%id%/$id/g;s/%version%/$version/g" Info.plist.xml > "$app/Contents/Info.plist"
cp "$name" "$app/Contents/MacOS"
cp "$cmd" "$app/Contents/MacOS"
cp "$name.icns" "$app/Contents/Resources"

# cleanup
rm -r "$name.iconset"
rm "$name" "$name.icns" "$png"

# codesign
if [ "$cert" ] ; then
    codesign -s "$cert" "$app"
fi

# make dmg
mkdir -p dmg/
cp -a "$app" dmg/
( cd dmg ; ln -s /Applications/ )
rm -f "$name.dmg"
hdiutil create -srcfolder dmg -volname "$name" "$name.dmg"
rm -rf dmg/
