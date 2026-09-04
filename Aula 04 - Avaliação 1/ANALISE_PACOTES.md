# Análise dos pacotes — Aula 04

## Resumo

Os arquivos são três níveis de distribuição do mesmo laboratório:

- `Pacote_Aluno.zip`: ambiente executável e roteiro da avaliação;
- `Pacote_Professor.zip`: pacote do aluno mais materiais reservados ao docente;
- `Laboratorio_Completo.zip`: contêiner de distribuição que reúne os dois pacotes e uma nota de orientação.

O objetivo pedagógico é mostrar que um algoritmo criptográfico forte não compensa credenciais de baixa entropia nem controles de autenticação ausentes.

## O que cada pacote faz

### `Pacote_Aluno.zip`

É o pacote entregue à turma. Ele contém:

| Caminho | Função |
| --- | --- |
| `docker-compose.yml` | Constrói e inicia o serviço web; publica a porta `8080` somente em `127.0.0.1` e injeta os hashes das credenciais do laboratório. |
| `Iniciar-Laboratorio.ps1` | Confere se o Docker está disponível e executa `docker compose up -d --build`. |
| `Parar-Laboratorio.ps1` | Encerra e remove o ambiente com `docker compose down`. |
| `ferramenta/Laboratorio-Seguranca.ps1` | Interface gráfica Windows Forms com duas abas: tentativa de senhas do login e tentativa de PINs do arquivo. O alvo é fixo em localhost. |
| `roteiro/ATIVIDADE.md` | Enunciado, regras de escopo, etapas e perguntas da avaliação. |
| `roteiro/RESPOSTAS.md` | Folha para registrar evidências e respostas. |
| `captura/captura_login.pcap` | Captura sintética para identificar o usuário e observar que a senha não foi enviada. |
| `servidor/Dockerfile` e `requirements.txt` | Definem uma imagem Python 3.13 mínima com Flask 3.1.2. |
| `servidor/app/app.pyc` | Bytecode do servidor Flask usado pelo aluno. A versão legível do fonte fica no pacote do professor. |
| `servidor/app/templates` e `static` | Tela de login, área restrita e folha de estilos. |
| `servidor/dados/desafio.enc` | Arquivo que só pode ser baixado depois da autenticação e que é usado na segunda etapa. |

### `Pacote_Professor.zip`

É um pacote de apoio ao docente. Além de uma cópia byte a byte do `Pacote_Aluno.zip`, inclui:

- `PREPARACAO.md`: conferências e instruções para preparar a aula;
- `GABARITO.md`: respostas esperadas, conceitos e sugestão de pontuação;
- `SEGREDOS.txt`: valores de validação que não devem ser distribuídos;
- `codigo_fonte_servidor/app.py`: fonte legível da aplicação Flask.

O bytecode no pacote do aluno reduz a inspeção casual do código durante a avaliação, mas não constitui uma medida de proteção para um sistema real.

### `Laboratorio_Completo.zip`

É um envelope de distribuição com três entradas: `Pacote_Aluno.zip`, `Pacote_Professor.zip` e `LEIA_PRIMEIRO.txt`. A orientação interna confirma que apenas o pacote do aluno deve ser entregue à turma. Como ele contém o pacote do professor, deve ser tratado como material reservado ao docente.

## Fluxo técnico completo

### 1. Análise do PCAP

O PCAP é uma captura clássica de cinco quadros: handshake TCP simplificado, uma requisição HTTP e o ACK correspondente. A requisição é um `POST` para `/identificar`, com `Content-Type: application/x-www-form-urlencoded` e um corpo que contém somente o campo `username`.

O endereço do cliente é `192.168.56.10` e o do servidor é `192.168.56.20`. A senha não aparece. O caminho `/identificar` é uma amostra didática independente; ele não é uma rota do servidor Flask em execução, que usa `/login` e `/api/login`.

### 2. Login online

O servidor compara o hash SHA-256 do usuário e o hash SHA-256 de uma senha precedida por um salt fixo, ambos recebidos por variáveis de ambiente no Compose. A rota usada pela ferramenta é `POST /api/login`.

