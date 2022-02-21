#!/usr/bin/env python3

import argparse
import collections
import ctypes
import ctypes.wintypes
import itertools
import json
import os
import pathlib
import platform
import re
import subprocess
import sys
import traceback
import urllib.parse

__version__ = '1.3.0.dev0'

class winproxy(object):
	class WINHTTP_CURRENT_USER_IE_PROXY_CONFIG(ctypes.Structure):
		_fields_ = [
			('fAutoDetect', ctypes.wintypes.BOOL),
			('lpszAutoConfigUrl', ctypes.wintypes.LPWSTR),
			('lpszProxy', ctypes.wintypes.LPWSTR),
			('lpszProxyBypass', ctypes.wintypes.LPWSTR),
		]

	class WINHTTP_AUTOPROXY_OPTIONS(ctypes.Structure):
		_fields_ = [
			('dwFlags', ctypes.wintypes.DWORD),
			('dwAutoDetectFlags', ctypes.wintypes.DWORD),
			('lpszAutoConfigUrl', ctypes.wintypes.LPCWSTR),
			('lpvReserved', ctypes.wintypes.LPVOID),
			('dwReserved', ctypes.wintypes.DWORD),
			('fAutoLogonIfChallenged', ctypes.wintypes.BOOL),
		]

	class WINHTTP_PROXY_INFO(ctypes.Structure):
		_fields_ = [
			('dwAccessType', ctypes.wintypes.DWORD),
			('lpszProxy', ctypes.wintypes.LPWSTR),
			('lpszProxyBypass', ctypes.wintypes.LPWSTR),
		]

	WINHTTP_CURRENT_USER_IE_PROXY_CONFIG_P = ctypes.POINTER(WINHTTP_CURRENT_USER_IE_PROXY_CONFIG)
	WINHTTP_AUTOPROXY_OPTIONS_P = ctypes.POINTER(WINHTTP_AUTOPROXY_OPTIONS)
	WINHTTP_PROXY_INFO_P = ctypes.POINTER(WINHTTP_PROXY_INFO)

	WINHTTP_AUTOPROXY_AUTO_DETECT = 1
	WINHTTP_AUTOPROXY_CONFIG_URL = 2

	WINHTTP_AUTO_DETECT_TYPE_DHCP = 1
	WINHTTP_AUTO_DETECT_TYPE_DNS_A = 2

	WINHTTP_ACCESS_TYPE_DEFAULT_PROXY = 0
	WINHTTP_ACCESS_TYPE_NO_PROXY = 1
	WINHTTP_ACCESS_TYPE_NAMED_PROXY = 3
	WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY = 4

	@classmethod
	def resolve(cls, uri):
		# pylint: disable=attribute-defined-outside-init
		useragent = 'Python {:s} / winproxy'.format(platform.python_version())
		proxyURI = ''
		autoProxy = False

		ctypes.windll.winhttp.WinHttpOpen.restype = ctypes.wintypes.LPVOID
		ctypes.windll.winhttp.WinHttpOpen.argtypes = [ctypes.wintypes.LPCWSTR, ctypes.wintypes.DWORD, ctypes.wintypes.LPCWSTR, ctypes.wintypes.LPCWSTR, ctypes.wintypes.DWORD]
		ctypes.windll.winhttp.WinHttpGetIEProxyConfigForCurrentUser.restype = ctypes.wintypes.BOOL
		ctypes.windll.winhttp.WinHttpGetIEProxyConfigForCurrentUser.argtypes = [cls.WINHTTP_CURRENT_USER_IE_PROXY_CONFIG_P]
		ctypes.windll.winhttp.WinHttpGetProxyForUrl.restype = ctypes.wintypes.BOOL
		ctypes.windll.winhttp.WinHttpGetProxyForUrl.argtypes = [ctypes.wintypes.LPVOID, ctypes.wintypes.LPCWSTR, cls.WINHTTP_AUTOPROXY_OPTIONS_P, cls.WINHTTP_PROXY_INFO_P]
		ctypes.windll.winhttp.WinHttpCloseHandle.restype = ctypes.wintypes.BOOL
		ctypes.windll.winhttp.WinHttpCloseHandle.argtypes = [ctypes.wintypes.LPVOID]

		hi = ctypes.windll.winhttp.WinHttpOpen(useragent, cls.WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, None, None, 0)
		ieProxyConfig = cls.WINHTTP_CURRENT_USER_IE_PROXY_CONFIG()
		autoProxyOptions = cls.WINHTTP_AUTOPROXY_OPTIONS()
		autoProxyInfo = cls.WINHTTP_PROXY_INFO()

		if ctypes.windll.winhttp.WinHttpGetIEProxyConfigForCurrentUser(ieProxyConfig):
			if ieProxyConfig.fAutoDetect:
				autoProxy = True

			if ieProxyConfig.lpszAutoConfigUrl is not None:
				autoProxy = True
				autoProxyOptions.lpszAutoConfigUrl = ieProxyConfig.lpszAutoConfigUrl
		else:
			autoProxy = True

		if autoProxy:
			if autoProxyOptions.lpszAutoConfigUrl is not None:
				autoProxyOptions.dwFlags = cls.WINHTTP_AUTOPROXY_CONFIG_URL
			else:
				autoProxyOptions.dwFlags = cls.WINHTTP_AUTOPROXY_AUTO_DETECT
				autoProxyOptions.dwAutoDetectFlags = cls.WINHTTP_AUTO_DETECT_TYPE_DHCP | cls.WINHTTP_AUTO_DETECT_TYPE_DNS_A

			autoProxyOptions.fAutoLogonIfChallenged = True

			autoProxy = ctypes.windll.winhttp.WinHttpGetProxyForUrl(hi, uri, autoProxyOptions, autoProxyInfo)

		if autoProxy:
			proxyURI = autoProxyInfo.lpszProxy
		elif ieProxyConfig.lpszProxy is not None:
			proxyURI = ieProxyConfig.lpszProxy

		ctypes.windll.winhttp.WinHttpCloseHandle(hi)

		return proxyURI.split(';') if proxyURI else []

