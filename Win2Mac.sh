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
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

LRINIT=$(dirname $(readlink $0))/LRSyncBase.sh

if [ ! -f "$LRINIT" ]
then
	echo "Cannot find LRInit.sh file from $LRINIT" >&2
	exit 1
fi

. "$LRINIT"
