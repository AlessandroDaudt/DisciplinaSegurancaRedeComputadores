# Pacote individual do aluno aluno01

Este pacote é exclusivo de um aluno da turma de 12 pessoas. Ele contém um PCAP próprio, mas aponta para a mesma aplicação didática local, que mantém as 12 contas e os 12 materiais criptografados.

## Pré-requisitos

- Windows 10/11;
- Windows PowerShell 5.1 ou superior;
- Docker Desktop com `docker compose`;
- Wireshark.

O primeiro build pode precisar de internet para obter `python:3.13-slim` e Flask. O uso da aplicação depois do build ocorre em `127.0.0.1`.

## Início rápido

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\Iniciar-Laboratorio.ps1
```

Depois, abra `captura\captura_login.pcap` no Wireshark e execute:

```powershell
.\ferramenta\Laboratorio-Seguranca.ps1
```

Use somente o usuário encontrado no PCAP deste pacote. Após descobrir a senha e autenticar no portal em `http://127.0.0.1:8080`, baixe o material `material_*.enc` associado à sessão.

## Segurança do laboratório

O alvo da ferramenta é fixo em localhost. Os dados são fictícios e a vulnerabilidade é intencional: a atividade demonstra força bruta online, força bruta offline de um PIN de seis dígitos e o impacto de controles de autenticação ausentes.

Não use a ferramenta contra redes, contas ou serviços externos.

## Encerrar

```powershell
.\Parar-Laboratorio.ps1
```
