class CriticalTestCaseSuiteStatus(object):
	ROBOT_LISTENER_API_VERSION = 3

	def end_test(self, data, test):
		if not test.passed:
			test.tags.add(('failure',))
