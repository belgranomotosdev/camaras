# setup-multicam-frp.ps1
# Setup de cámaras Tapo con MediaMTX + FFmpeg + FRP

# Cargar config
$configPath = ".\config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "❌ Falta el archivo de configuración config.json"; exit 1
}
$config = Get-Content $configPath | ConvertFrom-Json

# Crear carpeta de logs
$logsDir = ".\logs"
if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir | Out-Null }

# Lanzar MediaMTX
Write-Host "▶ Iniciando MediaMTX..."
Start-Process -NoNewWindow -FilePath ".\mediamtx.exe"
Start-Sleep -Seconds 2

# Lanzar FRPC
Write-Host "▶ Iniciando FRPC (puerto $($config.rtspPort))..."
Start-Process -NoNewWindow -FilePath ".\frpc.exe" -ArgumentList "-c $($config.frpcConfig)"
Start-Sleep -Seconds 5

# Leer cámaras desde camaras.txt
$camarasRaw = Get-Content ".\camaras.txt"
foreach ($linea in $camarasRaw) {
    if ($linea.Trim() -eq "") { continue }
    $parts = $linea -split "="
    if ($parts.Count -ne 2) {
        Write-Warning "❗ Línea inválida: $linea"; continue
    }

    $camId = $parts[0].Trim()
    $localRtsp = $parts[1].Trim()
    $rtspTargetLocal = "rtsp://localhost:$($config.rtspPort)/$camId"

    Write-Host ""
    Write-Host "▶ Iniciando FFmpeg para '$camId'…"
    Write-Host "    Origen: $localRtsp"
    Write-Host "    Destino: $rtspTargetLocal"

    $ffmpegArgs = @(
        "-rtsp_transport", "tcp"
        "-i", "`"$localRtsp`""
        "-c", "copy"
        "-f", "rtsp"
        "`"$rtspTargetLocal`""
    )

    Start-Process -WindowStyle Hidden -FilePath ".\ffmpeg.exe" -ArgumentList $ffmpegArgs `
        -RedirectStandardOutput "$logsDir\$camId-out.log" `
        -RedirectStandardError "$logsDir\$camId-err.log"

    Start-Sleep -Seconds 5

    $publicRtsp = "rtsp://$($config.frpPublicHost):$($config.frpPublicPort)/$camId"

    Write-Host "▶ Registrando '$camId' → $publicRtsp en el backend..."
    $payload = @{
        camId     = $camId
        publicUrl = $publicRtsp
    } | ConvertTo-Json -Compress

    try {
        Invoke-RestMethod -Uri "$($config.backendUrl)/api/register" `
                          -Method POST -Body $payload `
                          -ContentType "application/json"
        Write-Host "   ✅ Registrada: $camId"
        "$camId = $publicRtsp" | Out-File -FilePath ".\urls-publicas.txt" -Append
    } catch {
        Write-Warning "⚠️ Error registrando $camId: $_"
    }
}

Write-Host "`n✅ Todas las cámaras están en funcionamiento. URLs en: urls-publicas.txt"
Write-Host "🔁 Presiona Ctrl+C para detener el sistema..."

# Mantener la consola abierta
while ($true) { Start-Sleep -Seconds 1 }
