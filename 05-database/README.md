# CitizenTech — Camada de Banco de Dados

Projeto da Global Solution 2026/2 da FIAP — tema **CitizenTech: tecnologia com o cidadão no centro da inovação**.

Este repositório contém a camada de processamento de dados do aplicativo **CitizenTech**, uma solução mobile para o pequeno produtor de hortaliças e frutas da agricultura familiar.

---

## Integrantes

| Nome | RM | 
|------|-----|
| Guilherme Sena | 568101 |
| Igor Dantas da Silva | 568337 |
| Alan Christopher Gonzaga Miranda | 567033 |

---

## O problema

O pequeno produtor de hortaliças e frutas decide no escuro porque não tem acesso a informação. Irrigação errada, falta de previsão de chuva e venda a preço injusto são sintomas da mesma causa raiz: a ausência de dados acessíveis.

A divisão que importa não é entre pessoa física e jurídica, e sim entre quem tem dados e quem não tem. Grandes produtores já operam com dados de satélite, estações meteorológicas e consultoria agronômica. O pequeno produtor não.

Uma safra perdida por irrigação errada pode significar a renda inteira do ciclo.

## A solução

O problema não é falta de informação, é fragmentação da informação. Hoje o produtor precisaria consultar um app de clima, um site de previsão, um grupo de WhatsApp e um caderno para tomar uma decisão.

O aplicativo reúne tudo em um único lugar, com navegação simples, e funciona mesmo sem internet: mantém em cache a última previsão consultada, com data e hora da atualização, e os alertas já recebidos continuam visíveis.

### Público-alvo

Pequeno produtor de hortaliças e frutas. Agricultura familiar, hortas, cultivo de ciclo curto. Tem celular, não tem computador. Toma decisões de alto impacto com informação escassa.

### As cinco telas do aplicativo

1. **Cadastro de área e cultura** — o produtor cadastra sua área de cultivo, escolhe a cultura, informa o tamanho e a localização.
2. **Painel da safra** — visão consolidada com indicadores da área cadastrada: cultura, estágio, umidade, irrigação e alertas ativos.
3. **Clima e alertas por localização** — usa o GPS do celular para obter a localização e exibe previsão do tempo e alertas climáticos da região.
4. **Comunidade** — feed de relatos de produtores da mesma região: o que deu certo, o que deu errado, em qual cultura e em qual época.
5. **Alertas** — lista de avisos gerados pelo sistema (clima, irrigação) e pelo sensor de umidade do solo.

---

## Modelo de dados

O modelo foi desenhado com **6 tabelas relacionadas**, todas ligadas por chave estrangeira no formato 1:N (um para muitos).

### Diagrama das entidades

```text
PRODUTOR (1) ----< (N) AREA (1) ----< (N) CULTURA (1) ----< (N) ALERTA
                        |
                        +----< (N) LEITURA_SOLO

PRODUTOR (1) ----< (N) PUBLICACAO
```

### Descrição das tabelas

**PRODUTOR** — quem usa o aplicativo. Guarda nome, e-mail (único), senha, município e região.

**AREA** — o pedaço de terra cadastrado. Guarda nome, tamanho em hectares, latitude e longitude.

**CULTURA** — o que está plantado em cada área. Guarda tipo (hortaliça ou fruta), nome, data de plantio e estágio (germinação, crescimento, floração, colheita).

**LEITURA_SOLO** — o dado bruto do sensor. Guarda valor de umidade, data e hora, origem (sensor ou manual) e identificador do dispositivo Arduino.

**ALERTA** — a interpretação da leitura. Guarda tipo (clima, irrigação, umidade), severidade (crítico, moderado, normal), mensagem e status de leitura.

**PUBLICACAO** — o feed da comunidade. Guarda texto do relato, cultura, região, data e contagem de confirmações.

### Decisão de modelagem

A leitura de solo se liga à **área**, e não à cultura. O motivo é que o sensor mede o solo da terra, não a planta. Se o produtor trocar de cultura na mesma área, o histórico de umidade continua válido.

---

## Regras de negócio

### Classificação de severidade por umidade do solo

Esta é a regra central do sistema. Ela classifica a severidade do alerta a partir do valor de umidade lido pelo sensor.

