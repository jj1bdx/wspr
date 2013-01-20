#!/usr/bin/env python

version = "WSPR Version " + "3.00" + ", by K1JT"

from distutils.core import setup
from distutils.file_util import copy_file
import os

def wspr_install(install):
#
# In a true python environment, w.so would be compiled from python
# I'm doing a nasty hack here to support our hybrid build system -db
#
	if install == 1:
	    os.makedirs('build/lib/WsprMod')
	    copy_file('WsprMod/w.so', 'build/lib/WsprMod')
	setup(name='Wspr',
	version=version,
	description='Wspr Python Module for Weak Signal detection',
	long_description='''
WSPR is a computer program designed to facilitate Amateur Radio
communication under extreme weak-signal conditions. 
''',
	author='Joe Taylor',
	author_email='joe@Princeton.EDU',
	license='GPL',
	url='http://physics.princeton.edu/pulsar/K1JT',
	scripts=['wspr.py'],
	      packages=['WsprMod'],
	)

if __name__ == '__main__':
	import sys
	if 'install' in sys.argv:
		wspr_install(1)
	else:
		wspr_install(0)

