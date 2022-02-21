*** Settings ***
Resource          ../../TestSuite/CommonResources.robot
Resource          ../RFResource/TestToolOMICRON.robot
Library           AutoItLibrary

*** Keywords ***
Run VoltageAggregation.A2.4.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    49.99    59.99
    ${outputVoltageP3}    Get Iec62586 Test Point    measurand=VOLTAGE_VA    testPoint=P3    uNom=${ReferenceVoltage}
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Open Signal Device Connection    OMICRON    ${OmicronSerial}
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M10    fileGenInterval=H2
    Activate Configuration
    Set Voltage Output    ${outputFrequency}    0    -120    120    ${outputVoltageP3}    ${outputVoltageP3}    ${outputVoltageP3}
    Set Current Output    ${outputFrequency}    0    -120    120    1    1    1
    Activate Output
    Pause    10    Wait for the signal to output stably
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${1} or ${minute} == ${11} or ${minute} == ${21} or ${minute} == ${31} or ${minute} == ${41} or ${minute} == ${51}
        Sleep    5
    END
    ${aggreInfo}    Get Aggregation Info Cluster    period=700s    measInterval=BASE_10_12_CYCLE
    login
    Run Keyword And Continue On Failure    Validate Aggregation Time Tags    BASE_10_12_CYCLE    ${aggreInfo[0]}    allowedErrCount=${1}
    Run Keyword And Continue On Failure    Validate Aggregation Seq Num    ${aggreInfo[1]}
    Run Keyword And Continue On Failure    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Validate Aggregation Interval Num    10m    BASE_10_12_CYCLE
    Close Signal Device Connection

Run VoltageAggregation.A2.5.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    50.125    60.15
    ${outputVoltageP1}    Get Iec62586 Test Point    measurand=VOLTAGE_VA    testPoint=P1    uNom=${ReferenceVoltage}
    ${outputVoltageP3}    Get Iec62586 Test Point    measurand=VOLTAGE_VA    testPoint=P3    uNom=${ReferenceVoltage}
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Open Signal Device Connection    OMICRON    ${OmicronSerial}
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=AGGR_150_180_CYCLE
    Set Communication Ethernet Configuration    modbusTCP=BOTH
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M10    fileGenInterval=H2
    Run Keyword If    '${DeviceType}' == 'Q200'    Set ModbusTcp Configuration    voltageHarmonicsUnit=VOLTAGE
    Activate Configuration
    Set Simple Output    ${outputFrequency}    57.7    1
    Activate Output
    Start Sequence
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP1}    ub=${outputVoltageP1}    uc=${outputVoltageP1}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP1}    ub_t0=${outputVoltageP1}    uc_t0=${outputVoltageP1}    ua_t1=${outputVoltageP3}    ub_t1=${outputVoltageP3}    uc_t1=${outputVoltageP3}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP3}    ub=${outputVoltageP3}    uc=${outputVoltageP3}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP3}    ub_t0=${outputVoltageP3}    uc_t0=${outputVoltageP3}    ua_t1=${outputVoltageP1}    ub_t1=${outputVoltageP1}    uc_t1=${outputVoltageP1}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP1}    ub=${outputVoltageP1}    uc=${outputVoltageP1}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP1}    ub_t0=${outputVoltageP1}    uc_t0=${outputVoltageP1}    ua_t1=${outputVoltageP3}    ub_t1=${outputVoltageP3}    uc_t1=${outputVoltageP3}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP3}    ub=${outputVoltageP3}    uc=${outputVoltageP3}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP3}    ub_t0=${outputVoltageP3}    uc_t0=${outputVoltageP3}    ua_t1=${outputVoltageP1}    ub_t1=${outputVoltageP1}    uc_t1=${outputVoltageP1}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP1}    ub=${outputVoltageP1}    uc=${outputVoltageP1}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP1}    ub_t0=${outputVoltageP1}    uc_t0=${outputVoltageP1}    ua_t1=${outputVoltageP3}    ub_t1=${outputVoltageP3}    uc_t1=${outputVoltageP3}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP3}    ub=${outputVoltageP3}    uc=${outputVoltageP3}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP3}    ub_t0=${outputVoltageP3}    uc_t0=${outputVoltageP3}    ua_t1=${outputVoltageP1}    ub_t1=${outputVoltageP1}    uc_t1=${outputVoltageP1}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP1}    ub=${outputVoltageP1}    uc=${outputVoltageP1}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP1}    ub_t0=${outputVoltageP1}    uc_t0=${outputVoltageP1}    ua_t1=${outputVoltageP3}    ub_t1=${outputVoltageP3}    uc_t1=${outputVoltageP3}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP3}    ub=${outputVoltageP3}    uc=${outputVoltageP3}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP3}    ub_t0=${outputVoltageP3}    uc_t0=${outputVoltageP3}    ua_t1=${outputVoltageP1}    ub_t1=${outputVoltageP1}    uc_t1=${outputVoltageP1}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP1}    ub=${outputVoltageP1}    uc=${outputVoltageP1}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP1}    ub_t0=${outputVoltageP1}    uc_t0=${outputVoltageP1}    ua_t1=${outputVoltageP3}    ub_t1=${outputVoltageP3}    uc_t1=${outputVoltageP3}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP3}    ub=${outputVoltageP3}    uc=${outputVoltageP3}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP3}    ub_t0=${outputVoltageP3}    uc_t0=${outputVoltageP3}    ua_t1=${outputVoltageP1}    ub_t1=${outputVoltageP1}    uc_t1=${outputVoltageP1}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP1}    ub=${outputVoltageP1}    uc=${outputVoltageP1}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP1}    ub_t0=${outputVoltageP1}    uc_t0=${outputVoltageP1}    ua_t1=${outputVoltageP3}    ub_t1=${outputVoltageP3}    uc_t1=${outputVoltageP3}
    Activate Output
    End Sequence
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${9} or ${minute} == ${19} or ${minute} == ${29} or ${minute} == ${39} or ${minute} == ${49} or ${minute} == ${59}
        Sleep    5
    END
    Execute Sequence
    ${aggreInfo}    Get Aggregation Info Cluster    period=700s    measInterval=AGGR_150_180_CYCLE
    login
    ${allowedUncertainty}    Get Measurand Uncertainty    measurand=VOLTAGE_VA    uNom=${priNomVoltage}
    ${measurands}    Create List    PQ_VA_RMS    PQ_VB_RMS    PQ_VC_RMS
    ${measuredValues}    Get Measurands    PQ_VA_RMS    PQ_VB_RMS    PQ_VC_RMS
    ${expectedValues}    Create List    ${28.51}    ${28.51}    ${28.51}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_3P3W}    Create List    PQ_VAB_RMS    PQ_VBC_RMS    PQ_VCA_RMS
    ${measuredValues_3P3W}    Get Measurands    PQ_VAB_RMS    PQ_VBC_RMS    PQ_VCA_RMS
    ${expectedValues_3P3W}    Create List    ${49.38}    ${49.38}    ${49.38}
    ${allowedUncertainties_3P3W}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_3P4WB}    Create List    PQ_VA_RMS
    ${measuredValues_3P4WB}    Get Measurands    PQ_VA_RMS
    ${expectedValues_3P4WB}    Create List    ${28.51}
    ${allowedUncertainties_3P4WB}    Create List    ${allowedUncertainty}
    Run Keyword And Continue On Failure    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Validate Aggregation Interval Num    10m    AGGR_150_180_CYCLE
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_UNBALANCED'    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}
    ...    ELSE IF    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_3P4WB}    ${measuredValues_3P4WB}    ${expectedValues_3P4WB}    ${allowedUncertainties_3P4WB}
    ...    ELSE IF    '${networkType}' == 'SINGLE_PHASE'    Validate Measurands    ${measurands_3P4WB}    ${measuredValues_3P4WB}    ${expectedValues_3P4WB}    ${allowedUncertainties_3P4WB}
    ...    ELSE    Validate Measurands    ${measurands_3P3W}    ${measuredValues_3P3W}    ${expectedValues_3P3W}    ${allowedUncertainties_3P3W}
    Close Signal Device Connection

