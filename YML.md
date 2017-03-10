# About `.yml` files

The `recipes/meta` directory in this repository contains `.yml` files.

## Purpose of `.yml` files 

`.yml` files are used by the script used in the AppImages project that converts binary ingredients into AppImages for demonstration purposes. The `.yml` file format is __not__ part of the AppImage standard which just describes the AppImage container format and is agnostic as to how the payload inside an AppImage gets generated. The `.yml` file format is also __not__ not part of AppImageKit, because AppImageKit is only concerned with taking a pre-existing AppDir and converting that into an AppImage. 

The objective of `.yml` files is to make it very simple to convert pre-existing binaries into the AppImage format. If you can build your software from source, you may generate AppImages directly as part of your build workflow; in this case you may not need a `.yml` file (but a Travis CI `.travis.yml` and/or a `Makefile`, etc.

## General anatomy of `.yml` files

The general format of `.yml` files is as follows:

```
app: (name of the application)
(optional flags)

ingredients:
  (instructions that describe from where to get
  the binary ingedients used for the AppImage)

script:
  (instuctions on how to convert these ingredients to an AppImage)
```

As you can see, the `.yml` file consists of three sections:

1. The __overall section__ (containing the name of the application and optional flags)
2. The __ingredients section__ (describing from where to get the binary ingedients used for the AppImage)
3. The __script section__ (describing how to convert these ingredients to an AppImage)

Note that the sections may contain sub-sections. For example, the ingredients section can also have a script section containing instuctions on how to  determine the most recent version of the ingredients and how to download them.

### Overall section

#### `app` key

Mandatory. Contains the name of the application. If the `.yml` file uses ingredients from packages (e.g., `.deb`), then the name must match the package name of the main executable

#### Keys that enable relocateability

Optional. Either `binpatch: true` or `union: true`. These keys enable workarounds that make it possible to run applications from different, changing places in the filesystem (i.e., make them relocateable) that are not made for this. For example, some applications contain hardcoded paths to a compile-time `$PREFIX` such as `/usr`. This is generally discouraged, and application authors are asked to use paths relative to the main executable instead. Libraries like binreloc exist to make this easier. Since many applications are not relocateable yet, there are workarounds which can be used by one of these keys:

* `binpatch: true`  indicates that binaries in the AppImage should be patched to replace the string `/usr` by the string `././`,  an `AppRun` file should be put inside the AppImage that does a `chdir()` to the `usr/` directory of inside AppDir before executing the payload application. The net effect is this that applications can find their resources in the  `usr/` directory inside the AppImage as long as they do not internally use `chdir()` operations themselves
* `union: true` indicates that an `AppRun` file should be put inside the AppImage that tries to create the impression of a union filesystem, effectively creating the impression to the payload application that the contents of the AppImage are overlayed over `/`. This can be achieved, e.g., using `LD_PRELOAD` and a library that redirects filesystem calls. This works as long as the payload application is a dynamically linked binary 

### Ingredients section

Describes how to acquire the binary ingredients that go into the AppImage. Binary ingredients can be archives like `.zip` files, packages like `.deb` files, debian repositories, and Ubuntu PPAs.

__NOTE:__ In the future, source ingredients could also be included in the  `.yml` file definition. Source ingredients could include tarballs and Git repositories. Probably it would be advantageous to share the definition with other formats like snapcraft `.yaml` files. Proposals for this are welcome.

 `.yml` files are supposed not to hardcode version numbers, but determine at runtime the latest version. If the  `.yml` files describes the released version, it should determine the latest released version at runtime. If the  `.yml` files describes the development version, it might reference the latest nightly or continuous build instead.

#### Using ingredients from a binary archive

The following example ingredients section describes how to get the latest version of a binary archive:

```
ingredients:
  script:
    - DLD=$(wget -q "https://api.github.com/repos/atom/atom/releases/latest"  -O - | grep -E "https.*atom-amd64.tar.gz" | cut -d'"' -f4)
    - wget -c $DLD
    - tar zxvf atom*tar.gz
```

The `script` section inside the `ingredients` section determines the download link  of a binary archive, and downloads and extracts the binary archive.

#### Using ingredients from a debian repository

The following example ingredients section describes how to get the latest version of a package from a debian archive:

```
ingredients:
  dist: trusty
  sources:
    - deb http://archive.ubuntu.com/ubuntu/ trusty main universe
    - deb http://download.opensuse.org/repositories/isv:/KDAB/xUbuntu_14.04/ /
```

The `dist` section inside the `ingredients` section sets which debian distribution should be used. The `sources` section inside the `ingredients` section describes the repositories from which the package should be pulled. The entries are in the same format as lines in a debian `sources.list` file. Note that the `http://download.opensuse.org/repositories/isv:/KDAB/xUbuntu_14.04` repository needs the `http://archive.ubuntu.com/ubuntu/` repository so that dependencies can be resolved.

__NOTE:__ In the future, other types of packages like `.rpm` could also be included in the  `.yml` file definition. Proposals for this are welcome if the proposer also implements support for this in the Recipe script.

#### Using ingredients from an Ubuntu PPA

This is a special case of a debian repository and can, for brevity, be specified like this:

```
ingredients:
  dist: trusty
  sources: 
    - deb http://us.archive.ubuntu.com/ubuntu/ trusty main universe
  ppas:
    - geany-dev/ppa
```

The `ppas` section inside the `ingredients` section lets you specify one or more Ubuntu PPAs. This is equivalent to, but more elegant than, adding the corresponding `sources.list` entries to the `sources` section inside the `ingredients` section.

__NOTE:__ In the future, similar shortcuts for other types of personal repositories, such as projects on build.opensuse.org, could also be included in the  `.yml` file definition. Proposals for this are welcome if the proposer also implements support for this in the Recipe script.

#### Excluding certain packages

The dependency information in some packages may result in the package manager to refuse the application to be installed if some dependencies are not present in the system, even though they are not strictly necessary to run the application. In this case, it may be desirable to pretend certain packages to be installed on the target system by using the `exclude` key in the `ingredients` section:

```
ingredients:
  dist: trusty
  packages:
    - multisystem
    - gksu
  sources: 
    - deb http://us.archive.ubuntu.com/ubuntu/ trusty main universe
    - deb http://liveusb.info/multisystem/depot all main
  exclude:
    - qemu
    - qemu-kvm
    - cryptsetup
    - libwebkitgtk-3.0-0
    - dmsetup
```

#### Pretending certain versions of dependencies being installed

The dependency information in some packages may result in the package manager to refuse the application to be installed if some __exact__ versions of dependencies are not present in the system. In this case, it may be necessary pretend the __exact__ version of a dependency to be installed on the target system by using the `pretend` key in the `ingredients` section:

```
ingredients:
  dist: trusty
  sources:
    - deb http://archive.ubuntu.com/ubuntu/ trusty main universe
  ppas:
    - otto-kesselgulasch/gimp-edge
  pretend:
    - libcups2 1.7.2-0ubuntu1
```

The assumption here is that every target system has at least the pretended version available, and that newer versions of the pretended package are able to run the application just as well as the pretended version itself _(if this is not the case, then the pretended package has broken downward compatibility and should be fixed)_. 

#### Arbitrary scripts in the ingredients section

You may add arbitrary shell commands to the `script` section inside the `ingredients` section in order to facilitate the retrieval of the binary ingredients. This is so that even complex situations can be supported as illustrated in the following example:

```
ingredients:
  script:
    - URL=$(wget -q https://www.fosshub.com/JabRef.html -O - | grep jar | cut -d '"' -f 10)
    - wget -c "$URL"
    - wget -c --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u66-b17/jre-8u66-linux-x64.tar.gz
```

This downloads the payload application, JabRef, and the required JRE which requires to set a special cookie header.

### Script section

The `script` section may contain arbitrary shell commands that help in the translation of the binary ingredients to an AppDir suitable for generating an AppImage.

#### The script section needs to copy ingedients into place

If `.deb` packages, debian repositories, or PPAs have been specified in the `ingredients` section, then their dependencies are resolved (taking into account a blacklist of packages that are assumed to be present on all target systems in a recent enough version - such as glibc) and the packages are extracted into an AppDir. The shell commands contained in the `script` section are executed inside the root directory of this AppDir. However, some packages place things in non-standard locations, i.e., the main executable is outside of `usr/bin`. In these cases, the commands contained in the `script` section should normalize the filesystem structure. Sometimes it is also necessary to edit further files to reflect the changed file location. The following example illustrates this:

```
ingredients:
  dist: trusty
  sources: 
    - deb http://archive.ubuntu.com/ubuntu/ trusty main universe
  script:
    - DLD=$(wget -q "https://github.com/feross/webtorrent-desktop/releases/" -O - | grep _amd64.deb | head -n 1 | cut -d '"' -f 2)
    - wget -c "https://github.com/$DLD"

script:
  - mv opt/webtorrent-desktop/* usr/bin/
  - sed -i -e 's|/opt/webtorrent-desktop/||g' webtorrent-desktop.desktop
```

In the `ingredients` section, a `.deb` package is downloaded. Then, in the `script` section, the main executable is moved to its standard location in the AppDir. Finally, the `desktop` file is updated to reflect this.

If other types of binary ingredients have been specified, then the shell commands contained in the `script` section need to retrieve these by copying them into place. Note that since the commands contained in the `script` section are executed inside the root directory of the AppDir, the ingredients downloaded in the `ingredients` sections are one directory level above, i.e., in `../`. The following example illustrates this:

```
ingredients:
  script:
    - wget -c "https://telegram.org/dl/desktop/linux" --trust-server-names
    - tar xf tsetup.*.tar.xz

script:
  - cp ../Telegram/Telegram ./usr/bin/telegram-desktop
```

In the `ingredients` section, an archive is downloaded and unpacked. Then, in the `script` section, the main executable is copied into place inside the AppDir. 

### The script section needs to copy icon and `.desktop` file in place

Since an AppImage may contain more than one executable binary (e.g., helper binaries launched by the main executable) and also may contain multiple `.desktop` files, a clear entry point into the AppImage is required. For this reason, there is the convention that there should be exactly one `$ID.desktop` file and corresponding icon file in the top-level directory of the AppDir.

The script running the `.yml` file tries to do this automatically, which works if the name of the application specified in the `app:` key matches the name of the `$ID.desktop` file and the corresponding icon file. For example, if `app: myapp` is set, and there is `usr/bin/myapp`, `usr/share/applications/myapp.desktop`, and `usr/share/icons/*/myapp.png`, then the `myapp.desktop` and `myapp.png` files are automatically copied into the top-level directory of the AppDir. Unfortunately, not all packages are as strict in their naming. In that case, the shell commands contained in the `script` section must copy exactly one `$ID.desktop` file and the corresponding icon file into the top-level directory of the AppDir. The following example illustrates this:

```
script:
  - tar xf ../fritzing* -C usr/bin/ --strip 1
  - mv usr/bin/fritzing.desktop .
```

Unfortunately, not all applications come with a  `$ID.desktop` file. If it is missing, the shell commands contained in the `script` section need to create it. The following (simplified) example illustrates this:

```
script:
  - # Workaround for:
  - # https://bugzilla.mozilla.org/show_bug.cgi?id=296568
  - cat > firefox.desktop <<EOF
  - [Desktop Entry]
  - Type=Application
  - Name=Firefox
  - Icon=firefox
  - Exec=firefox %u
  - Categories=GNOME;GTK;Network;WebBrowser;
  - MimeType=text/html;text/xml;application/xhtml+xml;
  - StartupNotify=true
  - EOF
```

__Note:__ The optional `desktopintegration` script assumes that the name of the application specified in the `app:` key matches the name of the `$ID.desktop` file and the corresponding main executable. For example, if `app: myapp` is set, it expects `usr/bin/myapp`and `usr/share/applications/myapp.desktop`. For this reason, if you want to use the optional `desktopintegration` script, you may rearrange the AppDir. The following example illustrates this:

```
script:
  - cp ./usr/share/applications/FBReader.desktop fbreader.desktop
  - sed -i -e 's|Exec=FBReader|Exec=fbreader|g' fbreader.desktop
  - sed -i -e 's|Name=.*|Name=FBReader|g' fbreader.desktop
  - sed -i -e 's|Icon=.*|Icon=fbreader|g' fbreader.desktop
  - mv usr/bin/FBReader usr/bin/fbreader
  - cp usr/share/pixmaps/FBReader.png fbreader.png
```
