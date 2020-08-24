# pkg2appimage [![discourse](https://img.shields.io/badge/forum-discourse-orange.svg)](http://discourse.appimage.org) [![Build Status](https://travis-ci.org/AppImage/pkg2appimage.svg)](https://travis-ci.org/AppImage/pkg2appimage) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/0e7dd241a1bf44af9eebc80fd2c71763)](https://www.codacy.com/app/AppImage/pkg2appimage?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=AppImage/pkg2appimage&amp;utm_campaign=Badge_Grade) [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ZT9CL8M5TJU72)

[![Download as an AppImage](https://raw.githubusercontent.com/KhushrajRathod/KhushrajRathod/master/download-appimage.svg)](../../releases/tag/continuous)
 
This repository is intended to showcase the [AppImage](http://appimage.org) format and [AppImageKit](https://github.com/probonopd/AppImageKit) software used to create AppImages. It contains the `pkg2appimage` tool and some recipes to generate __AppImages__ (portable Linux apps) using [AppImageKit](https://github.com/probonopd/appimagekit).

There are [multiple ways](https://github.com/probonopd/AppImageKit/wiki/Creating-AppImages) to generate AppImages.  Upstream projects are encouraged to produce their own __upstream packaging__ AppImages, like [many projects](https://appimage.github.io) already do.

Some branded applications are unfortunately not provided in AppImage format by their authors yet, and are not allowed to be redistributed. However, if there are existing deb packages (either in archive or `.deb` format or a ppa) then once can to convert these to an AppImage using [pkg2appimage](../../releases/tag/continuous).

![image](https://user-images.githubusercontent.com/2480569/91085594-3aac8600-e63d-11ea-8c2e-a648e6ef3fdb.png)

## Usage

For applications for which there is already an existing [`.yml` recipe file](../../tree/master/recipes), you can simply use the name of the application (without `.yml`) as an argument. For example, to produce a Spotify AppImage, it is sufficient to do:

```
wget -c https://github.com/$(wget -q https://github.com/AppImage/pkg2appimage/releases -O - | grep "pkg2appimage-.*-x86_64.AppImage" | head -n 1 | cut -d '"' -f 2)
chmod +x ./pkg2appimage-*.AppImage
./pkg2appimage-*.AppImage Spotify
```

`.yml` recipes tell pkg2appimage where to get the ingredients from, and how to convert them to an AppImage. Study some [examples](https://github.com/AppImage/AppImages/tree/master/recipes) to see how it works.

To build an AppImage from a local `.yml` recipe (e.g., during development):

```
wget -c https://github.com/$(wget -q https://github.com/AppImage/pkg2appimage/releases -O - | grep "pkg2appimage-.*-x86_64.AppImage" | head -n 1 | cut -d '"' -f 2)
chmod +x ./pkg2appimage-*.AppImage
./pkg2appimage-*.AppImage recipes/XXX.yml
```

## Contributing

You are invited to contribute to the AppImage format, the AppImageKit tools, and the example AppImages provided by us).

The preferred channel of communication for general questions and remarks is our forum and mailing list at http://discourse.appimage.org/.

There is also the #AppImage IRC channel on irc.freenode.net - please stay in there for at least 48 hours because we are not all in the same timezone.

## Donations

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ZT9CL8M5TJU72)
