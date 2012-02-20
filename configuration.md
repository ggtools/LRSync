---
title: Configuration
layout: default
pygments: true
---

Main configuration file
=======================

LRSync main configuration file is the `lrsync.ini` file located in `$HOME/.lrsync`. This file and the `$HOME/.lrsync` are created the first time LRSync is run if they do not exist. The default contents are:

{% highlight ini %}
# Configuration file for LRSync
# Note: all keys should be written in UPPER CASE
[main]
# Location of the catalog repository
REPODIR=$HOME/Pictures/LRSync/repo
# Uncomment if the repo needs to be locked
# LOCKREPO=true

# Sample catalog configuration
# Catalog named MyPhotos.lrcat
[MyPhotos]
# Directory where MyPhotos.lrcat is located
DIR=$HOME/Pictures/Lightroom
# Configuration file for the folders either in absolute path or, in the example
# below, relatively to lrsync.ini.
FOLDERCONFIG=folders.conf

# Catalog named SharedPhotos.lrcat
[SharedPhotos]
DIR=/Users/Shared/Pictures/Lightroom
# Folder configuration file can be shared by several catalogs.
FOLDERCONFIG=folders.conf
{% endhighlight %}

Folders configuration
=====================

Displaying root folders
-----------------------

The root folders of a catalog can be displayed using LRSync using the following command:

{% highlight bash %}
$ ./lrsync.sh -q -c PhotosPerso-2-2 display
/Users/Me/Pictures/Lightroom/Photos/
/Users/Shared/Pictures/Lightroom/Photos/
{% endhighlight %}

Configuration file
------------------

A folder configuration file defines the relation between folders in the repo catalog and in the working catalogs. One or more folder configuration files may exist. The file consists in several lines with one folder definition per line. For instance:

{% highlight bash %}
# This is comment line
C:/Users/Toto/Picture/Lightroom=/Users/Me/Pictures/Lightroom
M:/Pictures/Lightroom=/Users/Shared/Pictures/Lightroom
{% endhighlight %}
