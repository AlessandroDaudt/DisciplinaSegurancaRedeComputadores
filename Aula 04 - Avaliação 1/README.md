# Aula 04 — Avaliação 1

Esta pasta contém um laboratório isolado para a primeira avaliação da disciplina. A atividade aborda análise de PCAP, força bruta online contra um login deliberadamente vulnerável e força bruta offline contra um arquivo criptografado.

Para a análise detalhada do conteúdo, do fluxo e dos cuidados de segurança, consulte [ANALISE_PACOTES.md](ANALISE_PACOTES.md).

## Pacotes disponíveis

| Arquivo | Uso | Conteúdo |
| --- | --- | --- |
| [Pacote_Aluno.zip](Pacote_Aluno.zip) | Distribuir à turma | Laboratório Docker, ferramenta PowerShell, PCAP, roteiro e folha de respostas |
| [Pacote_Professor.zip](Pacote_Professor.zip) | Manter somente com o docente | Pacote do aluno, fonte do servidor, preparação, gabarito e segredos de validação |
| [Laboratorio_Completo.zip](Laboratorio_Completo.zip) | Arquivo do docente | Reúne o pacote do aluno, o pacote do professor e uma orientação de distribuição |

Não distribua `Pacote_Professor.zip` nem `Laboratorio_Completo.zip` aos alunos: ambos carregam materiais que revelam a solução da avaliação.

## Fluxo da atividade

1. O docente distribui somente `Pacote_Aluno.zip`.
2. O aluno extrai o pacote no Windows, lê o README interno e inicia o laboratório com `Iniciar-Laboratorio.ps1`.
3. A aplicação Flask fica disponível apenas em `http://127.0.0.1:8080`.
4. O aluno analisa `captura/captura_login.pcap` no Wireshark para identificar o usuário.
5. A ferramenta `ferramenta/Laboratorio-Seguranca.ps1` testa o espaço de senhas do login e, depois do download autenticado, testa o espaço de PINs de `desafio.enc`.
6. O resultado é produzido em uma pasta `resultado`, que não deve ser versionada.

## Requisitos

- Windows 10 ou Windows 11;
- Windows PowerShell 5.1 ou superior;
- Docker Desktop com o comando `docker compose` disponível;
- Wireshark para a análise do PCAP.

O primeiro build pode precisar de acesso à internet para obter a imagem `python:3.13-slim` e instalar Flask. Depois que a imagem estiver disponível, a execução da atividade ocorre localmente. O daemon do Docker precisa estar iniciado antes de executar o script de inicialização.

## Uso seguro

O material usa dados fictícios e fixa o alvo em localhost, mas contém vulnerabilidades intencionais para fins didáticos. Execute-o somente no ambiente da disciplina e não adapte a ferramenta para endereços, contas ou serviços de terceiros sem autorização.
