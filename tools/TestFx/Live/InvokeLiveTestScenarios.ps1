param (
    [Parameter(Mandatory, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string] $BuildId,

    [Parameter(Mandatory, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string] $OSVersion,

    [Parameter(Mandatory, Position = 2)]
    [ValidateNotNullOrEmpty()]
    [string] $PSVersion,

    [Parameter(Mandatory, Position = 3)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string] $RepoRootPath,

    [Parameter(Mandatory, Position = 4)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string] $LiveTestRootPath
)

$srcDirectory = Join-Path -Path $RepoRootPath -ChildPath "src"
$liveScenarios = Get-ChildItem -LiteralPath $srcDirectory -Recurse -Directory -Filter "LiveTests" | ForEach-Object {
    Get-ChildItem -Path (Join-Path -Path $_.FullName -ChildPath "TestLiveScenarios.ps1") -File
}
$liveScenarios | ForEach-Object {
    $moduleName = [regex]::match($_.FullName, "[\\|\/]src[\\|\/](?<ModuleName>[a-zA-Z]+)[\\|\/]").Groups["ModuleName"].Value
    if ($PSVersion -eq "latest") {
        $PSVersion = (Get-Variable -Name PSVersionTable).Value.PSVersion.ToString()
    }
    Import-Module "./tools/TestFx/Assert.ps1" -Force
    Import-Module "./tools/TestFx/Live/LiveTestUtility.psd1" -ArgumentList $moduleName, $BuildId, $OSVersion, $PSVersion, $LiveTestRootPath -Force
    . $_
}
