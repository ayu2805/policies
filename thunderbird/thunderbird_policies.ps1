$ProgressPreference = "SilentlyContinue"

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Script is not running with administrative privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator." -ForegroundColor Yellow
    return
}

$ThunderbirdPolicyPath = "HKLM:\SOFTWARE\Policies\Mozilla\Thunderbird"

function Import-JsonToRegistry {
    param(
        [Parameter(Mandatory)] [string] $JsonPath,
        [Parameter(Mandatory)] [string] $RegistryPath
    )

    $JsonObject = Get-Content -LiteralPath $JsonPath -Raw | ConvertFrom-Json

    function Set-RegistryValue($KeyPath, $Name, $Value) {
        if ($Value -is [System.Management.Automation.PSCustomObject]) {
            Write-RegistryObject $Value (Join-Path $KeyPath $Name)
            return
        }

        $Type = if ($Value -is [bool] -or $Value -is [int]) { 'DWord' }
                elseif ($Value -is [string])                { 'String' }

        if ($Value -is [bool]) { $Value = [int]$Value }

        New-ItemProperty -Path $KeyPath -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
    }

    function Write-RegistryObject($JsonObject, $KeyPath) {
        New-Item -Path $KeyPath -Force | Out-Null

        foreach ($property in $JsonObject.PSObject.Properties) {
            $name  = $property.Name
            $value = $property.Value

            if ($value -is [array]) {
                $arrayKeyPath = Join-Path $KeyPath $name
                New-Item -Path $arrayKeyPath -Force | Out-Null

                for ($i = 0; $i -lt $value.Count; $i++) {
                    Set-RegistryValue $arrayKeyPath ([string]($i + 1)) $value[$i]
                }
            }
            else {
                Set-RegistryValue $KeyPath $name $value
            }
        }
    }
    Write-RegistryObject $JsonObject.policies $RegistryPath
}

Invoke-WebRequest `
    -Uri 'https://raw.githubusercontent.com/ayu2805/policies/main/thunderbird/thunderbird_policies.json' `
    -OutFile "$env:TEMP\thunderbird_policies.json" `
    -ErrorAction Stop
Import-JsonToRegistry -JsonPath "$env:TEMP\thunderbird_policies.json" -RegistryPath $ThunderbirdPolicyPath

Write-Host "Thunderbird policies have been applied successfully." -ForegroundColor Green
Write-Host "Restart Thunderbird, then check about:policies." -ForegroundColor Yellow