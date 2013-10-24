Bullet time scripts
===================

Bullet time scripts designer for [Canon EOS](http://www.usa.canon.com/cusa/consumer/products/cameras/slr_cameras) DSLR cameras.

### Precondition
You have to set OWNERNAME on the camera. 
For example:

	gphoto2 --set-config /main/settings/ownername="owner_name"

### Dependencies 
* [jhead](http://www.sentex.net/~mwandel/jhead) 
* [gphoto2](http://www.gphoto.org)

#### To install gphoto2, libghpoto2 and jhead from source on Ubuntu or Linux Mint or Debian use the provided install script.

Command line arguments:

	-t test mode (remove "0 &&" from libgphoto2 for libsubx testing)
	-d create .deb packages
