# Atividade Avaliada — Força Bruta, PCAP, Criptografia e Hashes

## Objetivo

Analisar o PCAP individual, descobrir a senha de uma conta de laboratório, baixar o material criptografado associado à conta e recuperar os pares de arquivos com o mesmo hash.

## Regras

- Use somente o ambiente local fornecido pela disciplina.
- Não altere os arquivos do servidor Docker.
- Não use a ferramenta contra endereços externos. Ela já está fixada em `127.0.0.1`.
- Não troque o PCAP deste pacote com o de outro aluno.

## Etapa 1 — PCAP

Abra `captura/captura_login.pcap` no Wireshark. A captura possui uma conexão TCP sintética e uma requisição HTTP com o usuário.

Sugestões de filtro:

- `http`
- `http.request.method == POST`

Responda:

1. Qual o IP do cliente?
2. Qual o IP do servidor?
3. Qual método HTTP aparece?
4. Qual usuário está presente na requisição?
5. A senha aparece na captura?

## Etapa 2 — Força bruta no login

1. Execute `ferramenta/Laboratorio-Seguranca.ps1`.
2. Digite o usuário obtido no PCAP.
3. Inicie a busca de senha.
4. Registre a senha encontrada e o tempo aproximado.
5. Abra `http://127.0.0.1:8080`, autentique-se e baixe o material `material_*.enc`.

A aplicação possui 12 contas, mas o PCAP deste pacote identifica a conta que deve ser usada nesta avaliação.

## Etapa 3 — Força bruta criptográfica

1. Na segunda aba da ferramenta, selecione o material `.enc` baixado.
2. Inicie a busca do PIN.
3. Ao final, a ferramenta criará `resultado/documentos.zip` e extrairá os 14 documentos em `resultado/documentos/`.

## Etapa 4 — Casamento por hash

1. Calcule o SHA-256 de `arquivo01.txt` até `arquivo14.txt`.
2. Agrupe os arquivos que possuem exatamente o mesmo hash.
3. Há sete pares: cada arquivo tem um único par correspondente.
4. Os pares têm o mesmo conteúdo byte a byte; os demais arquivos mantêm o mesmo texto, mas variam em espaços ou quebras de linha.

## Questões finais

6. Qual controle reduziria diretamente o ataque de força bruta contra o login? Cite três.
7. O arquivo usa AES-256. Por que ainda foi possível recuperar o conteúdo rapidamente?
8. Qual é aproximadamente a entropia máxima de um PIN decimal de 6 dígitos?
9. Qual a diferença entre força bruta online contra login e força bruta offline contra um arquivo?
10. Por que dois arquivos com o mesmo hash devem ser comparados byte a byte antes de serem considerados duplicados em outro contexto?
11. Cite uma melhoria para cada etapa do laboratório.
