#!/usr/bin/env bash

#VERSION_URL="https://raw.githubusercontent.com/cristianoliveira/ergo/master/.version"
#DOWNLOAD_URL="https://github.com/cristianoliveira/ergo/releases/download"
#NEW_DOWNLOAD_URL="https://github.com/cristianoliveira/ergo/archive/refs/heads/master.zip"
DEST_FOLDER="/usr/local/bin"
PROGNAME=`basename "$0"`
#VERSION=${1:-$(wget -q -O - "$VERSION_URL")}

die () {
	echo "$PROGNAME: [FATAL] $1" >&2; exit ${2:-1}  ;
}


getbuildcommand(){
	platform=$(uname -m)
	case $platform in
	x86_64)
		echo "build"
		;;
	aarch64)
		echo "build-linux-arm"
		;;
	arm64)
		echo "build-darwin-arm"
		;;
    *)
        die "$platform is not yet supported"
        ;;
    esac
}

install(){
	local buildcmd=$(getbuildcommand)

	make $buildcmd
    [ $? -ne 0 ] && die "Unable to compile ergo from source"

	if [ "$PWD" != "$DEST_FOLDER" ]
	then
		echo "Copying ergo to $DEST_FOLDER. May require sudo password."
		if [ -w $DEST_FOLDER ]; then
			find ./bin/ -type f -exec cp -av {} $DEST_FOLDER \;
		else
			find ./bin/ -type f -exec sudo cp -av {} $DEST_FOLDER \;
		fi
		[ $? -ne 0 ] && die "Unable to copy ergo to destination folder"
	fi

    echo "Application was successfully installed."
    echo "For uninstalling execute: rm ${DEST_FOLDER}/ergo"
}

show_help(){
    echo "Usage: $PROGNAME [-d destination_directory]"
}

main(){
    #[ -z "$VERSION" ] && die "Unable to get the version information to install"

	echo "DEST_FOLDER set to $DEST_FOLDER"

    install
}

while getopts "h?d:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    d)  DEST_FOLDER=`realpath $OPTARG`
        ;;
    esac
done

main
