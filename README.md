# AppImages [![Build Status](https://travis-ci.org/probonopd/AppImages.svg)](https://travis-ci.org/probonopd/AppImages)

 * Arduino [![Download](https://api.bintray.com/packages/probono/AppImages/Arduino/images/download.svg)](https://bintray.com/probono/AppImages/Arduino/_latestVersion)
 * Firefox [![Download](https://api.bintray.com/packages/probono/AppImages/Firefox/images/download.svg)](https://bintray.com/probono/AppImages/Firefox/_latestVersion)
 * Scribus [![Download](https://api.bintray.com/packages/probono/AppImages/Scribus/images/download.svg)](https://bintray.com/probono/AppImages/Scribus/_latestVersion)
 * Subsurface [![Download](https://api.bintray.com/packages/probono/AppImages/subsurface/images/download.svg)](https://bintray.com/probono/AppImages/subsurface/_latestVersion)
 
This repository contains some recipes to generate __AppImages__ (portable Linux apps) using [AppImageKit](https://github.com/probonopd/appimagekit). See the [Bintray page](https://bintray.com/probono/AppImages) tab for downloads of the generated AppImages.

This repository also contains __recipes__, which are the scripts used to create the AppImages, and __dockerfiles__ that are used to create [Docker images on Docker Hub](https://hub.docker.com/r/probonopd/appimages/) (think of them as glorified `chroot` environments) in which the recipes can run. Finally, everything is tied together using travis-ci which uses Docker containers created by the dockerfiles from this repository to generate AppImages using the recipes from this repository. The result are AppImages are uploaded to a Bintray repository and can run on most modern desktop Linux distributions.

This repository is intended to showcase the [AppImage](http://appimage.org) format and [AppImageKit](https://github.com/probonopd/AppImageKit) software used to create AppImages. Upstream projects are encouraged to use this showcase to produce their own __upstream packaging__ AppImages, as some projects (like [Subsurface](https://subsurface-divelog.org) already do).

## Motivation

Linus addresses some core issues of Linux on the desktop in his [DebConf 14_ QA with Linus Torvalds talk](https://www.youtube.com/watch?v=5PmHRSeA2c8). At 05:40 Linus highlights application packaging: 

> I'm talking about actual application writers that want to make a package of their application for Linux. And I've seen this firsthand with the other project I've been involved with, which is my divelog application.

Obviously Linus is talking about [Subsurface](https://subsurface-divelog.org). 

> We make binaries for Windows and OS X. 

[subsurface-4.5.exe](https://subsurface-divelog.org/downloads/subsurface-4.5.exe) for Windows is 83.5 MB large, [Subsurface-4.5.dmg](https://subsurface-divelog.org/downloads/Subsurface-4.5.dmg) for Mac weighs in at 38.3 MB.

Both bundle not only the application itself, but also the required Qt libraries that the application needs to run. Also included are dependency libraries like `libssh2.1.dylib`and `libzip.2.dylib`.

> We basically don't make binaries for Linux. Why? Because binaries for Linux desktop applications is a major f*ing pain in the ass. Right. You don't make binaries for Linux. You make binaries for Fedora 19, Fedora 20, maybe there's even like RHEL 5 from ten years ago, you make binaries for debian stable.

So why not use the same approach as on Windows and OS X, namely, treat the base operating system as a _platform_ on top of which we tun the application we care about. This means that we have to bundle the application with all their dependencies that are _not_ part of the base operating system. Welcome [application bundles](https://blogs.gnome.org/tvb/2013/12/10/application-bundles-for-glade/).

[Here](https://github.com/probonopd/AppImages/releases/tag/1) is is an AppImage of Subsurface, built from the latest git sources in a CentOS 6 chroot using this [recipe](https://github.com/probonopd/AppImages/blob/master/recipes/subsurface/Recipe). Just download, `chmod a+x`, and run. At 49 MB, the AppImage is roughly in line with the binaries for Windows and OS X. With some more hand-tuning, the size could probably be brought further down. So far, the AppImage has been verified to run on
 * CentOS-6.7-x86_64-LiveCD.iso
 * CentOS-7.0-1406-x86_64-GnomeLive.iso
 * CentOS-7-x86_64-LiveGNOME-1503.iso
 * Chromixium-1.5-amd64.iso
 * debian-live-8.2.0-amd64-cinnamon-desktop.iso
 * debian-live-8.2.0-amd64-gnome-desktop+nonfree.iso
 * elementary_OS_0.3_freya_amd64.iso
 * Fedora-Live-Desktop-x86_64-20-1.iso
 * Fedora-Live-Workstation-x86_64-22-3.iso
 * Fedora-Live-Workstation-x86_64-23-10.iso
 * kali-linux-2.0-amd64.iso
 * Mageia-5-LiveDVD-GNOME-x86_64-DVD.iso
 * openSUSE-Tumbleweed-GNOME-Live-x86_64-Current.iso (20151012)
 * openSUSE-Tumbleweed-KDE-Live-x86_64-Current.iso (20151022)
 * tanglu-3.0-gnome-live-amd64.hybrid.iso
 * trisquel_7.0_amd64.iso
 * ubuntu-12.04.5-desktop-amd64.iso
 * ubuntu-14.04.1-desktop-amd64.iso
 * ubuntu-15.04-desktop-amd64.iso
 * ubuntu-15.10-desktop-amd64.iso
 * ubuntu-gnome-15.04-desktop-amd64.iso
 * ubuntu-gnome-15.10-desktop-amd64.iso
 * wily-desktop-amd64.iso
 * xubuntu-15.04-desktop-amd64.iso

But we also target 32-bit systems like
 * CentOS-6.4-i386-LiveDVD.iso
 * CentOS-6.5-i386-LiveCD.iso
 * CentOS-6.7-i386-LiveCD.iso
 * debian_7.0.0_wheezy_i386_20130705_binary.hybrid.iso
 * debian-live-7.5.0-i386-gnome-desktop.iso
 * Fedora-Live-Design-suite-i686-20-1.iso
 * Fedora-Live-Desktop-i686-19-1.iso
 * Fedora-Live-Desktop-i686-20-1.iso
 * Fedora-Live-Xfce-i686-20-1.iso
 * kali-linux-1.0.7-i386.iso
 * openSUSE-13.1-GNOME-Live-i686.iso
 * openSUSE-Tumbleweed-GNOME-Live-i686-Snapshot20151012-Media.iso (20151012)
 * tails-i386-1.5.iso
 * ubuntu-11.04-desktop-i386.iso
 * ubuntu-12.04.2-desktop-i386.iso

> Or actually you don't make binaries for debian stable because debian stable has libraries that are so old that anything that was built in the last century doesn't work. But you might make binaries for debian... whatever the codename is for unstable. And even that is a major pain because (...) debian has those rules that you are supposed to use shared libraries. Right. 

Note that the AppImage runs not only on debian stable, but even on debian __oldstable__ (which is wheezy at this time).

Most likely it will run on others, too - and with some fine-tuning of the [recipe](https://github.com/probonopd/AppImages/blob/master/recipes/subsurface/Recipe) (i.e., bundling additional dependencies) even more.

> And if you don't use shared libraries, getting your package in, like, is just painful. 

"Getting your package in" means that the distribution accepts the package as part of the base operating system. For an application, that might not be desired at all. As long as we can package the application in a way that it seamlessly runs on top of the base operating system. 

> But using shared libraries is not an option when the libraries are experimental and the libraries are used by two people and one of them is crazy, so every other day some ABI breaks. 

One simple way to achieve this is to bundle private copies of the libraries in question with the application that uses them. Preferably in a way that does not interfere with anything else that is running on the base operating system. Note that this does not have to be true for all libraries; core libraries that are matured, have stable interfaces and can reasonably expected to be present in all distributions do not necessarily have to be bundled with the application.

> So you actually want to just compile one binary and have it work. Preferably forever. And preferably across all Linux distributions. 

That is actually possible, as long as you stay away from any distribution-specific packaging, and as long as you do not use a too recent build system. The same will probably be true for Windows and OS X - if you compile on OS X 10.11 then I would not expect the resulting build products to run on OS X 10.5.

> And I actually think distributions have done a horribly, horribly bad job. 

Distributions are all about building the base operating system. But I don't think distributions are a good way to get applications. Rather, I would prefer to get the latest versions of applications directly from the people who write them. And this is already a reality for software like Google Chrome, Eclipse, Arduino and other applications. Who uses the (mostly outdated and changed) versions that are part of the distributions? Probably most people don't.

> One of the things that I do on the kernel - and I have to fight this every single release and I think it's sad - we have one rule in the kernel, one rule: we don't break userspace. (...) People break userspace, I get really, really angry. (...) 

Excellent. Thank you for this policy! This is why I can still run the Mosaic browser from over a decade ago on modern Linux-based operating systems. (I tried and it works.)

> And then all the distributions come in and they screw it all up. Because they break binary compatibility left and right. 

Luckily, binaries built on older distributions tend to still work on newer distributions. At least that has been my experience over the last decade with building application bundles using AppImageKit, and before that, klik.

> They update glibc and everything breaks. (...) 

There is a [way around this](https://blogs.gnome.org/tvb/2013/12/14/application-bundles-revisited/), although not many people actually care to use the workaround (yet).

> So that's my rant. And that's what I really fundamentally think needs to change for Linux to work on the desktop because you can't have applications writers to do fifteen billion different versions.

AppImage to the rescue. The AppImage format is a standardized format for packaging applications in a way that allows them to run on target systems without further modification. The AppImage format (which basically is an ISO that gets mounted when you run the applicaiton) has been created with specific objectives in mind, which are explained in more detail in the [AppImageKit README](https://github.com/probonopd/AppImageKit/blob/master/README.md):

1. Be Simple
2. Maintain binary compatibility 
3. Be distribution-agostic 
4. Remove the need for installation
5. Keep apps compressed all the time
6. Allow to put apps anywhere
7. Make applications read-only
8. Do not require recompilation (not always desired or possible)
9. Keep base operating system untouched
10. Do not require root

I would welcome people writing applications to pick this up as an easy way to provide nightly builds that run (almost) everywhere and leave no traces in the base operating system. Some upstream projects like [Glade](https://github.com/GNOME/glade/tree/master/build/linux), [Gstreamer](http://lists.freedesktop.org/archives/gstreamer-bugs/2014-May/124914.html), and [Pitivi](http://pitivi.ecchi.ca/bundles/) have been building AppImages. There are more [sophisticated](http://0pointer.net/blog/revisiting-how-we-put-together-linux-systems.html) [approaches](https://wiki.gnome.org/Projects/SandboxedApps) in the works, which I welcome, but in the meantime here is something reasonably simple, universal, and robust that works today.

## Screenshots

Fedora 22 (Twenty Two) - Fedora-Live-Workstation-x86_64-22-3.iso

![fedora](https://cloud.githubusercontent.com/assets/2480569/10559493/0e837b86-74f2-11e5-94e1-56f901c51f6e.png)

CentOS Linux 7 (Core) - CentOS-7.0-1406-x86_64-GnomeLive.iso

![centos](https://cloud.githubusercontent.com/assets/2480569/10559404/919d607e-74f0-11e5-8816-e9032c25cdcd.png)

Ubuntu 14.04.1 LTS (Trusty Tahr) - ubuntu-14.04.1-desktop-amd64.iso

![ubuntu](https://cloud.githubusercontent.com/assets/2480569/10559436/02930bb2-74f1-11e5-88d0-2f8ce82e8846.png)

openSUSE Tumbleweed (20151012) - openSUSE-Tumbleweed-GNOME-Live-x86_64-Current.iso

![opensuse](https://cloud.githubusercontent.com/assets/2480569/10559386/f4bdc906-74ef-11e5-87b7-98d9033d1252.png)