A primeira aba testa sequencialmente todas as combinações de `0000` a `9999`. Quando recebe HTTP 200, considera a senha encontrada. O portal web usa `POST /login`, cria uma sessão Flask e libera `/area` e `/download/desafio.enc` para uma sessão autenticada.

### 3. Arquivo criptografado

O arquivo usa a seguinte estrutura lógica:

```text
desafio.enc = IV de 16 bytes || ciphertext AES-CBC
chave      = SHA-256(ASCII do PIN decimal de 6 dígitos)
plaintext  = marcador conhecido de 16 bytes || ZIP || padding PKCS#7
```

A segunda aba testa `000000` a `999999`, valida o primeiro bloco contra o marcador conhecido e, quando encontra uma chave compatível, descriptografa o conteúdo completo. Em seguida cria `resultado/documentos.zip` e extrai `resultado/documentos/`.

O ZIP interno contém um arquivo de conclusão, um inventário CSV, uma descrição JSON de rede e uma política fictícia. Os valores do gabarito não são repetidos nesta documentação.

O AES-256 não é quebrado nesse cenário. O problema é que um PIN decimal de seis dígitos oferece no máximo `log2(1.000.000) ≈ 19,93` bits de entropia, e o teste é offline: depois do download, cada tentativa ocorre localmente, sem depender de novas respostas do servidor.

## Avaliação de segurança

As fragilidades abaixo são intencionais e fazem parte do exercício:

| Elemento | Efeito didático | Tratamento em um sistema real |
| --- | --- | --- |
| Sem rate limiting, bloqueio ou MFA | Permite automatizar o login online. | Limitação progressiva, detecção de anomalias, bloqueio controlado e MFA. |
| Senha numérica curta | Reduz o espaço de busca para 10.000 tentativas. | Senha de alta entropia e política contra credenciais fracas. |
| SHA-256 rápido com salt fixo | Torna a validação de senha inadequada para produção. | Argon2id, scrypt ou bcrypt com salt aleatório por credencial. |
| HTTP sem TLS | Expõe requisições em redes reais. | HTTPS com certificados válidos e configuração segura de sessão. |
| PIN de seis dígitos para derivar a chave | Torna o AES forte vulnerável a busca offline. | Segredo aleatório de alta entropia ou KDF resistente a busca, com parâmetros adequados. |
| IV fixo e ausência de autenticação criptográfica | Não oferece as garantias esperadas para uso geral. | IV/nonce aleatório por mensagem e AEAD, como AES-GCM ou ChaCha20-Poly1305. |
| `FLASK_SECRET` definido no Compose e fallback no código | Facilita falsificação de sessão se o serviço sair do laboratório. | Segredo aleatório fora do repositório e cookies com flags de segurança. |

Os controles que reduzem o risco operacional do exercício são o bind em `127.0.0.1`, o uso de dados fictícios e a ausência de necessidade de elevação administrativa.

## Validações realizadas

- `Laboratorio_Completo.zip` abre e contém 3 entradas; `Pacote_Aluno.zip` contém 15; `Pacote_Professor.zip` contém 5.
- A cópia de `Pacote_Aluno.zip` dentro do pacote do professor tem o mesmo SHA-256 do arquivo principal.
- O `docker-compose.yml` foi validado pelo Compose.
- Os três scripts PowerShell foram analisados sem erros de sintaxe.
- O fonte Python do professor compila com Python 3.13, mesma linha da imagem usada no Dockerfile.
- O PCAP foi decodificado e confirmou os cinco quadros, os endereços IP, o `POST` e a ausência de senha.
- O `desafio.enc` foi validado com o material reservado do professor e produziu um ZIP interno legível com os quatro documentos esperados.

A inicialização ponta a ponta do contêiner ficou pendente nesta análise porque o daemon do Docker Desktop não estava em execução no ambiente. Antes da aula, o docente deve iniciar o Docker Desktop e repetir o teste descrito em `Pacote_Professor/PREPARACAO.md`.
