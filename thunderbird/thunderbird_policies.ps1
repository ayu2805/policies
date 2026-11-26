$ProgressPreference = "SilentlyContinue"

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Script is not running with administrative privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator." -ForegroundColor Yellow
    return
}

$ThunderbirdInstallationPath = (Get-Item 'HKLM:\SOFTWARE\Mozilla\Thunderbird\TaskBarIDs').GetValueNames() | Select-Object -First 1

$ThunderbirdPolicyPath = "HKLM:\SOFTWARE\Policies\Mozilla\Thunderbird"

New-Item -Path $ThunderbirdPolicyPath -Force | Out-Null

function Set-ThunderbirdPolicy {
    param (
        [string]$Path = $ThunderbirdPolicyPath,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [object]$Value
    )
    
    if ($Value -is [int]) {
        $propertyType = 'DWord'
    }
    elseif ($Value -is [string]) {
        try {
            $null = $Value | ConvertFrom-Json -ErrorAction Stop
            $propertyType = 'MultiString'
        }
        catch {
            $propertyType = 'String'
        }
    }

    New-ItemProperty `
        -Path $Path `
        -Name $Name `
        -PropertyType $propertyType `
        -Value $Value `
        -Force | Out-Null
}

$Cookies= Join-Path $ThunderbirdPolicyPath "Cookies"
New-Item -Path $Cookies -Force | Out-Null
Set-ThunderbirdPolicy -Path $Cookies -Name "AcceptThirdParty" -Value "never"
Set-ThunderbirdPolicy -Path $Cookies -Name "Default" -Value 0
Set-ThunderbirdPolicy -Path $Cookies -Name "Locked" -Value 1

$DNSOverHTTPS= Join-Path $ThunderbirdPolicyPath "DNSOverHTTPS"
New-Item -Path $DNSOverHTTPS -Force | Out-Null
Set-ThunderbirdPolicy -Path $DNSOverHTTPS -Name "Enabled" -Value 1
Set-ThunderbirdPolicy -Path $DNSOverHTTPS -Name "Locked" -Value 1
Set-ThunderbirdPolicy -Path $DNSOverHTTPS -Name "ProviderURL" -Value "https://mozilla.cloudflare-dns.com/dns-query"

Set-ThunderbirdPolicy -Name "DisableChat" -Value 1
Set-ThunderbirdPolicy -Name "DisableCommunity" -Value 1
Set-ThunderbirdPolicy -Name "DisableMasterPasswordCreation" -Value 1
Set-ThunderbirdPolicy -Name "DisableQRExport" -Value 1
Set-ThunderbirdPolicy -Name "DisableTelemetry" -Value 1
Set-ThunderbirdPolicy -Name "PasswordManagerEnabled" -Value 1

Set-ThunderbirdPolicy -Name "Preferences" -Value @'
{
    "calendar.agenda.days": {
        "Status": "locked",
        "Value": 1
    },
    "calendar.date.format": {
        "Status": "locked",
        "Value": 1
    },
    "calendar.view-minimonth.showWeekNumber": {
        "Status": "locked",
        "Value": false
    },
    "calendar.view.dayendhour": {
        "Status": "locked",
        "Value": 24
    },
    "calendar.view.daystarthour": {
        "Status": "locked",
        "Value": 0
    },
    "calendar.view.visiblehours": {
        "Status": "locked",
        "Value": 24
    },
    "calendar.week.d0sundaysoff": {
        "Status": "locked",
        "Value": false
    },
    "calendar.week.d1mondaysoff": {
        "Status": "locked",
        "Value": false
    },
    "calendar.week.d2tuesdaysoff": {
        "Status": "locked",
        "Value": false
    },
    "calendar.week.d3wednesdaysoff": {
        "Status": "locked",
        "Value": false
    },
    "calendar.week.d4thursdaysoff": {
        "Status": "locked",
        "Value": false
    },
    "calendar.week.d5fridaysoff": {
        "Status": "locked",
        "Value": false
    },
    "calendar.week.d6saturdaysoff": {
        "Status": "locked",
        "Value": false
    },
    "extensions.getAddons.showPane": {
        "Status": "locked",
        "Value": false
    },
    "general.autoScroll": {
        "Status": "locked",
        "Value": true
    },
    "mail.cloud_files.enabled": {
        "Status": "locked",
        "Value": false
    },
    "mail.collect_email_address_outgoing": {
        "Status": "locked",
        "Value": false
    },
    "mail.compose.autosaveinterval": {
        "Status": "locked",
        "Value": 1
    },
    "mail.enable_autocomplete": {
        "Status": "locked",
        "Value": false
    },
    "mail.threadpane.cardsview.rowcount": {
        "Status": "locked",
        "Value": 2
    },
    "mail.threadpane.listview": {
        "Status": "locked",
        "Value": 0
    },
    "mail.uifontsize": {
        "Status": "locked",
        "Value": 12
    },
    "mailnews.default_view_flags": {
        "Status": "locked",
        "Value": 0
    },
    "mailnews.message_display.disable_remote_image": {
        "Status": "locked",
        "Value": false
    },
    "mailnews.start_page.enabled": {
        "Status": "locked",
        "Value": false
    },
    "places.history.enabled": {
        "Status": "locked",
        "Value": false
    }
}
'@

$SearchEngines = Join-Path $ThunderbirdPolicyPath "SearchEngines"
$SearchEnginesAdd = Join-Path $SearchEngines "Add\1"
New-Item -Path $SearchEnginesAdd -Force | Out-Null
Set-ThunderbirdPolicy -Path $SearchEnginesAdd -Name "Name" -Value "DuckDuckGo"
Set-ThunderbirdPolicy -Path $SearchEnginesAdd -Name "URLTemplate" -Value "https://duckduckgo.com/?q={searchTerms}"
Set-ThunderbirdPolicy -Path $SearchEngines -Name "Default" -Value "DuckDuckGo"
Set-ThunderbirdPolicy -Path $SearchEngines -Name "PreventInstalls" -Value 1
$SearchEnginesRemove = Join-Path $SearchEngines "Remove"
New-Item -Path $SearchEnginesRemove -Force | Out-Null
Set-ThunderbirdPolicy -Path $SearchEnginesRemove -Name "1" -Value "Bing"
Set-ThunderbirdPolicy -Path $SearchEnginesRemove -Name "2" -Value "Perplexity"
Set-ThunderbirdPolicy -Path $SearchEnginesRemove -Name "3" -Value "Wikipedia (en)"

Write-Host "Thunderbird policies have been applied successfully." -ForegroundColor Green
Write-Host "Restart Thunderbird, then check about:policies." -ForegroundColor Yellow