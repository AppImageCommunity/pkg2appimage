# Generating AppImages as part of your Travis CI continuous builds

See these [real-world examples](https://github.com/search?l=yaml&q=appimage.sh+travis&ref=searchresults&type=Code&utf8=%E2%9C%93) for how you can integrate AppImage generation into your Travis CI builds.

One way to do it is to write/adopt an `appimage.sh` script, which you run in the `script:` or `after_success:` section of your `.travis.yml`.

TODO: Write a generic `appiamge.sh` that would make it trivially easy for any project to integrate.