| Umidade | Classificação | Ação recomendada |
|---------|---------------|------------------|
| Abaixo de 20% | CRÍTICO | Irrigação urgente. Risco alto de perda da safra. |
| Entre 20% e 35% | MODERADO | Irrigar nas próximas 24 horas. |
| Acima de 35% e até 70% | NORMAL | Umidade adequada. Manter monitoramento. |
| Acima de 70% | EXCESSO | Solo encharcado. Suspender irrigação. |

A mesma regra é aplicada em três contextos diferentes: na análise pontual de uma área, no processamento em lote de todas as áreas e na automação que registra uma leitura e gera o alerta correspondente.

### Regras de integridade

- Umidade do solo deve estar entre 0 e 100 (CHECK).
- Tipo de cultura aceita apenas HORTALICA ou FRUTA (CHECK).
- Estágio da cultura aceita apenas GERMINACAO, CRESCIMENTO, FLORACAO ou COLHEITA (CHECK).
- Severidade do alerta aceita apenas CRITICO, MODERADO ou NORMAL (CHECK).
- Origem da leitura aceita apenas SENSOR ou MANUAL (CHECK).
- E-mail do produtor é único (UNIQUE).
- Latitude deve estar entre -90 e 90 e longitude entre -180 e 180 (CHECK).
- Tamanho da área deve ser maior que zero (CHECK).

---

## Tecnologias

- **Oracle Database** — banco de dados relacional
- **Oracle PL/SQL** — regras de negócio, blocos anônimos, cursores e procedimentos armazenados
- **SQL Developer** — ambiente de execução e testes

---

## Como executar

### Pré-requisitos

- Acesso ao Oracle da FIAP (oracle.fiap.com.br) ou uma instância Oracle local (12c ou superior)
- SQL Developer, SQLcl ou SQL*Plus

### Passo a passo

1. Clone o repositório:

```bash
git clone https://github.com/[USUARIO]/[REPOSITORIO].git
```

2. Abra o SQL Developer e conecte ao banco Oracle.

3. Ative a saída de texto do PL/SQL:

```sql
SET SERVEROUTPUT ON SIZE UNLIMITED;
```

4. No SQL Developer, abra o painel **Dbms Output** (menu Exibir > Dbms Output) e clique no botão verde de conexão. Sem este passo a saída do DBMS_OUTPUT não aparece.

5. Execute o script completo:

```sql
@global_solution_banco.sql
```

Ou abra o arquivo e execute com **F5** (Executar Script). Não use F9, que executa apenas a linha atual e quebra nos blocos PL/SQL.

### Ordem de execução do script

O arquivo global_solution_banco.sql já está sequenciado. Execute de cima para baixo, sem pular partes:

| Parte | Conteúdo |
|-------|----------|
| 1 | DDL — criação das 6 tabelas |
| 2 | DML — carga de 62 registros de teste |
| 3 | Evidência 1 — conferência da carga |
| 4 | Evidência 2 — bloco anônimo com SELECT INTO |
| 5 | Evidência 3 — decisão IF/ELSIF/ELSE |
| 6 | Evidência 4 — repetição FOR |
| 7 | Evidência 5 — repetição WHILE |
| 8 | Evidência 6 — cursor explícito |
| 9 | Evidência 7 — procedimentos armazenados |
| 10 | Conferência final da carga |

---

## Como testar

### Conferir a carga de dados

```sql
SELECT 'PRODUTOR' AS tabela, COUNT(*) AS qtd FROM PRODUTOR
UNION ALL SELECT 'AREA', COUNT(*) FROM AREA
UNION ALL SELECT 'CULTURA', COUNT(*) FROM CULTURA
UNION ALL SELECT 'LEITURA_SOLO', COUNT(*) FROM LEITURA_SOLO
UNION ALL SELECT 'ALERTA', COUNT(*) FROM ALERTA
UNION ALL SELECT 'PUBLICACAO', COUNT(*) FROM PUBLICACAO;
```

Resultado esperado: 10 registros em cada tabela, exceto LEITURA_SOLO com 12.

### Testar os procedimentos armazenados

```sql
-- Procedimento de operação: registra leitura e gera alerta automaticamente
EXEC sp_registrar_leitura(1, 17.5, 'SENSOR', 'ARD-001');

-- Procedimento de consulta: relatório consolidado por produtor
EXEC sp_relatorio_produtor(1);
EXEC sp_relatorio_produtor(5);
```

