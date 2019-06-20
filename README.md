# pkg2appimage [![discourse](https://img.shields.io/badge/forum-discourse-orange.svg)](http://discourse.appimage.org) [![Build Status](https://travis-ci.org/AppImage/pkg2appimage.svg)](https://travis-ci.org/AppImage/pkg2appimage) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/0e7dd241a1bf44af9eebc80fd2c71763)](https://www.codacy.com/app/AppImage/pkg2appimage?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=AppImage/pkg2appimage&amp;utm_campaign=Badge_Grade) [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ZT9CL8M5TJU72)
 
This repository contains the `pkg2appimage` tool and some recipes to generate __AppImages__ (portable Linux apps) using [AppImageKit](https://github.com/probonopd/appimagekit). See the [Bintray page](https://bintray.com/probono/AppImages) tab for downloads of the generated AppImages.

__Recipes__ are the `.yml` files used to create the AppImages, and __Dockerfiles__ are used to build [Docker images on Docker Hub](https://hub.docker.com/r/probonopd/appimages/) (think of them as glorified `chroot` environments) in which the recipes can run. Finally, everything is tied together using travis-ci which uses Docker containers created by the Dockerfiles from this repository to generate AppImages using the recipes from this repository. The result are AppImages are uploaded to a Bintray repository and can run on most modern desktop Linux distributions.

This repository is intended to showcase the [AppImage](http://appimage.org) format and [AppImageKit](https://github.com/probonopd/AppImageKit) software used to create AppImages. Upstream projects are encouraged to use this showcase to produce their own __upstream packaging__ AppImages, as some projects (like [Subsurface](https://subsurface-divelog.org) already do).

## Usage

There are [multiple ways](https://github.com/probonopd/AppImageKit/wiki/Creating-AppImages) to generate AppImages. If you already have existing binaries (either in archive or `.deb` format or a ppa) then the recommended way to convert these to an AppImage is to write a [.yml description file](https://github.com/AppImage/AppImages/tree/master/recipes) and run it with [pkg2appimage](https://github.com/AppImage/AppImages/tree/master/pkg2appimage):

To build an AppImage from a `.yml` description file:

```
bash -ex ./pkg2appimage recipes/XXX.yml
```

`.yml` description files tell pkg2appimage where to get the ingredients from, and how to convert them to an AppImage (besides the general steps already included in pkg2appimage). Study some [examples](https://github.com/AppImage/AppImages/tree/master/recipes) to see how it works.

## Miscellaneous

### Uploading AppImages to Bintray

The script [bintray.sh](https://github.com/AppImage/AppImages/blob/master/bintray.sh) can be used by anyone to upload AppImages to Bintray.

The script will:

1. Extract metadata from the AppImage
2. Make the AppImage updatable with zsync
3. Upload the AppImage to Bintray

In order to use `bintray.sh` you must first define your Bintray credentials in the environment. In order to get your Bintray API Key, you need to enter the "API Key" section in https://bintray.com/profile/edit

Example:
```
wget https://raw.githubusercontent.com/AppImage/AppImages/master/bintray.sh
export BINTRAY_USER=<Your Bintray username>
export BINTRAY_REPO=<Your Bintray repository>
export BINTRAY_REPO_OWNER=<Your bintray Organization (optional)>
export BINTRAY_API_KEY=<Your Bintray API Key>
./bintray.sh "Subsurface-4.5.1.667-x86_64.AppImage"
```

If you use Travis for CI, you can define these variables in the Travis control panel, specially the `BINTRAY_API_KEY`, in order to keep it secure.

## Contributing

You are invited to contribute to the AppImage format, the AppImageKit tools, and the example AppImages provided by us).

The preferred channel of communication for general questions and remarks is our forum and mailing list at http://discourse.appimage.org/.

For technical contibutions, https://github.com/probonopd/AppImageKit - please file [Issues](https://github.com/probonopd/AppImageKit/issues) (also for wishlist items or discussion topics) or submit [Pull requests](https://github.com/probonopd/AppImageKit/pulls).

There is also the #AppImage IRC channel on irc.freenode.net and we use [Gitter](https://gitter.im/probonopd/AppImageKit) which has the advantage that one does not have to be online all the time and one can communicate despite not being in the same timezone.

## Donations

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ZT9CL8M5TJU72)

## Acknowledgments

This project would not have been possible without the contributors to AppImageKit and without the services which generously support Open Source projects:

* [JFrog](https://www.jfrog.com) for providing [Bintray](https://bintray.com), the distribution platform used to distribute AppImages built by the recipes in this project to users. Bintray has been truly invaluable for this project since it not only provides us with free hosting and traffic for our AppImages, but also makes it really easy to set up a repository for custom binary formats such as AppImage, and to maintain the metadata associated with the downloads. Thanks to the easy-to use REST API, we were able to set up an automated workflow involving GitHub and Travis CI to build, upload and catalog AppImages in no time. Also, JFrog Bintray relieved us from the burden to create a web UI for the repository by providing a generic one out-of-the-box. 
* [Travis CI](https://travis-ci.org) for providing cloud-based test and build services that are easy to integrate with GitHub.
* [GitHub](https://travis-ci.org) for making it possible to work on Code in the Cloud, and for making it super easy to contribute to Open Source projects.
