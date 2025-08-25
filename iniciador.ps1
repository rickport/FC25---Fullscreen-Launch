# --- INÍCIO DA CONFIGURAÇÃO ---
$gameProcessName = "FC25"
$gameWindowTitle = "EA SPORTS FC 25"
$launcherTriggerProcesses = @( "EADesktop", "EAAntiCheat.GameServiceLauncher" )
# Nomes dos arquivos de imagem para as cortinas
$curtainImageStart = "start.jpg"
$curtainImageEnd = "end.jpg"
# --- FIM DA CONFIGURAÇÃO ---


# Limpa a tela do console
Clear-Host
Add-Type -ReferencedAssemblies System.Drawing, System.Windows.Forms -TypeDefinition @"
using System;
using System.Drawing;
using System.Runtime.InteropServices;
[StructLayout(LayoutKind.Sequential)]
public struct RECT {
    public int Left, Top, Right, Bottom;
    public int Width { get { return Right - Left; } }
    public int Height { get { return Bottom - Top; } }
}
public class Win32Api {
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern int GetSystemMetrics(int nIndex);
}
"@
# Constantes de Métricas
$SW_HIDE = 0
$SM_CXSCREEN = 0; $SM_CYSCREEN = 1

# --- FUNÇÕES DE CORTINA ---
function Show-Curtain {
    param(
        [string]$ImageFileName
    )
    $curtainForm = New-Object System.Windows.Forms.Form
    $curtainForm.FormBorderStyle = 'None'
    $curtainForm.WindowState = 'Maximized'
    $curtainForm.TopMost = $true
    $imagePath = Join-Path $PSScriptRoot $ImageFileName
    if (Test-Path $imagePath) {
        try {
            $image = [System.Drawing.Image]::FromFile($imagePath)
            $curtainForm.BackgroundImage = $image
            $curtainForm.BackgroundImageLayout = 'Stretch'
        } catch { $curtainForm.BackColor = 'Black' }
    } else { $curtainForm.BackColor = 'Black' }
    $curtainForm.Show()
    [System.Windows.Forms.Application]::DoEvents()
    return $curtainForm
}

Write-Host "======================================================================" -ForegroundColor Green
Write-Host " MODO MONITOR: Assistente do EAFC 25 (v68 - Desligamento Supervisionado)" -ForegroundColor Green
Write-Host "======================================================================"
Write-Host "Este script agora está rodando em segundo plano. Inicie o jogo pela Steam."
Write-Host ""


# Loop principal infinito
while ($true) {
    # FASE 1
    Write-Host "FASE 1: Aguardando a JANELA de um processo de lançamento (verificação rápida)..." -ForegroundColor Yellow
    $windowFound = $false
    while (-not $windowFound) {
        $procs = Get-Process -Name $launcherTriggerProcesses -ErrorAction SilentlyContinue
        foreach ($proc in $procs) {
            if ($proc.MainWindowHandle -ne [System.IntPtr]::Zero) {
                $windowFound = $true; Write-Host "Gatilho detectado! Baixando a cortina..." -ForegroundColor Cyan; break
            }
        }
        Start-Sleep -Milliseconds 100
    }

    # FASE 2
    Write-Host "FASE 2: Cortina de início ativada..." -ForegroundColor Magenta
    $launchCurtain = Show-Curtain -ImageFileName $curtainImageStart

    # FASE 3
    Write-Host "FASE 3: Procurando pelo processo estável do jogo..."
    $stableGameProcess = $null
    $watchdogTimeout = 90
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    while (-not $stableGameProcess -and $stopwatch.Elapsed.TotalSeconds -lt $watchdogTimeout) {
        $currentGameProcess = Get-Process -Name $gameProcessName -ErrorAction SilentlyContinue
        if ($currentGameProcess -and $currentGameProcess.MainWindowHandle -ne [System.IntPtr]::Zero) {
            $stableGameProcess = $currentGameProcess
        }
        Start-Sleep -Milliseconds 500
    }
    
    if ($stableGameProcess) {
        Write-Host "Processo estável confirmado! Acionando Python para forçar a transição..."
        $pythonScriptPath = Join-Path $PSScriptRoot "focus_aggressively.py"
        try { Start-Process python.exe -ArgumentList "-u `"$pythonScriptPath`" `"$gameWindowTitle`"" -WindowStyle Hidden } catch { }

        # FASE 4
        Write-Host "FASE 4: Monitorando até o jogo confirmar o estado de tela cheia..." -ForegroundColor Yellow
        $isFullScreen = $false
        $timeout = 45; $stopwatch.Restart()
        $screenWidth = [Win32Api]::GetSystemMetrics($SM_CXSCREEN)
        $screenHeight = [Win32Api]::GetSystemMetrics($SM_CYSCREEN)
        
        while (-not $isFullScreen -and $stopwatch.Elapsed.TotalSeconds -lt $timeout) {
            $rect = New-Object RECT
            [Win32Api]::GetWindowRect($stableGameProcess.MainWindowHandle, [ref]$rect) | Out-Null
            if ($rect.Left -eq 0 -and $rect.Top -eq 0 -and $rect.Width -eq $screenWidth -and $rect.Height -eq $screenHeight) {
                $isFullScreen = $true
                Write-Host "Estado de TELA CHEIA confirmado!" -ForegroundColor Green
            } else { Start-Sleep -Milliseconds 500 }
        }

        # FASE 5
        if ($isFullScreen) {
            Write-Host "FASE 5: Levantando a cortina..." -ForegroundColor Green
            $launchCurtain.Close(); $launchCurtain.Dispose()
            Write-Host "Garantindo o foco final com o assistente Python..."
            try { Start-Process python.exe -ArgumentList "-u `"$pythonScriptPath`" `"$gameWindowTitle`"" -WindowStyle Hidden } catch { }
            Write-Host "Aproveite o jogo!"
        } else {
             Write-Warning "O jogo não atingiu o estado de tela cheia no tempo limite."
             $launchCurtain.Close(); $launchCurtain.Dispose()
        }
    } else {
        Write-Warning "Processo do jogo não foi encontrado."
        $launchCurtain.Close(); $launchCurtain.Dispose()
    }
    
    # FASE 6
    Write-Host "FASE 6: Monitorando o fim da sessão de jogo..." -ForegroundColor Yellow
    Wait-Process -Name $gameProcessName -ErrorAction SilentlyContinue
    
    # --- FASE 7 (MODIFICADA): DESLIGAMENTO SUPERVISIONADO ---
    Write-Host "Jogo encerrado." -ForegroundColor Cyan
    Write-Host "FASE 7: Baixando a cortina para a sincronização da EA..." -ForegroundColor Magenta
    $syncCurtain = Show-Curtain -ImageFileName $curtainImageEnd

    Write-Host "Aguardando o processo de sincronização da EA (EADesktop) terminar..." -ForegroundColor Yellow
    
    # Espera pacientemente até que o processo EADesktop não exista mais
    Wait-Process -Name "EADesktop" -Timeout 120 -ErrorAction SilentlyContinue
    
    Write-Host "Processo EADesktop encerrado. Limpeza concluída." -ForegroundColor Green
    
    Write-Host "Levantando a cortina da sincronização..."
    $syncCurtain.Close(); $syncCurtain.Dispose()

    $steamProcess = Get-Process -Name "steam" -ErrorAction SilentlyContinue
    if ($steamProcess) {
        [Win32Api]::SetForegroundWindow($steamProcess.MainWindowHandle) | Out-Null
    }

    Write-Host "Reiniciando o monitoramento..."
    Write-Host "----------------------------------------------------------"
}
