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

Não há pacote de professor versionado. O repositório não deve conter respostas de senhas, PINs ou pares de arquivos.

## Gerar novos pacotes

O arquivo [gerar-pacotes.ps1](gerar-pacotes.ps1) cria os 12 zips com senhas e PINs aleatórios, PCAPs distintos e materiais criptografados. Por padrão, ele não grava o controle das respostas:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\gerar-pacotes.ps1
```

Se o docente precisar de um controle privado para correção, informe um caminho fora do repositório:

```powershell
.\gerar-pacotes.ps1 -PrivateManifestPath C:\caminho-privado\aula04-manifesto.txt
```

Nunca salve esse manifesto na pasta do Git nem o distribua aos alunos. Cada execução gera novas credenciais e invalida os pacotes anteriores.

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
