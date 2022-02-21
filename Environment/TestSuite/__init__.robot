*** Settings ***
Suite Setup       Run Keywords    Open Device    &{PQDeviceRobot_OpenDevice_Config_Without_Reset}
...               AND    Login
...               AND    Get Generalinfo List    ipAddress=${IPAddress}    getSDCardVendor=${False}
...               AND    Close Device
Suite Teardown
Metadata          Version    1.3.0.dev0
Resource          CommonResources.robot
