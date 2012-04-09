---
title: "Synchronize Adobe Lightroom between computers"
layout: default
pygments: true
---

Overview
========

LRSync is a tool to help synchronizing Adobe Lightroom catalogs between computers. It is implemented as a bash script will ultimatly become the best sychronization tool ever made. The current version focus on the catalog conversion between the two computers as this is the part is not covered by any other tool I know. The following features are currently supported:

1. Conversion between the local computer and the remote one with different directory layout or operating system.

1. Safe conversion locking the catalog to ensure that Lightroom and LRSync are not modifying the catalog at the same time and by performing a validity check before actually committing changes made to the catalog.

LRSync as been developed and tested on Mac OS X Snow Leopard. It should probably work on:

* Mac OS X Lion
* Windows through Cygwin (provided the right packages are installed)
* Linux and BSDs although I don't think it'll be useful on these platforms as Lightroom only exists on Windows and Mac OS X.

From here you can [download](download.html) and [configure](configuration.html) LRSync or if you what to learn about the life, the universe and everything on LRSync have a look to the [history](history.html) page.