Run VoltageAggregation.A2.6.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Get Iec62586 Influence Quantities    FREQUENCY    S2
    ${outputVoltageP1}    Get Iec62586 Test Point    measurand=VOLTAGE_VA    testPoint=P1    uNom=${ReferenceVoltage}
    ${outputVoltageP3}    Get Iec62586 Test Point    measurand=VOLTAGE_VA    testPoint=P3    uNom=${ReferenceVoltage}
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Open Signal Device Connection    OMICRON    ${OmicronSerial}
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M10    fileGenInterval=H2
    Activate Configuration
    Set Simple Output    ${outputFrequency}    57.7    1
    Activate Output
    Start Sequence
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP1}    ub=${outputVoltageP1}    uc=${outputVoltageP1}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP1}    ub_t0=${outputVoltageP1}    uc_t0=${outputVoltageP1}    ua_t1=${outputVoltageP3}    ub_t1=${outputVoltageP3}    uc_t1=${outputVoltageP3}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP3}    ub=${outputVoltageP3}    uc=${outputVoltageP3}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP3}    ub_t0=${outputVoltageP3}    uc_t0=${outputVoltageP3}    ua_t1=${outputVoltageP1}    ub_t1=${outputVoltageP1}    uc_t1=${outputVoltageP1}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP1}    ub=${outputVoltageP1}    uc=${outputVoltageP1}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP1}    ub_t0=${outputVoltageP1}    uc_t0=${outputVoltageP1}    ua_t1=${outputVoltageP3}    ub_t1=${outputVoltageP3}    uc_t1=${outputVoltageP3}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP3}    ub=${outputVoltageP3}    uc=${outputVoltageP3}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP3}    ub_t0=${outputVoltageP3}    uc_t0=${outputVoltageP3}    ua_t1=${outputVoltageP1}    ub_t1=${outputVoltageP1}    uc_t1=${outputVoltageP1}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP1}    ub=${outputVoltageP1}    uc=${outputVoltageP1}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP1}    ub_t0=${outputVoltageP1}    uc_t0=${outputVoltageP1}    ua_t1=${outputVoltageP3}    ub_t1=${outputVoltageP3}    uc_t1=${outputVoltageP3}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP3}    ub=${outputVoltageP3}    uc=${outputVoltageP3}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP3}    ub_t0=${outputVoltageP3}    uc_t0=${outputVoltageP3}    ua_t1=${outputVoltageP1}    ub_t1=${outputVoltageP1}    uc_t1=${outputVoltageP1}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP1}    ub=${outputVoltageP1}    uc=${outputVoltageP1}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP1}    ub_t0=${outputVoltageP1}    uc_t0=${outputVoltageP1}    ua_t1=${outputVoltageP3}    ub_t1=${outputVoltageP3}    uc_t1=${outputVoltageP3}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP3}    ub=${outputVoltageP3}    uc=${outputVoltageP3}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP3}    ub_t0=${outputVoltageP3}    uc_t0=${outputVoltageP3}    ua_t1=${outputVoltageP1}    ub_t1=${outputVoltageP1}    uc_t1=${outputVoltageP1}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP1}    ub=${outputVoltageP1}    uc=${outputVoltageP1}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP1}    ub_t0=${outputVoltageP1}    uc_t0=${outputVoltageP1}    ua_t1=${outputVoltageP3}    ub_t1=${outputVoltageP3}    uc_t1=${outputVoltageP3}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP3}    ub=${outputVoltageP3}    uc=${outputVoltageP3}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP3}    ub_t0=${outputVoltageP3}    uc_t0=${outputVoltageP3}    ua_t1=${outputVoltageP1}    ub_t1=${outputVoltageP1}    uc_t1=${outputVoltageP1}
    Activate Output
    Set Voltage Output    frequency=${outputFrequency}    ua=${outputVoltageP1}    ub=${outputVoltageP1}    uc=${outputVoltageP1}
    Set Voltage Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ua_t0=${outputVoltageP1}    ub_t0=${outputVoltageP1}    uc_t0=${outputVoltageP1}    ua_t1=${outputVoltageP3}    ub_t1=${outputVoltageP3}    uc_t1=${outputVoltageP3}
    Activate Output
    End Sequence
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${9} or ${minute} == ${19} or ${minute} == ${29} or ${minute} == ${39} or ${minute} == ${49} or ${minute} == ${59}
        Sleep    5
    END
    Execute Sequence
    ${aggreInfo}    Run Keyword If    '${DeviceType}' == 'Q200' or '${DeviceType}' == 'Q100'    Get Aggregation Info Cluster    period=700s    measInterval=BASE_10_12_CYCLE
    ...    ELSE    Pause    680    wait avg value generated
    login
    ${allowedUncertainty}    Get Measurand Uncertainty    measurand=VOLTAGE_VA    uNom=${priNomVoltage}
    ${measurands}    Create List    PQ_VA_RMS    PQ_VB_RMS    PQ_VC_RMS
    ${measuredValues}    Get Measurands    PQ_VA_RMS    PQ_VB_RMS    PQ_VC_RMS
    ${expectedValues}    Run Keyword If    '${DeviceType}' == 'Q100' or '${DeviceType}' == 'Q200'    Create List    ${28.51}    ${28.51}    ${28.51}
    ...    ELSE    Create List    ${27.24}    ${27.24}    ${27.24}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_3P3W}    Create List    PQ_VAB_RMS    PQ_VBC_RMS    PQ_VCA_RMS
    ${measuredValues_3P3W}    Get Measurands    PQ_VAB_RMS    PQ_VBC_RMS    PQ_VCA_RMS
    ${expectedValues_3P3W}    Run Keyword If    '${DeviceType}' == 'Q100' or '${DeviceType}' == 'Q200'    Create List    ${49.38}    ${49.38}    ${49.38}
    ...    ELSE    Create List    ${47.18}    ${47.18}    ${47.18}
    ${allowedUncertainties_3P3W}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_3P4WB}    Create List    PQ_VA_RMS
    ${measuredValues_3P4WB}    Get Measurands    PQ_VA_RMS
    ${expectedValues_3P4WB}    Run Keyword If    '${DeviceType}' == 'Q100' or '${DeviceType}' == 'Q200'    Create List    ${28.51}
    ...    ELSE    Create List    ${27.24}
    ${allowedUncertainties_3P4WB}    Create List    ${allowedUncertainty}
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_UNBALANCED'    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}
    ...    ELSE IF    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_3P4WB}    ${measuredValues_3P4WB}    ${expectedValues_3P4WB}    ${allowedUncertainties_3P4WB}
    ...    ELSE IF    '${networkType}' == 'SINGLE_PHASE'    Validate Measurands    ${measurands_3P4WB}    ${measuredValues_3P4WB}    ${expectedValues_3P4WB}    ${allowedUncertainties_3P4WB}
    ...    ELSE    Validate Measurands    ${measurands_3P3W}    ${measuredValues_3P3W}    ${expectedValues_3P3W}    ${allowedUncertainties_3P3W}
    Run Keyword And Continue On Failure    Run Keyword If    '${DeviceType}' == 'Q100' or '${DeviceType}' == 'Q200'    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Close Signal Device Connection

Run VoltageHarmonicAggregation.A6.4.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    49.99    59.99
    ${expectedHarmonics}    Get Iec62586 Test Point    measurand=H_VA_1    testPoint=P2
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Open Signal Device Connection    OMICRON    ${OmicronSerial}
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Activate Configuration
    Set Harmonic Voltage Output    ${outputFrequency}    0    -120    120    ua=${ReferenceVoltage}    ub=${ReferenceVoltage}    uc=${ReferenceVoltage}    h_a=${expectedHarmonics}    h_b=${expectedHarmonics}    h_c=${expectedHarmonics}
    Activate Output
    Pause    10    Wait for the signal to output stably
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${1} or ${minute} == ${11} or ${minute} == ${21} or ${minute} == ${31} or ${minute} == ${41} or ${minute} == ${51}
        Sleep    5
    END
    ${aggreInfo}    Get Aggregation Info Cluster    period=700s    measInterval=BASE_10_12_CYCLE
    login
    Run Keyword And Continue On Failure    Validate Aggregation Time Tags    BASE_10_12_CYCLE    ${aggreInfo[0]}    allowedErrCount=${1}
    Run Keyword And Continue On Failure    Validate Aggregation Seq Num    ${aggreInfo[1]}
    Run Keyword And Continue On Failure    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Validate Aggregation Interval Num    10m    BASE_10_12_CYCLE
    Close Signal Device Connection

Run VoltageHarmonicAggregation.A6.5.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    50.125    60.15
    ${sequenceFileName}    Set Variable If    '${DeviceFrequency}' == 'F50'    A6.5.1_10min_aggre_50hz    A6.5.1_10min_aggre_60hz
    ${expectedHarmonics}    Get Iec62586 Test Point    measurand=H_VA_1    testPoint=P2
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=AGGR_150_180_CYCLE
    Run Keyword If    '${DeviceType}' == 'Q200'    Set ModbusTcp Configuration    voltageHarmonicsUnit=VOLTAGE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M10    fileGenInterval=H2
    Activate Configuration
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${9} or ${minute} == ${19} or ${minute} == ${29} or ${minute} == ${39} or ${minute} == ${49} or ${minute} == ${59}
        Sleep    5
    END
    RunOmicronRmpSequence    IEC62586Aggregation    ${sequenceFileName}    rmp
    ${aggreInfo}    Get Aggregation Info Cluster    period=700s    measInterval=AGGR_150_180_CYCLE
    login
    ${expectedHarmonic}    Evaluate    ${expectedHarmonics[0][1]}*${priNomVoltage}
    ${allowedUncertainty}    Get Measurand Uncertainty    measurand=H_VA_1    uNom=${priNomVoltage}    uMeas=${expectedHarmonic}
    ${measurands}    Create List    H_VA_3_RMS    H_VB_3_RMS    H_VC_3_RMS
    ${measuredValues}    Get Measurands    H_VA_3_RMS    H_VB_3_RMS    H_VC_3_RMS
    ${expectedValues}    Create List    ${3.33}    ${3.33}    ${3.33}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_3P3W}    Run Keyword If    '${DeviceType}'=='Q200'    Create List    H_VAB_3_RMS    H_VBC_3_RMS    H_VCA_3_RMS
    ...    ELSE    Create List    H_VA_3_RMS    H_VB_3_RMS    H_VC_3_RMS
    ${measuredValues_3P3W}    Run Keyword If    '${DeviceType}'=='Q200'    Get Measurands    H_VAB_3_RMS    H_VBC_3_RMS    H_VCA_3_RMS
    ...    ELSE    Get Measurands    H_VA_3_RMS    H_VB_3_RMS    H_VC_3_RMS
    ${expectedValues_3P3W}    Create List    ${5.76}    ${5.76}    ${5.76}
    ${allowedUncertainties_3P3W}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_3P4WB}    Create List    H_VA_3_RMS
    ${measuredValues_3P4WB}    Get Measurands    H_VA_3_RMS
    ${expectedValues_3P4WB}    Create List    ${3.33}
    ${allowedUncertainties_3P4WB}    Create List    ${allowedUncertainty}
    Run Keyword And Continue On Failure    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Validate Aggregation Interval Num    10m    AGGR_150_180_CYCLE
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_UNBALANCED'    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}
    ...    ELSE IF    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_3P4WB}    ${measuredValues_3P4WB}    ${expectedValues_3P4WB}    ${allowedUncertainties_3P4WB}
    ...    ELSE IF    '${networkType}' == 'SINGLE_PHASE'    Validate Measurands    ${measurands_3P4WB}    ${measuredValues_3P4WB}    ${expectedValues_3P4WB}    ${allowedUncertainties_3P4WB}
    ...    ELSE    Validate Measurands    ${measurands_3P3W}    ${measuredValues_3P3W}    ${expectedValues_3P3W}    ${allowedUncertainties_3P3W}

