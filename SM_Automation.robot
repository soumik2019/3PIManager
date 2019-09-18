*** Settings ***
Library           Selenium2Library
Library           Process
Library           Make_Excel
Variables         ../Lib/site-packages/Make_Excel.py
Variables         ../Lib/site-packages/file_check.py
Library           ../Lib/site-packages/file_check.py
Library           DateTime
Library           psv_file_compare

*** Variables ***
${response}       None
${response1}      None

*** Test Cases ***
Verify that no campaign report will be present before executing the program
    file_check.file_check

Verify that driver launch will be successful
    Open Browser    https://sdg-3ge.sero.gic.ericsson.se/tpim/    \ chrome
    Maximize Browser Window

Verify that login to the Customer Care Portal will be successful
    ${Window1Title}    Get Title
    Log    ${Window1Title}
    Select Frame    iframe
    Set Selenium Implicit Wait    30
    Click Element    id=username
    Input Text    id=username    manager
    Click Element    id=password
    Clear Element Text    id=password
    Input Text    id=password    manager
    Click Element    id=loginButton

Verify that navigation to report page will be successful
    Select Frame    iframe
    Select Frame    menuFrame
    click Element    //a[@id='cacReportLink']
    Set Selenium Implicit Wait    30
    Unselect Frame
    Select Frame    iframe
    Select Frame    mainFrame

Verify that navigation to campaign report will be successful
    sleep    10
    Click Element    //select[@id='selectReportName']/option[text()='Campaign Report']
    Click Element    //input[@value='Generate Report']
    Set Selenium Implicit Wait    30

Verify that download of campaign report will be successful
    sleep    10
    Set Selenium Implicit Wait    20
    Execute JavaScript    document.getElementById('exportToexcel').click()
    Set Selenium Implicit Wait    20
    Execute JavaScript    document.getElementById('exportTopsv').click()
    Sleep    10

Verify that show coloumn in campaign report is working fine
    Go Back
    Select Frame    iframe
    Select Frame    menuFrame
    click Element    //a[@id='cacReportLink']
    Set Selenium Implicit Wait    30
    Unselect Frame
    Select Frame    iframe
    Select Frame    mainFrame
    Set Selenium Implicit Wait    10
    Click Element    //select[@id='selectReportName']/option[text()='Campaign Report']
    Click Element    //input[@value='Generate Report']
    Set Selenium Implicit Wait    30
    Execute Javascript    window.scrollTo(0, document.body.scrollHeight)
    Unselect Checkbox    //*[@id="byPassQuotaCheck"]
    Unselect Checkbox    //*[@id="byPassEnumCheck"]
    Execute Javascript    window.scrollTo(document.body.scrollHeight, 50)
    Select Checkbox    //*[@id="toggleColumnsSelection"]
    Unselect Checkbox    //*[@id="toggleColumnsSelection"]
    Click Element    //*[@id="j_id591289735_f789577"]
    sleep    10
    ${response1}    Get Text    //*[@id="dynamicTable"]/div/table/tbody/tr/td
    Should Be Equal As Strings    ${response1}    No data available!
    sleep    5

Verify that the filter functionality will be working fine
    Go Back
    Select Frame    iframe
    Select Frame    menuFrame
    click Element    //a[@id='cacReportLink']
    Set Selenium Implicit Wait    30
    Unselect Frame
    Select Frame    iframe
    Select Frame    mainFrame
    sleep    5
    Click Element    //select[@id='selectReportName']/option[text()='Campaign Report']
    Click Element    //input[@value='Generate Report']
    Set Selenium Implicit Wait    30
    Click Element    //*[@id="filterValuesTable"]/tbody/tr[1]/td/div/div[@class='pq-select-text']
    Click Element    //*[@id="pq-option-0-5"]/span
    Click Element    //*[@id="dynamicTable"]/div/table/thead/tr/th[1]/div/span
    Click Element    //*[@id="filterValuesTable"]/tbody/tr[2]/td/div/div[@class='pq-select-text']
    Click Element    //*[@id="pq-option-1-4"]/input
    Click Element    //*[@id="dynamicTable"]/div/table/thead/tr/th[1]/div/span
    Execute Javascript    window.scrollTo(0,150)
    Click Element    //*[@id="filterValuesTable"]/tbody/tr[3]/td/div/div[@class='pq-select-text']
    Click Element    //*[@id="pq-option-2-6"]/input
    Click Element    //*[@id="dynamicTable"]/div/table/thead/tr/th[1]/div/span
    ${response}    Get Text    //div[@class='strong']/span[@id='selectedFiltersCount']
    Log    ${response}
    Should Be Equal As Integers    ${response}    3
    Click Button    //input[@value='Generate Custom Report']

Verify that navigation to content provider report will be successful
    Go Back
    Select Frame    iframe
    Select Frame    menuFrame
    click Element    //a[@id='cacReportLink']
    Set Selenium Implicit Wait    30
    Unselect Frame
    Select Frame    iframe
    Select Frame    mainFrame
    Click Element    //*[@id="selectReportName"]/option[5]
    Click Element    //input[@value='Generate Report']

Verify that download of content provider report will be successful
    Execute JavaScript    document.getElementById('exportToexcel').click()
    Set Selenium Implicit Wait    45
    Execute JavaScript    document.getElementById('exportTopsv').click()
    Set Selenium Implicit Wait    45
    Sleep    10

