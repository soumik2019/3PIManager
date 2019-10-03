*** Settings ***
Resource          ../Lib/site-packages/variable_test.txt
Library           requests
Library           Collections
Library           String
Library           RequestsLibrary
Library           OperatingSystem
Library           HttpLibrary.HTTP
Library           sdg_provisioing_api.py
Library           CP.py
Library           cp1.py

*** Variables ***
${db_loc}         sdg_3ge_db/sdg_3ge_db@127.16.1.200:15221/SDGDEV1
${cp_name}        ContentProvidermay7_17_355

*** Test Cases ***
Verify that every response for GET operationcontain PartnerId, limit (how many remain), offset, response codes.
    ################################## GET OPERATION SCENARIOES ##################################
    Create sesion and fetching response
    ${resp_content}=    Printing the request body of a response
    Create File    Response.json    ${resp_content}
    ${json}=    Get File    Response.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    ${resp_status_code}=    Status code of Response
    Log    ${object["total-size"]}
    Log    ${object["offset"]}
    Log    ${object["limit"]}
    comment    ${object["results"][0]["associations"][0]["policies"]}
    Should Be Equal As Strings    ${resp_status_code}    200
    Should Be Equal As Strings    ${object["limit"]}    10
    Should Be Equal As Strings    ${object["offset"]}    0

Verify the response for GET operation
    Create sesion and fetching response
    ${headers}=    Get Header
    ${resp}=    Get Request    httpbin    ${update_uri}    headers=${headers}
    ${respbody}=    Set Variable    ${resp.json()}
    Log    ${respbody}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Response_2.json    ${resp.content}
    ${json}=    Get File    Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Comment    Log    ${object["associations"]}
    Should Be Equal As Strings    ${resp.status_code}    200

Verify the service provisining in GET [partner and service id with offset and limit]
    Create sesion and fetching response
    ${headers}=    Get Header
    ${resp}=    Get Request    httpbin    ${update_uri}?offset=2&limit=6    headers=${headers}
    ${respbody}=    Set Variable    ${resp.json()}
    Log    ${respbody}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Response_2.json    ${resp.content}
    ${json}=    Get File    Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Log    ${object["offset"]}
    Log    ${object["limit"]}
    Should Be Equal As Strings    ${object["limit"]}    6
    Should Be Equal As Strings    ${object["offset"]}    2

Verify the response when a request is hit with negative limit.
    Create sesion and fetching response
    ${headers}=    Get Header
    ${resp}=    Get Request    httpbin    ${update_uri}?offset=2&limit=-5    headers=${headers}
    ${respbody}=    Set Variable    ${resp.json()}
    Log    ${respbody}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Response_2.json    ${resp.content}
    ${json}=    Get File    Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${object["description"]}
    Log    ${object["errorCode"]}
    Should Be Equal As Strings    ${object["description"]}    limit must be a positive integer
    Should Be Equal As Strings    ${object["errorCode"]}    50007

Verify the response when a request is hit with negative offset.
    Create sesion and fetching response
    ${headers}=    Get Header
    ${resp}=    Get Request    httpbin    ${update_uri}?offset=-2&limit=5    headers=${headers}
    ${respbody}=    Set Variable    ${resp.json()}
    Log    ${respbody}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Response_2.json    ${resp.content}
    ${json}=    Get File    Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${object["description"]}
    Log    ${object["errorCode"]}
    Should Be Equal As Strings    ${object["description"]}    offset must be a positive integer
    Should Be Equal As Strings    ${object["errorCode"]}    50006

Verify the response when a request is hit with optional parameter offset only.
    Create sesion and fetching response
    ${headers}=    Get Header
    ${resp}=    Get Request    httpbin    ${update_uri}?offset=10    headers=${headers}
    ${respbody}=    Set Variable    ${resp.json()}
    Log    ${respbody}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Response_2.json    ${resp.content}
    ${json}=    Get File    Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200

Verify the response when a request is hit with optional parameter limit only.
    Create sesion and fetching response
    ${headers}=    Get Header
    ${resp}=    Get Request    httpbin    ${update_uri}?limit=10    headers=${headers}
    ${respbody}=    Set Variable    ${resp.json()}
    Log    ${respbody}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Response_2.json    ${resp.content}
    ${json}=    Get File    Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200

Verify the response when a request is hit with huge number of limit (in 10 thousands range).
    Create sesion and fetching response
    ${headers}=    Get Header
    ${resp}=    Get Request    httpbin    ${update_uri}?offset=2&limit=6000000000    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Should Be Equal As Strings    ${resp.status_code}    400
    Create File    Response_2.json    ${resp.content}
    ${json}=    Get File    Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${object["description"]}
    Log    ${object["errorCode"]}
    Should Be Equal As Strings    ${object["description"]}    invalid response from capability access api
    Should Be Equal As Strings    ${object["errorCode"]}    50021

