Bullet time scripts
===================

Bullet time scripts designer for [Canon EOS](http://www.usa.canon.com/cusa/consumer/products/cameras/slr_cameras) cameras.

## Depencies (recommended to compile from source)
* [jhead](http://www.sentex.net/~mwandel/jhead) 
* [gphoto2](http://www.gphoto.org)

## Precondition
You have to set OWNERNAME on the camera. For example: `gphoto2 --set-config /main/settings/ownername="owner_name"`.


## Compile depencies on Ubuntu or Linux Mint

### Create directry
`cd ~`
`mkdir bulletdep`
`cd bulletdep`

### Remove old packages
`sudo apt-get remove gphoto2 libgphoto2-2 libgphoto2-l10n libgphoto2-port0 jhead` 

### Install depencies for compile
`sudo apt-get install build-essential libtool libusb-1.0-0-dev libusb-dev libjpeg-dev libexif-dev libpopt-dev liblockdev1-dev libreadline-dev libcdk5-dev libaa1-dev libgd2-xpm-dev`

### Downdload sources
`wget "http://sourceforge.net/projects/gphoto/files/libgphoto/2.5.0/libgphoto2-2.5.0.tar.gz/download" -O libgphoto2-2.5.0.tar.gz`
`wget "http://sourceforge.net/projects/gphoto/files/gphoto/2.5.0/gphoto2-2.5.0.tar.gz/download" -O gphoto2-2.5.0.tar.gz`

### Untar
`tar -zxvf libgphoto2-2.5.0.tar.gz` 
`tar -zxvf gphoto2-2.5.0.tar.gz`

### Compile and install libghoto2
`cd libgphoto2-2.5.0`
`./configure --prefix=/usr`
`make -j5`
`sudo make install`

### Compile and install gphoto2
`cd ../gphoto2-2.5.0`
`./configure --with-aalib`
`make`
`sudo make install`

### Check gphoto2
`gphoto2 --version`

