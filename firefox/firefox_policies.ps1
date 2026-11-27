$ProgressPreference = "SilentlyContinue"

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Script is not running with administrative privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator." -ForegroundColor Yellow
    return
}

$FirefoxInstallationPath = (Get-Item 'HKLM:\SOFTWARE\Mozilla\Firefox\TaskBarIDs').GetValueNames() | Select-Object -First 1

$AutoconfigDestination = Join-Path $FirefoxInstallationPath 'defaults\pref\autoconfig.js'
Invoke-WebRequest `
    -Uri 'https://raw.githubusercontent.com/ayu2805/policies/main/firefox/firefox_autoconfig.js' `
    -OutFile $AutoconfigDestination `
    -ErrorAction Stop

$PreferencesDestination = Join-Path $FirefoxInstallationPath 'firefox_pref.cfg'
Invoke-WebRequest `
    -Uri 'https://raw.githubusercontent.com/ayu2805/policies/main/firefox/firefox_preferences.cfg' `
    -OutFile $PreferencesDestination `
    -ErrorAction Stop

$FirefoxPolicyPath = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox"

New-Item -Path $FirefoxPolicyPath -Force | Out-Null

function Set-FirefoxPolicy {
    param (
        [string]$Path = $FirefoxPolicyPath,

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

$AIControlsDefault = Join-Path $FirefoxPolicyPath "AIControls\Default"
New-Item -Path $AIControlsDefault -Force | Out-Null
Set-FirefoxPolicy -Path $AIControlsDefault -Name "Locked" -Value 1
Set-FirefoxPolicy -Path $AIControlsDefault -Name "Value" -Value 'blocked'
$AIControlsTranslations = Join-Path $FirefoxPolicyPath "AIControls\Translations"
New-Item -Path $AIControlsTranslations -Force | Out-Null
Set-FirefoxPolicy -Path $AIControlsTranslations -Name "Locked" -Value 1
Set-FirefoxPolicy -Path $AIControlsTranslations -Name "Value" -Value 'available'

Set-FirefoxPolicy -Name "AutofillAddressEnabled" -Value 0
Set-FirefoxPolicy -Name "AutofillCreditCardEnabled" -Value 0
Set-FirefoxPolicy -Name "BrowserDataBackup" -Value 0

$ClearOnShutdown = Join-Path $FirefoxPolicyPath "ClearOnShutdown"
New-Item -Path $ClearOnShutdown -Force | Out-Null
Set-FirefoxPolicy -Path $ClearOnShutdown -Name "BrowsingHistoryAndDownloads" -Value 1
Set-FirefoxPolicy -Path $ClearOnShutdown -Name "Cache" -Value 1
Set-FirefoxPolicy -Path $ClearOnShutdown -Name "CookiesAndStorage" -Value 1
$ClearOnShutdownExceptions = Join-Path $ClearOnShutdown "Exceptions"
New-Item -Path $ClearOnShutdownExceptions -Force | Out-Null
Set-FirefoxPolicy -Path $ClearOnShutdownExceptions -Name "1" -Value "https://accounts.google.com"
Set-FirefoxPolicy -Path $ClearOnShutdownExceptions -Name "2" -Value "https://github.com"
Set-FirefoxPolicy -Path $ClearOnShutdownExceptions -Name "3" -Value "https://sso.crunchyroll.com"
Set-FirefoxPolicy -Path $ClearOnShutdownExceptions -Name "4" -Value "https://web.whatsapp.com"
Set-FirefoxPolicy -Path $ClearOnShutdownExceptions -Name "5" -Value "https://youtube.com"
Set-FirefoxPolicy -Path $ClearOnShutdown -Name "FormData" -Value 1
Set-FirefoxPolicy -Path $ClearOnShutdown -Name "SiteSettings" -Value 1

$Cookies= Join-Path $FirefoxPolicyPath "Cookies"
New-Item -Path $Cookies -Force | Out-Null
Set-FirefoxPolicy -Path $Cookies -Name "Locked" -Value 1
Set-FirefoxPolicy -Path $Cookies -Name "Behavior" -Value "reject-foreign"
Set-FirefoxPolicy -Path $Cookies -Name "BehaviorPrivateBrowsing" -Value "reject-foreign"

$DNSOverHTTPS= Join-Path $FirefoxPolicyPath "DNSOverHTTPS"
New-Item -Path $DNSOverHTTPS -Force | Out-Null
Set-FirefoxPolicy -Path $DNSOverHTTPS -Name "Enabled" -Value 1
Set-FirefoxPolicy -Path $DNSOverHTTPS -Name "Locked" -Value 1
Set-FirefoxPolicy -Path $DNSOverHTTPS -Name "ProviderURL" -Value "https://mozilla.cloudflare-dns.com/dns-query"

Set-FirefoxPolicy -Name "DisableFeedbackCommands" -Value 1
Set-FirefoxPolicy -Name "DisableFirefoxStudies" -Value 1
Set-FirefoxPolicy -Name "DisableLaunchOnLogin" -Value 1
Set-FirefoxPolicy -Name "DisableMasterPasswordCreation" -Value 1
Set-FirefoxPolicy -Name "DisableProfileImport" -Value 1
Set-FirefoxPolicy -Name "DisableRemoteImprovements" -Value 1
Set-FirefoxPolicy -Name "DisableSafeMode" -Value 1
Set-FirefoxPolicy -Name "DisableSetDesktopBackground" -Value 1
Set-FirefoxPolicy -Name "DisableTelemetry" -Value 1
Set-FirefoxPolicy -Name "DontCheckDefaultBrowser" -Value 1

$EnableTrackingProtection = Join-Path $FirefoxPolicyPath "EnableTrackingProtection"
New-Item -Path $EnableTrackingProtection -Force | Out-Null
Set-FirefoxPolicy -Path $EnableTrackingProtection -Name "Category" -Value "strict"
Set-FirefoxPolicy -Path $EnableTrackingProtection -Name "Locked" -Value 1
Set-FirefoxPolicy -Path $EnableTrackingProtection -Name "Value" -Value 1

$uBlockOrigin = Join-Path $FirefoxPolicyPath "ExtensionSettings\uBlock0@raymondhill.net"
New-Item -Path $uBlockOrigin -Force | Out-Null
Set-FirefoxPolicy -Path $uBlockOrigin -Name "installation_mode" -Value "force_installed"
Set-FirefoxPolicy -Path $uBlockOrigin -Name "private_browsing" -Value 1

$FirefoxHome = Join-Path $FirefoxPolicyPath "FirefoxHome"
New-Item -Path $FirefoxHome -Force | Out-Null
Set-FirefoxPolicy -Path $FirefoxHome -Name "Highlights" -Value 0
Set-FirefoxPolicy -Path $FirefoxHome -Name "Locked" -Value 1
Set-FirefoxPolicy -Path $FirefoxHome -Name "Search" -Value 0
Set-FirefoxPolicy -Path $FirefoxHome -Name "SponsoredStories" -Value 0
Set-FirefoxPolicy -Path $FirefoxHome -Name "SponsoredTopSites" -Value 0
Set-FirefoxPolicy -Path $FirefoxHome -Name "Stories" -Value 0
Set-FirefoxPolicy -Path $FirefoxHome -Name "TopSites" -Value 0
$FirefoxHomeWidgets = Join-Path $FirefoxPolicyPath "FirefoxHome\Widgets"
New-Item -Path $FirefoxHomeWidgets -Force | Out-Null
Set-FirefoxPolicy -Path $FirefoxHomeWidgets -Name "Enabled" -Value 0

Set-FirefoxPolicy -Name "HttpsOnlyMode" -Value "force_enabled"
Set-FirefoxPolicy -Name "NoDefaultBookmarks" -Value 1
Set-FirefoxPolicy -Name "PasswordManagerEnabled" -Value 0

$Permissions = Join-Path $FirefoxPolicyPath "Permissions"
New-Item -Path $Permissions -Force | Out-Null
$PermissionsLocation = Join-Path $Permissions "Location"
New-Item -Path $PermissionsLocation -Force | Out-Null
Set-FirefoxPolicy -Path $PermissionsLocation -Name "BlockNewRequests" -Value 1
Set-FirefoxPolicy -Path $PermissionsLocation -Name "Locked" -Value 1
$PermissionsNotifications = Join-Path $Permissions "Notifications"
New-Item -Path $PermissionsNotifications -Force | Out-Null
Set-FirefoxPolicy -Path $PermissionsNotifications -Name "BlockNewRequests" -Value 1
Set-FirefoxPolicy -Path $PermissionsNotifications -Name "Locked" -Value 1

Set-FirefoxPolicy -Name "Preferences" -Value @'
{
    "browser.formfill.enable": {
        "Status": "locked",
        "Value": false
    },
    "browser.search.suggest.enabled.private": {
        "Status": "locked",
        "Value": false
    },
    "browser.tabs.hoverPreview.showThumbnails": {
        "Status": "locked",
        "Value": false
    },
    "browser.theme.native-theme": {
        "Status": "locked",
        "Value": false
    },
    "browser.urlbar.showSearchSuggestionsFirst": {
        "Status": "locked",
        "Value": false
    },
    "browser.urlbar.showSearchTerms.enabled": {
        "Status": "locked",
        "Value": false
    },
    "browser.urlbar.suggest.engines": {
        "Status": "locked",
        "Value": false
    },
    "browser.urlbar.suggest.history": {
        "Status": "locked",
        "Value": false
    },
    "browser.urlbar.suggest.openpage": {
        "Status": "locked",
        "Value": false
    },
    "browser.urlbar.suggest.quickactions": {
        "Status": "locked",
        "Value": false
    },
    "browser.urlbar.suggest.recentsearches": {
        "Status": "locked",
        "Value": false
    },
    "browser.urlbar.suggest.topsites": {
        "Status": "locked",
        "Value": false
    },
    "browser.urlbar.suggest.trending": {
        "Status": "locked",
        "Value": false
    },
    "extensions.getAddons.showPane": {
        "Status": "locked",
        "Value": false
    },
    "extensions.htmlaboutaddons.recommendations.enabled": {
        "Status": "locked",
        "Value": false
    },
    "general.autoScroll": {
        "Status": "locked",
        "Value": true
    },
    "privacy.globalprivacycontrol.enabled": {
        "Status": "locked",
        "Value": false
    },
    "privacy.userContext.enabled": {
        "Status": "locked",
        "Value": false
    },
    "sidebar.visibility": {
        "Status": "locked",
        "Value": "hide-launcher"
    },
    "signon.autofillForms": {
        "Status": "locked",
        "Value": false
    },
    "signon.firefoxRelay.feature": {
        "Status": "locked",
        "Value": "disabled"
    },
    "signon.generation.enabled": {
        "Status": "locked",
        "Value": false
    },
    "signon.management.page.breach-alerts.enabled": {
        "Status": "locked",
        "Value": false
    }
'@

$SearchEngines = Join-Path $FirefoxPolicyPath "SearchEngines"
$SearchEnginesAdd = Join-Path $SearchEngines "Add\1"
New-Item -Path $SearchEnginesAdd -Force | Out-Null
Set-FirefoxPolicy -Path $SearchEnginesAdd -Name "Name" -Value "DuckDuckGo"
Set-FirefoxPolicy -Path $SearchEnginesAdd -Name "URLTemplate" -Value "https://duckduckgo.com/?q={searchTerms}"
Set-FirefoxPolicy -Path $SearchEngines -Name "Default" -Value "DuckDuckGo"
Set-FirefoxPolicy -Path $SearchEngines -Name "PreventInstalls" -Value 1
$SearchEnginesRemove = Join-Path $SearchEngines "Remove"
New-Item -Path $SearchEnginesRemove -Force | Out-Null
Set-FirefoxPolicy -Path $SearchEnginesRemove -Name "1" -Value "Bing"
Set-FirefoxPolicy -Path $SearchEnginesRemove -Name "2" -Value "Perplexity"
Set-FirefoxPolicy -Path $SearchEnginesRemove -Name "3" -Value "Wikipedia (en)"

Set-FirefoxPolicy -Name "SearchSuggestEnabled" -Value 0
Set-FirefoxPolicy -Name "SkipTermsOfUse" -Value 1

$UserMessaging = Join-Path $FirefoxPolicyPath "UserMessaging"
New-Item -Path $UserMessaging -Force | Out-Null
Set-FirefoxPolicy -Path $UserMessaging -Name "ExtensionRecommendations" -Value 0
Set-FirefoxPolicy -Path $UserMessaging -Name "FeatureRecommendations" -Value 0
Set-FirefoxPolicy -Path $UserMessaging -Name "FirefoxLabs" -Value 0
Set-FirefoxPolicy -Path $UserMessaging -Name "Locked" -Value 1
Set-FirefoxPolicy -Path $UserMessaging -Name "MoreFromMozilla" -Value 0

Write-Host "Firefox policies have been applied successfully." -ForegroundColor Green
Write-Host "Restart Firefox, then check about:policies." -ForegroundColor Yellow