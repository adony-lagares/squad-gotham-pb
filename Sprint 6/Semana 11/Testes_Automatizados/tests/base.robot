*** Settings ***
Resource        ../keywords/booking_keywords.robot
Suite Setup     Create Session
Suite Teardown  Conditional Teardown
Test Tags       API    Booking

*** Test Cases ***
Scenario: GET All Bookings 200
    [Tags]    GET    Public
    GET All Bookings
    Validate Status Code "200"

Scenario: Authentication and Token 200
    [Tags]    AUTH    Token
    Authenticate
    Should Not Be Empty    ${TOKEN}

Scenario: POST Create New Booking 200
    [Tags]    POST    CRUD
    ${response}=    POST New Booking    firstname=Superman    lastname=Kent
    Validate Status Code "200"    ${response}

Scenario: GET Booking by ID 200
    [Tags]    GET    CRUD
    ${response}=    POST New Booking
    ${booking_id}=    Get Booking ID From Response
    ${get_response}=    GET Booking By ID    ${booking_id}
    Validate Status Code "200"    ${get_response}

Scenario: PUT Update Booking 200
    [Tags]    PUT    CRUD
    Authenticate
    ${response}=    POST New Booking
    ${booking_id}=    Get Booking ID From Response
    ${put_response}=    Update Booking By ID    ${booking_id}    firstname=Bruce    lastname=Wayne
    Validate Status Code "200"    ${put_response}

Scenario: DELETE Remove Booking 201
    [Tags]    DELETE    CRUD
    Authenticate
    ${response}=    POST New Booking
    ${booking_id}=    Get Booking ID From Response
    ${delete_response}=    Delete Booking By ID    ${booking_id}
    Should Be Equal As Strings    ${delete_response.status_code}    201

Scenario: Complete Booking Flow
    [Tags]    FLOW    CRUD
    ${booking_id}=    Create Complete Flow
    ${get_response}=    GET Booking By ID    ${booking_id}
    Validate Status Code "200"    ${get_response}
    ${put_response}=    Update Booking By ID    ${booking_id}
    Validate Status Code "200"    ${put_response}
    ${delete_response}=    Delete Booking By ID    ${booking_id}
    Should Be Equal As Strings    ${delete_response.status_code}    201
