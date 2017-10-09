#! /bin/bash

# Sets up PPAs required for AppImage building.
# They contain patched libraries and tools which significantly improve
# AppImages and their building process.

echo "deb http://ppa.launchpad.net/djcj/libcurl-slim/ubuntu xenial main" >> /etc/apt/sources.list
echo "deb http://ppa.launchpad.net/djcj/gnutls-patched/ubuntu trusty main" >> /etc/apt/sources.list

cat > /etc/apt/preferences.d/appimage-pin <<EOF
Package: *
Pin: release o=LP-PPA-djcj-libcurl-slim
Pin-Priority: 9999

Package: *
Pin: release o=LP-PPA-djcj-gnutls-patched
Pin-Priority: 9999
EOF

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4BC359BE72
apt-get update
