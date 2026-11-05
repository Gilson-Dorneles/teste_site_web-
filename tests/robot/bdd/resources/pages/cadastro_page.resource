language: pt-BR

*** Configurações ***
Recurso    ../config/qa.resource

*** Variáveis ***
${ABA_CADASTRO}       css:button[data-tab="register"]
${CAMPO_NOME}         id:register-name
${CAMPO_IDADE}        id:register-age
${CAMPO_SEXO}         id:register-sex
${CAMPO_USUARIO}      id:register-username
${CAMPO_SENHA}        id:register-password
${BOTAO_CADASTRAR}    css:#register-panel button[type="submit"]
${ALERTA_SUCESSO}     css:.message-success

*** Palavras-Chave ***
Abrir formulário de cadastro
    Click Element    ${ABA_CADASTRO}
    Wait Until Element Is Visible    ${CAMPO_NOME}    timeout=${TIMEOUT_PADRAO}

Preencher formulário de cadastro
    [Argumentos]    ${nome}    ${idade}    ${sexo}    ${usuario}    ${senha}
    Input Text    ${CAMPO_NOME}    ${nome}
    Input Text    ${CAMPO_IDADE}    ${idade}
    Select From List By Value    ${CAMPO_SEXO}    ${sexo}
    Input Text    ${CAMPO_USUARIO}    ${usuario}
    Input Password    ${CAMPO_SENHA}    ${senha}

Enviar formulário de cadastro
    Click Button    ${BOTAO_CADASTRAR}

Confirmar mensagem de cadastro realizado
    Wait Until Element Is Visible    ${ALERTA_SUCESSO}    timeout=${TIMEOUT_PADRAO}
    Element Should Contain    ${ALERTA_SUCESSO}    ${MENSAGEM_CADASTRO_OK}
