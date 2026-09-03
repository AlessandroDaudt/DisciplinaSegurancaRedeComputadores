[CmdletBinding()]
param()

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'interface-comum.ps1')

$script:pastaAtividade = $PSScriptRoot
$script:scriptAtividade = Join-Path $script:pastaAtividade 'atividade-05-criptografia-assimetrica.ps1'
$script:roteiroAtividade = Join-Path $script:pastaAtividade 'README.md'
$script:arquivoPadrao = Join-Path (Join-Path $script:pastaAtividade 'dados') 'mensagem-confidencial.txt'

$script:ui = New-InterfaceDidatica -Titulo 'Atividade 05 — Criptografia assimétrica' -Subtitulo 'Use um certificado de laboratório para proteger a mensagem com chave pública.' -Objetivo 'Diferenciar o uso da chave pública para proteção e da chave privada para recuperação da informação.' -Passos @(
    'Escolha uma mensagem de texto.',
    'Clique em Proteger e recuperar mensagem.',
    'Observe o certificado criado ou reutilizado e compare o texto recuperado.'
) -TextoExecutar 'Proteger e recuperar' -Aviso 'A atividade pode criar um certificado autoassinado no usuário atual. Ele serve somente para este laboratório.'

$script:campoArquivo = Add-CampoArquivo -Painel $script:ui.Campos -Rotulo 'Mensagem de texto que será protegida' -ValorInicial $script:arquivoPadrao -Filtro 'Arquivos de texto (*.txt)|*.txt|Todos os arquivos (*.*)|*.*' -TituloSelecao 'Selecione a mensagem de texto'
Add-NotaDidatica -Painel $script:ui.Campos -Texto 'O certificado criado não representa uma cadeia de confiança real e não deve ser usado em produção.'

function Executar-Atividade05 {
    $arquivo = $script:campoArquivo.TextBox.Text.Trim()
    if (-not (Test-Path -LiteralPath $arquivo -PathType Leaf)) {
        Set-SaidaDaAtividade -Saida $script:ui.Saida -Erro -Texto 'Escolha uma mensagem de texto existente antes de executar.'
        return
    }

    Invoke-AtividadeComSaida -ScriptPath $script:scriptAtividade -Parametros @{ Arquivo = $arquivo } -Saida $script:ui.Saida -NomeAtividade 'Criptografia assimétrica com certificado'
}

function Abrir-RoteiroAtividade05 {
    Abrir-DocumentoDidatico -Caminho $script:roteiroAtividade -Saida $script:ui.Saida
}

function Abrir-PastaAtividade05 {
    Abrir-PastaDidatica -Caminho $script:pastaAtividade -Saida $script:ui.Saida
}

$script:ui.BotaoExecutar.Add_Click({ Executar-Atividade05 })
$script:ui.BotaoRoteiro.Add_Click({ Abrir-RoteiroAtividade05 })
$script:ui.BotaoDados.Add_Click({ Abrir-PastaAtividade05 })
$script:ui.BotaoLimpar.Add_Click({ $script:ui.Saida.Clear() })

[void]$script:ui.Form.ShowDialog()