Run VoltageHarmonicAggregation.A6.6.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    49.99    59.99
    ${sequenceFileName}    Set Variable If    '${DeviceFrequency}' == 'F50'    A6.6.1_10min_aggre_50hz    A6.6.1_10min_aggre_60hz
    ${expectedHarmonics}    Get Iec62586 Test Point    measurand=H_VA_1    testPoint=P2
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M10    fileGenInterval=H2
    Activate Configuration
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${9} or ${minute} == ${19} or ${minute} == ${29} or ${minute} == ${39} or ${minute} == ${49} or ${minute} == ${59}
        Sleep    5
    END
    RunOmicronRmpSequence    IEC62586Aggregation    ${sequenceFileName}    rmp
    ${aggreInfo}    Run Keyword If    '${DeviceType}' == 'Q200' or '${DeviceType}' == 'Q100'    Get Aggregation Info Cluster    period=700s    measInterval=BASE_10_12_CYCLE
    ...    ELSE    Pause    680    wait avg value generated
    login
    ${expectedHarmonic}    Evaluate    ${expectedHarmonics[0][1]}*${priNomVoltage}
    ${allowedUncertainty}    Get Measurand Uncertainty    measurand=H_VA_1    uNom=${priNomVoltage}    uMeas=${expectedHarmonic}
    ${measurands}    Create List    H_VA_3_RMS    H_VB_3_RMS    H_VC_3_RMS
    ${measuredValues}    Get Measurands    H_VA_3_RMS    H_VB_3_RMS    H_VC_3_RMS
    ${expectedValues}    Create List    ${3.33}    ${3.33}    ${3.33}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_3P3W}    Run Keyword If    '${DeviceType}'=='Q200'    Create List    H_VAB_3_RMS    H_VBC_3_RMS    H_VCA_3_RMS
    ...    ELSE    Create List    H_VA_3_RMS    H_VB_3_RMS    H_VC_3_RMS
    ${measuredValues_3P3W}    Run Keyword If    '${DeviceType}'=='Q200'    Get Measurands    H_VAB_3_RMS    H_VBC_3_RMS    H_VCA_3_RMS
    ...    ELSE    Get Measurands    H_VA_3_RMS    H_VB_3_RMS    H_VC_3_RMS
    ${expectedValues_3P3W}    Create List    ${5.76}    ${5.76}    ${5.76}
    ${allowedUncertainties_3P3W}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_3P4WB}    Create List    H_VA_3_RMS
    ${measuredValues_3P4WB}    Get Measurands    H_VA_3_RMS
    ${expectedValues_3P4WB}    Create List    ${3.33}
    ${allowedUncertainties_3P4WB}    Create List    ${allowedUncertainty}
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_UNBALANCED'    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}
    ...    ELSE IF    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_3P4WB}    ${measuredValues_3P4WB}    ${expectedValues_3P4WB}    ${allowedUncertainties_3P4WB}
    ...    ELSE IF    '${networkType}' == 'SINGLE_PHASE'    Validate Measurands    ${measurands_3P4WB}    ${measuredValues_3P4WB}    ${expectedValues_3P4WB}    ${allowedUncertainties_3P4WB}
    ...    ELSE    Validate Measurands    ${measurands_3P3W}    ${measuredValues_3P3W}    ${expectedValues_3P3W}    ${allowedUncertainties_3P3W}
    Run Keyword And Continue On Failure    Run Keyword If    '${DeviceType}' == 'Q100' or '${DeviceType}' == 'Q200'    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Run Keyword If    '${DeviceType}' == 'Q100' or '${DeviceType}' == 'Q200'    Validate Aggregation Interval Num    10m    BASE_10_12_CYCLE

Run VoltageInterharmonicAggregation.A7.4.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    49.99    59.99
    ${expectedInterHarmonics}    Get Iec62586 Test Point    measurand=HI_VA_1    testPoint=P2
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Open Signal Device Connection    OMICRON    ${OmicronSerial}
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Run Keyword If    '${DeviceType}' == 'Q200'    Set ModbusTcp Configuration    voltageHarmonicsUnit=VOLTAGE
    Activate Configuration
    Set Interharmonic Voltage Output    ${outputFrequency}    0    -120    120    ua=${ReferenceVoltage}    ub=${ReferenceVoltage}    uc=${ReferenceVoltage}    inter_h_a=${expectedInterHarmonics}    inter_h_b=${expectedInterHarmonics}    inter_h_c=${expectedInterHarmonics}
    Activate Output
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${1} or ${minute} == ${11} or ${minute} == ${21} or ${minute} == ${31} or ${minute} == ${41} or ${minute} == ${51}
        Sleep    5
    END
    ${aggreInfo}    Get Aggregation Info Cluster    period=700s    measInterval=BASE_10_12_CYCLE
    login
    Run Keyword And Continue On Failure    Validate Aggregation Time Tags    BASE_10_12_CYCLE    ${aggreInfo[0]}    allowedErrCount=${1}
    Run Keyword And Continue On Failure    Validate Aggregation Seq Num    ${aggreInfo[1]}
    Run Keyword And Continue On Failure    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Validate Aggregation Interval Num    10m    BASE_10_12_CYCLE
    Close Signal Device Connection

Run VoltageInterharmonicAggregation.A7.5.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    50.125    60.15
    ${sequenceFileName}    Set Variable If    '${DeviceFrequency}' == 'F50'    A7.5.1_10min_aggre_50hz    A7.5.1_10min_aggre_60hz
    ${expectedInterHarmonics}    Get Iec62586 Test Point    measurand=HI_VA_1    testPoint=P2
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=AGGR_150_180_CYCLE
    Run Keyword If    '${DeviceType}' == 'Q200'    Set ModbusTcp Configuration    voltageHarmonicsUnit=VOLTAGE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M10    fileGenInterval=H2
    Activate Configuration
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${9} or ${minute} == ${19} or ${minute} == ${29} or ${minute} == ${39} or ${minute} == ${49} or ${minute} == ${59}
        Sleep    5
    END
    RunOmicronRmpSequence    IEC62586Aggregation    ${sequenceFileName}    rmp
    ${aggreInfo}    Get Aggregation Info Cluster    period=700s    measInterval=AGGR_150_180_CYCLE
    login
    ${expectedInterHarmonic}    Evaluate    ${expectedInterHarmonics[0][1]}*${priNomVoltage}
    ${allowedUncertainty}    Get Measurand Uncertainty    measurand=HI_VA_1    uNom=${priNomVoltage}    uMeas=${expectedInterHarmonic}
    ${measurands}    Create List    HI_VA_7_RMS    HI_VB_7_RMS    HI_VC_7_RMS
    ${measuredValues}    Get Measurands    HI_VA_7_RMS    HI_VB_7_RMS    HI_VC_7_RMS
    ${expectedValues}    Create List    ${3.33}    ${3.33}    ${3.33}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_3P3W}    Run Keyword If    '${DeviceType}'=='Q200'    Create List    HI_VAB_7_RMS    HI_VBC_7_RMS    HI_VCA_7_RMS
    ...    ELSE    Create List    HI_VA_7_RMS    HI_VB_7_RMS    HI_VC_7_RMS
    ${measuredValues_3P3W}    Run Keyword If    '${DeviceType}'=='Q200'    Get Measurands    HI_VAB_7_RMS    HI_VBC_7_RMS    HI_VCA_7_RMS
    ...    ELSE    Get Measurands    HI_VA_7_RMS    HI_VB_7_RMS    HI_VC_7_RMS
    ${expectedValues_3P3W}    Create List    ${5.76}    ${5.76}    ${5.76}
    ${allowedUncertainties_3P3W}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_3P4WB}    Create List    HI_VA_7_RMS
    ${measuredValues_3P4WB}    Get Measurands    HI_VA_7_RMS
    ${expectedValues_3P4WB}    Create List    ${3.33}
    ${allowedUncertainties_3P4WB}    Create List    ${allowedUncertainty}
    Run Keyword And Continue On Failure    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Validate Aggregation Interval Num    10m    AGGR_150_180_CYCLE
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_UNBALANCED'    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}
    ...    ELSE IF    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_3P4WB}    ${measuredValues_3P4WB}    ${expectedValues_3P4WB}    ${allowedUncertainties_3P4WB}
    ...    ELSE IF    '${networkType}' == 'SINGLE_PHASE'    Validate Measurands    ${measurands_3P4WB}    ${measuredValues_3P4WB}    ${expectedValues_3P4WB}    ${allowedUncertainties_3P4WB}
    ...    ELSE    Validate Measurands    ${measurands_3P3W}    ${measuredValues_3P3W}    ${expectedValues_3P3W}    ${allowedUncertainties_3P3W}

