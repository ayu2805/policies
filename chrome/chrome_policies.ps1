$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Script is not running with administrative privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator." -ForegroundColor Yellow
    return
}

$ChromePolicyPath = "HKLM:\SOFTWARE\Policies\Google\Chrome"

New-Item -Path $ChromePolicyPath -Force | Out-Null

function Set-ChromePolicy {
    param (
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
        -Path $ChromePolicyPath `
        -Name $Name `
        -PropertyType $propertyType `
        -Value $Value `
        -Force | Out-Null
}


Set-ChromePolicy -Name "AIModeSettings" -Value 1
Set-ChromePolicy -Name "AutofillGenAiSettings" -Value 2
Set-ChromePolicy -Name "AutofillSettings" -Value @'
{
    "blocked_types": [
        "all"
    ],
    "url_pattern": "*"
}
'@
Set-ChromePolicy -Name "BackgroundModeEnabled" -Value 0
Set-ChromePolicy -Name "BlockThirdPartyCookies" -Value 1
Set-ChromePolicy -Name "ChromeSuggestionsSettings" -Value 1
Set-ChromePolicy -Name "ClearBrowsingDataOnExitList" -Value @'
[
    "browsing_history",
    "download_history",
    "cached_images_and_files",
    "password_signin",
    "autofill",
    "site_settings",
    "hosted_app_data"
]
'@
Set-ChromePolicy -Name "CookiesAllowedForUrls" -Value @'
[
    "accounts.google.com",
    "github.com",
    "sso.crunchyroll.com",
    "web.whatsapp.com"
]
'@
Set-ChromePolicy -Name "CreateThemesSettings" -Value 2
Set-ChromePolicy -Name "DefaultAutomaticDownloadsSetting" -Value 1
Set-ChromePolicy -Name "DefaultCookiesSetting" -Value 4
Set-ChromePolicy -Name "DefaultGeolocationSetting" -Value 2
Set-ChromePolicy -Name "DefaultIdleDetectionSetting" -Value 2
Set-ChromePolicy -Name "DefaultNotificationsSetting" -Value 2
Set-ChromePolicy -Name "DefaultSearchProviderEnabled" -Value 1
Set-ChromePolicy -Name "DefaultSearchProviderName" -Value "DuckDuckGo"
Set-ChromePolicy -Name "DefaultSearchProviderSearchURL" -Value "https://duckduckgo.com/?q={searchTerms}"
Set-ChromePolicy -Name "DevToolsGenAiSettings" -Value 2
Set-ChromePolicy -Name "DnsOverHttpsMode" -Value "secure"
Set-ChromePolicy -Name "DnsOverHttpsTemplates" -Value "https://cloudflare-dns.com/dns-query"
Set-ChromePolicy -Name "GeminiActOnWebSettings" -Value 1
Set-ChromePolicy -Name "GeminiSettings" -Value 1
Set-ChromePolicy -Name "GeminiSparkSettings" -Value 1
Set-ChromePolicy -Name "GenAILocalFoundationalModelSettings" -Value 1
Set-ChromePolicy -Name "HelpMeWriteSettings" -Value 2
Set-ChromePolicy -Name "HighEfficiencyModeEnabled" -Value 0
Set-ChromePolicy -Name "HistorySearchSettings" -Value 2
Set-ChromePolicy -Name "HomepageLocation" -Value "chrome://new-tab-page"
Set-ChromePolicy -Name "HttpsOnlyMode" -Value "force_balanced_enabled"
Set-ChromePolicy -Name "NTPCardsVisible" -Value 0
Set-ChromePolicy -Name "NewTabPageLocation" -Value "chrome://new-tab-page"
Set-ChromePolicy -Name "PasswordLeakDetectionEnabled" -Value 0
Set-ChromePolicy -Name "PasswordManagerEnabled" -Value 0
Set-ChromePolicy -Name "PaymentMethodQueryEnabled" -Value 0
Set-ChromePolicy -Name "PromotionsEnabled" -Value 0
Set-ChromePolicy -Name "RestoreOnStartup" -Value 5
Set-ChromePolicy -Name "SafeBrowsingProtectionLevel" -Value 0
Set-ChromePolicy -Name "SearchContentSharingSettings" -Value 1
Set-ChromePolicy -Name "SearchSuggestEnabled" -Value 0
Set-ChromePolicy -Name "SmartTabSharingSettings" -Value 1
Set-ChromePolicy -Name "SyncTypesListDisabled" -Value @'
[
    "apps",
    "autofill",
    "bookmarks",
    "extensions",
    "preferences",
    "passwords",
    "payments",
    "productComparison",
    "readingList",
    "tabs",
    "themes",
    "typedUrls",
    "wifiConfigurations"
]
'@
Set-ChromePolicy -Name "TabCompareSettings" -Value 2
Set-ChromePolicy -Name "ThirdPartyAiChatSettings" -Value 1
Set-ChromePolicy -Name "TryOnYouSettings" -Value 2
Set-ChromePolicy -Name "VoiceTypingSettings" -Value 2

Write-Host "Chrome policies have been applied successfully." -ForegroundColor Green
Write-Host "Restart Chrome, then check chrome://policy." -ForegroundColor Yellow
