import enum
import functools
import hashlib
import struct

from pymodbus.client.sync import ModbusSerialClient
from pymodbus.client.sync import ModbusTcpClient
from pymodbus.client.sync import ModbusUdpClient
from pymodbus.constants import Defaults
from pymodbus.exceptions import ModbusException
from pymodbus.pdu import ExceptionResponse
from pymodbus.register_read_message import ReadHoldingRegistersResponse

from .version import VERSION

__version__ = VERSION

class ModbusConnectionType(enum.Enum):
	TCP = 0
	UDP = 1
	RTU = 2

class ModbusType(enum.Enum):
	RAW = 0
	STRING = 1
	FLOAT = 2
	DOUBLE = 3
	SHORT = 4
	USHORT = 5

class ModbusRobot(object):
	ROBOT_LIBRARY_SCOPE = 'GLOBAL'
	ROBOT_LIBRARY_VERSION = __version__

	def __init__(self, connectionType=None, **connectParams):
		self._clients = {}
		self._connections = {}
		self._active_connection = None

		if connectionType is not None:
			self.open_modbus_connection(connectionType, **connectParams)

	def _check_connectionID(self, connectionID):
		if connectionID is None:
			connectionID = self._active_connection

		if connectionID is None:
			raise ModbusException('No Modbus connection established')

		if connectionID not in self._connections:
			raise ModbusException('No Modbus connection with ID {:s} established'.format(connectionID))

		if self._connections[connectionID]['clientID'] not in self._clients:
			raise ModbusException('Modbus connection with ID {:s} exists, but no Modbus client was found')

		return connectionID

	def open_modbus_connection(self, connectionType, **connectParams):
		connectionType = ModbusConnectionType[connectionType] if isinstance(connectionType, str) else ModbusConnectionType(connectionType)
		clientID = None

		connectionClass = None
		connectParams.update({
			'timeout': float(connectParams.get('timeout', Defaults.Timeout)),
		})

		if 'unit' not in connectParams:
			unit = int(connectParams.pop('unit', 1))
		else:
			unit = int(connectParams.get('unit'))

		if connectionType in [ModbusConnectionType.TCP, ModbusConnectionType.UDP]:
			connectionTypeMapping = {
				ModbusConnectionType.TCP: {
					'connectionClass': ModbusTcpClient,
					'protocol': 'tcp',
				},
				ModbusConnectionType.UDP: {
					'connectionClass': ModbusUdpClient,
					'protocol': 'udp',
				},
			}

			if 'host' not in connectParams:
				raise ValueError('No host address given for Modbus {:s} connection'.format(connectionType.name))

			connectionClass = connectionTypeMapping[connectionType]['connectionClass']
			connectParams.update({
				'host': connectParams.get('host'),
				'port': int(connectParams.get('port', Defaults.Port)),
			})
			clientID = hashlib.sha1('{:s}://{!s}:{:d}'.format(
				connectionTypeMapping[connectionType]['protocol'],
				connectParams.get('host'),
				connectParams.get('port'),
			).encode('utf-8')).hexdigest()
		elif connectionType == ModbusConnectionType.RTU:
			if 'port' not in connectParams:
				raise ValueError('No COM port given for Modbus {:s} connection'.format(connectionType.name))

			connectionClass = ModbusSerialClient
			connectParams.update({
				'method': 'rtu',
				'port': connectParams.get('port'),
				'baudrate': int(connectParams.get('baudRate', 19200)),
				'parity': connectParams.get('parity', 'E'),
				'stopbits': int(connectParams.get('stopbits', Defaults.Stopbits)),
				'bytesize': int(connectParams.get('bytesize', Defaults.Bytesize)),
			})
			clientID = hashlib.sha1('{:s}'.format(connectParams.get('port')).encode('utf-8')).hexdigest()

		connectionID = '{:s}-{:d}'.format(clientID, unit)

		if clientID not in self._clients:
			self._clients[clientID] = {
				'client': connectionClass(**connectParams),
				'counter': 0,
			}

		if connectionID not in self._connections:
			self._connections[connectionID] = {
				'clientID': clientID,
				'unit': unit,
				'type': connectionType,
			}
			self._clients[clientID]['counter'] += 1

		self._active_connection = connectionID

		return connectionID

	def get_modbus_connection_parameters(self, connectionID=None):
		connectionID = self._check_connectionID(connectionID)

		if self._connections[connectionID]['type'] == ModbusConnectionType.TCP:
			return {
				'connectionType': ModbusConnectionType.TCP,
				'host': self._clients[self._connections[connectionID]['clientID']]['client'].host,
				'port': self._clients[self._connections[connectionID]['clientID']]['client'].port,
				'unit': self._connections[connectionID]['unit'],
				'timeout': self._clients[self._connections[connectionID]['clientID']]['client'].timeout,
			}
		elif self._connections[connectionID]['type'] == ModbusConnectionType.RTU:
			return {
				'connectionType': ModbusConnectionType.RTU,
				'port': self._clients[self._connections[connectionID]['clientID']]['client'].port,
				'baudrate': self._clients[self._connections[connectionID]['clientID']]['client'].baudrate,
				'parity': self._clients[self._connections[connectionID]['clientID']]['client'].parity,
				'stopbits': self._clients[self._connections[connectionID]['clientID']]['client'].stopbits,
				'bytesize': self._clients[self._connections[connectionID]['clientID']]['client'].bytesize,
				'unit': self._connections[connectionID]['unit'],
				'timeout': self._clients[self._connections[connectionID]['clientID']]['client'].timeout,
			}

	def switch_modbus_connection(self, connectionID):
		if connectionID not in self._connections:
			raise ModbusException('No Modbus connection with ID {:s} established'.format(connectionID))

		self._active_connection = connectionID

		return connectionID

	def close_modbus_connection(self, connectionID=None):
		connectionID = self._check_connectionID(connectionID)

		self._clients[self._connections[connectionID]['clientID']]['counter'] -= 1

		if self._clients[self._connections[connectionID]['clientID']]['counter'] <= 0:
			self._clients[self._connections[connectionID]['clientID']]['client'].close()

			del self._clients[self._connections[connectionID]['clientID']]['client']
			del self._clients[self._connections[connectionID]['clientID']]

		del self._connections[connectionID]

		self._active_connection = None if not self._connections else next(iter(self._connections.keys()))

		return self._active_connection

	def close_all_modbus_connections(self):
		for connectionID in [*self._connections.keys()]:
			self.close_modbus_connection(connectionID)

		self._active_connection = None

		return self._active_connection

	def _check_respose(self, response):
		if isinstance(response, ModbusException):
			raise response

		if isinstance(response, ExceptionResponse):
			raise ModbusException('{!s}'.format(response))

	def read_holding_data(self, address, mbusType='USHORT', size=1, connectionID=None):
		address = int(address)
		mbusType = ModbusType[mbusType] if isinstance(mbusType, str) else ModbusType(mbusType)
		size = int(size)
		connectionID = self._check_connectionID(connectionID)

		if mbusType == ModbusType.STRING:
			return self.read_holding_string(address, size * 2, connectionID)
		elif mbusType == ModbusType.FLOAT:
			return self.read_holding_float(address, connectionID)
		elif mbusType == ModbusType.DOUBLE:
			return self.read_holding_double(address, connectionID)
		elif mbusType == ModbusType.SHORT:
			return self.read_holding_short(address, connectionID)
		elif mbusType == ModbusType.USHORT:
			return self.read_holding_unsigned_short(address, connectionID)
		elif mbusType == ModbusType.RAW:
			return self.read_holding_registers(address, size, connectionID)
		else:
			raise ModbusException('Type not supported')

	def read_holding_string(self, address, maxLength, connectionID=None):
		connectionID = self._check_connectionID(connectionID)
		response = self._clients[self._connections[connectionID]['clientID']]['client'].read_holding_registers(int(address), int(maxLength / 2), unit=self._connections[connectionID]['unit']) # type: ReadHoldingRegistersResponse

		self._check_respose(response)

		s = struct.pack('!{:s}'.format('H' * len(response.registers)), *response.registers)
		i = -1

		try:
			i = s.index(b'\x00')

			return s[:i].decode('ascii')
		except ValueError:
			return s.decode('ascii')

	def read_holding_float(self, address, connectionID=None):
		connectionID = self._check_connectionID(connectionID)
		response = self._clients[self._connections[connectionID]['clientID']]['client'].read_holding_registers(int(address), 2, unit=self._connections[connectionID]['unit']) # type: ReadHoldingRegistersResponse

		self._check_respose(response)

		return struct.unpack('!f', struct.pack('!HH', *response.registers))[0]

	def read_holding_double(self, address, connectionID=None):
		connectionID = self._check_connectionID(connectionID)
		response = self._clients[self._connections[connectionID]['clientID']]['client'].read_holding_registers(int(address), 4, unit=self._connections[connectionID]['unit']) # type: ReadHoldingRegistersResponse

		self._check_respose(response)

		return struct.unpack('!d', struct.pack('!HHHH', *response.registers))[0]

	def read_holding_unsigned_short(self, address, connectionID=None):
		connectionID = self._check_connectionID(connectionID)
		response = self._clients[self._connections[connectionID]['clientID']]['client'].read_holding_registers(int(address), 1, unit=self._connections[connectionID]['unit']) # type: ReadHoldingRegistersResponse

		self._check_respose(response)

		return response.registers[0]

	def read_holding_short(self, address, connectionID=None):
		connectionID = self._check_connectionID(connectionID)
		response = self._clients[self._connections[connectionID]['clientID']]['client'].read_holding_registers(int(address), 1, unit=self._connections[connectionID]['unit']) # type: ReadHoldingRegistersResponse

		self._check_respose(response)

		return struct.unpack('!h', struct.pack('!H', *response.registers))[0]

	def read_input_status(self, address, connectionID=None):
		connectionID = self._check_connectionID(connectionID)
		response = self._clients[self._connections[connectionID]['clientID']]['client'].read_discrete_inputs(int(address), 1, unit=self._connections[connectionID]['unit'])

		self._check_respose(response)

		return response.bits[0]

	def read_coil_status(self, address, connectionID=None):
		connectionID = self._check_connectionID(connectionID)
		response = self._clients[self._connections[connectionID]['clientID']]['client'].read_coils(int(address), 1, unit=self._connections[connectionID]['unit'])

		self._check_respose(response)

		return response.bits[0]

	def read_holding_registers(self, address, n, connectionID=None):
		connectionID = self._check_connectionID(connectionID)
		response = self._clients[self._connections[connectionID]['clientID']]['client'].read_holding_registers(int(address), int(n), unit=self._connections[connectionID]['unit']) # type: ReadHoldingRegistersResponse

		self._check_respose(response)

		return response.registers

	def read_discrete_inputs(self, address, n, connectionID=None):
		connectionID = self._check_connectionID(connectionID)
		response = self._clients[self._connections[connectionID]['clientID']]['client'].read_discrete_inputs(int(address), int(n), unit=self._connections[connectionID]['unit'])

		self._check_respose(response)

		return response.bits

	def read_coils(self, address, n, connectionID=None):
		connectionID = self._check_connectionID(connectionID)
		response = self._clients[self._connections[connectionID]['clientID']]['client'].read_coils(int(address), int(n), unit=self._connections[connectionID]['unit'])

		self._check_respose(response)

		return response.bits

	def write_coil(self, address, value, connectionID=None):
		connectionID = self._check_connectionID(connectionID)
		response = self._clients[self._connections[connectionID]['clientID']]['client'].write_coil(int(address), value, unit=self._connections[connectionID]['unit'])

		self._check_respose(response)

		return response

	def write_unsigned_short(self, address, value, connectionID=None):
		connectionID = self._check_connectionID(connectionID)
		response = self._clients[self._connections[connectionID]['clientID']]['client'].write_register(int(address), int(value), unit=self._connections[connectionID]['unit'])

		self._check_respose(response)

		return response

	def write_holding_registers(self, address, values, connectionID=None):
		connectionID = self._check_connectionID(connectionID)
		response = self._clients[self._connections[connectionID]['clientID']]['client'].write_registers(int(address), values, unit=self._connections[connectionID]['unit'])

		self._check_respose(response)

		return response

	def write_bits(self, address, bits):
		if any(x > 15 for x in bits):
			raise ModbusException('Trying to set bit out of range')

		value = functools.reduce(lambda x, y: x | y, [1 << x for x in bits], 0)

		self.write_unsigned_short(address, value)
