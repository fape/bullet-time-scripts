#!/bin/sh
#update
sudo yum update
sudo yum -y upgrade

#create dir
cd ~
mkdir bulletdep
cd bulletdep

#essential packages
sudo yum groupinstall "Development Tools"
sudo yum -y install git libtool-ltdl-devel libusb-devel libusb1-devel libjpeg-turbo-devel libexif-devel popt-static lockdev-devel readline-devel cdk-devel aalib-devel gd-devel

#download sources 
wget "http://sourceforge.net/projects/gphoto/files/libgphoto/2.5.1.1/libgphoto2-2.5.1.1.tar.bz2/download" -O libgphoto2-2.5.1.1.tar.gz
wget "http://sourceforge.net/projects/gphoto/files/gphoto/2.5.1/gphoto2-2.5.1.tar.gz/download" -O gphoto2-2.5.1.tar.gz
wget "http://www.sentex.net/~mwandel/jhead/jhead-2.97.tar.gz"

#extract
echo *.tar.gz | xargs -n 1 tar -xvf

#install libgphoto2
cd libgphoto2-2.5.1.1
./configure --prefix=/usr
make -j5
sudo make install

#install gphoto2
cd ../gphoto2-2.5.1
./configure --with-aalib --prefix=/usr
make
sudo make install

#install jhead
cd ../jhead-2.97
make
sudo make install

#ldconfig
echo "include /usr/local/lib" >> /etc/ld.so.conf
ldconfig

#check
cd ~
gphoto2 --version
jhead -V

echo -e "\n\nBefore you run the bullet-time-script.sh make sure to do a \"su -\" and then run the script or it wont work.\n\n"
