#!/bin/bash 

# Build Subsurface AppImage locally without travis-ci 
# inside a minimal Ubuntu 12.04.4 using schroot; 
# tested on a Ubuntu 15.10 host system

# Halt on errors
set -e

# Be verbose
set -x

# Check whether we are running on an Ubuntu-like live system
if [ ! -e "/isodevice}" ] ; then
  echo "Not running on an Ubuntu-like live system."
  echo "Please adjust the paths in this script to your environment."
  echo "You can also remove the part about using disk images if you do not need it."
fi

# Determine which architecture should be built
if [[ "$1" = "i386" ||  "$1" = "amd64" ]] ; then
	ARCH=$1
else
	echo "Call me with either i386 or amd64"
	exit 1
fi

# Download old enough system to build in
# TODO: Consider moving to https://ftp.uni-erlangen.de/openvz/template/precreated/contrib/ubuntu-10.04-minimal_10.04_i386.tar.gz
# In that case, ise libfuse2 instead of fuse and do not install python-requests as it is not available there.
# Further changes would be required as "add-apt-repository: error: no such option: -y".
# So maybe it is not really worth it.

if [[ "$ARCH" = "amd64" ]] ; then
	DISKIMAGE=/isodevice/image64.ext3 # NOTE: Use your own location for the ext3 image
	UBU="http://cdimage.ubuntu.com/ubuntu-core/releases/12.04.5/release/ubuntu-core-12.04.4-core-amd64.tar.gz"
fi
if [[ "$ARCH" = "i386" ]] ; then
	DISKIMAGE=/isodevice/image32.ext3 # NOTE: Use your own location for the ext3 image
	UBU="http://cdimage.ubuntu.com/ubuntu-core/releases/12.04.5/release/ubuntu-core-12.04.4-core-i386.tar.gz"
fi

# Create a disk image for the proot (I want everything contained in one file for portability)
if [ ! -e "${DISKIMAGE}" ] ; then
  echo "Creating new disk image ${DISKIMAGE}..."
  sudo dd if=/dev/zero of="${DISKIMAGE}" bs=10M count=280 
  sudo mkfs.ext3 "${DISKIMAGE}"
else
  echo "Using existing disk image ${DISKIMAGE}"
fi

# Mount and populate the disk image with a minimal Ubuntu 12.04.4 system
sudo mount "${DISKIMAGE}" /mnt/ -o loop
sudo chmod -R a+rwx /mnt
cd /mnt
wget -c "${UBU}"
tar xfv *tar.gz || true
cd -

# schroot into the minimal Ubuntu 12.04.4 system
sudo apt-get --yes --force-yes install debootstrap schroot
sudo bash -c "cat >/etc/schroot/schroot.conf" <<'EOF'
[AppImageBuilder32]
type=directory
directory=/mnt
users=$USER
personality=linux32
[AppImageBuilder64]
type=directory
directory=/mnt
users=$USER
personality=linux
EOF

cat > /mnt/inside.sh <<EOF
#!/bin/bash

# Halt on errors
set -e

# Be verbose
set -x

cd /root

# Install dependencies
apt-get update
apt-get --yes --force-yes install git wget sudo

# Get latest AppImages project from git
if [ ! -d AppImages ] ; then
  git clone https://github.com/probonopd/AppImages.git
fi
cd AppImages/
git pull --rebase
cd ..

if [[ "$ARCH" = "amd64" ]] ; then
	linux64 bash -ex AppImages/recipes/subsurface.sh amd64
fi
if [[ "$ARCH" = "i386" ]] ; then
	linux32 bash -ex AppImages/recipes/subsurface.sh i386
fi
EOF
chmod a+x /mnt/inside.sh

if [[ "$ARCH" = "amd64" ]] ; then
	sudo schroot -c AppImageBuilder64 /inside.sh
fi
if [[ "$ARCH" = "i386" ]] ; then
	sudo schroot -c AppImageBuilder32 /inside.sh
fi
