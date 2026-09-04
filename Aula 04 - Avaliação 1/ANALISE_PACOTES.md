# Análise dos pacotes — Aula 04

## Modelo da turma

O laboratório foi preparado para 12 alunos. O docente entrega um pacote numerado para cada pessoa:

| Pacote | PCAP entregue | Conta identificada | Material liberado após o login |
| --- | --- | --- | --- |
| `Pacote_Aluno_01.zip` | exclusivo do pacote 01 | uma conta `aluno01` | `material_aluno01.enc` |
| … | cada pacote tem bytes próprios | uma conta correspondente ao número | um material correspondente |
| `Pacote_Aluno_12.zip` | exclusivo do pacote 12 | uma conta `aluno12` | `material_aluno12.enc` |

O PCAP de cada pacote é diferente e contém somente o usuário daquela distribuição. A aplicação copiada em cada pacote conhece as 12 contas e os 12 materiais, mas a rota de download usa o usuário da sessão para selecionar o material correspondente.

O repositório não contém pacote de professor, gabarito, senha em claro, PIN em claro ou tabela de respostas. O gerador só cria um manifesto de respostas quando o docente informa explicitamente um caminho privado fora da pasta versionada.

## Conteúdo de cada pacote de aluno

Cada `Pacote_Aluno_XX.zip` possui 27 arquivos externos:

| Caminho | Função |
| --- | --- |
| `docker-compose.yml` | Constrói o servidor e publica `127.0.0.1:8080`. |
| `Iniciar-Laboratorio.ps1` | Inicia o laboratório com `docker compose up -d --build`. |
| `Parar-Laboratorio.ps1` | Remove o container e a rede do laboratório. |
| `ferramenta/Laboratorio-Seguranca.ps1` | Interface Windows Forms para força bruta online do login e offline do material. |
| `roteiro/ATIVIDADE.md` | Enunciado com PCAP, login, descriptografia e casamento por hash. |
| `roteiro/RESPOSTAS.md` | Folha de respostas sem valores preenchidos. |
| `captura/captura_login.pcap` | Única captura do pacote, específica do aluno. |
| `servidor/app/app.pyc` | Bytecode do servidor Flask; o fonte fica no diretório `modelo` do repositório para geração, não no pacote entregue. |
| `servidor/dados/usuarios.json` | 12 nomes, hashes de usuário/senha e associação de cada usuário ao material; não contém senhas ou PINs em claro. |
| `servidor/dados/materiais/material_aluno01.enc` … `material_aluno12.enc` | 12 materiais criptografados, cada um com PIN próprio. |
| `servidor/app/templates` e `static` | Telas do portal e folha de estilos. |

## Geração

O [gerar-pacotes.ps1](gerar-pacotes.ps1) é o único gerador necessário. Ele:

1. cria 12 usuários `aluno01` a `aluno12`;
2. sorteia 12 senhas numéricas de quatro dígitos, todas diferentes;
3. sorteia 12 PINs decimais de seis dígitos, todos diferentes;
4. grava somente hashes das credenciais em `usuarios.json`;
5. cria 12 PCAPs com endereços, portas, sequências e usuário distintos;
6. cria um material criptografado por usuário;
7. empacota os arquivos sem fonte do servidor e sem material reservado.

As senhas e os PINs existem em memória durante a geração. O parâmetro opcional `-PrivateManifestPath` produz um controle para o docente; o script rejeita um caminho dentro do diretório de saída para evitar que o gabarito seja incluído por acidente.

## Fluxo técnico

### 1. PCAP individual

Cada captura é um PCAP clássico de cinco quadros: handshake TCP sintético, ACK, requisição HTTP e ACK final. A requisição é um `POST /identificar` com `Content-Type: application/x-www-form-urlencoded` e corpo contendo somente `username=...`. Não há senha no PCAP.

O caminho `/identificar` é uma amostra didática independente; o servidor em execução usa `/login` e `/api/login`.

### 2. Login online

O servidor carrega os 12 registros de `usuarios.json`. Para cada conta, ele compara o SHA-256 do usuário e o SHA-256 de `lab-salt-2026:` concatenado à senha. A ferramenta usa `POST /api/login` e testa sequencialmente `0000` a `9999`.

Depois do login web em `POST /login`, a sessão Flask libera `/area` e `/download/material.enc`. A aplicação localiza o registro da sessão e envia somente o material associado àquele usuário.

### 3. Material criptografado

Cada `material_*.enc` possui a estrutura:

```text
material.enc = IV aleatório de 16 bytes || ciphertext AES-CBC
chave        = SHA-256(ASCII do PIN decimal de 6 dígitos)
plaintext    = marcador conhecido de 16 bytes || ZIP || padding PKCS#7
```

A ferramenta testa `000000` a `999999`, valida o primeiro bloco conhecido e, ao encontrar o PIN, descriptografa o ZIP completo em `resultado/documentos.zip`.

### 4. Casamento dos arquivos

Cada material contém exatamente `arquivo01.txt` até `arquivo14.txt`. Existem sete variantes de whitespace do mesmo texto semântico; cada variante é usada em dois arquivos byte a byte idênticos. Portanto, cada material possui sete hashes distintos e cada hash aparece exatamente duas vezes. Espaços no fim das linhas, linhas em branco e finais de linha diferentes são suficientes para produzir hashes distintos sem alterar o texto lido.

O material também recebe um identificador de conjunto dentro do texto comum, de forma que os 12 materiais sejam diferentes além da chave e do IV. Dentro de um mesmo material, os 14 arquivos continuam semanticamente iguais.

## Avaliação de segurança

As fragilidades são deliberadas:

| Fragilidade | Demonstração | Mitigação real |
| --- | --- | --- |
| Ausência de rate limiting, bloqueio e MFA | Viabiliza força bruta online. | Limitação progressiva, detecção de anomalias, bloqueio controlado e MFA. |
| Senha numérica de quatro dígitos | Espaço de apenas 10.000 tentativas. | Senhas de alta entropia e proteção contra credenciais fracas. |
| PIN de seis dígitos | Espaço de apenas 1.000.000 de chaves, cerca de 19,93 bits. | Segredo aleatório de alta entropia e KDF adequada. |
| SHA-256 rápido para senha/PIN | Facilita testes offline. | Argon2id, scrypt ou bcrypt para senhas; parâmetros adequados para derivação. |
| HTTP e segredo Flask de laboratório | Não é apropriado para produção. | HTTPS, segredo fora do repositório e cookies com flags de segurança. |

O bind em `127.0.0.1`, os dados fictícios e o alvo fixo da ferramenta reduzem o risco operacional do exercício; eles não transformam as vulnerabilidades em controles de produção.

## Validação do conteúdo gerado

Após a geração atual, foram confirmados:

- 12 zips extraíveis e 12 cópias descompactadas equivalentes, sem `GABARITO`, `SEGREDOS`, fonte do professor ou pacote de professor;
- 12 senhas de login únicas e 12 PINs únicos, mantidos somente no manifesto privado temporário usado no teste;
- 12 PCAPs com hashes distintos e o usuário correspondente em cada captura;
- 12 contas e 12 materiais em cada pacote;
- 14 nomes corretos por material, texto semântico comum e sete pares exatos de SHA-256;
- geração do bytecode Python 3.13 e configuração Compose válida;
- servidor pronto para ser iniciado em localhost, com o Docker Desktop como único pré-requisito de execução.

O build do Docker requer que o Docker Desktop esteja iniciado e pode baixar a imagem base e o Flask na primeira execução.
