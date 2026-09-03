# Disciplina: Segurança de Redes de Computadores

Repositório didático com atividades práticas desenvolvidas em **Windows PowerShell 5.1**, utilizando o **PowerShell ISE**. O material foi organizado para apoiar o estudo dos fundamentos de segurança da informação e a observação de evidências de segurança em um ambiente local e controlado.

> Material destinado exclusivamente a fins acadêmicos e laboratoriais.

## Objetivos

Ao concluir as atividades, o estudante deverá ser capaz de:

- relacionar confidencialidade, integridade e disponibilidade à tríade CIA;
- diferenciar ameaça, ataque e vulnerabilidade;
- utilizar hashes para verificar a integridade de arquivos;
- reconhecer as diferenças entre criptografia simétrica e assimétrica;
- verificar autenticidade por meio de assinaturas digitais;
- interpretar registros de eventos e organizar uma linha do tempo;
- realizar uma triagem inicial de indicadores de segurança.

## Organização do repositório

| Tópico | Conteúdo principal | Atividades |
|---|---|---|
| 01 - Fundamentos e CIA | Segurança da informação e tríade CIA | Auditoria de confidencialidade, integridade e disponibilidade |
| 02 - Integridade e hash | Hash, linha de base e detecção de alterações | Verificação de hash e monitoramento de arquivos |
| 03 - Criptografia | Criptografia simétrica e assimétrica | Proteção com AES e CMS/certificado |
| 04 - Autenticidade e responsabilização | Assinaturas, registros e forense | Verificação de assinatura e análise de eventos |
| 05 - Ameaças, ataques e mini-SOC | Classificação e triagem | Exercício interativo e relatório de triagem |

Cada tópico possui um `README.md` próprio, scripts `.ps1` e uma pasta `dados` com os arquivos de teste necessários.

## Requisitos

- Windows 10 ou Windows 11;
- Windows PowerShell 5.1;
- PowerShell ISE;
- permissão para ler os arquivos da pasta do laboratório.

As atividades foram planejadas para não depender de internet, ferramentas externas ou acesso a máquinas de terceiros. A atividade de criptografia assimétrica cria, quando necessário, um certificado **autoassinado apenas para o laboratório** no repositório de certificados do usuário atual.

## Como executar em sala de aula

1. Abra o PowerShell ISE.
2. Abra um dos arquivos `.ps1` do repositório.
3. Leia o `README.md` do respectivo tópico.
4. Execute o script com `F5` ou selecione somente uma parte do código e pressione `F8`.
5. Observe os resultados e registre as conclusões no caderno ou no relatório da disciplina.

Os arquivos e pastas criados automaticamente durante os exercícios são gravados em `resultado` e já estão protegidos pelo `.gitignore`.

## Roteiro recomendado

1. `topico-02-integridade-e-hash/atividade-02-hash-integridade.ps1`
2. `topico-02-integridade-e-hash/atividade-03-monitoramento-alteracoes.ps1`
3. `topico-01-fundamentos-e-cia/atividade-01-auditoria-cia.ps1`
4. `topico-03-criptografia/atividade-04-criptografia-simetrica.ps1`
5. `topico-03-criptografia/atividade-05-criptografia-assimetrica.ps1`
6. `topico-04-autenticidade-e-responsabilizacao/atividade-06-autenticidade-assinatura.ps1`
7. `topico-04-autenticidade-e-responsabilizacao/atividade-07-logs-e-forense.ps1`
8. `topico-05-ameacas-ataques-e-mini-soc/atividade-08-classificacao-seguranca.ps1`
9. `topico-05-ameacas-ataques-e-mini-soc/atividade-09-mini-soc.ps1`

## Segurança e escopo

Os scripts são demonstrativos. Eles operam sobre arquivos locais de teste e dados sintéticos. A coleta opcional da atividade 09 é somente de leitura. Não execute adaptações destes scripts contra redes, contas, serviços ou dispositivos sem autorização formal.

## Referência conceitual

As atividades foram alinhadas ao conteúdo da disciplina, que aborda princípios de segurança, tríade CIA, ameaças, ataques, vulnerabilidades, mecanismos e serviços de segurança, criptografia, hash, autenticidade e não repúdio.
