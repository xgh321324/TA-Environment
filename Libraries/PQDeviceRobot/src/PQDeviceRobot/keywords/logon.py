import socket

from robot.api import logger
from robot.utils import robottypes
from selenium.common.exceptions import WebDriverException
from selenium.webdriver.common.keys import Keys

from ._context import _Context
from .common import _CommonKeywords
from .device import _DeviceKeywords
from .pages import _PagesKeywords
from .seleniumext import _SeleniumExtKeywords


class _LogonKeywords(_Context):
	def __init__(self, *args):
		super().__init__(*args)

		self._common = _CommonKeywords(*args)
		self._device = _DeviceKeywords(*args)
		self._pages = _PagesKeywords(*args)
		self._seleniumext = _SeleniumExtKeywords(*args)

	#region Login / Logout
	def login(self,loginTimeout='30s'):
		pass

	def logout(self, allowDisabledLogin=False):
		pass

	def user_is_logged_in(self):
		pass

	def validate_user_is_logged_in(self):
		pass

	def validate_user_is_not_logged_in(self):
		logger.info('Validating user is not logged in')
		pass

	#endregion
