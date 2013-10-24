#!/bin/sh
TEST_MODE=0
CREATE_DEB=0
#getopts
while getopts ":td" opt; do
  case $opt in
    t)
	echo "test mode\n replacing \"(0 &&\" in libgphoto2/camlibs/ptp2/library.c" >&2
	tput sgr0
      	TEST_MODE=1
      	sleep 3
      	;;
    d)
        echo "creating .deb mode\n YOU WILL HAVE TO ANSWER SOME QUESTIONS REGARDING THE PACKAGE!!!" >&2
	tput sgr0
	CREATE_DEB=1
      	sleep 3
      	;;
    \?)
      	echo "Invalid option: -$OPTARG" >&2
      	;;
  esac
done

#create dir
mkdir deps
cd deps

CPU=`grep -c processor /proc/cpuinfo`

#remove old packages
sudo apt-get remove gphoto2 libgphoto2-2 libgphoto2-l10n libgphoto2-port0 jhead

#install needed packages
sudo apt-get install build-essential gettext automake autopoint libtool libusb-1.0-0-dev libusb-dev libjpeg-dev libexif-dev libpopt-dev liblockdev1-dev libreadline-dev libcdk5-dev libaa1-dev libgd2-xpm-dev git libltdl-dev

#download sources
git clone https://github.com/gphoto/libgphoto2.git
cd libgphoto2
cd ..

git clone https://github.com/gphoto/gphoto2.git
cd gphoto2
cd ..
wget "http://www.sentex.net/~mwandel/jhead/jhead-2.97.tar.gz"

#extract
echo *.tar.gz | xargs -n 1 tar -xvf
rm *.tar.gz

#install libgphoto2
cd libgphoto2
if [ $TEST_MODE -eq 1 ]
   then
        cp camlibs/ptp2/library.c camlibs/ptp2/library.c.org
        sed -i '/if (0 && (camera->port!=NULL) && (camera->port->type == GP_PORT_USB)) {/c\if ((camera->port!=NULL) && (camera->port->type == GP_PORT_USB)) {' camlibs/ptp2/library.c

fi
autoreconf -is
./configure --prefix=/usr
make -j $CPU
if [ $CREATE_DEB -eq 1 ]
  then
	sudo checkinstall -D --install=no
else
	sudo make install
fi

#install gphoto2
cd ../gphoto2
autoreconf -is
./configure --with-aalib
make
if [ $CREATE_DEB -eq 1 ]
  then
        sudo checkinstall -D --install=no
else
        sudo make install
fi


#install jhead
cd ../jhead-2.97
make
if [ $CREATE_DEB -eq 1 ]
  then
        sudo checkinstall -D --install=no
else
        sudo make install
fi

#check
if [ $CREATE_DEB -eq 1 ]
  then
	cd ..
	mkdir deb
        mv gphoto2/*.deb deb/
        mv libgphoto2/*.deb deb/
	mv jhead*/*.deb deb/
	echo "Now you can install the *.deb packages with dpkg -i *.deb\n"
else
	cd ~
	gphoto2 --version
	jhead -V
fi
