#!/bin/bash
#
# This file is part of LRSync. Copyright © 2011 Christophe Labouisse.
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

case $(basename $0) in
    Win2Mac*)
        CONV=WIN2MAC
    ;;

    Mac2Win*)
        CONV=MAC2WIN
    ;;

    *)
        echo >&2 "Cannot recognize command type in $0"
        exit 1
    ;;
esac

while getopts "c:v:" opt; do
	case $opt in
		c)
			echo "Using $OPTARG as catalog" >&2
			CAT="$OPTARG"
			;;
		v)
			echo "Using $OPTARG as volume definition" >&2
			VOLDEF_FILE="$OPTARG"
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			;;
		esac
done

if [ -z "$CAT" -o -z "$VOLDEF_FILE" ]; then
    cat <<EOF >&2
Usage:
    $(basename $0) -c catalog -v volume_definition

EOF
    exit 1
fi

if [ ! -f "$CAT" ]; then
	echo >&2 "Cannot open catalog file '$CAT'"
	exit 2
fi

if [ ! -f "$VOLDEF_FILE" ]; then
	echo >&2 "Cannot open volume definition file '$VOLDEF_FILE'"
	exit 3
fi

# Loading volume definitions
i=0
for a in $(sed 's/#.*//' "$VOLDEF_FILE" | grep -F =) ;do
	winVols[$i]=$(echo "$a" | cut -d = -f 1)
	macVols[$i]=$(echo "$a" | cut -d = -f 2)
	let i++
done

if lockfile -! -r 1 -1 "${CAT}.lock"; then
    echo "Catalog locked, aborting"
    exit 4
fi

TEMPCAT=$(mktemp "${CAT}.lrsync.XXXXXXXX")
cp -p "$CAT" "${TEMPCAT}"

{
	echo ".echo on"
	for (( i=0 ; i < ${#winVols[*]} ; i++ ))
	do
    if [ "$CONV" = "WIN2MAC" ];
    then
		cat <<EOF
update AgLibraryRootFolder set absolutePath=replace(absolutePath, '${winVols[$i]}', '${macVols[$i]}') where absolutePath LIKE '${winVols[$i]}/%';
EOF
    else
        cat <<EOF
update AgLibraryRootFolder set absolutePath=replace(absolutePath, '${macVols[$i]}', '${winVols[$i]}') where absolutePath LIKE '${macVols[$i]}/%';
EOF
    fi
	done
} | sqlite3 "${TEMPCAT}"

touch -r "${CAT}" "${TEMPCAT}"
mv -f "${CAT}" "${CAT}.lrsync"
mv "${TEMPCAT}" "${CAT}"
rm -f "${CAT}.lock"
