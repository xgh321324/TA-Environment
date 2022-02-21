*** Settings ***
Resource          Variables.robot
Library           Collections
Library           DateTime
Library           Dialogs
Library           ModbusRobot
Library           OperatingSystem
Library           RequestsLibrary
Library           SeleniumLibrary    timeout=${SeleniumTimeout}    run_on_failure=Nothing    plugins=PQDeviceRobot.workarounds.BrowserManagementKeywords
Library           String
Library           PQDeviceRobot    # needs to be the last library

*** Variables ***
