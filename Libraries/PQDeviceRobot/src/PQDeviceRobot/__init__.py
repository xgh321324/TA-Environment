import logging
import os
import pathlib
import sys

from ModbusRobot import ModbusRobot
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.BuiltIn import RobotNotRunningError
from SeleniumLibrary import SeleniumLibrary

from .keywords.common import _CommonKeywords
from .keywords.device import _DeviceKeywords
from .keywords.logon import _LogonKeywords
from .keywords.pages import _PagesKeywords
from .version import VERSION

__version__ = VERSION

class PQDeviceRobot(
		_CommonKeywords,
		_DeviceKeywords,
		_LogonKeywords,
		_PagesKeywords,
):
	ROBOT_LIBRARY_SCOPE = 'GLOBAL'
	ROBOT_LIBRARY_VERSION = __version__

	def __init__(self, selenium=None, mbus=None):
		if 'https_proxy' in os.environ:
			del os.environ['https_proxy']

		if 'http_proxy' in os.environ:
			del os.environ['http_proxy']

		tlslog = pathlib.Path() / 'PQDeviceRobotOutput' / 'tlskey.log'

		try:
			self._sel = BuiltIn().get_library_instance('SeleniumLibrary') if selenium is None else selenium # type: SeleniumLibrary
			self._mbus = BuiltIn().get_library_instance('ModbusRobot') if mbus is None else mbus # type: ModbusRobot

			tlslog = BuiltIn().get_variable_value('${TLSLOG}')

			if not tlslog:
				tlslog = pathlib.Path(BuiltIn().get_variable_value('${OUTPUT DIR}')) / 'tlskey.log'
			else:
				tlslog = pathlib.Path(tlslog)
		except RobotNotRunningError:
			self._sel = SeleniumLibrary(run_on_failure='Nothing') if selenium is None else selenium # type: SeleniumLibrary
			self._mbus = ModbusRobot() if mbus is None else mbus # type: ModbusRobot

			logger = logging.getLogger('RobotFramework') # type: logging.Logger

			if not logger.hasHandlers():
				handler = logging.StreamHandler(sys.stdout)
				formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')

				handler.setFormatter(formatter)
				handler.setLevel(logging.INFO)
				logger.setLevel(logging.INFO)
				logger.addHandler(handler)

		os.environ['SSLKEYLOGFILE'] = str(tlslog.resolve())

		for base in PQDeviceRobot.__bases__:
			base.__init__(self, self._sel, self._mbus)

	def active_device(self):
		return _DeviceKeywords.active_device()

	@property
	def sel(self):
		# type: () -> SeleniumLibrary
		return self._sel

	@property
	def mbus(self):
		# type: () -> ModbusRobot
		return self._mbus
