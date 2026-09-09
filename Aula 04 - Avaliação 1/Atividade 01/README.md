# Atividade 01 — investigação de acesso HTTPS, brute force e integridade

## Visão geral

Esta atividade é um laboratório local para dez alunos. Cada aluno recebe uma pasta independente contendo:

- uma captura Wireshark `.pcap` de uma conexão HTTPS completa;
- um arquivo de chaves TLS para permitir a análise didática do tráfego cifrado;
- uma lista de candidatos para o teste de senha web;
- uma lista de candidatos para a senha do arquivo ZIP;
- três ferramentas PowerShell com interface gráfica.

O professor inicia uma aplicação web HTTPS em Docker. Cada pasta de aluno corresponde a um usuário diferente, com senha web diferente e senha de criptografia diferente.

O nome do usuário deve ser descoberto a partir da captura. O aluno não recebe a tabela de credenciais do servidor.

## Escopo e regras de segurança

- O alvo autorizado é exclusivamente `https://127.0.0.1:8443`.
- A aplicação PowerShell bloqueia alvos que não sejam `localhost` ou `127.0.0.1`.
- Não use as ferramentas contra sites, redes, contas ou arquivos externos.
- O brute force é limitado a listas locais preparadas para esta aula.
- O arquivo ZIP contém somente textos didáticos sem dados pessoais.
- A captura e o arquivo `tls-keys.log` são material de laboratório. Não reutilize chaves ou credenciais fora dele.
- O professor deve manter a pasta `professor/` fora do material distribuído aos alunos.

## Dependências instaladas com winget

No Windows 10/11, instale:

```powershell
winget install --id Docker.DockerDesktop --exact --source winget
winget install --id Microsoft.PowerShell --exact --source winget
winget install --id WiresharkFoundation.Wireshark --exact --source winget
winget install --id 7zip.7zip --exact --source winget
```

| Pacote | Uso |
|---|---|
| `Docker.DockerDesktop` | Executar a aplicação HTTPS do professor |
| `Microsoft.PowerShell` | Executar os aplicativos gráficos `.ps1` |
| `WiresharkFoundation.Wireshark` | Abrir o `.pcap` e descriptografar a sessão com o key log |
| `7zip.7zip` | Testar senhas do ZIP AES e extrair o conteúdo |

O Docker Desktop já fornece Docker Engine, Docker CLI e Docker Compose. Não instale o Compose separadamente. O `curl.exe` do Windows é opcional e não é necessário para as ferramentas gráficas.

Depois da instalação, abra o Docker Desktop e aguarde **Engine running**.

## Estrutura do material

```text
Atividade 01/
├── README.md
├── docker-compose.yml
├── professor/                  # somente professor; ignorado pelo Git
│   ├── Dockerfile
│   ├── app.py
│   ├── users.json
│   ├── certs/
│   └── archives/
└── alunos/
    ├── aluno-01/
    ├── aluno-02/
    ├── ...
    └── aluno-10/
```

Cada diretório de aluno possui três aplicativos gráficos:

| Aplicativo | Finalidade |
|---|---|
| `01-BruteForce-Web.ps1` | Testar candidatos contra o login HTTPS local |
| `02-BruteForce-ZIP.ps1` | Testar candidatos do ZIP criptografado e extrair o conteúdo |
| `03-Hashes-Arquivos.ps1` | Calcular hashes e agrupar os sete pares |

O `LabAluno.psm1` é somente um módulo auxiliar importado pelos três aplicativos; ele não é executado diretamente.

## Preparação do professor

Na pasta da atividade, execute:

```powershell
docker compose up -d --build
docker compose ps
```

A aplicação estará em:

```text
https://127.0.0.1:8443
```

Como o certificado é didático e autoassinado, o navegador exibirá um aviso. No laboratório local, prossiga para o endereço somente depois de confirmar que a URL é `127.0.0.1:8443`.

Verificações do professor:

```powershell
docker compose logs --no-log-prefix web
docker compose exec web python /app/app.py --self-test
```

O comando de self-test valida o carregamento dos dez usuários e dos dez arquivos ZIP dentro do container. Ele não expõe as senhas no navegador.

## Roteiro do aluno

### 1. Analisar a captura HTTPS

