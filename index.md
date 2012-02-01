---
title: "LRSync: an Adobe LightRoom synchronizer"
layout: default
---

{{ page.title }}
============

Introduction
------------

LightRoom is a neat tool to organize and process photos. However when you need to keep in sync two computers (typically a desktop and a laptop) things are becoming a little bit more difficult especially if the laptop is a Mac and the Desktop a PC. The solutions I was able to find on Internet can be categorized as:

1. **Synchronize photos**. This is a more basic synchronization as it involves synchronizing only the photos and use the *synchronize folder* feature in LightRoom.

    This is working in my case but even if LightRoom is instructed to save all metadata in the `xmp` file you will loose most of the development settings.

1. **Share photos and catalog**. This category can be implemented either by using an external hard drive (for instance in [Adobe's FAQ](http://kb2.adobe.com/cps/333/333736.html#main_Can_I_have_more_than_one_catalog_)) or by using some synchronization tool such as [Rsync][], [Chronosync][], [Dropbox][], etc. (See a very detailled explaination with [Unison][] on [Stackexchange](http://photo.stackexchange.com/questions/1558/what-is-the-best-way-to-synchronize-adobe-lightroom-databases-between-two-comput)).

    This is a solution far better than the first one. However it requires to have the same directory hierarchy on both computers or an additional manipulation will be required to tell LightRoom the actual location of the image folders. I don't like much the idea of putting all my photos on an external drive and carry it. Of course I have backups (Do I ?) but I like the idea of having two copies of my photos one on the laptop and one on the desktop.

1. **Export/Import catalog**. This category requires the user to use the _Export as catalog_ and _Import catalog_ features of LightRoom. (See [this one](http://www.peachpit.com/articles/article.aspx?p=1664584) for more details).

    This is definitly working but is requiring a lot of handling. In the example above it is important to notice that the synchonization is only from the laptop to the desktop which is exactly what you are doing if you are taking photos on the field and processing them in the soft warmness of you home/studio but not if you are willing to process pictures from your desktop while you're away from home.

Downloads
---------

You can download this project in either [zip](https://github.com/ggtools/LRSync/zipball/master) or [tar](https://github.com/ggtools/LRSync/tarball/master) formats.

[rsync]: http://en.wikipedia.org/wiki/Rsync
[chronosync]: http://econtechnologies.com/pages/cs/chrono_overview.html
[Dropbox]: http://www.dropbox.com/
[Unison]: http://www.cis.upenn.edu/~bcpierce/unison/