Verify the response when a request is hit with invalid limit(anything other than numeric).
    Create sesion and fetching response
    ${headers}=    Get Header
    ${resp}=    Get Request    httpbin    ${update_uri}?offset=2&limit=6P    headers=${headers}
    ${respbody}=    Set Variable    ${resp.json()}
    Log    ${respbody}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Response_2.json    ${resp.content}
    ${json}=    Get File    Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${object["description"]}
    Log    ${object["errorCode"]}
    Should Be Equal As Strings    ${object["description"]}    limit must be a positive integer
    Should Be Equal As Strings    ${object["errorCode"]}    50007

Verify the response when a request is hit with invalid offset(anything other than numeric).
    Create sesion and fetching response
    ${headers}=    Get Header
    ${resp}=    Get Request    httpbin    ${update_uri}?offset=2AAA&limit=6    headers=${headers}
    ${respbody}=    Set Variable    ${resp.json()}
    Log    ${respbody}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Response_2.json    ${resp.content}
    ${json}=    Get File    Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${object["description"]}
    Log    ${object["errorCode"]}
    Should Be Equal As Strings    ${object["description"]}    offset must be a positive integer
    Should Be Equal As Strings    ${object["errorCode"]}    50006

VVerify the response when a request is hit with mandatory parameter partner_id and optional parameter offset only. (default limit should be taken)
    Create sesion and fetching response
    ${headers}=    Get Header
    ${resp}=    Get Request    httpbin    ${update_uri}?offset=0    headers=${headers}
    ${respbody}=    Set Variable    ${resp.json()}
    Log    ${respbody}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Response_2.json    ${resp.content}
    ${json}=    Get File    Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["limit"]}    10

Verify the response if a request is hit with optional parameter offset and limit only
    Create sesion and fetching response
    ${headers}=    Get Header
    ${resp}=    Get Request    httpbin    ${update_uri}?offset=2&limit=6    headers=${headers}
    ${respbody}=    Set Variable    ${resp.json()}
    Log    ${respbody}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Response_2.json    ${resp.content}
    ${json}=    Get File    Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    ${object}=    set to dictionary    ${object}    "offset"=${100}
    ${object}=    evaluate    json.dumps('''${object}''')    json
    Create File    Response_3.json    ${object}

Verify the response if a request is hit with mandatory parameter partner_id and optional parameter limit then the default offset should be taken
    Create sesion and fetching response
    ${headers}=    Get Header
    ${resp}=    Get Request    httpbin    ${update_uri}?limit=10    headers=${headers}
    ${respbody}=    Set Variable    ${resp.json()}
    Log    ${respbody}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Response_2.json    ${resp.content}
    ${json}=    Get File    Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["offset"]}    0

Verify that every GET request should have the authorization header(Error 401).
    ${auth}=    Create List    ${username}    ${incorrect_password}
    Create Session    httpbin    ${url}    auth=${auth}
    ${resp}=    Get Request    httpbin    prov/v1/partners/P-ybSuiRWr512/services?offset=-2&limit=5
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    Should Be Equal As Strings    ${resp.status_code}    401

Verify the response if a request is hit with mandatory parameter partner_id and optional parameters offset and limit.
    Create sesion and fetching response
    ${resp_content}=    Printing the request body of a response
    Create File    Response.json    ${resp_content}
    ${resp_status_code}=    Status code of Response
    Should Be Equal As Strings    ${resp_status_code}    200

Verify the response if a GET equest is hit with invalid/unknown partner_id(anything other than alphanumeric)
    Create sesion and fetching response
    ${resp}=    Get Request    httpbin    prov/v1/partners/P-ybSuiR@@@@@Wr512/content-providers?offset=-2&limit=5
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    Should Be Equal As Strings    ${resp.status_code}    401

Verify the response if a GET request is hit without mandatory and optional parameter
    Create sesion and fetching response
    ${resp}=    Get Request    httpbin    prov/v1/partners/services?offset=-2&limit=5
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}.
    Should Be Equal As Strings    ${resp.status_code}    404

Verify that, GET method should give successful response for the content provider,irrespective of created from UI or API.
    Create sesion and fetching response
    ${resp_content}=    Printing the request body of a response
    Create File    Response.json    ${resp_content}
    ${json}=    Get File    Response.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    ${resp_status_code}=    Status code of Response
    Should Be Equal As Strings    ${resp_status_code}    200

Verify that for invalid authorization header error should be thrown for PUT CP
    ${auth}=    Create List    ${username}    ${incorrect_password}
    Create Session    httpbin    ${url}    auth=${auth}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    Should Be Equal As Strings    ${resp.status_code}    401

