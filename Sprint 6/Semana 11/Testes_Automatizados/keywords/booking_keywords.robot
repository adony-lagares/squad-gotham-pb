*** Settings ***
Library    RequestsLibrary
Library    Collections
Resource   ../resources/variables.robot
Resource   ../resources/test_data.robot

*** Keywords ***
Create Session
    RequestsLibrary.Create Session    restful    ${BASE_URL}    verify=False

Authenticate
    [Arguments]    ${username}=${USERNAME}    ${password}=${PASSWORD}
    ${body}=    Create Dictionary    username=${username}    password=${password}
    ${response}=    POST On Session    restful    /auth    json=${body}
    Should Be Equal As Strings    ${response.status_code}    200
    ${token}=    Set Variable    ${response.json()['token']}
    Set Global Variable    ${TOKEN}    ${token}
    RETURN    ${token}

GET All Bookings
    ${response}=    GET On Session    restful    /booking
    Set Global Variable    ${RESPONSE}    ${response}
    RETURN    ${response}

Validate Status Code "${code}"
    [Arguments]    ${response}=${RESPONSE}
    Should Be Equal As Strings    ${response.status_code}    ${code}

POST New Booking
    [Arguments]    ${firstname}=${DEFAULT_BOOKING.firstname}    ${lastname}=${DEFAULT_BOOKING.lastname}    
    ...    ${totalprice}=${DEFAULT_BOOKING.totalprice}    ${depositpaid}=${DEFAULT_BOOKING.depositpaid}
    ...    ${checkin}=${DEFAULT_BOOKING_DATES.checkin}    ${checkout}=${DEFAULT_BOOKING_DATES.checkout}
    ...    ${additionalneeds}=${DEFAULT_BOOKING.additionalneeds}
    
    ${bookingdates}=    Create Dictionary    checkin=${checkin}    checkout=${checkout}
    &{payload}=    Create Dictionary
    ...    firstname=${firstname}
    ...    lastname=${lastname}
    ...    totalprice=${totalprice}
    ...    depositpaid=${depositpaid}
    ...    bookingdates=${bookingdates}
    ...    additionalneeds=${additionalneeds}

    ${response}=    POST On Session    restful    /booking    json=${payload}
    Set Global Variable    ${RESPONSE}    ${response}
    Log To Console    Booking created: ${response.json()}
    RETURN    ${response}

GET Booking By ID
    [Arguments]    ${booking_id}=None
    ${id}=    Run Keyword If    '${booking_id}' == 'None'    
    ...    Get Booking ID From Response
    ...    ELSE    Set Variable    ${booking_id}
    
    ${get_response}=    GET On Session    restful    /booking/${id}
    Log To Console    >>> Booking details with ID ${id}: ${get_response.json()}
    Set Global Variable    ${GET_RESPONSE}    ${get_response}
    RETURN    ${get_response}

Get Booking ID From Response
    ${body}=    Set Variable    ${RESPONSE.json()}
    ${id}=      Set Variable    ${body['bookingid']}
    RETURN    ${id}

Update Booking By ID
    [Arguments]    ${booking_id}=None    ${firstname}=Bruce    ${lastname}=Wayne    
    ...    ${totalprice}=555    ${depositpaid}=False
    ...    ${checkin}=${DEFAULT_BOOKING_DATES.checkin}    ${checkout}=${DEFAULT_BOOKING_DATES.checkout}
    ...    ${additionalneeds}=Cave

    ${id}=    Run Keyword If    '${booking_id}' == 'None'    
    ...    Get Booking ID From Response
    ...    ELSE    Set Variable    ${booking_id}

    ${bookingdates}=    Create Dictionary    checkin=${checkin}    checkout=${checkout}
    &{update_payload}=    Create Dictionary
    ...    firstname=${firstname}
    ...    lastname=${lastname}
    ...    totalprice=${totalprice}
    ...    depositpaid=${depositpaid}
    ...    bookingdates=${bookingdates}
    ...    additionalneeds=${additionalneeds}

    ${headers}=    Create Dictionary    Cookie=token=${TOKEN}
    ${put_response}=    PUT On Session    restful    /booking/${id}    headers=${headers}    json=${update_payload}
    Set Global Variable    ${PUT_RESPONSE}    ${put_response}
    Log To Console    >>> Booking updated: ${put_response.json()}
    RETURN    ${put_response}

Delete Booking By ID
    [Arguments]    ${booking_id}=None
    ${id}=    Run Keyword If    '${booking_id}' == 'None'    
    ...    Get Booking ID From Response
    ...    ELSE    Set Variable    ${booking_id}
    
    ${headers}=    Create Dictionary    Cookie=token=${TOKEN}
    ${delete_response}=    DELETE On Session    restful    /booking/${id}    headers=${headers}
    Set Global Variable    ${DELETE_RESPONSE}    ${delete_response}
    Log To Console    >>> Booking ID ${id} deleted with status: ${delete_response.status_code}
    RETURN    ${delete_response}

Create Complete Flow
    [Arguments]    ${create_auth}=True
    Run Keyword If    ${create_auth}    Authenticate
    ${response}=    POST New Booking
    ${id}=    Get Booking ID From Response
    RETURN    ${id}

Conditional Teardown
    Run Keyword If    '${RESPONSE}' != 'None'    Verify And Delete Created Booking
    Clear Variables
    Close Session
    Log To Console    *** Complete teardown executed ***

Verify And Delete Created Booking
    ${json}=    Evaluate    json.loads("""${RESPONSE.text}""")    modules=json
    Run Keyword If    'bookingid' in ${json}
    ...    Delete Booking In Teardown    ${json['bookingid']}

Delete Booking In Teardown
    [Arguments]    ${id}
    ${headers}=    Create Dictionary    Cookie=token=${TOKEN}
    ${result}=    Run Keyword And Ignore Error    DELETE On Session    restful    /booking/${id}    headers=${headers}
    ${status}=    Set Variable If    '${result[0]}' == 'PASS'    ${result[1].status_code}    N/A
    Log To Console    >>> Teardown: Deletion of ID ${id} returned status ${status}

Clear Variables
    Set Global Variable    ${TOKEN}             None
    Set Global Variable    ${RESPONSE}          None
    Set Global Variable    ${GET_RESPONSE}      None
    Set Global Variable    ${PUT_RESPONSE}      None
    Set Global Variable    ${DELETE_RESPONSE}   None

Close Session
    Delete All Sessions
