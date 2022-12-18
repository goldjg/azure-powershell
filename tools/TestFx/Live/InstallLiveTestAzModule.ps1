param (
    [Parameter(Mandatory)]
    [ValidateSet("PSGallery", "LocalRepo", IgnoreCase = $false)]
    [string] $Source,

    [Parameter()]
    [string] $RepoLocation
)

switch ($Source) {
    "PSGallery" {
        Set-PSRepository -Name $Source -InstallationPolicy Trusted
    }
    "LocalRepo" {
        Register-PSRepository -Name $Source -SourceLocation $RepoLocation -PackageManagementProvider NuGet -InstallationPolicy Trusted
    }
}

Install-Module -Name Az -Repository $Source -Scope CurrentUser -AllowClobber -Force
