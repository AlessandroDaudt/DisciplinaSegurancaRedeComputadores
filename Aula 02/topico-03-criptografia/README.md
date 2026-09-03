# Tópico 03 — Criptografia

## Objetivo

Comparar criptografia simétrica e assimétrica, relacionando chaves, texto simples, texto cifrado e confidencialidade.

## Atividade 04 — Criptografia simétrica

Script: [atividade-04-criptografia-simetrica.ps1](atividade-04-criptografia-simetrica.ps1)

Interface para alunos: [interface-atividade-04-criptografia-simetrica.ps1](interface-atividade-04-criptografia-simetrica.ps1)

O exercício usa AES para proteger o conteúdo de [dados/mensagem-confidencial.txt](dados/mensagem-confidencial.txt). A mesma senha de laboratório é usada para derivar a chave e recuperar o texto original.

Modos disponíveis:

- `Demonstrar`: cifra e decifra automaticamente;
- `Criptografar`: cria o arquivo cifrado em `resultado`;
- `Descriptografar`: recupera o texto a partir do arquivo cifrado.

Exemplo:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\atividade-04-criptografia-simetrica.ps1" -Modo Demonstrar
```

A senha padrão é propositalmente didática e não deve ser usada em produção.

## Atividade 05 — Criptografia assimétrica

Script: [atividade-05-criptografia-assimetrica.ps1](atividade-05-criptografia-assimetrica.ps1)

Interface para alunos: [interface-atividade-05-criptografia-assimetrica.ps1](interface-atividade-05-criptografia-assimetrica.ps1)

O script cria ou reutiliza um certificado autoassinado no repositório do usuário atual e usa `Protect-CmsMessage` e `Unprotect-CmsMessage`. A proteção usa a chave pública; a recuperação depende da chave privada.

O certificado é exclusivo do laboratório e não representa uma cadeia de confiança real. A atividade é local e não envia dados para a internet.