Run VoltageInterharmonicAggregation.A7.6.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    49.99    59.99
    ${sequenceFileName}    Set Variable If    '${DeviceFrequency}' == 'F50'    A7.6.1_10min_aggre_50hz    A7.6.1_10min_aggre_60hz
    ${expectedInterHarmonics}    Get Iec62586 Test Point    measurand=HI_VA_1    testPoint=P2
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Run Keyword If    '${DeviceType}' == 'Q200'    Set ModbusTcp Configuration    voltageHarmonicsUnit=VOLTAGE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M10    fileGenInterval=H2
    Activate Configuration
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${9} or ${minute} == ${19} or ${minute} == ${29} or ${minute} == ${39} or ${minute} == ${49} or ${minute} == ${59}
        Sleep    5
    END
    RunOmicronRmpSequence    IEC62586Aggregation    ${sequenceFileName}    rmp
    ${aggreInfo}    Get Aggregation Info Cluster    period=700s    measInterval=BASE_10_12_CYCLE
    login
    ${expectedInterHarmonic}    Evaluate    ${expectedInterHarmonics[0][1]}*${priNomVoltage}
    ${allowedUncertainty}    Get Measurand Uncertainty    measurand=HI_VA_1    uNom=${priNomVoltage}    uMeas=${expectedInterHarmonic}
    ${measurands}    Create List    HI_VA_7_RMS    HI_VB_7_RMS    HI_VC_7_RMS
    ${measuredValues}    Get Measurands    HI_VA_7_RMS    HI_VB_7_RMS    HI_VC_7_RMS
    ${expectedValues}    Create List    ${3.33}    ${3.33}    ${3.33}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_3P3W}    Run Keyword If    '${DeviceType}'=='Q200'    Create List    HI_VAB_7_RMS    HI_VBC_7_RMS    HI_VCA_7_RMS
    ...    ELSE    Create List    HI_VA_7_RMS    HI_VB_7_RMS    HI_VC_7_RMS
    ${measuredValues_3P3W}    Run Keyword If    '${DeviceType}'=='Q200'    Get Measurands    HI_VAB_7_RMS    HI_VBC_7_RMS    HI_VCA_7_RMS
    ...    ELSE    Get Measurands    HI_VA_7_RMS    HI_VB_7_RMS    HI_VC_7_RMS
    ${expectedValues_3P3W}    Create List    ${5.76}    ${5.76}    ${5.76}
    ${allowedUncertainties_3P3W}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_3P4WB}    Create List    HI_VA_7_RMS
    ${measuredValues_3P4WB}    Get Measurands    HI_VA_7_RMS
    ${expectedValues_3P4WB}    Create List    ${3.33}
    ${allowedUncertainties_3P4WB}    Create List    ${allowedUncertainty}
    Run Keyword And Continue On Failure    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Validate Aggregation Interval Num    10m    BASE_10_12_CYCLE
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_UNBALANCED'    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}
    ...    ELSE IF    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_3P4WB}    ${measuredValues_3P4WB}    ${expectedValues_3P4WB}    ${allowedUncertainties_3P4WB}
    ...    ELSE IF    '${networkType}' == 'SINGLE_PHASE'    Validate Measurands    ${measurands_3P4WB}    ${measuredValues_3P4WB}    ${expectedValues_3P4WB}    ${allowedUncertainties_3P4WB}
    ...    ELSE    Validate Measurands    ${measurands_3P3W}    ${measuredValues_3P3W}    ${expectedValues_3P3W}    ${allowedUncertainties_3P3W}

Run CurrentAggregation.A14.4.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    49.99    59.99
    ${outputCurrentP3}    Get Iec62586 Test Point    measurand=CURRENT_IA    testPoint=P3    iNom=${ReferenceCurrent}
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Open Signal Device Connection    OMICRON    ${OmicronSerial}
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M10    fileGenInterval=H2
    Activate Configuration
    Set Voltage Output    ${outputFrequency}    0    -120    120    ${ReferenceVoltage}    ${ReferenceVoltage}    ${ReferenceVoltage}
    Set Current Output    ${outputFrequency}    0    -120    120    ${outputCurrentP3}    ${outputCurrentP3}    ${outputCurrentP3}
    Activate Output
    Pause    10    Wait for the signal to output stably
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${1} or ${minute} == ${11} or ${minute} == ${21} or ${minute} == ${31} or ${minute} == ${41} or ${minute} == ${51}
        Sleep    5
    END
    ${aggreInfo}    Get Aggregation Info Cluster    period=700s    measInterval=BASE_10_12_CYCLE
    login
    Run Keyword And Continue On Failure    Validate Aggregation Time Tags    BASE_10_12_CYCLE    ${aggreInfo[0]}    allowedErrCount=${1}
    Run Keyword And Continue On Failure    Validate Aggregation Seq Num    ${aggreInfo[1]}
    Run Keyword And Continue On Failure    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Validate Aggregation Interval Num    10m    BASE_10_12_CYCLE
    Close Signal Device Connection

Run CurrentAggregation.A14.5.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    50.125    60.15
    ${outputCurrentP1}    Get Iec62586 Test Point    measurand=CURRENT_IA    testPoint=P1    iNom=${ReferenceCurrent}
    ${outputCurrentP3}    Get Iec62586 Test Point    measurand=CURRENT_IA    testPoint=P3    iNom=${ReferenceCurrent}
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Open Signal Device Connection    OMICRON    ${OmicronSerial}
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=AGGR_150_180_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M10    fileGenInterval=H2
    Activate Configuration
    Set Simple Output    ${outputFrequency}    ${ReferenceVoltage}    ${ReferenceCurrent}
    Activate Output
    Start Sequence
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP1}    ib=${outputCurrentP1}    ic=${outputCurrentP1}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP1}    ib_t0=${outputCurrentP1}    ic_t0=${outputCurrentP1}    ia_t1=${outputCurrentP3}    ib_t1=${outputCurrentP3}    ic_t1=${outputCurrentP3}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP3}    ib=${outputCurrentP3}    ic=${outputCurrentP3}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP3}    ib_t0=${outputCurrentP3}    ic_t0=${outputCurrentP3}    ia_t1=${outputCurrentP1}    ib_t1=${outputCurrentP1}    ic_t1=${outputCurrentP1}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP1}    ib=${outputCurrentP1}    ic=${outputCurrentP1}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP1}    ib_t0=${outputCurrentP1}    ic_t0=${outputCurrentP1}    ia_t1=${outputCurrentP3}    ib_t1=${outputCurrentP3}    ic_t1=${outputCurrentP3}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP3}    ib=${outputCurrentP3}    ic=${outputCurrentP3}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP3}    ib_t0=${outputCurrentP3}    ic_t0=${outputCurrentP3}    ia_t1=${outputCurrentP1}    ib_t1=${outputCurrentP1}    ic_t1=${outputCurrentP1}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP1}    ib=${outputCurrentP1}    ic=${outputCurrentP1}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP1}    ib_t0=${outputCurrentP1}    ic_t0=${outputCurrentP1}    ia_t1=${outputCurrentP3}    ib_t1=${outputCurrentP3}    ic_t1=${outputCurrentP3}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP3}    ib=${outputCurrentP3}    ic=${outputCurrentP3}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP3}    ib_t0=${outputCurrentP3}    ic_t0=${outputCurrentP3}    ia_t1=${outputCurrentP1}    ib_t1=${outputCurrentP1}    ic_t1=${outputCurrentP1}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP1}    ib=${outputCurrentP1}    ic=${outputCurrentP1}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP1}    ib_t0=${outputCurrentP1}    ic_t0=${outputCurrentP1}    ia_t1=${outputCurrentP3}    ib_t1=${outputCurrentP3}    ic_t1=${outputCurrentP3}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP3}    ib=${outputCurrentP3}    ic=${outputCurrentP3}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP3}    ib_t0=${outputCurrentP3}    ic_t0=${outputCurrentP3}    ia_t1=${outputCurrentP1}    ib_t1=${outputCurrentP1}    ic_t1=${outputCurrentP1}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP1}    ib=${outputCurrentP1}    ic=${outputCurrentP1}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP1}    ib_t0=${outputCurrentP1}    ic_t0=${outputCurrentP1}    ia_t1=${outputCurrentP3}    ib_t1=${outputCurrentP3}    ic_t1=${outputCurrentP3}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP3}    ib=${outputCurrentP3}    ic=${outputCurrentP3}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP3}    ib_t0=${outputCurrentP3}    ic_t0=${outputCurrentP3}    ia_t1=${outputCurrentP1}    ib_t1=${outputCurrentP1}    ic_t1=${outputCurrentP1}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP1}    ib=${outputCurrentP1}    ic=${outputCurrentP1}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP1}    ib_t0=${outputCurrentP1}    ic_t0=${outputCurrentP1}    ia_t1=${outputCurrentP3}    ib_t1=${outputCurrentP3}    ic_t1=${outputCurrentP3}
    Activate Output
    End Sequence
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${9} or ${minute} == ${19} or ${minute} == ${29} or ${minute} == ${39} or ${minute} == ${49} or ${minute} == ${59}
        Sleep    5
    END
    Execute Sequence
    ${aggreInfo}    Get Aggregation Info Cluster    period=700s    measInterval=AGGR_150_180_CYCLE
    login
    ${allowedUncertainty}    Get Measurand Uncertainty    measurand=CURRENT_IA    iNom=${ReferenceCurrent}
    ${measurands}    Create List    PQ_IA_RMS    PQ_IB_RMS    PQ_IC_RMS
    ${measuredValues}    Get Measurands    PQ_IA_RMS    PQ_IB_RMS    PQ_IC_RMS
    ${expectedValues}    Create List    ${0.494}    ${0.494}    ${0.494}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_Balance}    Create List    PQ_IA_RMS
    ${measuredValues_Balance}    Get Measurands    PQ_IA_RMS
    ${expectedValues_Balance}    Create List    ${0.494}
    ${allowedUncertainties_Balance}    Create List    ${allowedUncertainty}
    Run Keyword And Continue On Failure    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Validate Aggregation Interval Num    10m    AGGR_150_180_CYCLE
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE IF    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE IF    '${networkType}' == 'SINGLE_PHASE'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}
    Close Signal Device Connection

