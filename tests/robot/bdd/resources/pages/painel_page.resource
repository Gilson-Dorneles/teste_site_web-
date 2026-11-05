language: pt-BR

*** Configurações ***
Recurso    ../config/qa.resource

*** Palavras-Chave ***
Confirmar usuário no painel de cadastros
    [Argumentos]    ${usuario}    ${nome}    ${idade}
    ${linha_usuario}=    Set Variable    xpath=//tbody/tr[td[2][normalize-space(.)='${usuario}']]
    Wait Until Element Is Visible    ${linha_usuario}    timeout=${TIMEOUT_PADRAO}
    Element Should Contain    ${linha_usuario}    ${nome}
    Element Should Contain    ${linha_usuario}    ${idade} anos
