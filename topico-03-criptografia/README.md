# Tópico 03 - Criptografia

## Objetivo

Praticar a diferença entre criptografia simétrica e assimétrica, relacionando chave, texto simples, texto cifrado e confidencialidade.

## Atividade 04 - Criptografia simétrica

Arquivo: `atividade-04-criptografia-simetrica.ps1`

O script utiliza AES para proteger o conteúdo de `dados/mensagem-confidencial.txt`. A mesma senha de laboratório é usada para derivar a chave de cifragem e recuperar o texto original.

### Modos de execução

- `Demonstrar`: cifra e decifra automaticamente;
- `Criptografar`: cria o arquivo cifrado em `resultado`;
- `Descriptografar`: recupera o texto a partir do arquivo cifrado.

Exemplo de chamada no console do ISE: `.\atividade-04-criptografia-simetrica.ps1 -Modo Demonstrar`

A senha padrão é propositalmente didática. Ela não deve ser utilizada em produção.

## Atividade 05 - Criptografia assimétrica

Arquivo: `atividade-05-criptografia-assimetrica.ps1`

O script cria ou reutiliza um certificado autoassinado no repositório do usuário atual e utiliza `Protect-CmsMessage` e `Unprotect-CmsMessage`. A proteção usa a chave pública; a recuperação depende da chave privada.

O certificado é apenas de laboratório e não representa uma cadeia de confiança real. A atividade é executada localmente e não envia dados para a internet.