Verify that navigation to content provider history report will be successful
    Go Back
    Select Frame    iframe
    Select Frame    menuFrame
    click Element    //a[@id='cacReportLink']
    Set Selenium Implicit Wait    30
    Unselect Frame
    Select Frame    iframe
    Select Frame    mainFrame
    Click Element    //*[@id="selectReportName"]/option[9]
    Click Element    //*[@id="reportSelectDateRangeToDiv"]/img
    Click Element    //*[@id="ui-datepicker-div"]/table/tbody/tr[1]/td[7]/a
    Click Element    //*[@id="reportSelectDateRangeFromDiv"]/img
    Click Element    //a[@class='ui-datepicker-prev ui-corner-all']
    Click Element    //*[@id="ui-datepicker-div"]/table/tbody/tr[2]/td[3]/a
    Click Element    //div[@id='createReport']
    Set Selenium Implicit Wait    30
    Execute JavaScript    document.getElementById('j_id243136558_e7df97c').onclick()

Verify that download of content provider history report will be successful
    Execute JavaScript    document.getElementById('exportToexcel').click()
    Set Selenium Implicit Wait    30
    Execute JavaScript    document.getElementById('exportTopsv').click()
    Set Selenium Implicit Wait    30
    Sleep    10

Verify that navigation to campaign history report will be successful
    Go Back
    Select Frame    iframe
    Select Frame    menuFrame
    click Element    //a[@id='cacReportLink']
    Set Selenium Implicit Wait    30
    Unselect Frame
    Select Frame    iframe
    Select Frame    mainFrame
    Click Element    //*[@id="selectReportName"]/option[8]
    Click Element    //*[@id="reportSelectDateRangeToDiv"]/img
    Click Element    //*[@id="ui-datepicker-div"]/div/a[1]/span
    Click Element    //*[@id="ui-datepicker-div"]/table/tbody/tr[3]/td[4]/a
    Click Element    //*[@id="reportSelectDateRangeFromDiv"]/img
    Click Element    //*[@id="ui-datepicker-div"]/div/a[1]/span
    Click Element    //*[@id="ui-datepicker-div"]/table/tbody/tr[2]/td[3]/a
    Click Element    //div[@id='createReport']
    Set Selenium Implicit Wait    30
    Execute JavaScript    document.getElementById('j_id243136558_e7df97c').onclick()
    Comment    ${from_date}    Get Value    id=filterSelectDateRangeFrom
    Comment    ${to_date}    Get Value    id=filterSelectDateRangeTo

Verify that download of campaign history report will be successful
    Execute JavaScript    document.getElementById('exportToexcel').click()
    Set Selenium Implicit Wait    30
    Execute JavaScript    document.getElementById('exportTopsv').click()
    Set Selenium Implicit Wait    30
    sleep    10

Verify that when dates are empty for from & to error should be thrown
    Go Back
    Select Frame    iframe
    Select Frame    menuFrame
    click Element    //a[@id='cacReportLink']
    Set Selenium Implicit Wait    30
    Unselect Frame
    Select Frame    iframe
    Select Frame    mainFrame
    Click Element    //*[@id="selectReportName"]/option[8]
    Execute JavaScript    document.getElementById('j_id243136558_e7df97c').onclick()
    ${msg_emptydates}    Get Text    id=formErrorMessage
    Should Be Equal    ${msg_emptydates}    &{error_msg}[msg1]

Verify that when to date is greater than from date error should be thrown
    Comment    Go Back
    Comment    Select Frame    iframe
    Comment    Select Frame    menuFrame
    Comment    click Element    //a[@id='cacReportLink']
    Comment    Set Selenium Implicit Wait    30
    Comment    Unselect Frame
    Comment    Select Frame    iframe
    Comment    Select Frame    mainFrame
    Click Element    //*[@id="selectReportName"]/option[8]
    Click Element    //*[@id="reportSelectDateRangeToDiv"]/img
    Click Element    //*[@id="ui-datepicker-div"]/div/a[1]/span
    Click Element    //*[@id="ui-datepicker-div"]/table/tbody/tr[2]/td[3]/a
    Click Element    //*[@id="reportSelectDateRangeFromDiv"]/img
    Click Element    //*[@id="ui-datepicker-div"]/div/a[1]/span
    Click Element    //*[@id="ui-datepicker-div"]/table/tbody/tr[3]/td[4]/a
    Click Element    //div[@id='createReport']
    Set Selenium Implicit Wait    30
    Execute JavaScript    document.getElementById('j_id243136558_e7df97c').onclick()
    ${msg_greaterdates}    Get Text    id=formErrorMessage1
    Should Be Equal    ${msg_greaterdates}    &{error_msg}[msg2]

Verify the logout functionality
    Unselect Frame
    Select Frame    iframe
    Select Frame    topFrame
    Click Element    //*[@id="headerBottom"]/div/span[2]
    Click Element    //*[@id="logoutLink3Pi"]

Verify that creating Database Connection:will be successful
    sleep    10
    DIRCHECK
    connection    sdg_reporting_db/sdg_reporting_db@127.16.1.200:15221/SDGDEV1

Verify the Excel and DB comparison
    sleep    20
    file location

Verify the PSV and DB comparison
    sleep    20
    file_comp    sdg_reporting_db/sdg_reporting_db@127.16.1.200:15221/SDGDEV1

Verify the PSV and DB comparison for Content Provider History Report
    sleep    10
    Content_providerHistory_PSV.PSVfile_comp    ${db_value1}    ${download_loc}

Verify the PSV and DB comparison for campaign Report
    sleep    10
    psv_file_compare.file_comp    ${db_value}    ${download_loc}

Verify the PSV and DB comparison for content provider Report
    sleep    10
    Content_provider_PSV.PSVfile_comp    ${db_value}    ${download_loc}

Verify the PSV and DB comparison for campaign history Report
    campaignhistory_PSV.file_comppsv    ${db_value1}    ${download_loc}    ${from_date}    ${to_date}
