from ModbusRobot import ModbusRobot
from SeleniumLibrary import SeleniumLibrary
from SeleniumLibrary.locators import ElementFinder


class _Context(object):
	def __init__(self, sel, mbus):
		self._sel = sel # type: SeleniumLibrary
		self._mbus = mbus # type: ModbusRobot
		self._element_finder = ElementFinder(self._sel)