Verify that error should be thrown when request URL is incorrect for CP create
    Create sesion and fetching response
    ${headers}=    Get Header
    ${resp}=    Get Request    httpbin    prov/v3/partners/P-ybSuiRWr512/services/${content_provider}    headers=${headers}
    ${respbody}=    Set Variable    ${resp.json()}
    Log    ${respbody}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Response_2.json    ${resp.content}
    ${json}=    Get File    Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    404
    Should Be Equal As Strings    ${object["message"]}    Not Found

Verify that when PartnerId is missing in URL an error should be thrown for CP create
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    prov/v1/partners//content-providers/${content_provider}    { "name": "amitp448", "state": "in-test", "attributes": { "trust-score": "100" }, "associations": \ { "policies": { "href": "/partners/{partner-id}/policies/Ram-Reports-Policy" } } }    headers=${headers}
    Log    ${resp.content}
    Comment    This is the default behavior, if the URL has //
    Should Be Equal As Strings    ${resp.status_code}    401

Verify that when partner-Id in hearder is empty, an error should be thrown
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=""    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    401

Verify that when partner-Id in URL is different from hearder, an error should be thrown
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr514    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${object["errorCode"]}    50032

Verify that when unknown partnerId is given in URL an error should be thrown for CP create
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr514    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "content", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    401
    comment    ${object["errorCode"]}    50001
    comment    ${object["description"]}    Either partner id is not valid or missing in the request."

Verify that when complete request body is not provided error should be thrown for CP create
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${object["description"]}
    Log    ${object["errorCode"]}
    Should Be Equal As Strings    ${resp.status_code}    400

Verify that name cannot be empty for Content provider create
    ### Manager Login ###
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50009
    Should Be Equal As Strings    ${object["description"]}    Name cannot be null or empty.

Verify that state cannot be empty for Content provider create
    ### Manager Login ###
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50011
    Should Be Equal As Strings    ${object["description"]}    State cannot be null or empty.

Verify that policy cannot be empty for Content provider create
    ### Manager Login ###
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/" \ } } \ }    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50004
    comment    ${object["description"]}    Policy Id is empty or null in the request body.

Verify the partnerId in request body cannot be empty for Content provider create
    ### Manager Login ###
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners//policy_state_news" } } \ }    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50001
    Should Be Equal As Strings    ${object["description"]}    Either partner id is not valid or missing in the request body .

Verify that invalid state throws error for Content provider create
    ### Manager Login ###
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "New", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50005
    Should Be Equal As Strings    ${object["description"]}    State is not valid in the request body for this user. Please provides valid state.

Verify that alpha trust-score throws error for Content provider create
    ### Manager Login ###
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", \ "state": "new", "attributes": { "trust-score": shajksdh }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    60026
    comment    ${object["description"]}    not a valid input value. Please provides valid inputs.

Verify that negative trust-score throws error for Content provider create
    ### Manager Login ###
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": -10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50012
    Should Be Equal As Strings    ${object["description"].strip()}    Trust score is null or empty or not a valid input.

Verify that outofrange trust-score throws error for Content provider create
    ### Manager Login ###
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 643768 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50019
    Should Be Equal As Strings    ${object["description"]}    Trust Score value should be between 0 to 65535

Verify that unknow policy throws error for Content provider create
    ### Manager Login ###
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_newsuprisanjusoumi" } } \ }    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50004
    comment    ${object["description"]}    PolicyGroupId or PartnerId is not valid . Please provide valid policyGroupId or PartnerId in the request body

Verify that when policy is in new state error should be thrown for Content provider create
    ### Manager Login ###
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/Donotupdatethispolicy" } } \ }    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    comment    ${object["errorCode"]}    50004
    comment    ${object["description"]}    PolicyGroupId or PartnerId is not valid . Please provide valid policyGroupId or PartnerId in the request body

Verify that when policy doesn't contain CP Quota error should be thrown for Content provider create
    ### Manager Login ###
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/PolicywithoutCPquota" } } \ }    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    comment    ${object["errorCode"]}    50031
    comment    ${object["description"].strip()}    Invalid PolicyId, because \ content provider quota is not available as service type

Verify that unknow partnerid in request body throws error for Content provider create
    ### Manager Login ###
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr54412/policies/policy_state_new" } } \ }    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50001
    Should Be Equal As Strings    ${object["description"]}    Either partner id is not valid or missing in the request body .

