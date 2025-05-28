*** Settings ***
Library     RequestsLibrary
Resource    ../variables.robot
Resource    ../resources/keywords.robot

Suite Setup     Create Session    restful    ${BASE_URL}


*** Test Cases ***
POTS - Login com Sucesso
    Autenticar Usuario
    Validar Status Code 200    ${AUTH_RESPONSE}
    ${token}=    Extrair Token    ${AUTH_RESPONSE}


GET - Listar Reservas Com Sucesso
    ${response}=    GET On Session    restful    /booking
    Should Be Equal As Strings    ${response.status_code}    200
    ${lista_de_reservas}=    To Json    ${response.content}
    Should Be True    ${lista_de_reservas} != []


POST - Montar Reserva Com Sucesso
    Montar Corpo Da Reserva
    Enviar Requisicao POST Reserva
    Verificar Status code 200    ${POST_RESPONSE}
    Verificar Se Contem BookingID    ${POST_RESPONSE}


GET - Validar Reserva Criada Pelo ID
    Montar Corpo Da Reserva
    Enviar Requisicao POST Reserva
    Extrair BookingID    ${POST_RESPONSE}
    ${GET_RESPONSE}=    GET On Session    restful    /booking/${booking_id}
    ${dados_reserva}=    Set Variable    ${GET_RESPONSE.json()}
    Dictionary Should Contain Item    ${dados_reserva}    firstname    jim
    Dictionary Should Contain Item    ${dados_reserva}    lastname     brown


PUT - Atualizar Reserva Com Sucesso
    Autenticar Usuario
    ${token}=    Extrair Token    ${AUTH_RESPONSE}
    Montar Corpo Da Reserva
    Enviar Requisicao POST Reserva
    Extrair BookingID    ${POST_RESPONSE}
    Montar Corpo Atualizado
    Enviar PUT Com Token
    Verificar Status Code PUT 200    ${PUT_RESPONSE}


DELET - Deletar Reserva Com Sucesso
    Autenticar Usuario
    ${token}=    Extrair Token    ${AUTH_RESPONSE}
    Montar Corpo Da Reserva
    Enviar Requisicao POST Reserva
    Extrair BookingID    ${POST_RESPONSE}
    ${cookie}=     Set Variable    token=${token}
    ${headers}=    Create Dictionary    Cookie=${cookie}
    ${DELETE_RESPONSE}=    DELETE On Session    restful    /booking/${booking_id}    headers=${headers}
    Should Be Equal As Strings    ${DELETE_RESPONSE.status_code}    201
    

EBUG - Ver Estrutura da Resposta
    Montar Corpo Da Reserva
    Enviar Requisicao POST Reserva
    ${json}=    Set Variable    ${POST_RESPONSE.json()}
    Log    ${json}    console=yes
