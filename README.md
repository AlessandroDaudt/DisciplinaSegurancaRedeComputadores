# Segurança de Redes de Computadores

Repositório de apoio para a disciplina de Segurança de Redes de Computadores. O conteúdo reúne materiais de aula, espaços para avaliações e atividades práticas em Windows PowerShell.

> Uso acadêmico e laboratorial. Execute os scripts somente no ambiente local de testes e com autorização.

## Como começar

1. Escolha a aula que deseja estudar e leia o README da pasta.
2. Consulte o PDF do tópico, quando ele estiver disponível.
3. Para realizar as atividades práticas, abra [Aula 02](Aula%2002/README.md).
4. Execute a [interface principal](interface-principal.ps1) ou abra diretamente o script indicado no roteiro.

Para iniciar a interface pelo Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\interface-principal.ps1"
```

O parâmetro `-ExecutionPolicy Bypass` vale apenas para o processo iniciado e não altera a política permanente do computador.

## Organização do repositório

| Pasta | Conteúdo |
| --- | --- |
| [Aula 01](Aula%2001/) | Material em PDF do Tópico 1 — Fundamentos e tríade CIA |
| [Aula 02](Aula%2002/) | Atividades práticas em PowerShell, organizadas por tópico |
| [Aula 03](Aula%2003/) | Material em PDF do Tópico 3 — Criptografia |
| [Aula 04 - Avaliação 1](Aula%2004%20-%20Avalia%C3%A7%C3%A3o%201/) | Espaço reservado para a primeira avaliação |
| [Aula 05](Aula%2005/) | Material em PDF do Tópico 4 — Autenticidade e responsabilização |
| [Aula 06 - Avaliação 2](Aula%2006%20-%20Avalia%C3%A7%C3%A3o%202/) | Material em PDF do Tópico 5 — Ameaças, ataques e mini-SOC |
| [Aula 07 - Avaliação 3](Aula%2007%20-%20Avalia%C3%A7%C3%A3o%203/) | Espaço reservado para a terceira avaliação |
| [Aula 08 - Recuperação](Aula%2008%20-%20Recupera%C3%A7%C3%A3o/) | Espaço reservado para a recuperação |

As atividades de PowerShell ficam concentradas em [Aula 02](Aula%2002/), conforme a organização definida para este material de apoio. O PDF do Tópico 2 não estava presente na pasta recebida, mas as atividades de integridade e hash estão disponíveis.

## Atividades práticas

| Atividade | Tema | Arquivo |
| --- | --- | --- |
| 01 | Auditoria da tríade CIA | [atividade-01](Aula%2002/topico-01-fundamentos-e-cia/atividade-01-auditoria-cia.ps1) |
| 02 e 03 | Integridade, hash e linha de base | [tópico 02](Aula%2002/topico-02-integridade-e-hash/README.md) |
| 04 e 05 | Criptografia simétrica e assimétrica | [tópico 03](Aula%2002/topico-03-criptografia/README.md) |
| 06 e 07 | Assinaturas, logs e análise forense | [tópico 04](Aula%2002/topico-04-autenticidade-e-responsabilizacao/README.md) |
| 08 e 09 | Classificação de cenários e mini-SOC | [tópico 05](Aula%2002/topico-05-ameacas-ataques-e-mini-soc/README.md) |

Cada tópico possui seu próprio roteiro e uma pasta `dados` com arquivos sintéticos. Os resultados gerados durante a execução ficam em pastas `resultado`, que não devem ser versionadas.

## Requisitos

- Windows 10 ou Windows 11;
- Windows PowerShell 5.1;
- PowerShell ISE, caso queira usar a interface e executar as atividades interativas;
- permissão de leitura e gravação na cópia local do repositório.

As atividades não dependem de internet nem de acesso a máquinas de terceiros. A atividade de criptografia assimétrica pode criar um certificado autoassinado no repositório de certificados do usuário atual, exclusivamente para demonstração.

## Escopo de segurança

Os scripts trabalham com arquivos locais de teste e dados sintéticos. A coleta opcional do mini-SOC é somente de leitura. Não adapte ou execute o material contra redes, contas, serviços ou dispositivos sem autorização formal.

## Licença e uso

Este repositório é material didático de apoio. Preserve os roteiros e os dados sintéticos ao adaptar os exercícios para a turma.