Verify that a CP is created successfully using content provider create API in PENDING APPROVAL state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}_PendingApproval    { "name": "Content Name", "state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    201
    Should Be Equal As Strings    ${object["name"]}    Content Name
    Should Be Equal As Strings    ${object["state"]}    pending-approval
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10
    ${contentprovider_name}=    CP.cp    ${db_loc}    ${cp_name}_PendingApproval
    Should Be Equal    ${contentprovider_name}    ('${cp_name}_PendingApproval', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10)

Verify that a CP is created successfully using content provider create API in IN TEST state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}_InTest    { "name": "Content Name", \ "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    201
    Should Be Equal As Strings    ${object["name"]}    Content Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    in-test
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10
    ${contentprovider_name}=    CP.cp    ${db_loc}    ${cp_name}_InTest
    Should Be Equal    ${contentprovider_name}    ('${cp_name}_InTest', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10)

Verify that a CP is created successfully using content provider create API in DEPLOYMENT PENDING APPROVAL state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}_DPApproval    { "name": "Content Name","state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    201
    Should Be Equal As Strings    ${object["name"]}    Content Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    deployment-pending-approval
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10
    ${contentprovider_name}=    CP.cp    ${db_loc}    ${cp_name}_DPApproval
    Should Be Equal    ${contentprovider_name}    ('${cp_name}_DPApproval', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10)

Verify that a CP is created successfully using content provider create API in DEPLOYED state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}_Deployed    { "name": "Content Name", "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    201
    Should Be Equal As Strings    ${object["name"]}    Content Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    deployed
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10
    ${contentprovider_name}=    CP.cp    ${db_loc}    ${cp_name}_Deployed
    Should Be Equal    ${contentprovider_name}    ('${cp_name}_Deployed', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10)

Verify that a CP is not created using content provider create API in LIVE EDIT state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}_LiveEdit    { "name": "Content Name", "state": "live-edit", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that a CP is not created using content provider create API in EDIT APPROVAL state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}_editapproval    { "name": "Content Name", "state": "edit-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that a CP is not created using content provider create API in REMOVED state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}_Removed    { "name": "Content Name", "state": "removed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": {"href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that a CP is not created using content provider create API in DELETE state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}_Delete    { "name": "Content Name", "state": "deleted", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    comment    ${object["errorCode"]}    50025
    comment    ${object["description"]}    Invalid state for the content provider

Verify that a CP is created successfully using content provider create API in NEW state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    201
    Should Be Equal As Strings    ${object["name"]}    Content Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    new
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10
    ${contentprovider_name}=    CP.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10)

Verify that when no content/state is changed error as to be thrown for content provider update in NEW state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50032
    Should Be Equal As Strings    ${object["description"]}    No update/state change is observed for ${content_provider}.

Verify that name should be successfully updated in NEW state using content provider
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Provider Name", \ "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Provider Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    new
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10
    ${contentprovider_name}=    CP.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Provider Name', 'P-ybSuiRWr512', 'policy_state_new', 10)

Verify that trust-score should be successfully updated in NEW state using content provider
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Provider Name", \ "state": "new", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Provider Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    new
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    20
    ${contentprovider_name}=    CP.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Provider Name', 'P-ybSuiRWr512', 'policy_state_new', 20)

Verify that manager can change the state of Content provider from new to pending-approval
    ### Manager Login ###
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10, 'SDG-PENDING_APPROVAL')

Verify that manager can change the state of Content provider from pending approval to new
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Provider Name", "state": "new", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Provider Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    new
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    20
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Provider Name', 'P-ybSuiRWr512', 'policy_state_new', 20, 'SDG-NEW')

Verify that manager can change the state of Content provider from new to in-test
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10, 'SDG-IN_TEST')

Verify that manager can change the state of Content provider from in-test to new state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10, 'SDG-NEW')

Verify that manager can change the state of Content provider from new to deployment-pending-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10, 'SDG-DEPLOYMENT_PENDING_APPROVAL')

Verify that manager can change the state of Content provider from deployment-pending-approval to new
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10, 'SDG-NEW')

Verify that manager can change the state of Content provider from new to deployed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", \ "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10, 'SDG-DEPLOYED')

Verify that manager can change the state of Content provider from deployed to new
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Provider Name", \ "state": "new", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Provider Name', 'P-ybSuiRWr512', 'policy_state_new', 20, 'SDG-NEW')

Verify that manager can change the state of Content provider from new to removed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Provider Name", \ "state": "removed", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Provider Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    removed
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    20
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Provider Name', 'P-ybSuiRWr512', 'policy_state_new', 20, 'SDG-REMOVED')

Verify that manager can change the state of Content provider from removed to new
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Provider Name", \ "state": "new", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Provider Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    new
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    20
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Provider Name', 'P-ybSuiRWr512', 'policy_state_new', 20, 'SDG-NEW')

Verify that when no content/state is changed error as to be thrown for content provider update in PENDING APPROVAL state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": {"href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "type": "content-provider", "state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50032
    comment    ${object["description"]}    No update/state change is observed for ${content_provider}.
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10, 'SDG-PENDING_APPROVAL')

Verify that manager can change the state of Content provider from pending-approval to in-test
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name"\, "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10, 'SDG-IN_TEST')

Verify that manager can change the state of Content provider from in-test to pending approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Provider Name", \ "state": "pending-approval", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Provider Name', 'P-ybSuiRWr512', 'policy_state_new', 20, 'SDG-PENDING_APPROVAL')

