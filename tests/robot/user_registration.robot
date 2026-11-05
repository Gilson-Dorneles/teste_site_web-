*** Settings ***
Documentation    Cadastra cinco usuários usando dados do CSV e Faker.
Library          SeleniumLibrary
Library          FakerLibrary    locale=pt_BR
Library          DataDriver    file=data/users.csv    encoding=UTF-8    dialect=excel
Test Setup       Abrir o portal
Test Teardown    Close All Browsers
Test Template    Cadastrar usuário com dados do datapool
Test Tags        cadastro    datapool

*** Variables ***
${BASE_URL}      http://127.0.0.1:5000/
${BROWSER}       chrome

*** Test Cases ***
Cadastro ${age} anos - ${sex}

*** Keywords ***
Abrir o portal
    Open Browser    ${BASE_URL}    ${BROWSER}    options=add_argument("--headless=new")
    Set Selenium Timeout    10s

Cadastrar usuário com dados do datapool
    [Arguments]    ${age}    ${sex}
    Set Log Level    WARN
    ${name}=       FakerLibrary.Name
    ${uuid}=       FakerLibrary.Uuid4
    ${suffix}=     Evaluate    $uuid.replace("-", "")[:27]
    ${username}=   Set Variable    rf_${suffix}
    ${password}=   FakerLibrary.Password    length=12

    Click Element    css:button[data-tab="register"]
    Input Text    id:register-name    ${name}
    Input Text    id:register-age    ${age}
    Select From List By Value    id:register-sex    ${sex}
    Input Text    id:register-username    ${username}
    Input Password    id:register-password    ${password}
    Click Button    css:#register-panel button[type="submit"]

    Wait Until Element Is Visible    css:.message-success    timeout=10s
    Element Should Contain    css:.message-success    Cadastro realizado. Entre com seu usuário e senha.

    Input Text    id:login-username    ${username}
    Input Password    id:login-password    ${password}
    Click Button    css:#login-panel button[type="submit"]
    Wait Until Location Contains    /dashboard    timeout=10s

    ${row}=    Set Variable    xpath=//tbody/tr[td[2][normalize-space(.)='${username}']]
    Wait Until Element Is Visible    ${row}    timeout=10s
    Element Should Contain    ${row}    ${name}
    Element Should Contain    ${row}    ${age} anos
