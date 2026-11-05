language: pt-BR

*** Configurações ***
Recurso    ../config/qa.resource

*** Variáveis ***
${CAMPO_LOGIN_USUARIO}    id:login-username
${CAMPO_LOGIN_SENHA}      id:login-password
${BOTAO_ENTRAR}           css:#login-panel button[type="submit"]

*** Palavras-Chave ***
Preencher e enviar formulário de login
    [Argumentos]    ${usuario}    ${senha}
    Input Text    ${CAMPO_LOGIN_USUARIO}    ${usuario}
    Input Password    ${CAMPO_LOGIN_SENHA}    ${senha}
    Click Button    ${BOTAO_ENTRAR}

Confirmar acesso ao painel de usuários
    Wait Until Location Contains    /dashboard    timeout=${TIMEOUT_PADRAO}
