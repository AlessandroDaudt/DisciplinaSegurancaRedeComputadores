# Aula 04 — Avaliação 1

Laboratório individualizado para uma turma de 12 alunos. Cada pacote de aluno contém um PCAP próprio; a aplicação local possui 12 contas e associa cada conta a um material criptografado diferente.

Para conhecer a estrutura, o fluxo e as validações, consulte [ANALISE_PACOTES.md](ANALISE_PACOTES.md).

## Pacotes

Distribua exatamente um pacote por aluno:

`Pacote_Aluno_01.zip`, `Pacote_Aluno_02.zip`, `Pacote_Aluno_03.zip`, `Pacote_Aluno_04.zip`, `Pacote_Aluno_05.zip`, `Pacote_Aluno_06.zip`, `Pacote_Aluno_07.zip`, `Pacote_Aluno_08.zip`, `Pacote_Aluno_09.zip`, `Pacote_Aluno_10.zip`, `Pacote_Aluno_11.zip` e `Pacote_Aluno_12.zip`.

Cada pacote contém:

- um único `captura/captura_login.pcap`, diferente dos demais;
- a aplicação Flask com as 12 contas e os 12 materiais;
- a ferramenta PowerShell para descobrir a senha do login e o PIN do material;
- um roteiro e uma folha de respostas, sem gabarito.

Além dos arquivos compactados, as cópias completas ficam disponíveis em
`pacotes-descompactados/Pacote_Aluno_01` até `pacotes-descompactados/Pacote_Aluno_12`.
Essas pastas podem ser usadas para inspeção ou execução direta; os respectivos
`.zip` têm o mesmo conteúdo para distribuição aos alunos.

Não há pacote de professor versionado. O repositório não deve conter respostas de senhas, PINs ou pares de arquivos.

## Preparar o ambiente da disciplina (todos os labs)

Abra o Windows PowerShell e instale apenas os componentes necessários. Os IDs
abaixo são os IDs oficiais usados pelo `winget`:

```powershell
# Repositório e atividades que usam Git
winget install --id Git.Git --exact --source winget --accept-source-agreements --accept-package-agreements

# Atividades de análise de tráfego
winget install --id WiresharkFoundation.Wireshark --exact --source winget --accept-source-agreements --accept-package-agreements

# Necessário somente para labs/scripts Python ou para gerar os pacotes da Aula 04
winget install --id Python.Python.3.13 --exact --source winget --accept-source-agreements --accept-package-agreements

# Necessário para a Aula 04 e para qualquer lab que use containers
winget install --id Docker.DockerDesktop --exact --source winget --accept-source-agreements --accept-package-agreements
```

Se um componente já estiver instalado, o `winget` informa isso; não é preciso
reinstalá-lo. Depois da instalação, abra um novo PowerShell e valide o que for
usado no laboratório:

```powershell
git --version
python --version
docker --version
docker compose version
winget list --id WiresharkFoundation.Wireshark --exact
```

O Docker Desktop deve estar iniciado antes de executar um lab com Docker. O
Python não é necessário para executar o pacote de aluno da Aula 04, pois o
servidor roda dentro do container; ele é útil para os labs que usam Python e
para a geração docente dos pacotes.

## Clonar ou ressincronizar o repositório

Na primeira instalação, clone o repositório:

```powershell
$repoPath = 'C:\projetos\DisciplinaSegurancaRedeComputadores'
New-Item -ItemType Directory -Path (Split-Path -Parent $repoPath) -Force | Out-Null
Set-Location -LiteralPath (Split-Path -Parent $repoPath)
git clone https://github.com/AlessandroDaudt/DisciplinaSegurancaRedeComputadores.git
Set-Location -LiteralPath $repoPath
```

Se a pasta já existir, faça o resync sem apagar alterações locais:

```powershell
$repoPath = 'C:\projetos\DisciplinaSegurancaRedeComputadores'
Set-Location -LiteralPath $repoPath
git status --short
git fetch --prune origin
git pull --ff-only origin main
```

Se `git status --short` mostrar alterações, salve-as em um commit ou use um
`git stash` antes do `pull`; conflitos devem ser revisados manualmente. Não use
`git reset --hard` para “corrigir” o resync, pois esse comando pode apagar o
trabalho local.

## Gerar novos pacotes

O arquivo [gerar-pacotes.ps1](gerar-pacotes.ps1) cria os 12 zips e as respectivas cópias descompactadas, com senhas e PINs aleatórios, PCAPs distintos e materiais criptografados. Por padrão, ele não grava o controle das respostas:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\gerar-pacotes.ps1
```

Se o docente precisar de um controle privado para correção, informe um caminho fora do repositório:

```powershell
.\gerar-pacotes.ps1 -PrivateManifestPath C:\caminho-privado\aula04-manifesto.txt
```

Nunca salve esse manifesto na pasta do Git nem o distribua aos alunos.

Além dos zips, o comando recria as cópias descompactadas em
`pacotes-descompactados\`. Cada execução gera novas credenciais e invalida os
pacotes anteriores.

## Execução do pacote do aluno

No Windows, dentro da pasta extraída:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\Iniciar-Laboratorio.ps1
```

Depois, abra o PCAP individual no Wireshark e execute:

```powershell
.\ferramenta\Laboratorio-Seguranca.ps1
```

O portal fica disponível em `http://127.0.0.1:8080`. Após o login, o aluno baixa o `material_*.enc` correspondente à conta descoberta. A ferramenta extrai 14 arquivos — `arquivo01.txt` até `arquivo14.txt` — em `resultado/documentos/`; o objetivo final é agrupar os sete pares que possuem o mesmo SHA-256.

## Requisitos e segurança

- Windows 10 ou Windows 11;
- Windows PowerShell 5.1 ou superior;
- Docker Desktop com `docker compose`;
- Wireshark.

O primeiro build pode precisar de internet para obter `python:3.13-slim` e Flask. A aplicação e a ferramenta usam somente `127.0.0.1` depois da instalação. Os dados são fictícios e as vulnerabilidades são intencionais para a aula; não use a ferramenta contra redes, contas ou serviços externos.

Para encerrar:

```powershell
.\Parar-Laboratorio.ps1
```
