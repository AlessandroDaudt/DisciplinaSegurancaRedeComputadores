# Roteiro do aluno 10

Este conjunto é individual. Trabalhe apenas com `https://127.0.0.1:8443` ou com o endereço privado autorizado do professor em `10.0.0.0/8` ou `192.168.0.0/16`, sempre na porta 8443, e com os arquivos desta pasta.

## Objetivos

1. Usar o Wireshark para reconstruir uma conexão HTTPS e localizar o `POST /login`.
2. Identificar o campo `username` da requisição.
3. Testar a lista fornecida contra o login local usando a ferramenta gráfica.
4. Baixar o ZIP após o login e descobrir a senha de criptografia com a segunda ferramenta gráfica.
5. Extrair os 14 textos e localizar os sete pares com a terceira ferramenta gráfica.

## 1. Captura

1. Abra `captura_https.pcap` no Wireshark.
2. Em **Edit → Preferences → Protocols → TLS**, informe o arquivo `tls-keys.log` no campo **(Pre)-Master-Secret log filename**.
3. Recarregue a captura e use `tls`, `http` ou `tcp.port == 8443`.
4. Localize `POST /login` e registre o valor de `username`.

O `tls-keys.log` acompanha a captura para esta análise didática. O valor de `password` visto nessa captura é apenas um valor de demonstração do tráfego.

## 2. Login controlado

Abra o PowerShell 7 na pasta deste aluno e execute:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
& .\01-BruteForce-Web.ps1
```

Informe o usuário obtido no Wireshark, use `https://127.0.0.1:8443` ou o endereço privado autorizado do professor, selecione `wordlist-web.txt` e inicie o teste.

Abra a mesma URL autorizada no navegador, faça login com o resultado e baixe o ZIP. Aceite o aviso de certificado somente para o endereço do laboratório.

As listas desta atividade foram dimensionadas para que a descoberta de cada senha leve aproximadamente dez minutos no computador de referência. O tempo varia conforme o hardware e as versões instaladas; não encerre a ferramenta enquanto o teste estiver em andamento.

## 3. ZIP protegido

Execute `02-BruteForce-ZIP.ps1`, selecione o ZIP baixado e `wordlist-zip.txt`, escolha uma pasta vazia e inicie a quebra. Quando a senha for encontrada, use **Extrair conteúdo**.

## 4. Hashes

Execute `03-Hashes-Arquivos.ps1`, selecione a pasta extraída e gere os hashes. Compare os hashes normalizados e entregue os sete grupos de dois arquivos. Explique por que os hashes brutos podem ser diferentes quando há espaços ou quebras de linha invisíveis.

Não tente acessar endereços fora das redes privadas autorizadas, sites ou contas. Esta atividade foi preparada para o serviço da aula.
