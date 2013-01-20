# WSPR 4.0 r2874 build kit for Lubuntu 12.10 x86\_64

* WSPR by Joe Taylor, K1JT: <http://physics.princeton.edu/pulsar/K1JT/wspr.html>
* Based on WSPR 4.0 r2963
* SVN source URL: `svn://svn.berlios.de/wsjt/branches/wspr` 
* Windows-specific `.dll` and `.exe` files removed
* Edited and tested by Kenji Rikitake, JJ1BDX

## Required libraries/tools to build

    sudo apt-get install \
        python-dev gfortran python-pmw python-numpy portaudio19-dev \
        libsamplerate0-dev python-imaging-tk libfftw3-dev \
        libhamlib-util2

## Building procedure

    make distclean clean
    ./configure --with-portaudio-include-dir=/usr/include --with-portaudio-lib-dir=/usr/lib/x86_64-linux-gnu
    make

## Required permission for the serial/USB control ports

* Adding the user to the group `dialout` is required to run `rigctl` for the serial ports
* `rigctl` is installed by `libhamlib-util2`

[end of memorandum]