class PQTAESetup(object):
	ENVIRONMENT_FOLDER = pathlib.Path('../Environment')

	@classmethod
	def main(cls):
		sys.excepthook = cls._handle_exception

		args = cls.parse_args()
		offline = cls.check_offline()

		cls.check_https_proxy(args.index_url)

		if args.prep_dev:
			cls.download_dev_modules(args.index_url)

			print('\nSuccessfully downloaded development dependencies')
		elif args.gen_variables:
			cls.write_suite_variables(cls.ENVIRONMENT_FOLDER)
		else:
			cls.install_dev_modules(args.index_url, offline)
			cls.check_dev_modules()
			cls.write_ride_config(cls.ENVIRONMENT_FOLDER)
			cls.write_suite_variables(cls.ENVIRONMENT_FOLDER)

			print('\nSuccessfully set up test development environment')

		input('Press enter to exit...')

	@staticmethod
	def parse_args():
		parser = argparse.ArgumentParser()
		parser.add_argument('--prep-dev', help='Download all dependencies for offline developer installation', action='store_true')
		parser.add_argument('--gen-variables', help='Generate Variables.robot file', action='store_true')
		parser.add_argument('--index-url', help='Base URL of Python Package Index', default='https://devops.bt.siemens.com/artifactory/api/pypi/pypi-all/simple')

		return parser.parse_args()

	@staticmethod
	def check_https_proxy(indexURL):
		indexURL = urllib.parse.urlparse(indexURL)
		indexURL = urllib.parse.urlunparse((indexURL.scheme, indexURL.netloc, '', '', '', ''))

		print('Trying to get proxy config')

		proxyURI = winproxy.resolve(indexURL)

		if proxyURI and proxyURI[0]:
			os.environ['https_proxy'] = proxyURI[0]

			print('HTTPS proxy set to {:s}'.format(proxyURI[0]))
		else:
			os.environ['https_proxy'] = ''

			print('No proxy found')

	@staticmethod
	def check_offline():
		return os.path.isfile('./offline')

	@classmethod
	def download_dev_modules(cls, indexURL):
		print('\nDownloading dependencies for offline developer installation')

		requirementsDev = pathlib.Path('./DependencyLists/requirements.dev.txt').resolve()
		libsFolder = pathlib.Path('./3rdParty-PythonLibs/').resolve()

		cwd = os.getcwd()
		os.chdir('../')

		try:
			subprocess.check_call([
				sys.executable,
				'-m',
				'pip',
				'download',
				'-d',
				str(libsFolder),
				'--find-links',
				str(libsFolder),
				'--index-url',
				indexURL,
				'--exists-action',
				'i',
				'-r',
				str(requirementsDev),
			])
		except subprocess.CalledProcessError as err:
			raise EnvironmentError('Unable to download all necessary dependency packages') from err

		os.chdir(cwd)

	@classmethod
	def install_dev_modules(cls, indexURL, offline=False):
		cls._install_modules('development', ['../3rdParty-PythonLibs'], './DependencyLists/requirements.dev.txt', '../', indexURL, offline)

	@staticmethod
	def _install_modules(packageType, libraries, requirements, directory, indexURL, noIndex=False):
		print('\nInstalling {:s} packages'.format(packageType))

		libraries = [str(pathlib.Path(lib).resolve()) for lib in libraries]
		requirements = pathlib.Path(requirements).resolve()

		cwd = os.getcwd()
		os.chdir(directory)

		params = [sys.executable, '-m', 'pip', 'install', '-U', '--index-url', indexURL, '-r', str(requirements)]
		params.extend(itertools.chain.from_iterable(zip(itertools.repeat('--find-links'), libraries)))

		if noIndex:
			params.append('--no-index')

		try:
			subprocess.check_call(params)
		except subprocess.CalledProcessError as err:
			raise EnvironmentError('Unable to install all {:s} packages'.format(packageType)) from err

		os.chdir(cwd)

	@classmethod
	def check_dev_modules(cls):
		cls._check_modules('development', './DependencyLists/modules.dev.txt')

	@staticmethod
	def _check_modules(moduleType, requirements):
		print('\nChecking for successful {:s} module installation'.format(moduleType))

		errorOccured = False

		with open(requirements, 'r') as modulesList:
			for moduleIdentifier in modulesList:
				moduleIdentifier = moduleIdentifier.strip()

				try:
					subprocess.check_call([sys.executable, '-c', 'import {:s}'.format(moduleIdentifier.strip())])
					print('Module {:s} successfully installed'.format(moduleIdentifier))
				except subprocess.CalledProcessError:
					print('Module {:s} not installed'.format(moduleIdentifier))
					errorOccured = True

		if errorOccured:
			raise EnvironmentError('Some modules were not installed correctly')

	@staticmethod
	def write_ride_config(testEnv):
		print('\nWriting RIDE config')

		testEnv = pathlib.Path(testEnv).resolve()

		# TODO: replace with cfg parsing and only discarding necessary settings

		from robotide.context import SETTINGS_DIRECTORY
		from robotide.preferences.configobj import ConfigObj

		confPath = pathlib.Path(SETTINGS_DIRECTORY) / 'settings.cfg'

		try:
			confPath.unlink()
		except (OSError, IOError):
			pass

		conf = ConfigObj('./Files/ride-settings.cfg', unrepr=True)
		conf['Plugins']['Test Runner']['custom_script_runner_script'] = str((testEnv / 'TestExec' / 'RunTests.bat').resolve())
		conf['Plugins']['Recent Files']['recent_files'] = [str((testEnv / 'TestSuite').resolve())]

		with open(confPath, 'wb') as confFile:
			conf.write(confFile)

	@staticmethod
	def write_suite_variables(testEnv):
		print('\nGenerating test suite variables file')

		newVariables = None
		existingVariables = collections.OrderedDict()

		testEnv = pathlib.Path(testEnv).resolve()
		varsFileName = (testEnv / 'TestSuite' / 'Variables.robot').resolve()

		with open('./Files/suite-variables.json', 'rb') as varsFile:
			newVariables = json.load(varsFile, object_pairs_hook=collections.OrderedDict)

		if (testEnv / 'TestSuite' / 'Variables.robot').is_file():
			with open(varsFileName, 'r') as varsFile:
				for line in varsFile:
					match = re.match(r'^\${(?P<name>.*?)}\s+(?P<value>.*?)(?:\s*|\s+#\s*(?P<comment>.*?))$', line)

					if match:
						existingVariables[match.group('name')] = {
							'value': match.group('value')
						}

						try:
							existingVariables[match.group('name')]['comment'] = match.group('comment')
						except IndexError:
							pass

		for varName in newVariables:
			if varName not in existingVariables or newVariables[varName]['overwrite']:
				existingVariables[varName] = {
					'value': newVariables[varName]['value']
				}

				if 'comment' in newVariables[varName]:
					existingVariables[varName]['comment'] = newVariables[varName]['comment']

		with open(varsFileName, 'w') as varFile:
			varFile.write('*** Variables ***\n')

			for varName in existingVariables:
				line = '${{{:s}}}\t{:s}'.format(varName, str(existingVariables[varName]['value']))

				if 'comment' in existingVariables[varName] and existingVariables[varName]['comment']:
					line = '{:s}\t# {:s}'.format(line, existingVariables[varName]['comment'])

				print(line, file=varFile)

	@staticmethod
	def _handle_exception(_type, _value, _traceback):
		print(' '.join(traceback.format_exception(_type, _value, _traceback)), file=sys.stderr)
		input('Press enter to exit...')
		sys.exit(1)

if __name__ == '__main__':
	PQTAESetup.main()