Run CurrentAggregation.A14.6.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Get Iec62586 Influence Quantities    FREQUENCY    S2
    ${outputCurrentP1}    Get Iec62586 Test Point    measurand=CURRENT_IA    testPoint=P1    iNom=${ReferenceCurrent}
    ${outputCurrentP3}    Get Iec62586 Test Point    measurand=CURRENT_IA    testPoint=P3    iNom=${ReferenceCurrent}
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Open Signal Device Connection    OMICRON    ${OmicronSerial}
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M10    fileGenInterval=H2
    Activate Configuration
    Set Simple Output    ${outputFrequency}    ${ReferenceVoltage}    ${ReferenceCurrent}
    Activate Output
    Start Sequence
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP1}    ib=${outputCurrentP1}    ic=${outputCurrentP1}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP1}    ib_t0=${outputCurrentP1}    ic_t0=${outputCurrentP1}    ia_t1=${outputCurrentP3}    ib_t1=${outputCurrentP3}    ic_t1=${outputCurrentP3}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP3}    ib=${outputCurrentP3}    ic=${outputCurrentP3}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP3}    ib_t0=${outputCurrentP3}    ic_t0=${outputCurrentP3}    ia_t1=${outputCurrentP1}    ib_t1=${outputCurrentP1}    ic_t1=${outputCurrentP1}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP1}    ib=${outputCurrentP1}    ic=${outputCurrentP1}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP1}    ib_t0=${outputCurrentP1}    ic_t0=${outputCurrentP1}    ia_t1=${outputCurrentP3}    ib_t1=${outputCurrentP3}    ic_t1=${outputCurrentP3}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP3}    ib=${outputCurrentP3}    ic=${outputCurrentP3}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP3}    ib_t0=${outputCurrentP3}    ic_t0=${outputCurrentP3}    ia_t1=${outputCurrentP1}    ib_t1=${outputCurrentP1}    ic_t1=${outputCurrentP1}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP1}    ib=${outputCurrentP1}    ic=${outputCurrentP1}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP1}    ib_t0=${outputCurrentP1}    ic_t0=${outputCurrentP1}    ia_t1=${outputCurrentP3}    ib_t1=${outputCurrentP3}    ic_t1=${outputCurrentP3}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP3}    ib=${outputCurrentP3}    ic=${outputCurrentP3}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP3}    ib_t0=${outputCurrentP3}    ic_t0=${outputCurrentP3}    ia_t1=${outputCurrentP1}    ib_t1=${outputCurrentP1}    ic_t1=${outputCurrentP1}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP1}    ib=${outputCurrentP1}    ic=${outputCurrentP1}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP1}    ib_t0=${outputCurrentP1}    ic_t0=${outputCurrentP1}    ia_t1=${outputCurrentP3}    ib_t1=${outputCurrentP3}    ic_t1=${outputCurrentP3}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP3}    ib=${outputCurrentP3}    ic=${outputCurrentP3}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP3}    ib_t0=${outputCurrentP3}    ic_t0=${outputCurrentP3}    ia_t1=${outputCurrentP1}    ib_t1=${outputCurrentP1}    ic_t1=${outputCurrentP1}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP1}    ib=${outputCurrentP1}    ic=${outputCurrentP1}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP1}    ib_t0=${outputCurrentP1}    ic_t0=${outputCurrentP1}    ia_t1=${outputCurrentP3}    ib_t1=${outputCurrentP3}    ic_t1=${outputCurrentP3}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP3}    ib=${outputCurrentP3}    ic=${outputCurrentP3}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP3}    ib_t0=${outputCurrentP3}    ic_t0=${outputCurrentP3}    ia_t1=${outputCurrentP1}    ib_t1=${outputCurrentP1}    ic_t1=${outputCurrentP1}
    Activate Output
    Set Current Output    frequency=${outputFrequency}    ia=${outputCurrentP1}    ib=${outputCurrentP1}    ic=${outputCurrentP1}
    Set Current Magnitude Ramp    duration=${60}    resolution=${100}    frequency=${outputFrequency}    ia_t0=${outputCurrentP1}    ib_t0=${outputCurrentP1}    ic_t0=${outputCurrentP1}    ia_t1=${outputCurrentP3}    ib_t1=${outputCurrentP3}    ic_t1=${outputCurrentP3}
    Activate Output
    End Sequence
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${9} or ${minute} == ${19} or ${minute} == ${29} or ${minute} == ${39} or ${minute} == ${49} or ${minute} == ${59}
        Sleep    5
    END
    Execute Sequence
    ${aggreInfo}    Run Keyword If    '${DeviceType}' == 'Q200' or '${DeviceType}' == 'Q100'    Get Aggregation Info Cluster    period=700s    measInterval=BASE_10_12_CYCLE
    ...    ELSE    Pause    680    wait avg value generated
    login
    ${allowedUncertainty}    Get Measurand Uncertainty    measurand=CURRENT_IA    iNom=${ReferenceCurrent}
    ${measurands}    Create List    PQ_IA_RMS    PQ_IB_RMS    PQ_IC_RMS
    ${measuredValues}    Get Measurands    PQ_IA_RMS    PQ_IB_RMS    PQ_IC_RMS
    ${expectedValues}    Create List    ${0.494}    ${0.494}    ${0.494}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_Balance}    Create List    PQ_IA_RMS
    ${measuredValues_Balance}    Get Measurands    PQ_IA_RMS
    ${expectedValues_Balance}    Create List    ${0.494}
    ${allowedUncertainties_Balance}    Create List    ${allowedUncertainty}
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE IF    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE IF    '${networkType}' == 'SINGLE_PHASE'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}
    Run Keyword And Continue On Failure    Run Keyword If    '${DeviceType}' == 'Q100' or '${DeviceType}' == 'Q200'    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Close Signal Device Connection

Run CurrentHarmonicAggregation.A15.4.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    49.99    59.99
    ${expectedHarmonics}    Get Iec62586 Test Point    measurand=H_IA_1    testPoint=P2
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Open Signal Device Connection    OMICRON    ${OmicronSerial}
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Activate Configuration
    Set Voltage Output    ${outputFrequency}    ua=${ReferenceVoltage}    ub=${ReferenceVoltage}    uc=${ReferenceVoltage}
    Set Harmonic current Output    ${outputFrequency}    0    -120    120    ia=${ReferenceCurrent}    ib=${ReferenceCurrent}    ic=${ReferenceCurrent}    h_a=${expectedHarmonics}    h_b=${expectedHarmonics}    h_c=${expectedHarmonics}
    Activate Output
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${1} or ${minute} == ${11} or ${minute} == ${21} or ${minute} == ${31} or ${minute} == ${41} or ${minute} == ${51}
        Sleep    5
    END
    ${aggreInfo}    Get Aggregation Info Cluster    period=700s    measInterval=BASE_10_12_CYCLE
    login
    Run Keyword And Continue On Failure    Validate Aggregation Time Tags    BASE_10_12_CYCLE    ${aggreInfo[0]}    allowedErrCount=${1}
    Run Keyword And Continue On Failure    Validate Aggregation Seq Num    ${aggreInfo[1]}
    Run Keyword And Continue On Failure    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Validate Aggregation Interval Num    10m    BASE_10_12_CYCLE
    Close Signal Device Connection

Run CurrentHarmonicAggregation.A15.5.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    50.125    60.15
    ${expectedHarmonics}    Get Iec62586 Test Point    measurand=H_IA_1    testPoint=P2
    ${sequenceFileName}    Set Variable If    '${DeviceFrequency}' == 'F50'    A15.5.1_10min_aggre_50hz    A15.5.1_10min_aggre_60hz
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=AGGR_150_180_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M10    fileGenInterval=H2
    Activate Configuration
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${9} or ${minute} == ${19} or ${minute} == ${29} or ${minute} == ${39} or ${minute} == ${49} or ${minute} == ${59}
        Sleep    5
    END
    RunOmicronRmpSequence    IEC62586Aggregation    ${sequenceFileName}    rmp
    ${aggreInfo}    Get Aggregation Info Cluster    period=700s    measInterval=AGGR_150_180_CYCLE
    login
    ${expectedHarmonic}    Evaluate    ${expectedHarmonics[0][1]}*${ReferenceCurrent}
    ${allowedUncertainty}    Get Measurand Uncertainty    measurand=H_IA_1    iNom=${ReferenceCurrent}    iMeas=${expectedHarmonic}
    ${measurands}    Create List    H_IA_3_RMS    H_IB_3_RMS    H_IC_3_RMS
    ${measuredValues}    Get Measurands    H_IA_3_RMS    H_IB_3_RMS    H_IC_3_RMS
    ${expectedValues}    Create List    ${0.0576}    ${0.0576}    ${0.0576}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_Balance}    Create List    H_IA_3_RMS
    ${measuredValues_Balance}    Get Measurands    H_IA_3_RMS
    ${expectedValues_Balance}    Create List    ${0.0576}
    ${allowedUncertainties_Balance}    Create List    ${allowedUncertainty}
    Run Keyword And Continue On Failure    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Validate Aggregation Interval Num    10m    AGGR_150_180_CYCLE
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE IF    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE IF    '${networkType}' == 'SINGLE_PHASE'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}

