from setuptools import find_packages
from setuptools import setup

version = '1.3.0.dev0'

setup(
	name='PQDeviceRobot',
	version=version,

	author='Stefan Hahn',
	author_email='stefanhahn@siemens.com',

	url='https://code.siemens.com/pq-testautomation/PQDeviceRobot',

	package_dir={
		'': 'src',
	},
	packages=find_packages('src'),

	install_requires=[
		'attrs>=17.4',
		'deprecated>=1.2',
		'lxml>=4.1',
		'numpy>=1.14',
		'pydal>=17.11',
		'pymysql>=0.9',
		'requests>=2.18',
		'robotframework-seleniumlibrary>=4.1',
		'robotframework>=3.0',
		'scapy>=2.4.4',
		'selenium>=3.9',
		'more-itertools>=8.5.0',
		'ModbusRobot',
		'syslog-rfc5424-parser>=0.3.2',
		'pytz>=2021.3'
	],

	classifiers=[
		'Development Status :: 4 - Beta',
		'Framework :: Robot Framework',
		'Framework :: Robot Framework :: Library',
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