Verify that manager cannot change the state of Content provider from pending approval to live-edit
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", \ "state": "live-edit", "attributes": { "trust-score": 10 }, "associations": \ { "policies": {"href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed

Verify that manager cannot change the state of Content provider from pending approval to edit-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", \ "state": "edit-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": {"href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager cannot change the state of Content provider from pending approval to delete
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "delete", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed

Verify that manager can change the state of Content provider from pending approval to deployment-pending-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    deployment-pending-approval
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10, 'SDG-DEPLOYMENT_PENDING_APPROVAL')

Verify that manager can change the state of Content provider from deployment-pending-approval to pending-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": {"href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10, 'SDG-PENDING_APPROVAL')

Verify that manager can change the state of Content provider from pending approval to deployed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    deployed
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10, 'SDG-DEPLOYED')

Verify that manager can change the state of Content provider from pending approval to removed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Provider Name", \ "state": "pending-approval", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Provider Name", \ "state": "removed", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Provider Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    removed
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    20
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Provider Name', 'P-ybSuiRWr512', 'policy_state_new', 20, 'SDG-REMOVED')

Verify that when no content/state is changed error as to be thrown for content provider update in IN TEST state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", \ "state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": {"href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Provider Name", "state": "in-test", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Provider Name", \ "state": "in-test", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50032
    Should Be Equal As Strings    ${object["description"]}    No update/state change is observed for ${content_provider}.

Verify that manager can change the state of Content provider from in-test to deployed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": {"href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 20, 'SDG-DEPLOYED'')

Verify that manager cannot change the state of Content provider from in-test to live-edit
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name","state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "live-edit", "attributes": { "trust-score": 10 }, "associations": \ { "policies": {"href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager cannot change the state of Content provider from in-test to edit-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "edit-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager can change the state of Content provider from in-test to deployment-pending-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "type": "content-provider", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment    ${object["errorCode"]}    50030
    ${contentprovider_name}=    cp1.cp    ${db_loc}    ${cp_name}
    Should Be Equal    ${contentprovider_name}    ('${cp_name}', 'Content Name', 'P-ybSuiRWr512', 'policy_state_new', 10, 'SDG-DEPLOYMENT_PENDING_APPROVAL')

Verify that manager can change the state of Content provider from in-test to Remove
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name","state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "type": "content-provider", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "type": "content-provider", "state": "removed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["state"]}    removed
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

Verify that manager can change the state of Content provider from removed to in-test
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed

Verify that manager can change the state of Content provider from in-test to Deployment pending-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Name
    Should Be Equal As Strings    ${object["state"]}    deployment-pending-approval
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

Verify that when no content/state is changed error as to be thrown for content provider update in DEPLOYMENT PENDING APPROVAL state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": {"href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50032
    Should Be Equal As Strings    ${object["description"]}    No update/state change is observed for ${content_provider}.

Verify that manager cannot change the state of Content provider from Deployment pending-approval to live-edit
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", \ "state": "live-edit", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager cannot change the state of Content provider from Deployment pending-approval to edit-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", \ "state": "edit-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager can change the state of Content provider from Deployment pending-approval to pending-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", \ "state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200

Verify that manager can change the state of Content provider from Deployment pending-approval to in-test
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Provider Name", "state": "in-test", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Provider Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    in-test
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    20

Verify that manager can change the state of Content provider from Deployment pending-approval to removed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "type": "content-provider", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "removed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": {"href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    removed
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

Verify that manager can change the state of Content provider from removed to Deployment pending-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": {"href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed

Verify that manager can change the state of Content provider from removed to new (workaround)
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    new
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

Verify that manager can change the state of Content provider from Deployment pending-approval to deployed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    deployed
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

Verify that when no content/state is changed error as to be thrown for content provider update in DEPLOYED state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50032
    Should Be Equal As Strings    ${object["description"]}    No update/state change is observed for ${content_provider}.

Verify that manager cannot change the state of Content provider from deployed to Edit Aprroval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "edit-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager can change the state of Content provider from deployed to Deployment pending-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", \ "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed

Verify that manager can change the state of Content provider from deployed to in-test
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name","state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    in-test
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

Verify that manager can change the state of Content provider from deployed to removed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "type": "content-provider", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "type": "content-provider", "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "type": "content-provider", "state": "removed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    removed
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

Verify that when no content/state is changed error as to be thrown for content provider update in REMOVED state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "removed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50032
    Should Be Equal As Strings    ${object["description"]}    No update/state change is observed for ${content_provider}.

Verify that manager can change the state of Content provider from removed to deployed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed

Verify that manager can change the state of Content provider from deployed to live-edit
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "type": "content-provider", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "type": "content-provider", "state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "type": "content-provider", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "type": "content-provider", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "type": "content-provider", "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "type": "content-provider", "state": "live-edit", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    live-edit
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

Verify that when no content/state is changed error as to be thrown for content provider update in LIVE EDIT state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "live-edit", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50032
    Should Be Equal As Strings    ${object["description"]}    No \ update/state change is observed for ${content_provider}.

Verify that manager cannot change the state of Content provider from live-edit to Deployment pending-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager cannot change the state of Content provider from live-edit to in-test
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name","state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager cannot change the state of Content provider from live-edit to pending-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name","state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager cannot change the state of Content provider from live-edit to new
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager cannot change the state of Content provider from live-edit to removed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "removed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" \ } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager can change the state of Content provider from live-edit to deployed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Provider Name", "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Provider Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    deployed
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

Verify that manager can change the state of Content provider from live-edit to edit-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "live-edit", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "edit-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    edit-approval
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

Verify that when no content/state is changed error as to be thrown for content provider update in EDIT APPROVAL state
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "edit-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50032
    Should Be Equal As Strings    ${object["description"]}    No \ update/state change is observed for ${content_provider}.

Verify that manager cannot change the state of Content provider from edit-approval to Deployment pending-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": {"href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager cannot change the state of Content provider from edit-approval to in-test
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager cannot change the state of Content provider from edit-approval to pending-approval
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new"} } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager cannot change the state of Content provider from edit-approval to new
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new"} } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager cannot change the state of Content provider from edit-approval to removed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "removed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

Verify that manager cannot change the state of Content provider from edit-approval to delete
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", "state": "deleted", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    400
    comment    ${object["errorCode"]}    50030
    comment    ${object["description"]}    state change is not allowed

Verify that manager can change the state of Content provider from edit-approval to live-edit
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Provider Name", "state": "live-edit", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new"} } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Provider Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    live-edit
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    20

