For a new firmware version, place the firmware PCK / CMS file in the FWImages
folder in the test environment. Start RIDE and change the FWTargetVersion
and FWTargetImageFilename to the current tested version and firmware image
file name. Also, change the FWDowngradeVersion and FWDowngradeImageFilename
to the respective version of the firmware for the downgrade test.

As of version 0.2.0, the test environment runs the upgrade with secure
device resetting. Because this feature is only available from Fallback mode,
the tester has to start the device in Fallback mode by pressing F4 during
reboot. This procedure has to be done when the test run instructs the tester
to do so. When starting the test run, the device has to run in normal operation
mode. When ready, the test run will instruct the tester to reboot to Fallback
mode. When done, the tester has to confirm the activation of Fallback mode
and press OK to continue test execution.

The Protocol variable has to be set to HTTP or HTTPS, depending on the CURRENTLY
installed firmware, not the firmware to be uploaded.

Certain test cases use an Omicron device to emit test signals and check the
measured signal properties of the Q200 device under testing. For this to work,
the tester has to have an Omicron device attached and associated with the PC
running the test. The Omicron Device has to be wired appropiatly to feed the
signals correctly. For the more complex binary test cases, the necessary wiring
is described in the attached image file.

A switchable power supply unit (PSU) is necessary to execute certain tests, mainly
the Performance test suite. This PSU is used to turn off the Q200 device and measured
the boot time after turning the device back on until it's reachable via certain
communication protocols. Currently, there are two supported PSU device types:
Allnet ALL3075 v3 and Siemens SICAM IO Unit. The environment in its default
configuration expects a SICAM IO Unit to be used. The SICAM IO Unit is expected
to be updated to the latest firmware (V02.15). The SICAM IO Unit has to be
configured before test execution. A config file is supplied in the TestResources
folder. Adjustments for the IP address have to be made according to the setup.

ATTENTION: No device in the test network should be configured to use the IP
address 192.168.0.55. This is due to the Q200 device fall back to this default IP
address when deleted securly. If there are other devices with this IP address
attached to the same network, test execution can't continue.

Tests can now be executed. If no test case is selected, all the test cases
will be executed when starting the test in the »Run« tab. If you want to limit
the execution to certain test, tick the checkbox next to the test cases.
Test cases also contain some tags. By using the corresponding function in RIDE,
the tester can limit the test execution to certain tags.

For test run configuration, there are certain variables. Some of these are more or
less static, because they are built from other variables based on the test
environment. Those static variables should usually not be edited unless the
device or test environment changes drastically.

Variables
 - IPAddress: IP address of the tested Q200 device
 - SubnetMask: Subnet mask of the tested Q200 device
 - DefaultGateway: Default gateway of the test Q200 device
 - Protocol: Set to either http or https depending on the CURRENT installed firmware
 - Browser: Set to ie (Internet Explorer), chrome (Chrome) or ff (Firefox)
 - OmicronSerial: Serial of the attached Omicron device
 - PSUModel: Identifier for attached PSU, currently supports SICAMIOUnit and AllnetALL3075v3
 - PSUIPAddress: IP address of the PSU
 - PSUInverted: Boolean value indicating if the PSU ist set to inverted mode
 - FWTargetVersion: Expected firmware version after upgrade
 - FWTargetImageFilename: The tested firmware image file
 - FWDowngradeVersion: The firmware version for downgrade testing
 - FWDowngradeImageFilename: The firmware image file for downgrade testing
 - FWReadmeOSSVersion: Expected ReadmeOSS version
 - QCPFPGAVersion: Expected QCP FPGA version
 - QVMFPGAVersion: Expected QVM FPGA version
 - QCPCPLDVersion: Expected QCP CPLD version

Static variables
 - FWImagePath: Path to the folder containing the firmware image files
