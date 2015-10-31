# AppImages [![Build Status](https://travis-ci.org/probonopd/AppImages.svg)](https://travis-ci.org/probonopd/AppImages)

Some AppImages (portable Linux apps) generated with travis-ci using [AppImageKit](https://github.com/probonopd/appimagekit)

See the [Releases](https://github.com/probonopd/AppImages/releases) tab for downloads. (Note that the build products might be newer than the revision shown there.)

Linus addresses some core issues of Linux on the desktop in his [DebConf 14_ QA with Linus Torvalds talk](https://www.youtube.com/watch?v=5PmHRSeA2c8). At 05:40 Linus highlights application packaging: 

> I'm talking about actual application writers that want to make a package of their application for Linux. And I've seen this firsthand with the other project I've been involved with, which is my divelog application.

Obviously Linus is talking about [Subsurface](https://subsurface-divelog.org). 

> We make binaries for Windows and OS X. 

[subsurface-4.5.exe](https://subsurface-divelog.org/downloads/subsurface-4.5.exe) for Windows is 83.5 MB large, [Subsurface-4.5.dmg](https://subsurface-divelog.org/downloads/Subsurface-4.5.dmg) for Mac weighs in at 38.3 MB.

Both bundle not only the application itself, but also the required Qt libraries that the application needs to run. Also included are dependency libraries like `libssh2.1.dylib`and `libzip.2.dylib`.

> We basically don't make binaries for Linux. Why? Because binaries for Linux desktop applications is a major f*ing pain in the ass. Right. You don't make binaries for Linux. You make binaries for Fedora 19, Fedora 20, maybe there's even like RHEL 5 from ten years ago, you make binaries for debian stable, or actually you don't make binaries for debian stable because debian stable has libraries that are so old that anything that was built in the last century doesn't work. But you might make binaries for debian... whatever the codename is for unstable. And even that is a major pain because (...) debian has those rules that you are supposed to use shared libraries. Right. 

So why not use the same approach as on Windows and OS X, namely, treat the base operating system as a _platform_ on top of which we tun the application we care about. This means that we have to bundle the application with all their dependencies that are _not_ part of the base operating system. Welcome [application bundles](https://blogs.gnome.org/tvb/2013/12/10/application-bundles-for-glade/).

[Here](https://github.com/probonopd/AppImages/releases) is is an AppImage of Subsurface, built from the latest git sources in an [automated process](https://github.com/probonopd/AppImages/blob/master/recipes/subsurface.sh). Just download, `chmod a+x`, and run. With 73.3 MB, `Subsurface_4.5.0_x86_64.AppImage` is roughly in line with the binaries for Windows and OS X. With some more hand-tuning, the size could probably be brought further down. So far, the AppImage has been verified to run on
* CentOS Linux 7 (Core) - CentOS-7.0-1406-x86_64-GnomeLive.iso
* CentOS Linux release 7.1.1503 (Core) - CentOS-7-x86_64-LiveGNOME-1503.iso
* Fedora 22 (Twenty Two) - Fedora-Live-Workstation-x86_64-22-3.iso
* Ubuntu 14.04.1 LTS (Trusty Tahr) - ubuntu-14.04.1-desktop-amd64.iso
* Ubuntu 15.04 (Vivid Vervet) - ubuntu-15.04-desktop-amd64.iso
* openSUSE Tumbleweed (20151012) - openSUSE-Tumbleweed-GNOME-Live-x86_64-Current.iso
* Antergos - antergos-2014.08.07-x86_64.iso
* elementary OS 0.3 Freya - elementary_OS_0.3_freya_amd64.iso

But we are also targeting older ones such as
* Fedora 20 (Heisenbug) - Fedora-Live-Desktop-x86_64-20-1.iso
* Ubuntu 12.04.5 LTS (Precise Pangolin) - ubuntu-12.04.5-desktop-amd64.iso

Most likely it will run on others, too - and with some fine-tuning of the [recipe](https://github.com/probonopd/AppImages/blob/master/recipes/subsurface.sh) (i.e., bundling additional dependencies) even more.

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

AppImage to the rescue. The AppImage format is a standardized format for packaging applications in a way that allows them to run on target systems without further modification. The AppImage format (which basically is an ISO that gets mounted when you run the applicaiton) has been created with specific objectives in mind, which are explained in more detail in the [AppImageKit Documentation](http://portablelinuxapps.org/docs/1.0/AppImageKit.pdf):
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
