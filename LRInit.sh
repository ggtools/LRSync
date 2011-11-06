#!/bin/bash -xv
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
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

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
	echo $i
	let i++
done