Run CurrentHarmonicAggregation.A15.6.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    49.99    59.99
    ${sequenceFileName}    Set Variable If    '${DeviceFrequency}' == 'F50'    A15.6.1_10min_aggre_50hz    A15.6.1_10min_aggre_60hz
    ${expectedHarmonics}    Get Iec62586 Test Point    measurand=H_IA_1    testPoint=P2
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M10    fileGenInterval=H2
    Activate Configuration
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${9} or ${minute} == ${19} or ${minute} == ${29} or ${minute} == ${39} or ${minute} == ${49} or ${minute} == ${59}
        Sleep    5
    END
    RunOmicronRmpSequence    IEC62586Aggregation    ${sequenceFileName}    rmp
    ${aggreInfo}    Run Keyword If    '${DeviceType}' == 'Q200' or '${DeviceType}' == 'Q100'    Get Aggregation Info Cluster    period=700s    measInterval=BASE_10_12_CYCLE
    ...    ELSE    Pause    680    wait avg value generated
    login
    ${expectedHarmonic}    Evaluate    ${expectedHarmonics[0][1]}*${ReferenceCurrent}
    ${allowedUncertainty}    Get Measurand Uncertainty    measurand=H_IA_1    iNom=${ReferenceCurrent}    iMeas=${expectedHarmonic}
    ${measurands}    Create List    H_IA_3_RMS    H_IB_3_RMS    H_IC_3_RMS
    ${measuredValues}    Get Measurands    H_IA_3_RMS    H_IB_3_RMS    H_IC_3_RMS
    ${expectedValues}    Create List    ${0.0576}    ${0.0576}    ${0.0576}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_Balance}    Create List    H_IA_3_RMS
    ${measuredValues_Balance}    Get Measurands    H_IA_3_RMS
    ${expectedValues_Balance}    Create List    ${0.0576}
    ${allowedUncertainties_Balance}    Create List    ${allowedUncertainty}
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE IF    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE IF    '${networkType}' == 'SINGLE_PHASE'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}
    Run Keyword And Continue On Failure    Run Keyword If    '${DeviceType}' == 'Q100' or '${DeviceType}' == 'Q200'    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Run Keyword If    '${DeviceType}' == 'Q100' or '${DeviceType}' == 'Q200'    Validate Aggregation Interval Num    10m    BASE_10_12_CYCLE

Run CurrentInterharmonicAggregation.A16.4.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    49.99    59.99
    ${expectedInterHarmonics}    Get Iec62586 Test Point    measurand=HI_IA_1    testPoint=P2
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Open Signal Device Connection    OMICRON    ${OmicronSerial}
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Activate Configuration
    Set Voltage Output    ${outputFrequency}    ua=${ReferenceVoltage}    ub=${ReferenceVoltage}    uc=${ReferenceVoltage}
    Set Interharmonic Current Output    ${outputFrequency}    0    -120    120    ia=${ReferenceCurrent}    ib=${ReferenceCurrent}    ic=${ReferenceCurrent}    inter_h_a=${expectedInterHarmonics}    inter_h_b=${expectedInterHarmonics}    inter_h_c=${expectedInterHarmonics}
    Activate Output
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${1} or ${minute} == ${11} or ${minute} == ${21} or ${minute} == ${31} or ${minute} == ${41} or ${minute} == ${51}
        Sleep    5
    END
    ${aggreInfo}    Get Aggregation Info Cluster    period=700s    measInterval=BASE_10_12_CYCLE
    login
    Run Keyword And Continue On Failure    Validate Aggregation Time Tags    BASE_10_12_CYCLE    ${aggreInfo[0]}    allowedErrCount=${1}
    Run Keyword And Continue On Failure    Validate Aggregation Seq Num    ${aggreInfo[1]}
    Run Keyword And Continue On Failure    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Validate Aggregation Interval Num    10m    BASE_10_12_CYCLE
    Close Signal Device Connection

Run CurrentInterharmonicAggregation.A16.5.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    50.125    60.15
    ${sequenceFileName}    Set Variable If    '${DeviceFrequency}' == 'F50'    A16.5.1_10min_aggre_50hz    A16.5.1_10min_aggre_60hz
    ${expectedInterHarmonics}    Get Iec62586 Test Point    measurand=HI_IA_1    testPoint=P2
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=AGGR_150_180_CYCLE
    Activate Configuration
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${9} or ${minute} == ${19} or ${minute} == ${29} or ${minute} == ${39} or ${minute} == ${49} or ${minute} == ${59}
        Sleep    5
    END
    RunOmicronRmpSequence    IEC62586Aggregation    ${sequenceFileName}    rmp
    ${aggreInfo}    Get Aggregation Info Cluster    period=700s    measInterval=AGGR_150_180_CYCLE
    login
    ${expectedInterHarmonic}    Evaluate    ${expectedInterHarmonics[0][1]}*${ReferenceCurrent}
    ${allowedUncertainty}    Get Measurand Uncertainty    measurand=HI_IA_1    iNom=${ReferenceVoltage}    iMeas=${expectedInterHarmonic}
    ${measurands}    Create List    HI_IA_7_RMS    HI_IB_7_RMS    HI_IC_7_RMS
    ${measuredValues}    Get Measurands    HI_IA_7_RMS    HI_IB_7_RMS    HI_IC_7_RMS
    ${expectedValues}    Create List    ${0.0576}    ${0.0576}    ${0.0576}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_Balance}    Create List    HI_IA_7_RMS
    ${measuredValues_Balance}    Get Measurands    HI_IA_7_RMS
    ${expectedValues_Balance}    Create List    ${0.0576}
    ${allowedUncertainties_Balance}    Create List    ${allowedUncertainty}
    Run Keyword And Continue On Failure    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Validate Aggregation Interval Num    10m    AGGR_150_180_CYCLE
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE IF    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE IF    '${networkType}' == 'SINGLE_PHASE'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}

Run CurrentInterharmonicAggregation.A16.6.1 Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    49.99    59.99
    ${sequenceFileName}    Set Variable If    '${DeviceFrequency}' == 'F50'    A16.6.1_10min_aggre_50hz    A16.6.1_10min_aggre_60hz
    ${expectedInterHarmonics}    Get Iec62586 Test Point    measurand=HI_IA_1    testPoint=P2
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M10    fileGenInterval=H2
    Activate Configuration
    FOR    ${n}    IN RANGE    120
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == ${9} or ${minute} == ${19} or ${minute} == ${29} or ${minute} == ${39} or ${minute} == ${49} or ${minute} == ${59}
        Sleep    5
    END
    RunOmicronRmpSequence    IEC62586Aggregation    ${sequenceFileName}    rmp
    ${aggreInfo}    Get Aggregation Info Cluster    period=700s    measInterval=BASE_10_12_CYCLE
    login
    ${expectedInterHarmonic}    Evaluate    ${expectedInterHarmonics[0][1]}*${ReferenceCurrent}
    ${allowedUncertainty}    Get Measurand Uncertainty    measurand=HI_IA_1    iNom=${ReferenceVoltage}    iMeas=${expectedInterHarmonic}
    ${measurands}    Create List    HI_IA_7_RMS    HI_IB_7_RMS    HI_IC_7_RMS
    ${measuredValues}    Get Measurands    HI_IA_7_RMS    HI_IB_7_RMS    HI_IC_7_RMS
    ${expectedValues}    Create List    ${0.0576}    ${0.0576}    ${0.0576}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_Balance}    Create List    HI_IA_7_RMS
    ${measuredValues_Balance}    Get Measurands    HI_IA_7_RMS
    ${expectedValues_Balance}    Create List    ${0.0576}
    ${allowedUncertainties_Balance}    Create List    ${allowedUncertainty}
    Run Keyword And Continue On Failure    Validate Aggregation Interval Num    10m    BASE_10_12_CYCLE
    Run Keyword And Continue On Failure    Validate Aggregation Syn Tick    ${aggreInfo[2]}
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE IF    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE IF    '${networkType}' == 'SINGLE_PHASE'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}

Run Aggregation Vn Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    50    60
    ${ReferenceVoltage}    Set Variable    100
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    networkType=${networkType}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M1    fileGenInterval=H2
    Activate Configuration
    Set Simple Output    ${outputFrequency}    100    1
    Activate Output
    Start Sequence
    Set Voltage Output    ${outputFrequency}    0    0    0    100    100    100
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    0    0    50    50    50
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    0    0    100    100    100
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    0    0    50    50    50
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    0    0    100    100    100
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    0    0    50    50    50
    Activate Output
    Wait By Time    seconds=${30}
    End Sequence
    Execute Sequence
    Pause    120    wait for execute sequence
    ${allowedUncertaintyStandard}    Get Measurand Uncertainty    measurand=VOLTAGE_VA    uNom=${priNomVoltage}
    ${allowedUncertainties}    Create List    ${allowedUncertaintyStandard}
    ${measurands}    Create List    PQ_VN_RMS
    ${measuredValues}    Get Measurands    PQ_VN_RMS
    ${expectedValues}    Run Keyword If    '${DeviceType}' == 'Q100'    Create List    ${79.0569}
    ...    ELSE    Create List    ${59.18}
    Run Keyword And Continue On Failure    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}

