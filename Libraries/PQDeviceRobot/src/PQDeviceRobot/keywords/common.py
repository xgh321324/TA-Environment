import filecmp
import json
import os
import pathlib
import pytz
import re
import shutil
import time
import urllib.parse
import warnings
import zipfile
from datetime import datetime, timedelta

import requests
from robot.api import logger
from enum import Enum
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.BuiltIn import RobotNotRunningError
from robot.utils import secs_to_timestr
from robot.utils import timestr_to_secs

from ..enums.device import SupportedDevice
from ..utils import Utils
from ._context import _Context
from .device import _DeviceKeywords
from .seleniumext import _SeleniumExtKeywords


class _CommonKeywords(_Context):
	def __init__(self, *args):
		super().__init__(*args)

		self._device = _DeviceKeywords(*args)
		self._seleniumext = _SeleniumExtKeywords(*args)

	def enter_password(self, password, hashFuncName='hex_md5', locator='name:Password'):
		if _DeviceKeywords.active_device().rbac:
			logger.info('Skip password entering to the device being RBAC enabled')
			return

		with self._seleniumext.disable_logging():
			self._sel.wait_for_condition('return !!{:s};'.format(hashFuncName), '30s')

			if hashFuncName != 'hex_md5':
				self._sel.wait_for_condition('return !!hex_md5;', '30s')

		self._sel.input_text(locator, password)

	def send_authenticated_request(self, url, method='GET', params=None):
		if params is None:
			params = {}

		try:
			cookies = self._seleniumext.get_parsed_cookies()

			if not cookies:
				raise AssertionError('No session cookie found')
		except:
			cookies = None

		logger.info('Sending authenticated {:s} request to {:s}'.format(method, url))

		with warnings.catch_warnings():
			warnings.simplefilter('ignore')
			resp = requests.request(method.upper(), url, params=params, cookies=cookies, stream=True, verify=False)

		if resp.status_code != 200:
			raise AssertionError('Error downloading file {:s}'.format(url))

		return resp

	def download_file(self, path, url, method='GET', params=None):
		if params is None:
			params = {}

		resp = self.send_authenticated_request(url, method, params)
		resp.raw.decode_content = True

		if path is None:
			targetFolder = self.get_output_folder()

			filename = pathlib.PurePath(urllib.parse.urlparse(resp.url).path).name

			if 'content-disposition' in resp.headers:
				contDisp = resp.headers['content-disposition'].strip().split(';', 1)

				if contDisp[0].lower() != 'attachment':
					raise IOError('Content-Disposition header is not of type attachment.')

				if contDisp[1] != '':
					filename = re.search('filename="(?P<filename>.*?)"', contDisp[1], re.I).group('filename')

			if filename == '':
				raise IOError('No path given, url path is empty and no Content-Disposition header found.')

			path = targetFolder / filename
		else:
			path = pathlib.Path(path)

		path = path.resolve()

		if path.exists():
			raise IOError('File {:s} already exists in test case file folder'.format(path.name))

		with open(path, 'wb') as downloadFile:
			shutil.copyfileobj(resp.raw, downloadFile)

		return (resp, path)

	def remove_empty_folders(self, folder):
		folder = pathlib.Path(folder)

		if not folder.exists():
			return

		if not folder.is_dir():
			raise IOError('{!s} is not a directory'.format(folder))

		for child in folder.iterdir():
			if child.is_dir():
				self.remove_empty_folders(child)

		if not [*folder.iterdir()]:
			folder.rmdir()

	def get_output_folder(self):
		outputFolder = pathlib.Path('.') / 'PQDeviceRobotOutput'

		try:
			outputFolder = pathlib.Path(BuiltIn().get_variable_value('${OUTPUT DIR}')) / (BuiltIn().get_variable_value('${TEST NAME}') or '.')
		except RobotNotRunningError:
			pass

		outputFolder = outputFolder.resolve()

		if not outputFolder.exists():
			try:
				outputFolder.mkdir(parents=True)
			except OSError:
				raise IOError('Unable to create output folder {!s}'.format(outputFolder))

		return outputFolder

	def await_reboot(self, rebootTimeout, afterAction, *args, **kwargs):
		logger.info('Waiting for reboot')
		self._seleniumext.fragment_sleep(5)

		rebootTimeout = timestr_to_secs(rebootTimeout)

		error = None
		timeoutAbs = time.time() + rebootTimeout

		if not callable(afterAction):
			builtin = BuiltIn()
			afterActionKeyword = afterAction

			def afterActionCallable(*args, **kwargs):
				builtin.run_keyword(afterActionKeyword, *args, **kwargs)

			afterAction = afterActionCallable
			afterAction.__name__ = afterActionKeyword

		while time.time() < timeoutAbs:
			# pylint: disable=broad-except
			try:
				return afterAction(*args, **kwargs)
			except Exception as err:
				error = err
				self._seleniumext.fragment_sleep(10)

		raise AssertionError('Reboot with method {:s} not successful after {:s}. Last error was: {}'.format(afterAction.__name__, secs_to_timestr(rebootTimeout), error))

	def pause(self, timestr, reason=None):
		seconds = timestr_to_secs(timestr)

		if seconds < 0:
			seconds = 0

		message = 'Pausing for {:s}'.format(secs_to_timestr(seconds))

		if reason:
			message = '{:s}: {:s}'.format(message, reason)

		logger.info(message)

		self._seleniumext.fragment_sleep(seconds)

	def generate_distinct_filename(self, fileName, ipAddress, deviceType=None):
		deviceType = Utils.to_enum(deviceType, SupportedDevice) if deviceType is not None else _DeviceKeywords.active_device().deviceType
		currentTime = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
		newFileName = '{}_{}_{}_{}'.format(currentTime, deviceType.name, ipAddress, fileName)

		return newFileName

	def format_file_size(self, filePath):
		fileSize = float(pathlib.Path(filePath).stat().st_size) / 1024

		if fileSize >= 1024:
			fileSize = fileSize / 1024

			if fileSize >= 1024:
				return f'{fileSize / 1024:.2f} GiB'
			else:
				return f'{fileSize:.2f} MiB'
		else:
			return f'{fileSize:.2f} KiB'

	def file_content_compare(self, filePath1, filePath2):
		filePath1 = pathlib.Path(filePath1).resolve()
		filePath2 = pathlib.Path(filePath2).resolve()

		logger.info('Start comparing the contents of {} and {}.'.format(filePath1, filePath2))

		res = filecmp.cmp(filePath1, filePath2, shallow=True)

		return res

	def rename_fileName(self, filePath, newName=None):
		filePath = pathlib.Path(filePath).resolve()
		newName = self.generate_distinct_filename(filePath.name, _DeviceKeywords.active_device().ipAddress) if newName is None else str(newName)

		logger.info('Start renaming file {} to {}'.format(filePath, newName))

		newPath = filePath.parent / newName
		filePath.rename(newPath)

		return newPath

	def unzip_zip_file(self, zipFilePath, destFilePath=None):
		zipFiles = zipfile.ZipFile(zipFilePath)

		if destFilePath is None:
			destFilePath = self.get_output_folder()

		for fileName in zipFiles.namelist():
			zipFiles.extract(fileName, destFilePath)
			logger.info('{} saved in {}'.format(fileName, destFilePath))

	def get_name_list_from_zip_file(self, zipFilePath):
		return zipfile.ZipFile(zipFilePath).namelist()

	def get_latest_file_from_folder(self, filePath):
		files = os.listdir(filePath)

		logger.info('geting the latest file of {}'.format(files))

		files.sort(key=lambda fn:os.path.getmtime(filePath + "\\" +fn))
		latestFile = files[-1]

		logger.info('the latest file is {}'.format(latestFile))

		return latestFile

	def validate_texts_present_on_page(self, page, textList, timeout=None):
		isChanged = False

		logger.info('Check {:s} page'.format(page))
		self._sel.go_to(self._device.get_device_address(page))
		self._seleniumext.wait_until_page_contains_all_element(['id:footer', 'id:workingArea'], timeout)

		for text in list(textList):
			try:
				self._sel.page_should_contain(str(text))
			except AssertionError as err:
				logger.error(str(err))
				isChanged = True

		if isChanged:
			raise AssertionError('Page {:s} does not contain all the expected text, the page has changed'.format(page))