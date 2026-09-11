# Roteiro do aluno — Avaliação 2

## Regras

- Execute tudo somente neste laboratório local.
- Não altere as portas para expor os alvos à rede ou à Internet.
- Não teste outros endereços, serviços ou contas.
- Não use reverse shell, persistência ou payload externo.
- Registre evidências antes e depois da correção.

## 1. Iniciar o laboratório

No PowerShell:

```powershell
Set-Location 'C:\projetos\DisciplinaSegurancaRedeComputadores\Aula 06 - Avaliação 2\lab-docker-vulnerabilidades'
git pull
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\scripts\start.ps1
docker compose ps
```

A política de execução vale somente para esta janela do PowerShell.

Confirme que estão ativos: `apache`, `mysql`, `osroot` e `exploiter`.

## 2. Fazer a varredura inicial

```powershell
New-Item -ItemType Directory -Force .\resultado | Out-Null
.\scripts\scan.ps1 | Tee-Object .\resultado\varredura-antes.txt
```

Anote para cada alvo:

- serviço e versão;
- porta;
- resultado do scanner;
- CVE indicado na seção `CVEs para pesquisa`;
- comportamento observado;
- possível vulnerabilidade.

## 3. Investigar o Apache

1. Acesse `http://127.0.0.1:8081`.
2. Pesquise o CVE indicado no resultado e confira a versão encontrada.
3. Registre a fonte consultada, o identificador e a correção indicada.
4. Abra o Metasploit:

```powershell
docker compose exec exploiter msfconsole -q
```

Dentro do Metasploit:

```text
search type:exploit apache
info <modulo_escolhido>
use <modulo_escolhido>
set RHOSTS apache
set RPORT 80
show options
check
run
```

Use somente um módulo compatível com o alvo. Registre uma evidência mínima e
inofensiva do resultado.

## 4. Investigar o MySQL

Execute:

```powershell
docker compose --profile tools run --rm scanner -Pn -sV -p 3306 mysql
docker compose --profile tools run --rm mysql-check
```

1. Relacione o CVE indicado, a versão e o comportamento observado.
2. Pesquise a referência e a versão corrigida.
3. Registre a evidência do acesso indevido.
4. Consulte somente dados fictícios do laboratório.
5. Não altere tabelas, senhas ou dados.

## 5. Investigar o Linux/SSH

Conecte-se ao alvo:

```powershell
ssh -p 2222 aluno@127.0.0.1
```

Senha: `aluno`

Dentro do container, faça a enumeração:

```bash
id
uname -a
sudo --version
sudo -l
```

1. Pesquise o CVE indicado e confira a versão e a configuração encontrada.
2. Registre a referência e a correção indicada.
3. Faça uma demonstração controlada somente dentro do container.
4. Use `id` para registrar o resultado.
5. Saia do SSH com `exit`.

## 6. Corrigir os três alvos

Edite somente os arquivos do laboratório.

- Apache: atualizar para uma versão corrigida e remover a configuração
  insegura de CGI e de acesso ao sistema de arquivos.
- MySQL: usar uma versão corrigida, restringir a administração remota e
  aplicar autenticação e privilégios mínimos.
- Linux/SSH: atualizar o componente vulnerável e remover a regra ampla de
  `sudo`.

Depois das alterações:

```powershell
docker compose down
docker compose build --no-cache apache osroot
docker compose pull mysql
docker compose up -d
docker compose ps
```

Se você alterou a imagem do MySQL no Compose, confirme que a nova versão foi
baixada antes de iniciar os serviços.

## 7. Validar a correção

```powershell
.\scripts\scan.ps1 | Tee-Object .\resultado\varredura-depois.txt
```

Repita os testes autorizados e confirme que:

- o Apache não apresenta mais o comportamento vulnerável;
- o acesso indevido ao MySQL não é mais aceito;
- a elevação de privilégio no Linux não funciona mais;
- os serviços continuam disponíveis somente nas funções necessárias.

## 8. Entrega

Entregue um relatório contendo:

1. tabela com serviço, versão, porta e vulnerabilidade de cada alvo;
2. fonte consultada e correção indicada;
3. evidência da situação inicial;
4. alteração aplicada;
5. evidência da validação após a correção;
6. arquivos `varredura-antes.txt` e `varredura-depois.txt`.

## 9. Encerrar o laboratório

```powershell
docker compose down
```
