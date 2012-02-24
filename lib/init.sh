#!/bin/bash
#
# This file is part of LRSync. Copyright © 2011-2012 Christophe Labouisse.
# 
# LRSync is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# LRSync is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with LRSync.  If not, see <http://www.gnu.org/licenses/>.

# Reads a section of the ini file and put the results in variables prefixed by the supplied prefix. 
readIniSection() {
	local PREFIX="$1"
	local SECTION="${2-main}"
	
	# Neat way to parse the ini section from LRS_INI
	# shamelessly taken from http://www.tuxz.net/blog/
	eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
    -e 's/;.*$//' \
    -e 's/[[:space:]]*$//' \
    -e 's/^[[:space:]]*//' \
    -e "s/^\(.*\)=\([^\"']*\)$/\1=\"\2\"/" \
    -e "s/^\(.*\)=/${PREFIX}\1=/" \
   < $LRS_INI \
    | sed -n -e "/^\[$SECTION\]/,/^\s*\[/{/^[^;].*\=.*/p;}"`
}

usage() {
	cat <<EOF
lrsync -c catalog [-q] [-r repo_dir] operation

	-c catalog  : the catalog to be converted, must be declared in lrsync.ini
	-f          : force conversion even if source is older than destination or
                  if the post conversion tests fail.
	-q          : remove output during conversion
	-r repo_dir : directory containing the reference catalogs
	
	operation   : fromRepo or toRepo to synchronize a catalog from or to the repo.
	              display to display a list of the root folders of the catalog.
	
EOF
}

msg() {
	[ "$LRS_QUIET" ] || echo $@
}

set +e

LRS_INIDIR="$HOME/.lrsync"
LRS_INI="$LRS_INIDIR/lrsync.ini"
SQLITE="sqlite3"

# Create the lrsync configuration directory and copy a default .ini file.
if [ ! -d "$LRS_INIDIR" ]; then
	mkdir -p "$LRS_INIDIR"
	cp "$LRS_LIBDIR/default.ini" "$LRS_INI"
fi

# Load the "main" section of LRS_INI
readIniSection LRS_

# Override it with the command line
while getopts "?hc:fqr:" opt; do
	case $opt in
		c)
			LRS_CATALOG="$OPTARG"
			;;
		f)
			LRS_FORCE=1
			;;
		q)
			LRS_QUIET=1
			;;
		r)
			LRS_REPODIR="$OPTARG"
			;;
		\?|h)
			[ -n "$OPTARG" ] && echo "Invalid option: -$OPTARG" >&2
			usage >&2
			exit 1
			;;
		esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift
if [[ "$1" =~ ^from|to|display ]]; then
	LRS_DIRECTION=${BASH_REMATCH[0]}
else
	if [ -z "$1" ]; then
		echo "Missing mandatory argument direction" >&2
	else
		echo "Invalid direction '$1'" >&2
	fi
	usage >&2
	exit 1
fi

mkdir -p "$LRS_REPODIR"

if [ ! -d "$LRS_REPODIR" ]; then
	echo "Repository directory '$LRS_REPODIR' does not exist" >&2
	exit 2
fi

if [ -z "$LRS_DIRECTION" ]; then
	echo "-d direction is mandatory" >&2
	usage >&2
	exit 2
fi

if [ -z "$LRS_CATALOG" ]; then
	echo "-c catalog is mandatory" >&2
	usage >&2
	exit 2
fi

readIniSection LRS_CAT_ "$LRS_CATALOG"

if [ ! -d "$LRS_CAT_DIR" ]; then
	echo "Catalog directory '$LRS_CAT_DIR' not found" >&2
	usage >&2
	exit 3
fi

LRS_CAT_FILE="$LRS_CAT_DIR/$LRS_CATALOG.lrcat"
if [[ "$LRS_DIRECTION" =~ to|display && ! -f "$LRS_CAT_FILE" ]]; then
	echo "Catalog file '$LRS_CAT_FILE' not found" >&2
	usage >&2
	exit 3
fi

LRS_REPO_FILE="$LRS_REPODIR/$LRS_CATALOG.lrcat"
if [ "$LRS_DIRECTION" = "from" -a ! -f "$LRS_REPO_FILE" ]; then
	echo "Repo file '$LRS_REPO_FILE' not found" >&2
	usage >&2
	exit 3
fi

[[ "$LRS_CAT_FOLDERCONFIG" =~ ^/ ]] || LRS_CAT_FOLDERCONFIG="$LRS_INIDIR/$LRS_CAT_FOLDERCONFIG"

if [ ! -f "$LRS_CAT_FOLDERCONFIG" ]; then
	echo "Catalog '$LRS_CATALOG' is not properly defined in lrsync.ini." >&2
	usage >&2
	exit 3
fi

# Loading volume definitions
msg "Loading  folder configuration from '$LRS_CAT_FOLDERCONFIG'"
i=0
for a in $(sed -n '{s/#.*//; /=/p;}' "$LRS_CAT_FOLDERCONFIG"); do
	repoVols[$i]=$(echo "$a" | cut -d = -f 1)
	catVols[$i]=$(echo "$a" | cut -d = -f 2)
	let i++
done

if [ -z "$LRS_QUIET" ]; then
	cat <<EOF
Catalog   : $LRS_CATALOG
Direction : $LRS_DIRECTION
Repository: $LRS_REPODIR
Repo file : $LRS_REPO_FILE
LRCat dir : $LRS_CAT_DIR
LRCat file: $LRS_CAT_FILE
Folders:
EOF
	for (( i=0 ; i < ${#repoVols[*]} ; i++ ))
	do
		echo "            ${repoVols[$i]} -> ${catVols[$i]}"
	done
	echo ""
fi
