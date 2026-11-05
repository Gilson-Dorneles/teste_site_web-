language: pt-BR

*** Configurações ***
Recurso       ../config/qa.resource
Recurso       ../pages/cadastro_page.resource
Recurso       ../pages/login_page.resource
Recurso       ../pages/painel_page.resource

*** Palavras-Chave ***
que acesso a página de cadastro
    Go To    ${BASE_URL}
    Abrir formulário de cadastro


cadastro um usuário de ${age} anos e sexo ${sex}
    Set Log Level    WARN
    ${nome}=       FakerLibrary.Name
    ${uuid}=       FakerLibrary.Uuid4
    ${sufixo}=     Evaluate    $uuid.replace("-", "")[:26]
    ${usuario}=    Set Variable    bdd_${sufixo}
    ${senha}=      FakerLibrary.Password    length=12
    Set Test Variable    ${USUARIO_CADASTRADO}    ${usuario}
    Set Test Variable    ${NOME_CADASTRADO}       ${nome}
    Set Test Variable    ${SENHA_CADASTRADA}      ${senha}
    Preencher formulário de cadastro    ${nome}    ${age}    ${sex}    ${usuario}    ${senha}
    Enviar formulário de cadastro


o sistema confirma o cadastro
    Confirmar mensagem de cadastro realizado


consigo autenticar com os dados do usuário cadastrado
    Preencher e enviar formulário de login    ${USUARIO_CADASTRADO}    ${SENHA_CADASTRADA}
    Confirmar acesso ao painel de usuários


encontro o usuário de ${age} anos na lista
    Confirmar usuário no painel de cadastros    ${USUARIO_CADASTRADO}    ${NOME_CADASTRADO}    ${age}
