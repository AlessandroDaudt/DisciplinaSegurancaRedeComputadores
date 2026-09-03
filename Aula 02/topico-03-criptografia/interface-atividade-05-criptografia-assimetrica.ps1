[CmdletBinding()]
param()

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'interface-comum.ps1')

$script:pastaAtividade = $PSScriptRoot
$script:scriptAtividade = Join-Path $script:pastaAtividade 'atividade-05-criptografia-assimetrica.ps1'
$script:roteiroAtividade = Join-Path $script:pastaAtividade 'README.md'
$script:arquivoPadrao = Join-Path (Join-Path $script:pastaAtividade 'dados') 'mensagem-confidencial.txt'
$script:arquivoCifradoPadrao = Join-Path (Join-Path $script:pastaAtividade 'resultado') 'mensagem-confidencial.cms'

$script:ui = New-InterfaceDidatica -Titulo 'Atividade 05 — Criptografia assimétrica' -Subtitulo 'Use um certificado de laboratório para proteger a mensagem com chave pública.' -Objetivo 'Diferenciar o uso da chave pública para proteção e da chave privada para recuperação da informação.' -Passos @(
    'Para proteger, escolha uma mensagem de texto e clique em Proteger arquivo.',
    'Para recuperar, selecione o arquivo .cms criado e clique em Recuperar mensagem.',
    'Observe na saída quando a chave pública e a chave privada são utilizadas.'
) -TextoExecutar 'Proteger arquivo' -Aviso 'A atividade pode criar um certificado autoassinado no usuário atual. Ele serve somente para este laboratório.'

$script:ui.BotaoExecutar.Width = 145
$script:campoArquivo = Add-CampoArquivo -Painel $script:ui.Campos -Rotulo 'Mensagem de texto para proteger com a chave pública' -ValorInicial $script:arquivoPadrao -Filtro 'Arquivos de texto (*.txt)|*.txt|Todos os arquivos (*.*)|*.*' -TituloSelecao 'Selecione a mensagem de texto'
$script:campoArquivoCifrado = Add-CampoArquivo -Painel $script:ui.Campos -Rotulo 'Arquivo protegido para recuperar com a chave privada (.cms)' -ValorInicial $script:arquivoCifradoPadrao -Filtro 'Arquivos CMS (*.cms)|*.cms|Todos os arquivos (*.*)|*.*' -TituloSelecao 'Selecione o arquivo protegido'
$script:ui.GrupoCampos.Height = 235
Add-NotaDidatica -Painel $script:ui.Campos -Texto 'Use primeiro Proteger arquivo. Depois, use Recuperar mensagem para abrir o arquivo .cms criado. O certificado é apenas didático e não deve ser usado em produção.'

$script:botaoRecuperar = New-Object System.Windows.Forms.Button
$script:botaoRecuperar.Text = 'Recuperar mensagem'
$script:botaoRecuperar.Width = 165
$script:botaoRecuperar.Height = 34
$script:botaoRecuperar.BackColor = [System.Drawing.Color]::FromArgb(25, 118, 210)
$script:botaoRecuperar.ForeColor = [System.Drawing.Color]::White
$script:botaoRecuperar.FlatStyle = 'Flat'
$script:ui.Botoes.Controls.Add($script:botaoRecuperar)
$script:ui.Botoes.Controls.SetChildIndex($script:botaoRecuperar, 1)

function Proteger-Atividade05 {
    $arquivo = $script:campoArquivo.TextBox.Text.Trim()
    if (-not (Test-Path -LiteralPath $arquivo -PathType Leaf)) {
        Set-SaidaDaAtividade -Saida $script:ui.Saida -Erro -Texto 'Escolha uma mensagem de texto existente antes de proteger.'
        return
    }

    Invoke-AtividadeComSaida -ScriptPath $script:scriptAtividade -Parametros @{ Modo = 'Proteger'; Arquivo = $arquivo } -Saida $script:ui.Saida -NomeAtividade 'Proteção assimétrica'
}

function Recuperar-Atividade05 {
    $arquivoCifrado = $script:campoArquivoCifrado.TextBox.Text.Trim()
    if (-not (Test-Path -LiteralPath $arquivoCifrado -PathType Leaf)) {
        Set-SaidaDaAtividade -Saida $script:ui.Saida -Erro -Texto 'Escolha um arquivo protegido .cms existente antes de recuperar.'
        return
    }

    Invoke-AtividadeComSaida -ScriptPath $script:scriptAtividade -Parametros @{ Modo = 'Recuperar'; ArquivoCifrado = $arquivoCifrado } -Saida $script:ui.Saida -NomeAtividade 'Recuperação assimétrica'
}

function Abrir-RoteiroAtividade05 {
    Abrir-DocumentoDidatico -Caminho $script:roteiroAtividade -Saida $script:ui.Saida
}

function Abrir-PastaAtividade05 {
    Abrir-PastaDidatica -Caminho $script:pastaAtividade -Saida $script:ui.Saida
}

$script:ui.BotaoExecutar.Add_Click({ Proteger-Atividade05 })
$script:botaoRecuperar.Add_Click({ Recuperar-Atividade05 })
$script:ui.BotaoRoteiro.Add_Click({ Abrir-RoteiroAtividade05 })
$script:ui.BotaoDados.Add_Click({ Abrir-PastaAtividade05 })
$script:ui.BotaoLimpar.Add_Click({ $script:ui.Saida.Clear() })

[void]$script:ui.Form.ShowDialog()