Verify that manager can change the state of Content provider from edit-approval to deployed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Provider Name", \ "state": "edit-approval", "attributes": { "trust-score": 20 }, "associations": \ { "policies": {"href": "/partners/P-ybSuiRWr512/policies/policy_state_new" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${content_provider}    { "name": "Content Name", \ "state": "deployed", "attributes": { "trust-score": 180 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/policy_state_new"} } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Log    ${resp.status_code}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content Name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    deployed
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    180

Verify the AACA response for the service provisioning API
    ${auth}=    Create List    msdp-api    msdp-api
    Create Session    httpbin    http://127.16.1.11:8084    auth=${auth}
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    Get Request    httpbin    ${AACA_uri}${content_provider}
    ${respbody}=    Set Variable    ${resp.json()}
    Log    ${respbody}
    ${s_code}=    Set Variable    ${resp.status_code}    s
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Response_2.json    ${resp.content}
    ${json}=    Get File    Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200

PARTNER--Verify that the response for partner login
    ######## PARTNER LOGIN #########
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content Provider name", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    201
    Should Be Equal As Strings    ${object["name"]}    Content Provider name
    Should Be Equal As Strings    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    new
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

PARTNER--Verify that CP can be created in PENIDNG APPROVAL state for partner
    ######## PARTNER LOGIN #########
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", \ "state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200

PARTNER--Verify that CP should not be created in DEPLOYMENT PENIDNG APPROVAL state for partner
    ######## PARTNER LOGIN #########
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", \ "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    comment    ${object["errorCode"]}    50025
    comment    ${object["description"]}    Invalid state for the content provider

PARTNER--Verify that CP should not be created in DEPLOYED state for partner
    ######## PARTNER LOGIN #########
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

PARTNER--Verify that CP should not be created in LIVE EDIT state for partner
    ######## PARTNER LOGIN #########
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", \ "state": "live-edit", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

PARTNER--Verify that CP should not be created in EDIT APPROVAL state for partner
    ######## PARTNER LOGIN #########
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", "state": "edit-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    state change is not allowed

PARTNER--Verify that CP should not be created in REMOVED state for partner
    ######## PARTNER LOGIN #########
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", \ "state": "removed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    comment    ${object["errorCode"]}    50032
    comment    ${object["description"]}    state change is not allowed

PARTNER--Verify that when no content/state is changed in new state, error should be thrown
    ######## PARTNER LOGIN #########
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50030
    Should Be Equal As Strings    ${object["description"]}    No update/state change is observed for ${CP_Partner}.

Verify that the response after updating the name for partner login
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name", "type": "content-provider", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    new
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

Verify that the response after updating the trust-score for partner login
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name", "type": "content-provider", "state": "new", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    new
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    20

