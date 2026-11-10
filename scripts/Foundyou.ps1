function Get-fullName {

    try {
        $fullName = Net User $Env:username | Select-String -Pattern "Full Name"
        $fullName = ("$fullName").TrimStart("Full Name")
    }

    # Se nenhum nome for detectado, retorna $env:UserName
    catch {
        Write-Error "Nenhum nome foi encontrado"
        return $env:UserName
    }

    return $fullName
}

$FN = Get-fullName

#-----------------------------------------------------------------------------------------------------------------------------------------------------------

<#
.NOTES
    Obtem a latitude e longitude atuais do computador
#>

function Get-GeoLocation {
    try {
        Add-Type -AssemblyName System.Device
        $GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher
        $GeoWatcher.Start()

        while (($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied')) {
            Start-Sleep -Milliseconds 100
        }

        if ($GeoWatcher.Permission -eq 'Denied') {
            Write-Error 'Acesso negado para informacoes de localizacao'
            return $null
        } else {
            return $GeoWatcher.Position.Location
        }
    }
    catch {
        Write-Error "Nenhuma coordenada foi encontrada"
        return $null
    }
}

#-----------------------------------------------------------------------------------------------------------------------------------------------------------

<#
.NOTES
    Pausa o script ate detectar movimento do mouse
#>

function Pause-Script {
    Add-Type -AssemblyName System.Windows.Forms
    $originalPOS = [System.Windows.Forms.Cursor]::Position.X
    $o = New-Object -ComObject WScript.Shell

    while (1) {
        $pauseTime = 3
        if ([Windows.Forms.Cursor]::Position.X -ne $originalPOS) {
            break
        }
        else {
            $o.SendKeys("{CAPSLOCK}"); Start-Sleep -Seconds $pauseTime
        }
    }
}

#-----------------------------------------------------------------------------------------------------------------------------------------------------------

$GeoLocation = Get-GeoLocation

if ($GeoLocation) {
    $Lat = $GeoLocation.Latitude
    $Lon = $GeoLocation.Longitude
} else {
    $Lat = $null
    $Lon = $null
}

Pause-Script

# Abre o Google Maps com a localizacao atual (somente se as coordenadas foram obtidas)

if ($Lat -and $Lon) {
    Start-Process "https://www.google.com/maps/place/$Lat,$Lon/@$Lat,$Lon,19z/data=!3m1!1e3"
}

Start-Sleep -s 3

# Coloca o volume no maximo

$k = [Math]::Ceiling(100/2); $o = New-Object -ComObject WScript.Shell; for ($i = 0; $i -lt $k; $i++) { $o.SendKeys([char] 175) }

# Voz do Windows

$s = New-Object -ComObject SAPI.SpVoice
$s.Rate = -2
$s.Speak("Nós encontramos você Pedro")
$s.Speak("Nós sabemos onde você esta")
$s.Speak("Nós estamos em todos os lugares")
$s.Speak("Nós não perdoamos, Nós nao esquecemos")
$s.Speak("Espere por Nós")

# Fim do script. Nenhum arquivo, historico ou registro e apagado.
