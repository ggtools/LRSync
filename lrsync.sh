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

cleanAndExit() {
	code=${1-0}
	# Unlock catalog file.
	if [ -n "$catLocked" ]; then
		msg "Unlocking '$LRS_CAT_FILE'"
		rm -f "${LRS_CAT_FILE}.lock"
		catLock=""
	fi
	exit $code
}

LRS_BASEDIR=$(dirname $0)
LRS_LIBDIR=$LRS_BASEDIR/lib

# Read options and configuration
. ${LRS_LIBDIR}/init.sh

# Lock catalog file.
msg "Locking catalog file '$LRS_CAT_FILE'"
if lockfile -! -r 1 -1 "${LRS_CAT_FILE}.lock"; then
    echo "Catalog locked, aborting"
    exit 4
fi

catLocked=1

if [ "$LRS_DIRECTION" = "to" ]; then
	sourceCat="$LRS_CAT_FILE"
	sourceDir="$LRS_CAT_DIR"
	sourceVols=("${catVols[@]}")
	destCat="$LRS_REPO_FILE"
	destDir="$LRS_REPODIR"
	destVols=("${repoVols[@]}")
else
	sourceCat="$LRS_REPO_FILE"
	sourceDir="$LRS_REPODIR"
	sourceVols=("${repoVols[@]}")
	destCat="$LRS_CAT_FILE"
	destDir="$LRS_CAT_DIR"
	destVols=("${catVols[@]}")
fi

# TODO check if source catalog is older than destination catalog.

# Create a temporary catalog in the destination directory.
TEMPCAT=$(mktemp "${destDir}/${LRS_CATALOG}.lrsync.XXXXXXXX")
msg "Copying source catalog to $TEMPCAT"
cp -p "${sourceCat}" "${TEMPCAT}"

{
	# [ "$LRS_QUIET" ] || echo ".echo on"
		for (( i=0 ; i < ${#repoVols[*]} ; i++ ))
	do
		cat <<EOF
update AgLibraryRootFolder set absolutePath=replace(absolutePath, '${sourceVols[$i]}', '${destVols[$i]}') where absolutePath LIKE '${sourceVols[$i]}/%';
EOF
	done
} | ${SQLITE} "${TEMPCAT}"

# TODO check if catalog only contains acceptable root folders.

if [ $? -ne 0 ]; then
	echo "Error while processing catalog '$sourceCat'" >&2
	rm -f "$TEMPCAT"
	cleanAndExit 5
fi
	
touch -r "${sourceCat}" "${TEMPCAT}"
[ -f "${destCat}" ] && mv -f "${destCat}" "${destCat}.lrsync"
mv "${TEMPCAT}" "${destCat}"

cleanAndExit
