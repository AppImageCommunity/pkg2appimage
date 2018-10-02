#! /bin/bash

# Sets up PPAs required for AppImage building.
# They contain patched libraries and tools which significantly improve
# AppImages and their building process.

echo "deb http://ppa.launchpad.net/djcj/libcurl-slim/ubuntu xenial main" >> /etc/apt/sources.list

cat > /etc/apt/preferences.d/appimage-pin <<EOF
Package: *
Pin: release o=LP-PPA-djcj-libcurl-slim
Pin-Priority: 9999
EOF

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 24A5F4FED4B4972B
apt-get update
