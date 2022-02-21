from setuptools import find_packages
from setuptools import setup

version = '0.6.1.dev0'

setup(
	name='ModbusRobot',
	version=version,

	author='Stefan Hahn',
	author_email='stefanhahn@siemens.com',

	url='https://code.siemens.com/pq-testautomation/ModbusRobot',

	package_dir={
		'': 'src',
	},
	packages=find_packages('src'),

	install_requires=[
		'pymodbus>=1.3',
		'robotframework>=3.0',
	],

	classifiers=[
		'Development Status :: 4 - Beta',
		'Framework :: Robot Framework',
		'Framework :: Robot Framework :: Library',
		'Framework :: Twisted',
		'Intended Audience :: Developers',
		'Intended Audience :: Information Technology',
		'Intended Audience :: Science/Research',
		'Operating System :: MacOS :: MacOS X'
		'Operating System :: Microsoft :: Windows',
		'Operating System :: POSIX',
		'Operating System :: Unix',
		'Programming Language :: Python',
		'Programming Language :: Python :: 3',
		'Programming Language :: Python :: 3.6',
		'Topic :: Scientific/Engineering',
		'Topic :: Software Development :: Libraries',
		'Topic :: Software Development :: Testing',
	],
)
