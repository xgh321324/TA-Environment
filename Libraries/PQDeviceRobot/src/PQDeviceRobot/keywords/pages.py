from ._context import _Context
from .device import _DeviceKeywords
from .seleniumext import _SeleniumExtKeywords

class _PagesKeywords(_Context):
	def __init__(self, *args):
		super().__init__(*args)

		self._device = _DeviceKeywords(*args)
		self._seleniumext = _SeleniumExtKeywords(*args)

	#region GoTo Keywords

	def go_to_startup_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address())
		self._seleniumext.wait_until_page_contains_any_element(['name:ModeLoginHome', 'css:#navigationSidebar a[href="InfoDeviceInfo.html"]'], timeout)

	def go_to_login_page(self, timeout='20s'): # was 5s
		self._sel.go_to(self._device.get_device_address('/ModeLoginHome.html'))
		self._sel.wait_until_page_contains_element('name:ModeLoginHome', timeout, error='Login page not found')

	def go_to_upgrade_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/Fallback.html'))
		self._sel.wait_until_page_contains_element('css:form[action="fileupload.html"]', timeout, error='Upgrade page not found')

	def go_to_fallback_maintenance_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/Fallback.html?page=Maintenance'))
		self._sel.wait_until_page_contains_element('css:form[action="fwupload_zeroize_device.html"]', timeout, error='Fallback maintenance page not found')

	def go_to_ac_operational_values_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ViewAcOpVals.html'))
		self._sel.wait_until_page_contains_element('css:form[action="ViewAcOpVals.html"]', timeout, error='AC operational values page not found')

	def go_to_device_info_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/InfoDeviceInfo.html'))
		self._sel.wait_until_page_contains_element('css:form[action="InfoDeviceInfo.html"]', timeout, error='Device information page not found')

	def go_to_info_operational_log_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/InfoOpLog.html'))
		self._sel.wait_until_page_contains_element('css:form[action="InfoOpLog.html"]', timeout, error='Operational log page not found')

	def go_to_firmware_upload_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/MaintFwUpload.html'))
		self._sel.wait_until_page_contains_element('css:form[action="MaintFwUpload.html"]', timeout, error='Firmware upload page not found')

	def go_to_format_sd_card_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/MaintFormatSDCard.html'))
		self._sel.wait_until_page_contains_element('css:form[action="MaintFormatSDCard.html"]', timeout, error='Format SD card page not found')

	def go_to_reset_counters_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/MaintCounters.html'))
		self._sel.wait_until_page_contains_element('css:form[action="MaintCounters.html"]', timeout, error='Reset counter page not found')

	def go_to_set_datetime_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/MaintDateTime.html'))
		self._sel.wait_until_page_contains_element('css:form[action="MaintDateTime.html"]', timeout, error='Set datetime page not found')

	def go_to_reset_peak_values_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/MaintPeakValues.html'))
		self._sel.wait_until_page_contains_element('css:form[action="MaintPeakValues.html"]', timeout, error='Reset min and max values page not found')

	def go_to_delete_load_profile_buffer_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/MaintLoadProfile.html'))
		self._sel.wait_until_page_contains_element('css:form[action="MaintPQEvents.html"]', timeout, error='Delete load profile buffer page not found')

	def go_to_reset_events_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/MaintPQEvents.html'))
		self._sel.wait_until_page_contains_element('css:form[action="MaintPQEvents.html"]', timeout, error='Delete load profile buffer page not found')

	def go_to_transient_log_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/MaintTransientLog.html'))
		self._sel.wait_until_page_contains_element('css:form[action="MaintTransientLog.html"]', timeout, error='Transient log page not found')

	def go_to_maint_operational_log_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/MaintOpLog.html'))
		self._sel.wait_until_page_contains_element('css:form[action="MaintOpLog.html"]', timeout, error='Maintenance operational log page not found')

	def go_to_maint_error_log_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/MaintErrorLog.html'))
		self._sel.wait_until_page_contains_element('css:form[action="MaintErrorLog.html"]', timeout, error='Maintenance error log page not found')

	def go_to_audit_log_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/MaintSecurityLog.html'))
		self._sel.wait_until_page_contains_element('css:form[action="MaintSecurityLog.html"]', timeout, error='Audit log page not found')

	def go_to_diagnosis_iec61850_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/MaintDiagIEC61850.html'))
		self._sel.wait_until_page_contains_element('css:form[action="MaintDiagIEC61850.html"]', timeout, error='Diagnosis iec61850 page not found')

	def go_to_customer_support_functions_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/MaintDiagPages.html'))
		self._sel.wait_until_page_contains_element('css:form[action="MaintDiagPages.html"]', timeout, error='Customer support function page not found')

	def go_to_view_load_profile_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ViewLoadProfile.html'))
		self._sel.wait_until_page_contains_element('css:form[action="ViewLoadProfile.html"]', timeout, error='View load profile page not found')

	def go_to_harmonics_voltage_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ViewAcHarmonicsVoltage.html'))
		self._sel.wait_until_page_contains_element('css:form[action="ViewAcHarmonicsVoltage.html"]', timeout, error='Harmonics voltage page not found')

	def go_to_harmonics_current_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ViewAcHarmonicsCurrent.html'))
		self._sel.wait_until_page_contains_element('css:form[action="ViewAcHarmonicsCurrent.html"]', timeout, error='Harmonics current page not found')

	def go_to_harmonics_power_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ViewAcHarmonicsPower.html'))
		self._sel.wait_until_page_contains_element('css:form[action="ViewAcHarmonicsPower.html"]', timeout, error='Harmonics power page not found')

	def go_to_harmonics_power_direction_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ViewAcHarmonicsDirection.html'))
		self._sel.wait_until_page_contains_element('css:form[action="ViewAcHarmonicsDirection.html"]', timeout, error='Harmonics power direction page not found')

	def go_to_interharmonics_voltage_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ViewAcInterHarmonicsVoltage.html'))
		self._sel.wait_until_page_contains_element('css:form[action="ViewAcInterHarmonicsVoltage.html"]', timeout, error='Interharmonics voltage page not found')

	def go_to_interharmonics_current_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ViewAcInterHarmonicsCurrent.html'))
		self._sel.wait_until_page_contains_element('css:form[action="ViewAcInterHarmonicsCurrent.html"]', timeout, error='Interharmonics current page not found')

	def go_to_view_msv_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ViewMainsSIGVoltage.html'))
		self._sel.wait_until_page_contains_element('css:form[action="ViewMainsSIGVoltage.html"]', timeout, error='View MSV page not found')

	def go_to_view_meas_recorder_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ViewMeasurementRecord.html'))
		self._sel.wait_until_page_contains_element('css:form[action="ViewMeasurementRecord.html"]', timeout, error='View measurement recorder page not found')

	def go_to_view_trend_recorder_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ViewTrendRecord.html'))
		self._sel.wait_until_page_contains_element('css:form[action="ViewTrendRecord.html"]', timeout, error='View trend recorder page not found')

	def go_to_view_records_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ViewRecord.html'))
		self._sel.wait_until_page_contains_element('css:form[action="ViewRecord.html"]', timeout, error='View records page not found')

	def go_to_file_transfer_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ViewFileTransfer.html'))
		self._sel.wait_until_page_contains_element('css:form[action="ViewFileTransfer.html"]', timeout, error='File transfer page not found')

	def go_to_configure_limit_page_one(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ConfMeasurandLimits.html?Page_1'))
		self._sel.wait_until_page_contains_element('css:form[action="ConfMeasurandLimits.html"]', timeout, error='Configure limit page one not found')

	def go_to_configure_limit_page_two(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ConfMeasurandLimits.html?Page_2'))
		self._sel.wait_until_page_contains_element('css:form[action="ConfMeasurandLimits.html"]', timeout, error='Configure limit page two not found')

	def go_to_configure_group_indication_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ConfGroupIndications.html'))
		self._sel.wait_until_page_contains_element('css:form[action="ConfGroupIndications.html"]', timeout, error='Configure group indication page not found')

	def go_to_configure_binary_output_page(self, timeout=None):
		self._sel.go_to(self._device.get_device_address('/ConfBinaryOutputs.html'))
		self._sel.wait_until_page_contains_element('css:form[action="ConfBinaryOutputs.html"]', timeout, error='Configure binary output page not found')

	#endregion
