#!/usr/bin/env python3

import datetime
import os
import pathlib
import shutil
import sys
import zipfile

import robot


def run_tests(args=None):
	if args is None:
		args = sys.argv[1:]

	if '-c' not in args and '--critical' not in args:
		args[-1:-1] = ['-c', 'critical']

	args[-1:-1] = ['--listener', 'PQDeviceRobot.workarounds.CriticalStatus.CriticalTestCaseSuiteStatus']
	args[-1:-1] = ['-c', 'failure']

	if '-X' not in args and '--exitonfailure' not in args:
		args.insert(-1, '-X')

	if '-x' not in args and '--xunit' not in args:
		args[-1:-1] = ['-x', 'statistic']

	if '-d' not in args and '--outputdir' not in args:
		executionDate = '{:%Y-%m-%d_%H-%M-%S}'.format(datetime.datetime.now())
		args[-1:-1] = ['-d', '../TestOutput/{:s}'.format(executionDate)]

	if '-W' not in args and '--consolewidth' not in args:
		args[-1:-1] = ['-W', str(max(78, shutil.get_terminal_size()[0] - 2))]

	if 'path' not in os.environ:
		os.environ['path'] = str((pathlib.Path() / '..' / 'WebDrivers').resolve())
	else:
		os.environ['path'] = '{!s}{:s}{!s}'.format((pathlib.Path() / '..' / 'WebDrivers').resolve(), os.pathsep, os.environ['path'])

	robot.run_cli(args, exit=False)

	return executionDate

def zipDir(dirpath, outFullName):
	with zipfile.ZipFile(outFullName, "w", zipfile.ZIP_DEFLATED) as myzip:
		for path, dirnames, filenames in os.walk(dirpath):
			fpath = path.replace(dirpath, '')

			for filename in filenames:
				myzip.write(os.path.join(path, filename),os.path.join(fpath, filename))

def backupTestOutput(executionDate):
	remoteOutputDir = str((pathlib.Path() / '..' / 'TestOutput' / 'Remote').resolve())

	if os.path.exists(remoteOutputDir):
		shutil.rmtree(remoteOutputDir)

	isExists = os.path.exists(remoteOutputDir)
	if not isExists:
		os.makedirs(remoteOutputDir)
	else:
		print('The dir is already existed.')

	testLogDir = str((pathlib.Path() / '../TestOutput/{:s}/log.html'.format(executionDate)).resolve())
	testOutputDir = str((pathlib.Path() / '../TestOutput/{:s}/output.xml'.format(executionDate)).resolve())
	testReportDir = str((pathlib.Path() / '../TestOutput/{:s}/report.html'.format(executionDate)).resolve())
	testStatisticDir = str((pathlib.Path() / '../TestOutput/{:s}/statistic.xml'.format(executionDate)).resolve())

	remoteTestLogDir  = str((pathlib.Path() / '../TestOutput/Remote/log.html').resolve())
	remoteTestOutputDir = str((pathlib.Path() / '../TestOutput/Remote/output.xml').resolve())
	remoteTestReportDir = str((pathlib.Path() / '../TestOutput/Remote/report.html').resolve())
	remoteTestStatisticDir = str((pathlib.Path() / '../TestOutput/Remote/statistic.xml').resolve())

	shutil.copyfile(testLogDir, remoteTestLogDir)
	shutil.copyfile(testOutputDir, remoteTestOutputDir)
	shutil.copyfile(testReportDir, remoteTestReportDir)
	shutil.copyfile(testStatisticDir, remoteTestStatisticDir)

	testAttachmentDir = str((pathlib.Path() / '../TestOutput/{:s}'.format(executionDate)).resolve())
	remoteTestAttachmentDir = str((pathlib.Path() / '../TestOutput/Remote/attachment.zip'.format(executionDate)).resolve())
	zipDir(testAttachmentDir, remoteTestAttachmentDir)

if __name__ == '__main__':
	date = run_tests()

	backupTestOutput(date)