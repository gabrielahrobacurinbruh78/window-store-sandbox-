$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "[*] INITIALIZING OFFLINE ECOSYSTEM EXTENSION & PROVISIONING ENGINE" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

$InfrastructureServices = @(
    "wuauserv", 
    "AppXSvc", 
    "ClipSVC", 
    "LicenseManager", 
    "StateRepository", 
    "trustedinstaller", 
    "CryptSvc"
)

foreach ($Service in $InfrastructureServices) {
    try {
        Set-Service -Name $Service -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name $Service -ErrorAction SilentlyContinue
        $CurrentStatus = (Get-Service -Name $Service).Status
        Write-Host " -> Component Layer [$Service]: $CurrentStatus" -ForegroundColor Gray
    } catch {
        Write-Host " -> Component Layer [$Service]: Service deployment initialized" -ForegroundColor DarkYellow
    }
}

if (Get-Process -Name "SystemSettings" -ErrorAction SilentlyContinue) {
    Stop-Process -Name "SystemSettings" -Force -ErrorAction SilentlyContinue
}
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Value 1 -ErrorAction SilentlyContinue

$PackageTargets = @(
    "*WindowsStore*",
    "*StorePurchaseApp*",
    "*DesktopAppInstaller*",
    "*XboxIdentityProvider*",
    "*WindowsCalculator*",
    "*WindowsNotepad*",
    "*WindowsPhotos*",
    "*MicrosoftStickyNotes*",
    "*VCLibs*",
    "*UI.Xaml*",
    "*NET.Native.Framework*",
    "*NET.Native.Runtime*"
)

$SearchPaths = @(
    "C:\HostWinSxS",
    "C:\HostWindowsApps",
    "C:\Windows\SystemApps"
)

$FrameworkQueue = [System.Collections.Generic.List[string]]::new()
$ApplicationQueue = [System.Collections.Generic.List[string]]::new()

foreach ($Path in $SearchPaths) {
    if (Test-Path $Path) {
        Write-Host " -> Component Scanned Index Target: $Path" -ForegroundColor Yellow
        foreach ($Target in $PackageTargets) {
            $Matches = Get-ChildItem -Path $Path -Filter $Target -Directory -ErrorAction SilentlyContinue
            foreach ($Folder in $Matches) {
                $Manifest = Join-Path $Folder.FullName "AppxManifest.xml"
                if (Test-Path $Manifest) {
                    if ($Folder.Name -match "Framework" -or $Folder.Name -match "VCLibs" -or $Folder.Name -match "UI.Xaml" -or $Folder.Name -match "NET.Native") {
                        if (-not $FrameworkQueue.Contains($Manifest)) { $FrameworkQueue.Add($Manifest) }
                    } else {
                        if (-not $ApplicationQueue.Contains($Manifest)) { $ApplicationQueue.Add($Manifest) }
                    }
                }
            }
        }
    }
}

Write-Host "`n -> Discovery State Complete: ($($FrameworkQueue.Count)) Core Framework Layers Found." -ForegroundColor Green
Write-Host " -> Discovery State Complete: ($($ApplicationQueue.Count)) Core Application Layers Found." -ForegroundColor Green

foreach ($Framework in $FrameworkQueue) {
    $FolderName = (Split-Path (Split-Path $Framework -Parent) -Leaf)
    Write-Host "   -> Registering System Dependency: $FolderName" -ForegroundColor White
    try {
        Add-AppxPackage -DisableDevelopmentMode -Register $Framework -ForceApplicationShutdown -ErrorAction Stop
    } catch {
        $ExMsg = $_.Exception.Message
        if ($ExMsg -match "higher version" -or $ExMsg -match "already installed") {
            Write-Host "      [State Confirmed]: Component layer verified." -ForegroundColor Cyan
        } else {
            Write-Host "      [Pipeline Bypassed]: Architecture mismatch." -ForegroundColor DarkGray
        }
    }
}

foreach ($App in $ApplicationQueue) {
    $FolderName = (Split-Path (Split-Path $App -Parent) -Leaf)
    Write-Host "   -> Force Registering Target Application: $FolderName" -ForegroundColor White
    try {
        Add-AppxPackage -DisableDevelopmentMode -Register $App -ForceApplicationShutdown -ErrorAction Stop
    } catch {
        $ExMsg = $_.Exception.Message
        if ($ExMsg -match "higher version" -or $ExMsg -match "already installed") {
            Write-Host "      [State Confirmed]: Core app profile verified." -ForegroundColor Cyan
        } else {
            Write-Host "      [Pipeline Bypassed]: Profile variant skipped." -ForegroundColor DarkGray
        }
    }
}

$SystemValidationIndex = Get-AppxPackage -AllUsers -Name "*WindowsStore*" -ErrorAction SilentlyContinue
if ($SystemValidationIndex) {
    Write-Host "======================================================================" -ForegroundColor Green
    Write-Host "[+] LOCAL DEPLOYMENT OPERATIONAL: ENVIRONMENT PROVISIONED" -ForegroundColor Green
    Write-Host "    Ecosystem Target: $($SystemValidationIndex.PackageFullName)" -ForegroundColor Gray
    Write-Host "======================================================================" -ForegroundColor Green
    Start-Process "ms-windows-store://" -ErrorAction SilentlyContinue
} else {
    Write-Host "======================================================================" -ForegroundColor Red
    Write-Host "[!] ALIGNMENT EXCEPTION: Missing structural packages in host volumes." -ForegroundColor Red
    Write-Host "======================================================================" -ForegroundColor Red
}
