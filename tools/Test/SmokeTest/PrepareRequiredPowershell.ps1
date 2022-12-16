[cmdletbinding()]
param(
  [string]
  [Parameter(Mandatory = $false, Position = 0)]
  $requiredPsVersion
)

$IsLinuxEnv = (Get-Variable -Name "IsLinux" -ErrorAction Ignore) -and $IsLinux
$IsMacOSEnv = (Get-Variable -Name "IsMacOS" -ErrorAction Ignore) -and $IsMacOS
$IsWinEnv = !$IsLinuxEnv -and !$IsMacOSEnv

if (-not $Destination) {
    if ($IsWinEnv) {
        $Destination = "$PSScriptRoot\Microsoft\powershell"
    } else {
        $Destination = "~/.powershell"
    }
}

Write-Verbose "The Destination is '$Destination'" -Verbose

$DestinationPreview = Join-Path -Path $Destination -ChildPath "new"
Write-Verbose "The DestinationPreview is '$DestinationPreview'" -Verbose
$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
function Expand-ArchiveInternal {
    [CmdletBinding()]
    param(
        $Path,
        $DestinationPath
    )

    if((Get-Command -Name Expand-Archive -ErrorAction Ignore))
    {
        Expand-Archive -Path $Path -DestinationPath $DestinationPath
    }
    else
    {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
        $resolvedDestinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DestinationPath)
        [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPath,$resolvedDestinationPath)
    }
}

function Install-Preview-PowerShell {
  if (-not $IsWinEnv) {
    $architecture = "x64"
  } elseif ($(Get-ComputerInfo -Property OsArchitecture).OsArchitecture -eq "ARM 64-bit Processor") {
    $architecture = "arm64"
  } else {
    switch ($env:PROCESSOR_ARCHITECTURE) {
        "AMD64" { $architecture = "x64" }
        "x86" { $architecture = "x86" }
        default { throw "PowerShell package for OS architecture '$_' is not supported." }
    }
  }

  $null = New-Item -ItemType Directory -Path $TempDir -Force -ErrorAction SilentlyContinue
  $metadata = Invoke-RestMethod https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json
  $release = $metadata.PreviewReleaseTag -replace '^v'

  if ($IsWinEnv) {
    $packageName = "PowerShell-${release}-win-${architecture}.zip"
  } elseif ($IsLinuxEnv) {
      $packageName = "powershell-${release}-linux-${architecture}.tar.gz"
  } elseif ($IsMacOSEnv) {
      $packageName = "powershell-${release}-osx-${architecture}.tar.gz"
  }

  $downloadURL = "https://github.com/PowerShell/PowerShell/releases/download/v${release}/${packageName}"
  Write-Verbose "About to download package from '$downloadURL'" -Verbose
  $packagePath = Join-Path -Path $TempDir -ChildPath $packageName

  try {
    Invoke-WebRequest -Uri $downloadURL -OutFile $packagePath
  } finally {
    if (!$PSVersionTable.ContainsKey('PSEdition') -or $PSVersionTable.PSEdition -eq "Desktop") {
      $ProgressPreference = $oldProgressPreference
    }
  }

  $contentPath= Join-Path -Path $TempDir -ChildPath "new"
  $null = New-Item -ItemType Directory -Path $contentPath -ErrorAction SilentlyContinue

  if ($IsWinEnv){
    Expand-ArchiveInternal -Path $packagePath -DestinationPath $contentPath
  }else{
    tar zxf $packagePath -C $contentPath
  }

  $null = New-Item -Path (Split-Path -Path $Destination -Parent) -ItemType Directory -ErrorAction SilentlyContinue
  Move-Item -Path $contentPath -Destination $Destination -Force 
}

function Install-PowerShell {
  param (
    [string]
    [Parameter(Mandatory = $false, Position = 0)]
    $requiredPsVersion
  )
  
  $windowsPowershellVersion = "5.1.14"

  # Prepare powershell
  if ($requiredPsVersion -ne $windowsPowershellVersion) {
    Write-Host "Installing PS $requiredPsVersion..."
    dotnet --version
    dotnet new tool-manifest --force
    if('latest' -eq $requiredPsVersion){
      dotnet tool install PowerShell
    }
    if('preview' -eq $requiredPsVersion){
      Install-Preview-PowerShell
    }
    else {
      dotnet tool install PowerShell --version $requiredPsVersion 
    }
    dotnet tool list
  }else {
    Write-Host "Powershell", $requiredPsVersion, "has been installed"
  }

  # Update PowershellGet to the latest one
  Write-Host "Updating PowershellGet to lastest version"
  if ($requiredPsVersion -eq $windowsPowershellVersion) {
    Install-Module -Repository PSGallery -Name PowerShellGet -Scope CurrentUser -AllowClobber -Force
  }else{
    $command = "Install-Module -Repository PSGallery -Name PowerShellGet -Scope CurrentUser -AllowClobber -Force `
    Exit"
    if('preview' -eq $requiredPsVersion){
      $env:Path=$DestinationPreview
      pwsh -c $command
      Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }else{
      dotnet tool run pwsh -c $command
    }
  }
}

# Image "macOS-10.15" preinstalled Az modules
# Image "vs2017-win2016" and "ubuntu-18.04" preinstalled AzureRM modules. 

# Remove Az.* modules
. "$PSScriptRoot/Common.ps1"
# Remove-AzModules

# If all images update AzureRM to Az, below codes should be deleted.
# Remove AzureRM.* modules
Remove-AzModules "AzureRM"
# If all images update AzureRM to Az, above codes should be deleted.

# Prepare PowerShell as required
Install-PowerShell $requiredPsVersion
 
