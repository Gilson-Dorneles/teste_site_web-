language: pt-BR

*** Configurações ***
Recurso    ../config/qa.resource

*** Palavras-Chave ***
Abrir navegador de teste
    Open Browser    ${BASE_URL}    ${BROWSER}    options=add_argument("--headless=new")
    Set Selenium Timeout    ${TIMEOUT_PADRAO}

Fechar navegador de teste
    Close All Browsers
