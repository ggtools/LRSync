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
	# Unlock repo if locked
	if [ -n "$repoLocked" ]; then
     	msg "Unlocking '${LRS_REPO_FILE}'"
     	rm -f "${LRS_REPO_FILE}.lock"
     	repoLocked=""
	fi
	# Unlock catalog file.
	if [ -n "$catLocked" ]; then
		msg "Unlocking '$LRS_CAT_FILE'"
		rm -f "${LRS_CAT_FILE}.lock"
		catLocked=""
	fi
	exit $code
}

# Just in cas the init file cannot be read.
set -e

LRS_TRM=$(readlink $0) # The Real Me
LRS_BASEDIR=$(dirname $LRS_TRM)
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

if [ -n "$LRS_LOCKREPO" ]; then
# Lock catalog file.
  msg "Locking catalog file '$LRS_REPO_FILE'"
  if lockfile -! -r 1 -1 "${LRS_REPO_FILE}.lock"; then
      echo "Repo locked, aborting"
      cleanAndExit 4
  fi
  
  repoLocked=1
fi

if [ "$LRS_DIRECTION" = "display" ]; then
	msg "The following rootfolders exist in the catalog:" 
	echo "select absolutePath from AgLibraryRootFolder;" | ${SQLITE} "$LRS_CAT_FILE"
	cleanAndExit
fi

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

if [ -z "$LRS_FORCE" -a "$sourceCat" -ot "$destCat" ]; then
	echo "Source catalog is older than destination catalog, not converting unless -f is supplied" >&2
	cleanAndExit 6
fi

# Create a temporary catalog in the destination directory.
TEMPCAT=$(mktemp "${destDir}/${LRS_CATALOG}.lrsync.XXXXXXXX")
msg "Copying source catalog to $TEMPCAT"
cp -p "${sourceCat}" "${TEMPCAT}"

{
	# [ "$LRS_QUIET" ] || echo ".echo on"
	for (( i=0 ; i < ${#sourceVols[*]} ; i++ ))
	do
		cat <<EOF
update AgLibraryRootFolder set absolutePath=replace(absolutePath, '${sourceVols[$i]}', '${destVols[$i]}') where absolutePath LIKE '${sourceVols[$i]}/%';
EOF
	done
} | ${SQLITE} "${TEMPCAT}"

if [ $? -ne 0 ]; then
	echo "Error while processing catalog '$sourceCat'" >&2
	rm -f "$TEMPCAT"
	cleanAndExit 5
fi

# Check if the dest catalog does not contain unconverted folders
if [ -z "$LRS_FORCE" ]; then
	statement="select name, absolutePath from AgLibraryRootFolder where id_local not in (select id_local from AgLibraryRootFolder where"
	for (( i=0 ; i < ${#destVols[*]} ; i++ ))
	do
		[ $i -gt 0 ] && statement="$statement or"
		statement="$statement absolutePath like '${destVols[$i]}/%'"
	done
	statement="$statement);"
	unconvFolders=$(echo "$statement" | $SQLITE "${TEMPCAT}")
	if [ -n "$unconvFolders" ]; then
		cat >&2 <<EOF
Converted catalog still contains unconverted folders. Won't convert without -f.
Unconverted folders:
$unconvFolders
EOF
		rm -f "$TEMPCAT"
		cleanAndExit 7
	fi
fi

touch -r "${sourceCat}" "${TEMPCAT}"
[ -f "${destCat}" ] && mv -f "${destCat}" "${destCat}.lrsync"
mv "${TEMPCAT}" "${destCat}"

msg "Synchronizing previews"
rsync -a --delete "${sourceDir}/${LRS_CATALOG} Previews.lrdata" "${destDir}"

cleanAndExit
