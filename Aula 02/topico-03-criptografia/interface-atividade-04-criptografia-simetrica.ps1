[CmdletBinding()]
param()

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'interface-comum.ps1')

$script:pastaAtividade = $PSScriptRoot
$script:scriptAtividade = Join-Path $script:pastaAtividade 'atividade-04-criptografia-simetrica.ps1'
$script:roteiroAtividade = Join-Path $script:pastaAtividade 'README.md'
$script:arquivoPadrao = Join-Path (Join-Path $script:pastaAtividade 'dados') 'mensagem-confidencial.txt'

$script:ui = New-InterfaceDidatica -Titulo 'Atividade 04 — Criptografia simétrica com AES' -Subtitulo 'Proteja e recupere uma mensagem usando a mesma senha de laboratório.' -Objetivo 'Compreender que a mesma chave é usada para cifrar e recuperar a informação.' -Passos @(
    'Escolha uma mensagem de texto.',
    'Use Demonstrar para cifrar e recuperar automaticamente.',
    'Leia o resultado e discuta o risco de divulgar a senha.'
) -TextoExecutar 'Executar criptografia' -Aviso 'A senha padrão é apenas didática. Nunca a use para proteger informações reais.'

$script:ui.GrupoCampos.Height = 250
$script:campoArquivo = Add-CampoArquivo -Painel $script:ui.Campos -Rotulo 'Mensagem de texto que será protegida' -ValorInicial $script:arquivoPadrao -Filtro 'Arquivos de texto (*.txt)|*.txt|Todos os arquivos (*.*)|*.*' -TituloSelecao 'Selecione a mensagem de texto'
$script:modo = Add-CampoLista -Painel $script:ui.Campos -Rotulo 'O que deseja fazer?' -Opcoes @('Demonstrar', 'Criptografar', 'Descriptografar') -Selecionado 'Demonstrar'
$script:senha = Add-CampoTexto -Painel $script:ui.Campos -Rotulo 'Senha de laboratório' -ValorInicial 'Senha-Laboratorio-2026!' -OcultarTexto
Add-NotaDidatica -Painel $script:ui.Campos -Texto 'O arquivo cifrado é salvo em resultado/mensagem-confidencial.aes.txt.'

function Executar-Atividade04 {
    $arquivo = $script:campoArquivo.TextBox.Text.Trim()
    $senha = $script:senha.Text
    if (-not (Test-Path -LiteralPath $arquivo -PathType Leaf)) {
        Set-SaidaDaAtividade -Saida $script:ui.Saida -Erro -Texto 'Escolha uma mensagem de texto existente antes de executar.'
        return
    }
    if ([string]::IsNullOrWhiteSpace($senha)) {
        Set-SaidaDaAtividade -Saida $script:ui.Saida -Erro -Texto 'Informe uma senha de laboratório antes de executar.'
        return
    }

    Invoke-AtividadeComSaida -ScriptPath $script:scriptAtividade -Parametros @{
        ArquivoEntrada = $arquivo
        Modo           = [string]$script:modo.SelectedItem
        Senha          = $senha
    } -Saida $script:ui.Saida -NomeAtividade 'Criptografia simétrica com AES'
}

function Abrir-RoteiroAtividade04 {
    Abrir-DocumentoDidatico -Caminho $script:roteiroAtividade -Saida $script:ui.Saida
}

function Abrir-PastaAtividade04 {
    Abrir-PastaDidatica -Caminho $script:pastaAtividade -Saida $script:ui.Saida
}

$script:ui.BotaoExecutar.Add_Click({ Executar-Atividade04 })
$script:ui.BotaoRoteiro.Add_Click({ Abrir-RoteiroAtividade04 })
$script:ui.BotaoDados.Add_Click({ Abrir-PastaAtividade04 })
$script:ui.BotaoLimpar.Add_Click({ $script:ui.Saida.Clear() })

[void]$script:ui.Form.ShowDialog()
