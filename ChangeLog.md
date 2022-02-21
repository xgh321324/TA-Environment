# => release/1.2.0 - 2021-09-18 - Release for SICAM Q200 V02.62

## ==> Updated Test Automation Environment from v1.1.0 to v1.2.0
### => New features:
1. Support IEEE519 for Q200
2. Support Power Loss for Q200
3. Support ITIC Curve for Q200
4. Support Aggregation for Q200
5. Support Energy Profile for Q200
6. Support Wareform diagram Download for Q200
7. Support THDS in Measurement Recorder-IEC61000-4-30, PQDIF channel extension for Q200
8. Support Harmonic distortion related logical node and IEC61850 report 
9. Support TOU for Q200, Q100
10. Support Load Profile extension for Q200, Q100(Next FW Version)
11. Support BO/BI with DAM1616D for Q200, Q100, P85X
12. Support Modbus Register Validation(Read) for Q200, Q100, P85X
13. Support FTPS for Q100(Next FW Version)
14. Support Measurement Recorder (PQDIF) for P85X

### => Fixes:
1. Add precondition in performance test(enable energy profile, power loss, IEEE519)
2. Smoke optimization for Q200, Q100, Q100V1, P85X
3. Update standard version for IEC62053 and IEC61557
4. Add Tag for MiniSystem

### => Note:
1. Update 3rd party library(Please pull the v1.2.0 and update environment by ./Setup-Dev-Environment.bat)

## ==> Updated PQDeviceRobot from v1.1.0 to v1.2.0
1. Support New FW function
2. Support FTPS
3. Adapt with P85X V2.70 new web structure
4. Update standard version for IEC62053 and IEC61557

## ==> Updated IEC61850Robot from v0.1.1 to v0.1.2
1. Support timestamp validation
2. Imporve download file method
3. Bug fixing for prefix name definition

## ==> Updated SignalRobot from v0.6.0 to v0.7.0
1. Support ramping signal

## ==> Updated ModbusRobot from v0.5.0 to v0.6.0
1. Support read and write coils register

## ==> No updated for COMTRADERobot
## ==> No updated for PQDIFRobot
## ==> No updated for PSURobot
## ==> No updated for RADIUSRobot
## ==> No updated for RADIUSRobot-IEC
## ==> No updated for robotframework-autoitlibrary

# => release/1.1.0 - 2021-06-03 - Release for SICAM Q100 V02.40

## ==> Updated Test Automation Environment from v1.0.0 to v1.1.0
### => New features:
1. Measurement Recorder for Q200, Q100
2. IEC62586 Aggregation for Q100
3. Compatibility Test for Q200, Q100
4. ITI Curve for Q100

### => Fixes:
1. SICAM-T smoke optimization
2. IEC61850 connection bug fixing
3. Tariff adapt with new webpage

### => Note:
None

## ==> Updated PQDeviceRobot from v1.0.0 to v1.1.0
1. New function support
2. Due to the defect CHDOC00167125 of Q100 device, extend restart time from 2m to 3m
3. Group indication keywords use enum as input
4. Add keywords for configuring energy upper limit and setting tariff

## ==> Updated IEC61850Robot from v0.1.0 to v0.1.1
1. Add keyword for downloading ITIC report file
2. Bug fixing for download comtrade and pqdif file from IEC61850

## ==> No updated for COMTRADERobot
## ==> No updated for ModbusRobot
## ==> No updated for PQDIFRobot
## ==> No updated for PSURobot
## ==> No updated for RADIUSRobot
## ==> No updated for RADIUSRobot-IEC
## ==> No updated for robotframework-autoitlibrary
## ==> No updated for SignalRobot

# => release/1.0.0 - 2021-04-09 - Release for SICAM Q200 V02.61

## ==> Updated Test Automation Environment from v0.9.0 to v1.0.0
### => New features:
1. Load Profile for Q200, Q100, Q100V1
2. Waveform Recorder(IEC 61850) for Q200, Q100
3. ITI Curve for Q200

### => Fixes:
1. Adapt with new HTML structure for Q200, Q100

### => Note:
In V1.0.0 we release a new library - COMTRADERobot in TA-PQ-Environment.
To make sure you can execute all the cases successfully, please pull with tag release/1.0.0 and re-setup your environment.

## ==> Release IEC61850Robot v0.1.0
1. Logical node read
2. Logical node reporting
3. File transfer

## ==> Release COMTRADERobot v0.1.0
1. COMTRADE file(.cfg, .dat, .hdr) parsing

## ==> Updated PQDeviceRobot from v0.9.0 to v1.0.0
1. Adapt with new HTML structure for Q200, Q100
2. New function support

## ==> Updated SignalRobot from v0.5.0 to v0.6.0
1. Fluke support
1. Omicron-Interharmonic support

## ==> Updated RADIUSRobot from v0.1.0 to v0.2.0

## ==> Updated PSURobot from v0.2.3 to v0.2.4

## ==> Updated ModbusRobot from v0.4.0 to v0.5.0

## ==> No updated for PQDIFRobot
## ==> No updated for RADIUSRobot-IEC
## ==> No updated for robotframework-autoitlibrary


