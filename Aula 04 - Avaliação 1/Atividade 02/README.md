# Atividade prática — descoberta, análise, exploração e correção

## Tema

**Segurança de redes e computadores — laboratório local de vulnerabilidade web**

Nesta atividade, a turma deverá descobrir uma vulnerabilidade antiga em uma aplicação web, confirmar o impacto com uma exploração controlada e aplicar uma correção por atualização de versão.

O laboratório foi preparado para rodar somente na máquina do aluno. O serviço Docker é publicado em `127.0.0.1:8080`; não publique essa porta na rede, na internet ou em um servidor real.

> O nome do CVE não é informado nesta folha. O objetivo é que o grupo relacione o produto, a versão e o comportamento observado a um CVE real.

## Objetivos de aprendizagem

Ao concluir o laboratório, o aluno deverá ser capaz de:

1. identificar o produto e a versão de um serviço HTTP;
2. distinguir uma hipótese de vulnerabilidade de uma evidência reproduzível;
3. pesquisar um CVE em uma fonte oficial ou base de referência;
4. demonstrar impacto com uma prova de conceito restrita e não destrutiva;
5. corrigir a exposição atualizando o componente para uma versão corrigida;
6. repetir os testes e registrar a evidência de correção.

## Regras de segurança do laboratório

- Use somente o alvo local `http://127.0.0.1:8080`.
- Não altere os scripts para apontar para outros endereços.
- Não tente executar comandos no container, obter shell ou testar a rede da instituição.
- A exploração fornecida lê apenas um arquivo didático e, opcionalmente, `/etc/passwd` dentro do container.
- Não transforme a atividade em uma varredura de terceiros.
- Ao terminar, derrube o laboratório com `docker compose down`.

## Dependências no Windows

Recomendação: Windows 10 ou Windows 11 com virtualização habilitada.

Abra o PowerShell como usuário com permissão para instalar programas e execute:

```powershell
winget install --id Docker.DockerDesktop --exact --source winget
winget install --id Microsoft.PowerShell --exact --source winget
```

Dependências fornecidas por cada pacote:

| Pacote | Uso |
|---|---|
| `Docker.DockerDesktop` | Docker Engine, Docker CLI e Docker Compose (`docker compose`) |
| `Microsoft.PowerShell` | Execução dos dois aplicativos gráficos `.ps1` |

O Windows já inclui o PowerShell 5.1. O pacote `Microsoft.PowerShell` instala uma versão mais nova e é recomendado, mas não é necessário se a escola optar por usar o PowerShell 5.1. Não é necessário instalar o Docker Compose separadamente.

Depois da instalação:

1. abra o **Docker Desktop**;
2. aguarde o status **Engine running**;
3. feche e abra novamente o PowerShell;
4. valide o ambiente:

```powershell
docker version
docker compose version
$PSVersionTable.PSVersion
```

Se o Docker Desktop solicitar o backend WSL 2, aceite a configuração recomendada e reinicie o Windows quando solicitado.

## Estrutura do material

```text
atividade-aula04-lab-http/
├── app/
│   ├── Analise-HTTP.ps1
│   ├── Exploracao-HTTP.ps1
│   └── LabHttp.psm1 (módulo auxiliar, não é executado diretamente)
├── docker/
│   └── vulnerable-apache/
│       ├── Dockerfile
│       ├── lab.conf
│       ├── htdocs/index.html
│       ├── lab-assets/publico.txt
│       └── lab-secrets/segredo.txt
├── docker-compose.yml
├── GABARITO-PROFESSOR.md
└── README.md
```

O arquivo `GABARITO-PROFESSOR.md` deve ser entregue somente ao professor.

## Parte 1 — iniciar a aplicação vulnerável

No PowerShell, entre na pasta desta atividade:

```powershell
Set-Location "C:\caminho\para\atividade-aula04-lab-http"
docker compose up -d --build
docker compose ps
```

Abra no navegador:

```text
http://127.0.0.1:8080
```

Se a imagem não estiver no computador, o primeiro `build` fará o download da imagem-base antiga. Isso pode levar alguns minutos.

Comandos úteis para observação:

```powershell
docker compose logs --no-log-prefix web
docker compose exec web httpd -v
docker image ls lab-apache-aula04
```

Não leia o gabarito antes de registrar suas próprias hipóteses.

## Parte 2 — descoberta

Use o aplicativo:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
& .\app\Analise-HTTP.ps1
```

Na janela:

1. confirme o alvo `http://127.0.0.1:8080`;
2. clique em **Analisar serviço**;
3. registre o cabeçalho `Server`, o status HTTP e a versão observada;
4. clique em **Executar prova segura**;
5. registre o status retornado e explique o que o resultado demonstra.

O analisador não faz varredura de rede. Ele consulta a página inicial e um único caminho local preparado para a aula.

### Perguntas de descoberta

Responda antes de pesquisar o CVE:

1. Qual é o produto e qual é a versão identificada?
2. O que há de incomum em uma URL que contém segmentos codificados como `.%2e`?
3. O teste seguro retornou um arquivo que não deveria estar disponível pelo caminho público? Qual foi a evidência?
4. Quais condições de configuração parecem ser necessárias para o comportamento ocorrer?

## Parte 3 — análise de vulnerabilidade

Pesquise o produto e a versão em fontes confiáveis, priorizando:

- boletim de segurança do fabricante/projeto;
- NVD ou CVE.org;
- documentação técnica de referência.

Não copie apenas o primeiro resultado de busca. Compare o identificador, a versão afetada, o impacto e a versão corrigida.

Preencha a tabela:

| Campo | Resposta do grupo |
|---|---|
| Produto e versão |  |
| CVE |  |
| Data aproximada da divulgação |  |
| CWE ou classe da falha |  |
| Vetor/condição necessária |  |
| Impacto comprovado nesta atividade |  |
| Impacto potencial descrito na fonte |  |
| Primeira versão corrigida |  |
| Fonte primária consultada |  |

Diferencie claramente:

- **impacto comprovado:** leitura do arquivo didático e/ou do arquivo de identificação do sistema dentro do container;
- **impacto potencial:** consequências descritas no boletim, que não devem ser reproduzidas nesta atividade.

## Parte 4 — exploração controlada

Use o segundo aplicativo:

```powershell
& .\app\Exploracao-HTTP.ps1
```

Selecione uma das provas disponíveis e clique em **Enviar requisição**.

As provas são:

- arquivo didático fora do diretório público;
- `/etc/passwd` do container, apenas para confirmar leitura de arquivo do sistema.

Registre:

1. a requisição HTTP enviada;
2. o código de status;
3. um trecho suficiente da resposta para demonstrar o impacto;
4. por que a resposta não seria esperada em uma aplicação corretamente configurada.

### Validação manual opcional

Se o professor permitir uma validação pelo terminal, o `curl.exe` do Windows pode ser usado somente contra o alvo local:

```powershell
curl.exe --path-as-is "http://127.0.0.1:8080/public/.%2e/lab-secrets/segredo.txt"
```

O parâmetro `--path-as-is` evita que o cliente normalize a URL antes de enviá-la. A aplicação gráfica já faz esse envio de forma controlada.

## Parte 5 — correção

O arquivo `docker-compose.yml` fixa intencionalmente a imagem-base em uma versão vulnerável. Faça uma cópia do arquivo antes de alterar, se desejar comparar o antes e o depois.

1. Pare a aplicação:

   ```powershell
   docker compose down
   ```

2. Abra `docker-compose.yml` e localize:

   ```yaml
   HTTPD_VERSION: "2.4.49"
   ```

3. Altere para a primeira versão corrigida indicada pelo boletim do fabricante:

   ```yaml
   HTTPD_VERSION: "2.4.51"
   ```

4. Recrie a imagem sem reutilizar a camada vulnerável:

   ```powershell
   docker compose build --no-cache
   docker compose up -d
   ```

5. Confirme a versão dentro do container:

   ```powershell
   docker compose exec web httpd -v
   ```

6. Execute novamente os dois aplicativos. O cabeçalho deve refletir a versão corrigida e a prova de leitura deve deixar de retornar o arquivo.

7. Registre a evidência de correção: versão nova, status da prova e explicação do motivo pelo qual o resultado mudou.

> Em um ambiente real, a correção também deve considerar a versão atualmente suportada pelo projeto, o ciclo de atualização da distribuição e outras vulnerabilidades posteriores. A versão `2.4.51` é usada aqui para isolar didaticamente a correção do CVE investigado.

## Critérios de entrega

Entregue um relatório de 2 a 4 páginas ou um arquivo Markdown contendo:

1. objetivo e escopo do teste;
2. desenho simples do laboratório: aluno → `127.0.0.1:8080` → container;
3. evidência de descoberta da versão;
4. identificação do CVE e fontes consultadas;
5. análise das condições necessárias e do impacto;
6. evidência da exploração controlada;
7. alteração aplicada para corrigir;
8. evidência do reteste após a correção;
9. limitações e medidas que seriam recomendadas em produção.

### Rubrica sugerida — 10 pontos

| Item | Pontos |
|---|---:|
| Descoberta do produto, versão e evidências | 2,0 |
| Correlação correta com um CVE real e fontes | 2,0 |
| Análise técnica das condições e do impacto | 2,0 |
| Exploração controlada, reproduzível e dentro do escopo | 1,5 |
| Correção por atualização e reteste | 1,5 |
| Clareza, ética, limites e qualidade do relatório | 1,0 |

## Encerramento

Após concluir:

```powershell
docker compose down --remove-orphans
```

Se a turma precisar liberar espaço depois da aula, o professor pode remover apenas a imagem criada para este laboratório após confirmar que ela não será reutilizada:

```powershell
docker image rm lab-apache-aula04:lab
```

Não remova imagens ou volumes de outros projetos sem verificar o nome do recurso.