Run Aggregation In Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    50    60
    ${ReferenceCurrent}    Set Variable    5
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    networkType=${networkType}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M1    fileGenInterval=H2
    Activate Configuration
    Set Simple Output    ${outputFrequency}    100    1
    Activate Output
    Start Sequence
    Set Voltage Output    ${outputFrequency}    0    0    0    100    100    100
    Set Current Output    ${outputFrequency}    0    0    0    2    2    2
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    0    0    100    100    100
    Set Current Output    ${outputFrequency}    0    0    0    1    1    1
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    0    0    100    100    100
    Set Current Output    ${outputFrequency}    0    0    0    2    2    2
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    0    0    100    100    100
    Set Current Output    ${outputFrequency}    0    0    0    1    1    1
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    0    0    100    100    100
    Set Current Output    ${outputFrequency}    0    0    0    2    2    2
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    0    0    100    100    100
    Set Current Output    ${outputFrequency}    0    0    0    1    1    1
    Activate Output
    Wait By Time    seconds=${30}
    End Sequence
    Execute Sequence
    Pause    120    wait for execute sequence
    ${allowedUncertaintyStandard}    Get Measurand Uncertainty    measurand=CURRENT_IA    iNom=${5}
    ${allowedUncertainties}    Create List    ${allowedUncertaintyStandard}
    ${measurands}    Create List    PQ_IN_RMS
    ${measuredValues}    Get Measurands    PQ_IN_RMS
    ${expectedValues}    Create List    ${4.74}
    Run Keyword And Continue On Failure    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}

Run Aggregation VAVG Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    50    60
    ${ReferenceVoltage}    Set Variable    100
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    networkType=${networkType}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M1    fileGenInterval=H2
    Activate Configuration
    Set Simple Output    ${outputFrequency}    100    1
    Activate Output
    Start Sequence
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    -120    120    50    50    50
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    -120    120    50    50    50
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    -120    120    50    50    50
    Activate Output
    Wait By Time    seconds=${30}
    End Sequence
    Execute Sequence
    Pause    120    wait for execute sequence
    ${allowedUncertainty}    Get Measurand Uncertainty    measurand=VOLTAGE_VA    uNom=${priNomVoltage}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}
    ${measurands}    Create List    PQ_VAVG_RMS
    ${measuredValues}    Get Measurands    PQ_VAVG_RMS
    ${expectedValues}    Create List    ${79.0569}
    ${measurands_3P3W}    Create List    PQ_VAVG_RMS
    ${measuredValues_3P3W}    Get Measurands    PQ_VAVG_RMS
    ${expectedValues_3P3W}    Create List    ${136.93}
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_3P3W}    ${measuredValues_3P3W}    ${expectedValues_3P3W}    ${allowedUncertainties}
    ...    ELSE IF    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    Validate Measurands    ${measurands_3P3W}    ${measuredValues_3P3W}    ${expectedValues_3P3W}    ${allowedUncertainties}
    ...    ELSE IF    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    Validate Measurands    ${measurands_3P3W}    ${measuredValues_3P3W}    ${expectedValues_3P3W}    ${allowedUncertainties}
    ...    ELSE    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}

Run Aggregation IAVG Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    50    60
    ${ReferenceCurrent}    Set Variable    5
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    networkType=${networkType}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M1    fileGenInterval=H2
    Activate Configuration
    Set Simple Output    ${outputFrequency}    100    1
    Activate Output
    Start Sequence
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Set Current Output    ${outputFrequency}    0    -120    120    4    4    4
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Set Current Output    ${outputFrequency}    0    -120    120    1    1    1
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Set Current Output    ${outputFrequency}    0    -120    120    4    4    4
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Set Current Output    ${outputFrequency}    0    -120    120    1    1    1
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Set Current Output    ${outputFrequency}    0    -120    120    4    4    4
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Set Current Output    ${outputFrequency}    0    -120    120    1    1    1
    Activate Output
    Wait By Time    seconds=${30}
    End Sequence
    Execute Sequence
    Pause    120    wait for execute sequence
    ${allowedUncertaintyStandard}    Get Measurand Uncertainty    measurand=CURRENT_IA    iNom=${5}
    ${allowedUncertainties}    Create List    ${allowedUncertaintyStandard}
    ${measurands}    Create List    PQ_IAVG_RMS
    ${measuredValues}    Get Measurands    PQ_IAVG_RMS
    ${expectedValues}    Create List    ${2.915}
    Run Keyword And Continue On Failure    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}

Run Aggregation THDS Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    50    60
    ${harmonic1}    Create List    ${2}    ${1}    ${0}
    ${harmonic2}    Create List    ${2}    ${0.1}    ${0}
    ${expectedHarmonics1}    Create List    ${harmonic1}
    ${expectedHarmonics2}    Create List    ${harmonic2}
    ${ReferenceVoltage}    Set Variable    100
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    networkType=${networkType}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M1    fileGenInterval=H2
    Activate Configuration
    Set Simple Output    ${outputFrequency}    100    1
    Activate Output
    Set Harmonic Voltage Output    ${outputFrequency}    0    -120    120    ua=100    ub=100    uc=100    h_a=${expectedHarmonics1}    h_b=${expectedHarmonics1}    h_c=${expectedHarmonics1}
    Activate Output
    Pause    30    Wait for output stable
    Set Harmonic Voltage Output    ${outputFrequency}    0    -120    120    ua=100    ub=100    uc=100    h_a=${expectedHarmonics2}    h_b=${expectedHarmonics2}    h_c=${expectedHarmonics2}
    Activate Output
    Pause    30    Wait for output stable
    Set Harmonic Voltage Output    ${outputFrequency}    0    -120    120    ua=100    ub=100    uc=100    h_a=${expectedHarmonics1}    h_b=${expectedHarmonics1}    h_c=${expectedHarmonics1}
    Activate Output
    Pause    30    Wait for output stable
    Set Harmonic Voltage Output    ${outputFrequency}    0    -120    120    ua=100    ub=100    uc=100    h_a=${expectedHarmonics2}    h_b=${expectedHarmonics2}    h_c=${expectedHarmonics2}
    Activate Output
    Pause    30    Wait for output stable
    Set Harmonic Voltage Output    ${outputFrequency}    0    -120    120    ua=100    ub=100    uc=100    h_a=${expectedHarmonics1}    h_b=${expectedHarmonics1}    h_c=${expectedHarmonics1}
    Activate Output
    Pause    30    Wait for output stable
    Set Harmonic Voltage Output    ${outputFrequency}    0    -120    120    ua=100    ub=100    uc=100    h_a=${expectedHarmonics2}    h_b=${expectedHarmonics2}    h_c=${expectedHarmonics2}
    Activate Output
    Pause    30    Wait for output stable
    ${allowedUncertainty}    Get Measurand Uncertainty    measurand=THDS_VA    measurementStandard=IEC61557_12_EDITION_2_2018
    ${measurands}    Create List    PQ_THDS_VA_RMS    PQ_THDS_VB_RMS    PQ_THDS_VC_RMS
    ${measuredValues}    Get Measurands    PQ_THDS_VA_RMS    PQ_THDS_VB_RMS    PQ_THDS_VC_RMS
    ${expectedValues}    Create List    ${71.063}    ${71.063}    ${71.063}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_3P3W}    Create List    PQ_THDS_VAB_RMS    PQ_THDS_VBC_RMS    PQ_THDS_VCA_RMS
    ${measuredValues_3P3W}    Get Measurands    PQ_THDS_VAB_RMS    PQ_THDS_VBC_RMS    PQ_THDS_VCA_RMS
    ${expectedValues_3P3W}    Create List    ${71.063}    ${71.063}    ${71.063}
    ${allowedUncertainties_3P3W}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_Balance}    Create List    PQ_THDS_VA_RMS
    ${measuredValues_Balance}    Get Measurands    PQ_THDS_VA_RMS
    ${expectedValues_Balance}    Create List    ${71.063}
    ${allowedUncertainties_Balance}    Create List    ${allowedUncertainty}
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE IF    '${networkType}' == 'SINGLE_PHASE'    Validate Measurands    ${measurands_Balance}    ${measuredValues_Balance}    ${expectedValues_Balance}    ${allowedUncertainties_Balance}
    ...    ELSE IF    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_UNBALANCED'    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}
    ...    ELSE    Validate Measurands    ${measurands_3P3W}    ${measuredValues_3P3W}    ${expectedValues_3P3W}    ${allowedUncertainties_3P3W}

