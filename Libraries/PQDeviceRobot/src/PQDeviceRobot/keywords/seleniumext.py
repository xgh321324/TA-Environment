import contextlib
import gc
import pathlib
import time

import lxml.etree
from deprecated import deprecated
from robot.api import logger
from robot.errors import DataError
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.BuiltIn import RobotNotRunningError
from robot.libraries.DateTime import convert_time
from robot.utils import robottypes
from robot.utils import secs_to_timestr
from robot.utils import timestr_to_secs
from robot.utils import unic
from selenium.common.exceptions import StaleElementReferenceException
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support.expected_conditions import staleness_of
from selenium.webdriver.support.ui import WebDriverWait
from SeleniumLibrary.keywords import WaitingKeywords
from SeleniumLibrary.utils import escape_xpath_value

from ..utils import Utils
from ._context import _Context


class _SeleniumExtKeywords(_Context):
	def __init__(self, *args):
		super().__init__(*args)

		self._wait = WaitingKeywords(self._sel)

	#region Wait Pageload

	@contextlib.contextmanager
	def wait_until_after_pageload(self, timeoutPageload=None, optionalPageload=False):
		page = self._sel.find_element('tag:html')

		if timeoutPageload is None:
			timeoutPageload = self._sel.get_selenium_timeout()

		yield

		try:
			WebDriverWait(self._sel.driver, convert_time(timeoutPageload)).until(staleness_of(page))
		except TimeoutException:
			if not optionalPageload:
				raise AssertionError('Page didn\'t reload within {:s}'.format(timeoutPageload))

	@contextlib.contextmanager
	def wait_until_page_contains_element_after_pageload(self, locator, timeoutPageload=None, timeoutElement=None, optionalPageload=False, errorElement=None):
		page = self._sel.find_element('tag:html')

		if timeoutPageload is None:
			timeoutPageload = self._sel.get_selenium_timeout()

		yield

		try:
			WebDriverWait(self._sel.driver, convert_time(timeoutPageload)).until(staleness_of(page))
		except TimeoutException:
			if not optionalPageload:
				raise AssertionError('Page didn\'t reload within {:s}'.format(timeoutPageload))

		self._sel.wait_until_page_contains_element(locator, timeoutElement, errorElement)

	@contextlib.contextmanager
	def wait_until_page_contains_after_pageload(self, text, timeoutPageload=None, timeoutText=None, optionalPageload=False, errorText=None):
		page = self._sel.find_element('tag:html')

		if timeoutPageload is None:
			timeoutPageload = self._sel.get_selenium_timeout()

		yield

		try:
			WebDriverWait(self._sel.driver, convert_time(timeoutPageload)).until(staleness_of(page))
		except TimeoutException:
			if not optionalPageload:
				raise AssertionError('Page didn\'t reload within {:s}'.format(timeoutPageload))

		self._sel.wait_until_page_contains(text, timeoutText, errorText)

	@contextlib.contextmanager
	def wait_until_dom_ready_after_pageload(self, timeoutPageload=None, timeoutDomReady=None, optionalPageload=False):
		page = self._sel.find_element('tag:html')

		if timeoutPageload is None:
			timeoutPageload = self._sel.get_selenium_timeout()

		yield

		try:
			WebDriverWait(self._sel.driver, convert_time(timeoutPageload)).until(staleness_of(page))
		except TimeoutException:
			if not optionalPageload:
				raise AssertionError('Page didn\'t reload within {:s}'.format(timeoutPageload))

		self._wait_until(lambda: self._sel.driver.execute_script('return document.readyState;').lower() in ['interactive', 'complete'], 'Page not loaded correctly after <TIMEOUT>', timeoutDomReady)

	@contextlib.contextmanager
	def wait_until_location_is_after_pageload(self, uri, timeoutPageload=None, timeoutLocation=None, optionalPageload=False):
		page = self._sel.find_element('tag:html')

		if timeoutPageload is None:
			timeoutPageload = self._sel.get_selenium_timeout()

		yield

		try:
			WebDriverWait(self._sel.driver, convert_time(timeoutPageload)).until(staleness_of(page))
		except TimeoutException:
			if not optionalPageload:
				raise AssertionError('Page didn\'t reload within {:s}'.format(timeoutPageload))

		self.wait_until_location_is(uri, timeoutLocation)

	#endregion

	#region Should Contain Multiple

	def page_should_contain_any(self, texts):
		if not self.is_any_text_present(texts):
			raise AssertionError('Page should have contained one of the texts "{:s}", but did not'.format(', '.join(texts)))

		logger.info('Current page contains one of the texts "{:s}".'.format(', '.join(texts)))

	def page_should_contain_all(self, texts):
		if not self.is_all_text_present(texts):
			raise AssertionError('Page should have contained all of the texts "{:s}", but did not'.format(', '.join(texts)))

		logger.info('Current page contains all of the texts "{:s}".'.format(', '.join(texts)))

	def page_should_contain_any_element(self, locators):
		if not self.is_any_element_present(locators):
			raise AssertionError('Page should have contained any of the elements "{:s}", but did not'.format(', '.join(locators)))

		logger.info('Current page contains any of the elements "{:s}".'.format(', '.join(locators)))

	def page_should_contain_all_element(self, locators):
		if not self.is_all_element_present(locators):
			raise AssertionError('Page should have contained all of the elements "{:s}", but did not'.format(', '.join(locators)))

		logger.info('Current page contains all of the elements "{:s}".'.format(', '.join(locators)))

	#endregion

	#region Wait Contain Multiple

	def wait_until_page_contains_any(self, texts, timeout=None, error=None):
		if error is None:
			error = 'Neither of the texts "{:s}" appeared in <TIMEOUT>'.format(', '.join(texts))

		self._wait_until(lambda: self.is_any_text_present(texts), error, timeout)

	def wait_until_page_contains_all(self, texts, timeout=None, error=None):
		if error is None:
			error = 'Not all of the texts "{:s}" appeared in <TIMEOUT>'.format(', '.join(texts))

		self._wait_until(lambda: self.is_all_text_present(texts), error, timeout)

	def wait_until_page_contains_any_element(self, locators, timeout=None, error=None):
		if error is None:
			error = 'Neither of the elements "{:s}" appeared in <TIMEOUT>'.format(', '.join(locators))

		self._wait_until(lambda: self.is_any_element_present(locators), error, timeout)

	def wait_until_page_contains_all_element(self, locators, timeout=None, error=None):
		if error is None:
			error = 'Not all of the elements "{:s}" appeared in <TIMEOUT>'.format(', '.join(locators))

		self._wait_until(lambda: self.is_all_element_present(locators), error, timeout)

	#endregion

	#region Contain Multiple Helpers

	def is_text_present(self, text):
		return self._element_finder.find('xpath://*[contains(., {:s})]'.format(escape_xpath_value(text)), required=False)

	def is_any_text_present(self, texts):
		for txt in texts:
			if self.is_text_present(txt):
				return True

		return False

	def is_all_text_present(self, texts):
		for txt in texts:
			if not self.is_text_present(txt):
				return False

		return True

	def is_any_element_present(self, locators):
		for locator in locators:
			if self._element_finder.find(locator, required=False):
				return True

		return False

	def is_all_element_present(self, locators):
		for locator in locators:
			if not self._element_finder.find(locator, required=False):
				return False

		return True

	#endregion

	#region Wait Location

	def wait_until_location_is(self, uri, timeout=None, error=None):
		if error is None:
			error = 'Location should have been "{:s}" after <TIMEOUT>'.format(uri)

		self._wait_until(lambda: self._is_location(uri), error, timeout)

	def _is_location(self, uri):
		return self._sel.get_location() == uri

	#endregion

	#region Wait other

	def wait_until_page_is_reachable(self, url, timeout='1m', elementTimeout='5s', error=None):
		if error is None:
			error = 'Page "{:s}" not reachable after <TIMEOUT>'.format(url)

		def _is_reachable():
			try:
				self._sel.go_to(url)
				self._sel.wait_until_page_contains_element('tag:html', elementTimeout, error='Page "{:s}" not reachable'.format(url))

				return True
			except Exception:
				return False

		self._wait_until(_is_reachable, error, timeout)

	def wait_until_page_is_not_reachable(self, url, timeout='30s', error=None):
		if error is None:
			error = 'Page "{:s}" is still reachable after <TIMEOUT>'.format(url)

		def _is_not_reachable():
			try:
				self._sel.go_to(url)
				self._sel.wait_until_page_contains_element('tag:html', timeout, error='Page "{:s}" not reachable'.format(url))

				return False
			except Exception:
				return True

		self._wait_until(_is_not_reachable, error, timeout)

	def wait_until_element_text_is(self, locator, expected, timeout=None, error=None, ignore_case=False):
		def _element_text_is(_locator, _expected, _ignore_case):
			try:
				text = self._sel.find_element(_locator).text
			except StaleElementReferenceException:
				# FIXME: this is just a workaround for the very weird behaviour with the #loginInfo text content
				return False

			if robottypes.is_truthy(_ignore_case):
				text = text.lower()
				_expected = _expected.lower()

			return text == _expected

		self._wait_until(
			lambda: _element_text_is(locator, expected, ignore_case),
			'Text of element \'{:s}\' not \'{:s}\' after <TIMEOUT>'.format(locator, expected),
			timeout, error
		)

	def _wait_until(self, condition, error, timeout=None, custom_error=None):
		# pylint: disable=protected-access
		self._wait._wait_until(condition, error, timeout, custom_error)

	#endregion

	#region Cookies

	def get_all_cookies(self):
		cookies = self._sel.get_cookies()

		if cookies != '':
			return cookies
		else:
			with self.disable_logging():
				return self._sel.execute_javascript('return document.cookie;')

	def get_parsed_cookies(self):
		cookies = {}
		rawCookies = self.get_all_cookies().split(';')

		for rawCookie in rawCookies:
			cookie = rawCookie.split('=', 1)
			cookies[cookie[0]] = cookie[1]

		return cookies

	#endregion

	def validate_xml_file(self, xmlFile, schemaFile=None):
		if isinstance(xmlFile, pathlib.PurePath):
			xmlFile = str(xmlFile)

		if schemaFile is None:
			return lxml.etree.parse(xmlFile)
		else:
			schemaPath = (pathlib.Path.cwd() / '..' / 'TestResources' / 'XSDs' / schemaFile).resolve()

			schema = lxml.etree.XMLSchema(file=str(schemaPath))
			parser = lxml.etree.XMLParser(schema=schema)

			return lxml.etree.parse(xmlFile, parser)

	@contextlib.contextmanager
	def disable_logging(self):
		loglevel = ''

		try:
			# pylint: disable=protected-access
			try:
				loglevel = BuiltIn()._context.output.set_log_level('NONE')
			except DataError as err:
				raise RuntimeError(unic(err))

			BuiltIn()._namespace.variables.set_global('${LOG_LEVEL}', 'NONE')
		except RobotNotRunningError:
			pass

		yield

		try:
			# pylint: disable=protected-access
			try:
				loglevel = BuiltIn()._context.output.set_log_level(loglevel)
			except DataError as err:
				raise RuntimeError(unic(err))

			BuiltIn()._namespace.variables.set_global('${LOG_LEVEL}', loglevel.upper())
		except RobotNotRunningError:
			pass

	@contextlib.contextmanager
	def disable_gc(self):
		gcStatus = gc.isenabled()
		gc.disable()

		yield

		if gcStatus:
			gc.enable()

	def fragment_sleep(self, seconds):
		endtime = time.time() + float(seconds)

		while True:
			fragment = endtime - time.time()

			if fragment <= 0:
				break

			time.sleep(min(fragment, 0.01))

	def wait_until_keyword_method_succeeds(self, timeout, interval, kwMethod, *args):
		timeout = timestr_to_secs(timeout)
		interval = timestr_to_secs(interval)

		error = None
		timeoutAbs = time.time() + timeout

		while time.time() < timeoutAbs:
			# pylint: disable=broad-except
			try:
				return kwMethod(*args)
			except Exception as err:
				error = err
				self.fragment_sleep(interval)

		raise AssertionError('Method {:s} not successful after {:s}. Last error was: {}'.format(kwMethod.__name__, secs_to_timestr(timeout), error))
