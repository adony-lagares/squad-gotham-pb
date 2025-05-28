*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
Resource  ../variables.robot


*** Keywords ***
Autenticar Usuario
    ${body}=    Create Dictionary    username=${USERNAME}    password=${PASSWORD}
    ${response}=    POST On Session    restful    /auth    json=${body}
    Set Test Variable    ${AUTH_RESPONSE}    ${response}


Validar Status Code 200
    [Arguments]    ${response}
    Should Be Equal As Strings    ${response.status_code}    200


Extrair BookingID
    [Arguments]    ${response}
    ${dados_da_reserva}=    Set Variable    ${response.json()}
    Log    ${dados_da_reserva}
    ${id_da_reserva}=    Get From Dictionary    ${dados_da_reserva}    bookingid
    Set Test Variable    ${booking_id}    ${id_da_reserva}

    
Montar Corpo Da Reserva
    ${bookingdates}=    Create Dictionary
    ...    checkin=2018-01-01
    ...    checkout=2019-01-01
    
    ${body}=    Create Dictionary
    ...    firstname=jim
    ...    lastname=brown
    ...    totalprice=${111}
    ...    depositpaid=${True}
    ...    bookingdates=${bookingdates}
    ...    additionalneeds=Breakfast
    
    Set Test Variable    ${POST_BODY}    ${body}


Enviar Requisicao POST Reserva
    Log    ${POST_BODY}    console=yes
    ${response}=    POST On Session    restful    /booking    json=${POST_BODY}
    Set Test Variable    ${POST_RESPONSE}    ${response}


Verificar Status code 200
    [Arguments]    ${response}
    Should Be Equal As Strings    ${response.status_code}    200


Verificar Se Contem BookingID
    [Arguments]    ${response}
    ${json}=    To JSON    ${response.content}
    Dictionary Should Contain Key    ${json}    bookingid


Montar Corpo Atualizado
    ${primeiro_nome_aleatorio}=    Generate Random String    6    [LETTERS]
    ${sobre_nome_aleatorio}=    Generate Random String    6    [LETTERS]
    ${preco_aleatorio}=    Evaluate    random.randint(1000, 9999)    modules=random
    ${periodo_da_reserva}=    Create Dictionary
    ...    checkin=2023-05-01
    ...    checkout=2023-05-10
    ${dados_reserva_atualizado}=    Create Dictionary
    ...    firstname=${primeiro_nome_aleatorio}
    ...    lastname=${sobre_nome_aleatorio}
    ...    totalprice=${preco_aleatorio}
    ...    depositpaid=${False}
    ...    bookingdates=${periodo_da_reserva}
    ...    additionalneeds=Sem pedidos
    
    Set Test Variable    ${PUT_BODY}    ${dados_reserva_atualizado}


Enviar PUT Com Token
    ${headers}=    Create Dictionary    Cookie=token=${token}
    ${resposta_put}=    PUT On Session    restful    /booking/${BOOKING_ID}    json=${PUT_BODY}    headers=${headers}
    Set Test Variable    ${PUT_RESPONSE}    ${resposta_put}


Verificar Status Code PUT 200
    [Arguments]    ${resposta_do_enviar_put}
    Should Be Equal As Strings    ${resposta_do_enviar_put.status_code}    200


Extrair Token
    [Arguments]    ${response}
    ${token}=    Get From Dictionary   ${response.json()}    token
    Set Test Variable    ${token}
    RETURN    ${token}
