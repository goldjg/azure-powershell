param (
    [Parameter(Mandatory)]
    [ValidateSet("PSGallery", "LocalRepo", IgnoreCase = $false)]
    [string] $Source,

    [Parameter()]
    [string] $RepoLocation
)

switch ($Source) {
    "PSGallery" {
        Write-Host "Source is PSGallery." -ForegroundColor Green

        Write-Host "Set installtion policy as trusted." -ForegroundColor Green

        Set-PSRepository -Name $Source -InstallationPolicy Trusted

        Write-Host "Successfully set installation policy as trusted." -ForegroundColor Green
    }
    "LocalRepo" {
        Write-Host "Source is LocalRepo." -ForegroundColor Green

        Write-Host "Register local repo as PS Repository." -ForegroundColor Green

        Register-PSRepository -Name $Source -SourceLocation $RepoLocation -PackageManagementProvider NuGet -InstallationPolicy Trusted

        Write-Host "Registered local repo as a trusted PS Repository." -ForegroundColor Green
    }
}

Write-Host "Install Az module." -ForegroundColor Green

Install-Module -Name Az -Repository $Source -Scope CurrentUser -AllowClobber -Force

Write-Host "Installed Az module." -ForegroundColor Green

Get-Module -Name Az -ListAvailable
Get-Module -Name Az.* -ListAvailable

Write-Host "Start to import module Az."

Import-Module -Name Az -MinimumVersion "2.6.0" -Verbose

Write-Host "Imported module Az."

Get-Module -Name Az