1. Abra `captura_https.pcap` no Wireshark.
2. Configure o arquivo de chaves:
   - abra **Edit → Preferences → Protocols → TLS**;
   - em **(Pre)-Master-Secret log filename**, selecione o `tls-keys.log` da sua pasta;
   - confirme e recarregue o `.pcap`.
3. Use filtros como:

   ```text
   tls
   http
   tcp.port == 8443
   ```

4. Localize a requisição `POST /login` após a descriptografia.
5. Identifique o campo `username` e registre apenas o nome de usuário no relatório.

O campo de senha presente na captura é um valor de demonstração do tráfego e não deve ser tratado como a senha atual do usuário da aplicação.

### 2. Descobrir a senha web por brute force controlado

Execute:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
& .\alunos\aluno-XX\01-BruteForce-Web.ps1
```

Na interface:

1. mantenha o alvo `https://127.0.0.1:8443`;
2. informe o usuário encontrado no Wireshark;
3. selecione `wordlist-web.txt`;
4. clique em **Iniciar teste**;
5. registre a senha encontrada e a quantidade de tentativas.

A ferramenta aceita o certificado autoassinado somente para o alvo local e envia somente requisições `POST /login`.

### Tempo esperado

As listas foram ampliadas para tornar a descoberta uma atividade de aproximadamente **10 minutos por senha** no computador de referência: `wordlist-web.txt` possui 90.000 candidatos e `wordlist-zip.txt` possui 12.000. A senha correta está posicionada próxima ao fim de cada lista. O tempo real varia conforme CPU, Docker, PowerShell e 7-Zip; execute uma ferramenta por vez e não encerre a janela durante o teste.

### 3. Fazer login e obter o ZIP

Abra `https://127.0.0.1:8443` no navegador, aceite o aviso do certificado somente para `127.0.0.1`, faça login com o usuário e a senha encontrados e baixe o arquivo ZIP.

Salve o arquivo na sua pasta de trabalho. O servidor só disponibiliza o ZIP após um login válido.

### 4. Descobrir a senha do ZIP

Execute:

```powershell
& .\alunos\aluno-XX\02-BruteForce-ZIP.ps1
```

Na interface:

1. selecione o ZIP baixado;
2. selecione `wordlist-zip.txt`;
3. selecione uma pasta vazia para a extração;
4. clique em **Iniciar quebra**;
5. quando a senha for encontrada, clique em **Extrair conteúdo**.

O teste usa o `7z.exe` local e verifica o código de retorno do teste de integridade do arquivo. A aplicação não executa arquivos extraídos.

### 5. Identificar os sete pares por hash

Execute:

```powershell
& .\alunos\aluno-XX\03-Hashes-Arquivos.ps1
```

Selecione a pasta extraída e clique em **Gerar hashes**.

A tabela mostra:

- SHA-256 bruto, que muda quando os bytes têm espaços ou quebras de linha diferentes;
- SHA-256 normalizado, calculado após normalizar espaços, tabs e quebras de linha;
- grupo do par identificado.

O resultado esperado são **sete grupos com dois arquivos cada**. Os nomes dos arquivos são diferentes. Dentro de cada par, o texto visível é o mesmo, mas os bytes possuem pequenas diferenças invisíveis, como espaço no fim da linha ou quebra de linha final.

Os 14 arquivos foram organizados como sete textos-base diferentes, com duas variantes de cada texto. Assim, o agrupamento correto é feito pelo hash normalizado: cada variante de um mesmo texto forma um par, enquanto textos-base diferentes permanecem em grupos distintos.

## Entrega

Entregue um relatório curto contendo:

1. nome de usuário identificado no `.pcap` e evidência do pacote HTTPS descriptografado;
2. método de descoberta da versão/serviço e limites do teste;
3. senha web encontrada, número de tentativas e data/hora do teste;
4. senha do ZIP encontrada e evidência de extração;
5. tabela com os sete pares, seus nomes e hashes normalizados;
6. diferença entre hash bruto e hash normalizado;
7. observações éticas e medidas para proteger um serviço real contra brute force.

Não inclua no relatório a tabela completa de credenciais do professor.

## Encerramento

Professor:

```powershell
docker compose down --remove-orphans
```

Aluno: feche o Wireshark, apague as cópias locais do ZIP e não compartilhe o `tls-keys.log` fora da turma.
