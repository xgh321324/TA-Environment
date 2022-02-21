import enum
import sys
import math

class Utils(object):
	@staticmethod
	def floatEquals(a, b, uncertainty=0.0, epsilon=None):
		a = float(a)
		b = float(b)
		uncertainty = float(uncertainty)
		epsilon = (sys.float_info.epsilon * 1e3) if epsilon is None else epsilon
		delta_AB = abs(a - b)

		if a == b:
			return True
		elif uncertainty == 0:
			return delta_AB < sys.float_info.epsilon
		else:
			if delta_AB < uncertainty:
				return True
			else:
				delta_deltaAB_uncertainty = abs(delta_AB - uncertainty)

				if delta_AB == uncertainty:
					return True
				elif delta_AB == 0 or uncertainty == 0 or delta_deltaAB_uncertainty < sys.float_info.min:
					return delta_deltaAB_uncertainty < (epsilon * sys.float_info.min)
				else:
					return (delta_deltaAB_uncertainty / min(delta_AB + uncertainty, sys.float_info.max)) < epsilon

	@staticmethod
	def to_enum(name, enumClass):
		if not issubclass(enumClass, enum.Enum):
			raise ValueError('Class {:s} is not a subclass of {:s}'.format(enumClass.__name__, enum.Enum.__name__))

		if issubclass(name.__class__, enum.Enum) and name.__class__ == enumClass:
			return name
		else:
			try:
				enumClass = enumClass[name]
			except KeyError:
				pass
			else:
				return enumClass

			try:
				enumClass = enumClass(name)
			except ValueError:
				raise ValueError('Enum class {:s} does not have an item with name or value {}'.format(enumClass.__name__, name))
			else:
				return enumClass

	@staticmethod
	def scientific_to_float(strNum):
		if 'e' in strNum:
			e = float(strNum.split('e')[0])
			sign = strNum.split('e')[1][:1]
			result_e = int(strNum.split('e')[1][1:])

			if sign == '+':
				floatNum = e * math.pow(10, result_e)
			elif sign == '-':
				floatNum = e * math.pow(10, -result_e)
			else:
				floatNum = None
				raise ValueError('error: unknown sign :{:s}'.format(sign))
		else:
			floatNum = float(strNum)

		return floatNum