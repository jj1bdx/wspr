# WSPR 4.0 r3015 build kit for Lubuntu 12.10 x86\_64

*Note: This software is no longer maintained.*

* WSPR by Joe Taylor, K1JT: <http://physics.princeton.edu/pulsar/K1JT/wspr.html>
* Based on WSPR 4.0 r3015
* SVN source URL: `svn://svn.berlios.de/wsjt/branches/wspr` 
* Edited and tested by Kenji Rikitake, JJ1BDX

## Notes

* See `FIX-Ubuntu-13.04/` for the Python PIL bug on Ubuntu 13.04
* Windows-specific `.dll` and `.exe` files removed

## Required libraries/tools to build

    sudo apt-get install \
        python-dev gfortran python-pmw python-numpy portaudio19-dev \
        libsamplerate0-dev python-imaging-tk libfftw3-dev \
        libhamlib-utils

## Building procedure

(change `/usr/lib/x86_64-linux-gnu` to `/usr/lib/i386-linux_gnu` for building on a 32bit environment)

    make clean distclean
    ./configure --with-portaudio-include-dir=/usr/include --with-portaudio-lib-dir=/usr/lib/x86_64-linux-gnu
    make

## Required permission for the serial/USB control ports

* Adding the user to the group `dialout` is required to run `rigctl` for the serial ports
* `rigctl` is installed by `libhamlib-utils`

[end of memorandum]
