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
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

LRINIT=$(dirname $(readlink $0))/LRInit.sh

if [ ! -f "$LRINIT" ]
then
	echo "Cannot find LRInit.sh file from $LRINIT" >&2
	exit 1
fi

. $(dirname $(readlink $0))/LRInit.sh

{
	echo ".echo on"
	for (( i=0 ; i < ${#winVols[*]} ; i++ ))
	do
		cat <<EOF
update AgLibraryRootFolder set absolutePath=replace(absolutePath, '${winVols[$i]}', '${macVols[$i]}') where absolutePath LIKE '${winVols[$i]}/%';
EOF
	done
} | sqlite3 "${TEMPCAT}"

touch -r "${CAT}" "${TEMPCAT}"
mv -f "${CAT}" "${CAT}.lrsw2m"
mv "${TEMPCAT}" "${CAT}"
rm -f "${CAT}.lock"