Run Aggregation Power Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    50    60
    ${ReferenceVoltage}    Set Variable    100
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    networkType=${networkType}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M1    fileGenInterval=H2
    Activate Configuration
    Set Simple Output    ${outputFrequency}    100    1
    Activate Output
    Start Sequence
    Set Voltage Output    ${outputFrequency}    120    0    -120    100    100    100
    Set Current Output    ${outputFrequency}    60    -60    -180    2    2    2
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    120    0    -120    50    50    50
    Set Current Output    ${outputFrequency}    60    -60    -180    1    1    1
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    120    0    -120    100    100    100
    Set Current Output    ${outputFrequency}    60    -60    -180    2    2    2
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    120    0    -120    50    50    50
    Set Current Output    ${outputFrequency}    60    -60    -180    1    1    1
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    120    0    -120    100    100    100
    Set Current Output    ${outputFrequency}    60    -60    -180    2    2    2
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    120    0    -120    50    50    50
    Set Current Output    ${outputFrequency}    60    -60    -180    1    1    1
    Activate Output
    Wait By Time    seconds=${30}
    End Sequence
    Execute Sequence
    Pause    135    Wait for execute sequence
    ${allowedUncertainty_P}    Get Active Power Uncertainty    iNom=1    iMax=3    cosPhi=0.5
    ${allowedUncertainty_Q}    Get Reactive Power Uncertainty    iNom=1    iMax=3    sinPhi=0.5
    ${allowedUncertainty_S}    Get Apparent Power Uncertainty    iNom=1    iMax=3
    ${Uncertainty_P}    Evaluate    ${allowedUncertainty_P} * ${100}
    ${Uncertainty_Q}    Evaluate    ${allowedUncertainty_Q} * ${173}
    ${Uncertainty_S}    Evaluate    ${allowedUncertainty_S} * ${200}
    ${Uncertainty_P_3P3W}    Evaluate    ${allowedUncertainty_P} * ${300}
    ${Uncertainty_Q_3P3W}    Evaluate    ${allowedUncertainty_Q} * ${519.6}
    ${Uncertainty_S_3P3W}    Evaluate    ${allowedUncertainty_S} * ${600}
    ${measurands}    Create List    PQ_PA_RMS    PQ_QA_RMS    PQ_SA_RMS
    ${measuredValues}    Get Measurands    PQ_PA_RMS    PQ_QA_RMS    PQ_SA_RMS
    ${expectedValues}    Create List    ${62.5}    ${108.25}    ${125}
    ${allowedUncertainties}    Create List    ${Uncertainty_P}    ${Uncertainty_Q}    ${Uncertainty_S}
    ${measurands_3P3W}    Create List    PQ_P_RMS    PQ_Q_RMS    PQ_S_RMS
    ${measuredValues_3P3W}    Get Measurands    PQ_P_RMS    PQ_Q_RMS    PQ_S_RMS
    ${expectedValues_3P3W}    Create List    ${187.5}    ${324.75}    ${375}
    ${allowedUncertainties_3P3W}    Create List    ${Uncertainty_P_3P3W}    ${Uncertainty_Q_3P3W}    ${Uncertainty_S_3P3W}
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_3P3W}    ${measuredValues_3P3W}    ${expectedValues_3P3W}    ${allowedUncertainties_3P3W}
    ...    ELSE IF    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    Validate Measurands    ${measurands_3P3W}    ${measuredValues_3P3W}    ${expectedValues_3P3W}    ${allowedUncertainties_3P3W}
    ...    ELSE IF    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    Validate Measurands    ${measurands_3P3W}    ${measuredValues_3P3W}    ${expectedValues_3P3W}    ${allowedUncertainties_3P3W}
    ...    ELSE    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}

Run Aggregation Cosphi Test
    [Arguments]    ${networkType}
    ${outputFrequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    50    60
    ${ReferenceVoltage}    Set Variable    100
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    networkType=${networkType}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M1    fileGenInterval=H2
    Activate Configuration
    Set Simple Output    ${outputFrequency}    100    1
    Activate Output
    Start Sequence
    Set Voltage Output    ${outputFrequency}    120    0    -120    100    100    100
    Set Current Output    ${outputFrequency}    60    -60    -180    2    2    2
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    -120    120    50    50    50
    Set Current Output    ${outputFrequency}    0    -120    120    1    1    1
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    120    0    -120    100    100    100
    Set Current Output    ${outputFrequency}    60    -60    -180    2    2    2
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    -120    120    50    50    50
    Set Current Output    ${outputFrequency}    0    -120    120    1    1    1
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    120    0    -120    100    100    100
    Set Current Output    ${outputFrequency}    60    -60    -180    2    2    2
    Activate Output
    Wait By Time    seconds=${30}
    Set Voltage Output    ${outputFrequency}    0    -120    120    50    50    50
    Set Current Output    ${outputFrequency}    0    -120    120    1    1    1
    Activate Output
    Wait By Time    seconds=${30}
    End Sequence
    Execute Sequence
    Pause    120    Wait for execute sequence
    ${allowedUncertainty}    Get Measurand Uncertainty    measurand=COSPHI_A    measurementStandard=IEC61557_12_EDITION_2_2018
    ${measurands}    Create List    PQ_COSPHI_A_RMS    PQ_COSPHI_B_RMS    PQ_COSPHI_C_RMS
    ${measuredValues}    Get Measurands    PQ_COSPHI_A_RMS    PQ_COSPHI_B_RMS    PQ_COSPHI_C_RMS
    ${expectedValues}    Create List    ${0.75}    ${0.75}    ${0.75}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}    ${allowedUncertainty}    ${allowedUncertainty}
    ${measurands_3P4WB}    Create List    PQ_COSPHI_A_RMS
    ${measuredValues_3P4WB}    Get Measurands    PQ_COSPHI_A_RMS
    ${expectedValues_3P4WB}    Create List    ${0.75}
    ${allowedUncertainties_3P4WB}    Create List    ${allowedUncertainty}
    ${measurands_3P3W}    Create List    PQ_PF_RMS
    ${measuredValues_3P3W}    Get Measurands    PQ_PF_RMS
    ${expectedValues_3P3W}    Create List    ${0.75}
    ${allowedUncertainties_3P3W}    Create List    ${allowedUncertainty}
    Run Keyword And Continue On Failure    Run Keyword If    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_UBALANCED'    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}
    ...    ELSE IF    '${networkType}' == 'FOUR_WIRE_THREE_PHASE_BALANCED'    Validate Measurands    ${measurands_3P4WB}    ${measuredValues_3P4WB}    ${expectedValues_3P4WB}    ${allowedUncertainties_3P4WB}
    ...    ELSE IF    '${networkType}' == 'SINGLE_PHASE'    Validate Measurands    ${measurands_3P4WB}    ${measuredValues_3P4WB}    ${expectedValues_3P4WB}    ${allowedUncertainties_3P4WB}
    ...    ELSE    Validate Measurands    ${measurands_3P3W}    ${measuredValues_3P3W}    ${expectedValues_3P3W}    ${allowedUncertainties_3P3W}

Run Aggregation 10s-Frequency Test
    [Arguments]    ${networkType}
    ${Frequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    50    60
    ${outputFrequency}    Evaluate    ${Frequency} + 5
    ${ReferenceVoltage}    Set Variable    100
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    networkType=${networkType}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M1    fileGenInterval=H2
    Activate Configuration
    Set Simple Output    ${Frequency}    100    1
    Activate Output
    Start Sequence
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    Wait By Time    seconds=${5}
    End Sequence
    Execute Sequence
    Set Time    minute=59    second=55
    Pause    130    Wait for execute sequence
    ${allowedUncertainty}    Set Variable    ${0.1}
    ${measurands}    Create List    PQ_F_10S_RMS
    ${measuredValues}    Get Measurands    PQ_F_10S_RMS
    ${expectedValue}    Evaluate    (${Frequency} + ${outputFrequency}) / 2
    ${expectedValues}    Create List    ${expectedValue}
    ${allowedUncertainties}    Create List    ${allowedUncertainty}
    Run Keyword And Continue On Failure    Validate Measurands    ${measurands}    ${measuredValues}    ${expectedValues}    ${allowedUncertainties}

Run Aggregation 10/12cycleFrequency Test
    [Arguments]    ${networkType}
    ${Frequency}    Set Variable If    '${DeviceFrequency}' == 'F50'    50    60
    ${outputFrequency}    Evaluate    ${Frequency} + 5
    ${ReferenceVoltage}    Set Variable    100
    ${3P3WVoltage}    Evaluate    ${ReferenceVoltage} * 1.732
    ${priNomVoltage}=    Set Variable If    '${networkType}' == 'THREE_WIRE_THREE_PHASE_BALANCED'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_2L'    ${3P3WVoltage}    '${networkType}' == 'THREE_WIRE_THREE_PHASE_UNBALANCED_3L'    ${3P3WVoltage}    ${ReferenceVoltage}
    ${currentMeasRange}    Set Variable If    '${ReferenceCurrent}'=='1'    ONEA    FIVEA
    Set AC Measurement Configuration    frequency=${DeviceFrequency}    networkType=${networkType}    primNomVoltage=${priNomVoltage}    currentTransformer=True    primRatedCurrent=${ReferenceCurrent}    secRatedCurrent=${ReferenceCurrent}    voltageHarmonicUnit=VOLT    currentMeasRange=${currentMeasRange}    measureInterval=BASE_10_12_CYCLE
    Set Measurement Recorder Configuration    measurementMode=ALL    aggrInterval=M1    fileGenInterval=H2
    Activate Configuration
    FOR    ${n}    IN RANGE    30
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${minute} == 0
        Sleep    1
    END
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    FOR    ${n}    IN RANGE    40
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${second} == 30
        Sleep    1
    END
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    FOR    ${n}    IN RANGE    40
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${second} == 0
        Sleep    1
    END
    Set Voltage Output    ${Frequency}    0    -120    120    100    100    100
    Activate Output
    FOR    ${n}    IN RANGE    40
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${second} == 30
        Sleep    1
    END
    Set Voltage Output    ${outputFrequency}    0    -120    120    100    100    100
    Activate Output
    FOR    ${n}    IN RANGE    40
        ${deviceTime}    Get Device Time    MODBUSTCP
        ${minute}    Set Variable    ${deviceTime.minute}
        ${second}    Set Variable    ${deviceTime.second}
        Exit For Loop If    ${second} == 0
        Sleep    1
    END
    sleep    5
    ${measurands}    Create List    PQ_F_RMS
    ${measurandValues}    Get Measurands    PQ_F_RMS
    ${expectedValue}    Evaluate    (${Frequency} + ${outputFrequency}) / 2
    ${expectedValues}    Create List    ${expectedValue}
    ${allowedUncertainty}    Create List    ${0.2}
    Run Keyword And Continue On Failure    Validate Measurands    ${measurands}    ${measurandValues}    ${expectedValues}    ${allowedUncertainty}

Run Tool
    [Arguments]    ${toolPath}
    AutoItLibrary.Run    ${toolPath}

Close Tool
    operatingSystem.Run    taskkill /IM "KeepScreen.exe" /T /F