Verify that state change from new to in-test is not allowed for partner
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name", "type": "content-provider", "state": "in-test", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from new to Deployment pending-approval is not allowed for partner
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name", "type": "content-provider", "state": "deployment-pending-approval", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from new to deployed is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name", "type": "content-provider", "state": "deployed", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from new to live-edit is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name", "type": "content-provider", "state": "live-edit", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from new to edit-approval is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name", "type": "content-provider", "state": "edit-approval", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from new to delete is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name", "type": "content-provider", "state": "delete", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from new to pending-approval is allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", "type": "content-provider", "state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content name Provider
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    pending-approval
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

PARTNER--Verify that when no content/state is changed in pending-approval state, error should be thrown
    ######## PARTNER LOGIN #########
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", "type": "content-provider", "state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50032
    Should Be Equal As Strings    ${object["description"]}    No update/state change is observed for ${CP_Partner}.

Verify that content change in PENDING APPROVAL is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name", "type": "content-provider", "state": "pending-approval", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50022
    Should Be Equal As Strings    ${object["description"]}    Content change is not allowed in the state. SDG-PENDING_APPROVAL

Verify that state change from pending-approval to new is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", "type": "content-provider", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from pending-approval to Deployment pending-approval is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", "type": "content-provider", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from pending-approval to deployed is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", "type": "content-provider", "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from pending-approval to live-edit is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", "type": "content-provider", "state": "live-edit", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from pending-approval to edit-approval is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", "type": "content-provider", "state": "edit-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from pending-approval to delete is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", "type": "content-provider", "state": "delete", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from pending-approval to in-test is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", "type": "content-provider", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from pending Approval to removed is allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name Provider", "type": "content-provider", "state": "removed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    Content name Provider
    Should Be Equal As Strings    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    removed
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

