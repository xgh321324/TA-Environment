from robot.api.deco import keyword
from robot.utils import robottypes
from robot.utils import timestr_to_secs
from SeleniumLibrary.keywords.browsermanagement import BrowserManagementKeywords


class BrowserManagementKeywords(BrowserManagementKeywords):
	@keyword
	def open_browser(self, url=None, browser='firefox', alias=None, remote_url=False, desired_capabilities=None, ff_profile_dir=None, options=None, service_log_path=None):
		browserIndex = super().open_browser(None, browser, alias, remote_url, desired_capabilities, ff_profile_dir, options, service_log_path)
		driver = self.drivers[browserIndex]

		driver.set_page_load_timeout(self.ctx.timeout)

		if robottypes.is_truthy(url):
			try:
				driver.get(url)
			except Exception:
				self.debug('Opened browser with session id {!s} but failed to open url \'{!s}\'.'.format(driver.session_id, url))
				raise

		return browserIndex

	@keyword
	def set_selenium_timeout(self, value):
		old_timeout = self.get_selenium_timeout()

		self.ctx.timeout = timestr_to_secs(value)

		for driver in self.drivers.active_drivers:
			driver.set_script_timeout(self.ctx.timeout)
			driver.set_page_load_timeout(self.ctx.timeout)

		return old_timeout
