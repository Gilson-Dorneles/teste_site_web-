language: pt-BR

*** Configurações ***
Documentação        Cenário BDD de cadastro, autenticação e consulta de usuários.
Biblioteca          DataDriver    file=${CURDIR}/../data/users.csv    encoding=UTF-8    dialect=excel
Recurso             resources/support/ambiente.resource
Recurso             resources/steps/cadastro_steps.resource
Inicialização De Teste    Abrir navegador de teste
Finalização De Teste      Fechar navegador de teste
Modelo De Teste           Executar cenário BDD de cadastro
Test Tags                 cadastro    bdd    datapool


*** Casos De Teste ***
Cadastrar usuário de ${age} anos e sexo ${sex}


*** Palavras-Chave ***
Executar cenário BDD de cadastro
    [Argumentos]    ${age}    ${sex}
    Dado que acesso a página de cadastro
    Quando cadastro um usuário de ${age} anos e sexo ${sex}
    Então o sistema confirma o cadastro
    E consigo autenticar com os dados do usuário cadastrado
    E encontro o usuário de ${age} anos na lista