Verify that content change in REMOVED state is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner}    { "name": "Content name", "type": "content-provider", "state": "removed", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50022
    Should Be Equal As Strings    ${object["description"]}    Content change is not allowed in the state. SDG-REMOVED

PARTNER-Verify that CP can be created in IN TEST state for partner
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    201
    Should Be Equal As Strings    ${object["name"]}    content name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    in-test
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

PARTNER--Verify that when no content/state is changed in IN TEST state, error should be thrown
    ######## PARTNER LOGIN #########
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50028
    Should Be Equal As Strings    ${object["description"]}    No update/state change is observed for ${CP_Partner_intest}.

Verify that content change is not allowed in in-test
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name provider", "type": "content-provider", "state": "in-test", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50022
    Should Be Equal As Strings    ${object["description"]}    Content change is not allowed in the state. SDG-IN_TEST

Verify that state change from in-test to pending-approval is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from in-test to deployed is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from in-test to live-edit is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "live-edit", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from in-test to edit-approval is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "edit-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from in-test to delete is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "delete", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from in-test to Deployment pending-approval is allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    content name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    deployment-pending-approval
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

PARTNER--Verify that when no content/state is changed in DEPLOYMENT PENDING APPROVAL state, error should be thrown
    ######## PARTNER LOGIN #########
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50028
    Should Be Equal As Strings    ${object["description"]}    No update/state change is observed for ${CP_Partner_intest}.

Verify that content change in DEPLOYMENT PENDING APPROVAL is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name PROVIDER", "type": "content-provider", "state": "deployment-pending-approval", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50022
    Should Be Equal As Strings    ${object["description"]}    Content change is not allowed in the state. SDG-DEPLOYMENT_PENDING_APPROVAL

Verify that state change from Deployment pending-approval to new is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from Deployment pending-approval to in-test is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from Deployment pending-approval to pending-approval is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from Deployment pending-approval to deployed is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from Deployment pending-approval to live-edit is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "live-edit", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from Deployment pending-approval to edit-approval is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "edit-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from Deployment pending-approval to delete is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "delete", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from Deployment pending-approval to Remove is allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "removed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    content name
    Should Be Equal As Strings    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    removed
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

PARTNER--Verify that when no content/state is changed in REMOVED state, error should be thrown
    ######## PARTNER LOGIN #########
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_intest}    { "name": "content name", "type": "content-provider", "state": "removed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50028
    comment    ${object["description"]}    No update/state change is observed for ${CP_Partner_intest}.

PARTNER--Verify that when no content/state is changed in DEPLOYED state, error should be thrown
    ######## PARTNER LOGIN #########
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name", "type": "content-provider", "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50028
    Should Be Equal As Strings    ${object["description"]}    No update/state change is observed for ${CP_Partner_deployed}.

Verify that content change in DEPLOYED is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "deployed", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50022
    Should Be Equal As Strings    ${object["description"]}    Content change is not allowed in the state. SDG-DEPLOYED

Verify that state change from deployed to new is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name", "type": "content-provider", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from deployed to pending-approval is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name", "type": "content-provider", "state": "pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from deployed to in-test is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name", "type": "content-provider", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    comment    ${object["description"]}    Invalid state for the content provider

Verify that state change from deployed to Deployment pending-approval is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name", "type": "content-provider", "state": "deployment-pending-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from deployed to edit-approval is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name", "type": "content-provider", "state": "edit-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from deployed to removed is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name", "type": "content-provider", "state": "removed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from deployed to delete is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name", "type": "content-provider", "state": "delete", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from deployed to live-edit is allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "live-edit", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    content name provider
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    live-edit
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    20

PARTNER--Verify that when no content/state is changed in LIVE EDIT state, error should be thrown
    ######## PARTNER LOGIN #########
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "live-edit", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50028
    Should Be Equal As Strings    ${object["description"]}    No \ update/state change is observed for ${CP_Partner_deployed}.

Verify that state change from live-edit to new is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "new", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from live-edit to pending-approval is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "pending-approval", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from live-edit to in-test is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "in-test", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from live-edit to Deployment pending-approval is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "deployment-pending-approval", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from live-edit to removed is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "removed", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from live-edit to delete is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "delete", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from live-edit to deployed is allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name", "type": "content-provider", "state": "deployed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    content name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    deployed
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

Verify that state change from live-edit to edit-approval is allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name", "type": "content-provider", "state": "live-edit", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/sac_bne" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name", "type": "content-provider", "state": "edit-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    content name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    edit-approval
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

PARTNER--Verify that when no content/state is changed in EDIT APPROVAL state,error should be thrown
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name", "type": "content-provider", "state": "edit-approval", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50028
    Should Be Equal As Strings    ${object["description"]}    No update/state change is observed for ${CP_Partner_deployed}.

PARTNER--Verify that content change in EDIT APPROVALis not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "edit-approval", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50022
    Should Be Equal As Strings    ${object["description"]}    Content change is not allowed in the state. SDG-EDIT_APPROVAL

Verify that state change from edit-approval to new is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "new", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from edit-approval to pending-approval is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "pending-approval", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from edit-approval to in Test is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "in-test", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from edit-approval to Deployment pending-approval is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "deployment-pending-approval", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from edit-approval to deployed is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "deployed", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from edit-approval to live-edit is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "live-edit", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from edit-approval to removed is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "removed", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Comment    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Comment    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

Verify that state change from edit-approval to delete is not allowed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_Partner_deployed}    { "name": "content name provider", "type": "content-provider", "state": "delete", "attributes": { "trust-score": 20 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/services/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    400
    Should Be Equal As Strings    ${object["errorCode"]}    50025
    Should Be Equal As Strings    ${object["description"]}    Invalid state for the content provider

PARTNER-Verify that state change from new to removed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_new_removed}    { "name": "content name", "type": "content-provider", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/sac_bne" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_new_removed}    { "name": "content name", "type": "content-provider", "state": "removed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/policies/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    content name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    removed
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

PARTNER-Verify that state change from in-test to new
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_intest_new}    { "name": "content name", "type": "content-provider", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/sac_bne" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_intest_new}    { "name": "content name", "type": "content-provider", "state": "new", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    content name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    new
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

PARTNER-Verify that state change from in-test to removed
    Create sesion and fetching response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_intest_removed}    { "name": "content name", "type": "content-provider", "state": "in-test", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/sac_bne" } } \ }    headers=${headers}
    ${resp}=    RequestsLibrary.Put Request    httpbin    ${update_uri}${CP_intest_removed}    { "name": "content name", "type": "content-provider", "state": "removed", "attributes": { "trust-score": 10 }, "associations": \ { "policies": { "href": "/partners/P-ybSuiRWr512/sac_bne" } } \ }    headers=${headers}
    Log    ${resp.content}
    ${s_code}=    Set Variable    ${resp.status_code}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Log    ${s_code}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    Create File    Put_Response_2.json    ${resp.content}
    ${json}=    Get File    Put_Response_2.json
    ${object}=    evaluate    json.loads('''${json}''')    json
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${object["name"]}    content name
    comment    ${object["type"]}    content-provider
    Should Be Equal As Strings    ${object["state"]}    removed
    Should Be Equal As Strings    ${object["attributes"]["trust-score"]}    10

*** Keywords ***
Create sesion and fetching response
    ${auth}=    Create List    ${username}    ${password}
    Create Session    httpbin    ${url}    auth=${auth}

Printing the request body of a response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    Get Request    httpbin    ${update_uri}    headers=${headers}
    ${respbody}=    Set Variable    ${resp.json()}
    ${resp_content}=    To Json    ${resp.content}    pretty_print=False
    Log    ${resp_content}
    [Return]    ${resp_content}

Status code of Response
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    ${resp}=    Get Request    httpbin    ${update_uri}    headers=${headers}
    ${s_code}=    Set Variable    ${resp.status_code}
    [Return]    ${s_code}

Get Header
    ${headers}=    Create Dictionary    Partner-Id=P-ybSuiRWr512    Content-Type=application/json
    [Return]    ${headers}
