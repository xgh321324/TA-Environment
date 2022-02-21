import datetime
import hashlib
import re
import socket

import attr
from robot.api import logger
from robot.utils import robottypes

from ..enums.device import DeviceCommIndication
from ..enums.device import DeviceIndicationState
from ..enums.device import DeviceStatus
from ..enums.device import INFODataSource
from ..enums.device import SupportedDevice
from ..utils import Utils
from ._context import _Context
from .seleniumext import _SeleniumExtKeywords


def _converter_device_type(deviceType):
	return Utils.to_enum(deviceType, SupportedDevice)

@attr.s
class DeviceConnection(object):
	deviceType = attr.ib(converter=_converter_device_type)
	protocol = attr.ib(type=str)
	ipAddress = attr.ib(type=str)
	newIpAddress = attr.ib(type=str, default='')

	ccsf = attr.ib(type=bool, default=False, converter=robottypes.is_truthy)

	login = attr.ib(type=bool, default=True, converter=robottypes.is_truthy)
	rbac = attr.ib(type=bool, default=False, converter=robottypes.is_truthy)
	rbacUsername = attr.ib(type=str, default='')
	rbacPassword = attr.ib(type=str, default='')

	configChangePassword = attr.ib(type=str, default='00000000')
	forceValuePassword = attr.ib(type=str, default='11111111')
	firmwareUploadPassword = attr.ib(type=str, default='22222222')
	passwordChangePassword = attr.ib(type=str, default='33333333')
	auditLogPassword = attr.ib(type=str, default='44444444')
	loginPassword = attr.ib(type=str, default='99999999')

	language = attr.ib(type=str, default='en-US')

class _DeviceKeywords(_Context):
	_connections = {}
	_active_connection = None

	def __init__(self, *args):
		super().__init__(*args)

		self._seleniumext = _SeleniumExtKeywords(*args)

	@classmethod
	def _switch_device_connection(cls, connectionID):
		if connectionID not in cls._connections:
			raise IndexError('No PQ device connection with connection ID {:s}'.format(connectionID))

		cls._active_connection = connectionID

		return connectionID

	@classmethod
	def _close_device_connection(cls, connectionID=None):
		if connectionID is None:
			connectionID = cls._active_connection

		if connectionID is None:
			raise IndexError('No device connection established')

		if connectionID not in cls._connections:
			raise IndexError('No device connection with connection ID {:s} established'.format(connectionID))

		# FIXME: close all Modbus and PSU connections

		del cls._connections[connectionID]
		cls._active_connection = None if not cls._connections else next(iter(cls._connections.keys()))

		return cls._active_connection

	@classmethod
	def active_device(cls):
		if cls._active_connection is None:
			raise EnvironmentError('No PQ device connection established')

		return cls._connections[cls._active_connection]

	def set_device_connection_parameter(self, parameterName, parameterValue):
		if hasattr(_DeviceKeywords.active_device(), parameterName):
			setattr(_DeviceKeywords.active_device(), parameterName, parameterValue)
		else:
			raise AssertionError('Object of type {:s} does not have an attribute named {!s}'.format(_DeviceKeywords.active_device().__class__.__name__, parameterName))

	def get_device_address(self, path='/'):
		return '{:s}://{:s}{:s}'.format(_DeviceKeywords.active_device().protocol, _DeviceKeywords.active_device().ipAddress, path)

	def get_device_debug_address(self, path='/'):
		return 'http://{:s}:8080{:s}'.format(_DeviceKeywords.active_device().ipAddress, path)

	def get_device_time(self, dataSource=INFODataSource.HTML):
		dataSource = Utils.to_enum(dataSource, INFODataSource)

		if dataSource == INFODataSource.MODBUSTCP:
			datetimeData = self._mbus.read_holding_registers(MBModbusRegister.DEVICE_DATE_TIME.value, 4)

			return datetime.datetime(
				(datetimeData[3] & 0xff) + 1900,
				(datetimeData[2] & 0xff00) >> 8,
				datetimeData[2] & 0xff,
				(datetimeData[1] & 0xff00) >> 8,
				datetimeData[1] & 0xff,
				datetimeData[0] // 1000,
				(datetimeData[0] % 1000) * 1000,
			)
		elif dataSource == INFODataSource.HTML:
			self._sel.go_to(self.get_device_address('/InfoDeviceInfo.html'))
			self._sel.wait_until_page_contains_element('id:footer', timeout=None, error='Device information page not found')

			localTime = self._sel.find_element('xpath://*[@id="workingArea"]/table[3]/tbody/tr[2]/td[2]').text
			datetimeData = re.split(r'[ .:?\-]', localTime)

			return datetime.datetime(
				int(datetimeData[0]),
				int(datetimeData[1]),
				int(datetimeData[2]),
				int(datetimeData[3]),
				int(datetimeData[4]),
				int(datetimeData[5]),
				int(datetimeData[6]) * 1000,
			)
		else:
			raise ValueError('Data source {:s} not implemented'.format(dataSource.name))