Após executar sp_registrar_leitura, a tabela LEITURA_SOLO passa a ter 13 registros, comprovando que o procedimento inseriu uma leitura nova e gerou o alerta correspondente.

---

## Resultados

### O que o script demonstra

**Bloco anônimo com SELECT INTO** — recupera o nome da área e a última leitura de umidade, classifica a severidade e apresenta o resultado formatado via DBMS_OUTPUT.

**Decisão IF/ELSIF/ELSE** — classifica a umidade nas quatro faixas (crítico, moderado, normal e excesso), demonstrando todos os ramos da estrutura, incluindo o ELSE final.

**Repetição FOR** — percorre todas as áreas cadastradas, classifica a última leitura de cada uma e consolida o total de áreas em cada faixa.

**Repetição WHILE** — simula 5 ciclos de irrigação, decrementando o número de áreas críticas a cada ciclo.

**Cursor explícito** — percorre as áreas com umidade crítica abaixo de 20%, trazendo produtor, área, cultura, umidade e data da leitura em uma única consulta que envolve quatro tabelas.

**Procedimento de operação (sp_registrar_leitura)** — recebe área, umidade, origem e identificador do dispositivo. Valida se a área tem cultura cadastrada, insere a leitura, classifica a severidade e gera o alerta correspondente na mesma transação, com ROLLBACK em caso de erro.

**Procedimento de consulta (sp_relatorio_produtor)** — recebe o ID do produtor e monta um relatório com nome, município, quantidade de áreas, total de alertas e quantos são críticos. Em seguida percorre as áreas daquele produtor mostrando cultura, estágio e última umidade.

### Evidências de execução

As capturas de tela das execuções estão na pasta evidencias/:

| Arquivo | O que comprova |
|---------|----------------|
| 01_modelo_carga.png | 6 tabelas relacionadas com no mínimo 10 linhas cada |
| 02_bloco_anonimo.png | Variáveis, SELECT INTO e saída DBMS_OUTPUT |
| 03_decisao.png | As 4 faixas de severidade demonstradas |
| 04_repeticao_for.png | Laço percorrendo todas as áreas com contagem por faixa |
| 05_repeticao_while.png | Laço com 5 ciclos de irrigação simulados |
| 06_cursor.png | Cursor percorrendo áreas críticas com dados de 4 tabelas |
| 07_procedures.png | As 2 procedures executando: operação e consulta |

---

## Estrutura do repositório

```text
.
├── README.md
├── global_solution_banco.sql
└── evidencias/
    ├── 01_modelo_carga.png
    ├── 02_bloco_anonimo.png
    ├── 03_decisao.png
    ├── 04_repeticao_for.png
    ├── 05_repeticao_while.png
    ├── 06_cursor.png
    └── 07_procedures.png
```

---

## Conexão com os ODS

- **ODS 2 — Fome zero e agricultura sustentável:** reduz perdas de safra na agricultura familiar.
- **ODS 9 — Indústria, inovação e infraestrutura:** leva infraestrutura digital a pequenos produtores rurais.
- **ODS 10 — Redução das desigualdades:** democratiza o acesso a dados que hoje estão disponíveis apenas para grandes produtores.
- **ODS 11 — Cidades e comunidades sustentáveis:** fortalece a produção local e o abastecimento de proximidade.
- **ODS 13 — Ação contra a mudança global do clima:** apoia a adaptação de pequenos produtores a eventos climáticos extremos.

---

## Declaração de uso de IA generativa

Conforme as regras da Global Solution, declaramos as ferramentas de IA generativa utilizadas no desenvolvimento deste projeto:

| Ferramenta | Uso |
|------------|-----|
| Adapta One |  apoio na revisão do código PL/SQL e na estruturação da documentação |

Todo o código entregue foi revisado e é compreendido pelos integrantes do grupo.

---

## Referências

- FIAP — Global Solution 2026/2, tema CitizenTech
- Oracle Database PL/SQL Language Reference
- UN-Habitat — Diretrizes internacionais para cidades inteligentes centradas nas pessoas
- ONU — Objetivos de Desenvolvimento Sustentável (Agenda 2030)
