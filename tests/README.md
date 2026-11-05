# Automação de cadastro

O projeto mantém duas implementações equivalentes do fluxo de cadastro para
comparar organização procedural e BDD. Ambas usam Robot Framework,
SeleniumLibrary, FakerLibrary e o mesmo datapool com cinco combinações de idade
e sexo em `robot/data/users.csv`.

## Estrutura

```text
robot/
├── data/users.csv
├── user_registration.robot
└── bdd/
    ├── user_registration_bdd.robot
    └── resources/
        ├── config/qa.resource
        ├── pages/
        │   ├── cadastro_page.resource
        │   ├── login_page.resource
        │   └── painel_page.resource
        ├── steps/cadastro_steps.resource
        └── support/ambiente.resource
```

O CSV é compartilhado para que a comparação não seja influenciada por conjuntos
de dados diferentes.

## Preparar o ambiente

Na raiz de `site_web`, instale as dependências de teste:

```bash
python -m pip install -r requirements-test.txt
```

Inicie a aplicação em outro terminal:

```bash
python app.py
```

## Executar a versão procedural

Na pasta `site_web/tests/robot`, rode:

```bash
python -m robot --outputdir results/procedural user_registration.robot
```

## Executar a versão BDD

Na pasta `site_web/tests/robot/bdd`, rode:

```bash
python -m robot --outputdir ../results/bdd user_registration_bdd.robot
```

## Comparação

| Aspecto | Procedural | BDD |
| --- | --- | --- |
| Ponto de entrada | `robot/user_registration.robot` | `robot/bdd/user_registration_bdd.robot` |
| Organização | Fluxo e interações concentrados na suíte | Cenário, steps, páginas, configuração e suporte separados |
| Leitura | Direta para quem implementa automação | Expressa o comportamento em Dado/Quando/Então para produto e QA |
| Manutenção | Mais simples para fluxos pequenos e técnicos | Steps e páginas reutilizáveis; mudanças de interface ficam isoladas |
| Custo | Menos arquivos e abstrações | Mais estrutura e disciplina para manter steps concisos e sem duplicação |

Para este fluxo, a versão procedural é mais leve; a BDD é melhor quando os
cenários precisam ser discutidos e revisados por pessoas não desenvolvedoras ou
quando os steps serão reutilizados em vários cenários. As duas executam os
mesmos cinco casos e validam cadastro, login e presença do usuário no painel.

> Cada execução real cria cinco usuários na base configurada pela aplicação.
> Por padrão, essa base é `site_web/users.sqlite3`; use `DATABASE_PATH` ao
> iniciar a aplicação se quiser direcionar os cadastros para outra base.
