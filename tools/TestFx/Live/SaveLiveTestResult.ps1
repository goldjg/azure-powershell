param (
    [Parameter(Mandatory, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [guid] $ServicePrincipalTenantId,

    [Parameter(Mandatory, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [guid] $ServicePrincipalId,

    [Parameter(Mandatory, Position = 2)]
    [ValidateNotNullOrEmpty()]
    [string] $ServicePrincipalSecret,

    [Parameter(Mandatory, Position = 3)]
    [ValidateNotNullOrEmpty()]
    [string] $ClusterName,

    [Parameter(Mandatory, Position = 4)]
    [ValidateNotNullOrEmpty()]
    [string] $ClusterRegion,

    [Parameter(Mandatory, Position = 5)]
    [ValidateNotNullOrEmpty()]
    [string] $DatabaseName,

    [Parameter(Mandatory, Position = 6)]
    [ValidateNotNullOrEmpty()]
    [string] $LiveTestTableName,

    [Parameter(Mandatory, Position = 7)]
    [ValidateNotNullOrEmpty()]
    [string] $TestCoverageTableName,

    [Parameter(Mandatory, Position = 8)]
    [ValidateNotNullOrEmpty()]
    [string] $LiveTestLocation,

    [Parameter(Mandatory, Position = 9)]
    [ValidateNotNullOrEmpty()]
    [string] $TestCoverageLocation
)

Import-Module "./tools/TestFx/Utilities/KustoUtility.psd1" -Force

$liveTestDirectory = Join-Path -Path $LiveTestLocation -ChildPath "LiveTestAnalysis" | Join-Path -ChildPath "Raw"
if (Test-Path -LiteralPath $liveTestDirectory) {
    $liveTestResults = Get-ChildItem -Path $liveTestDirectory -Filter "*.csv" -File | Select-Object -ExpandProperty FullName
    Import-KustoDataFromCsv `
        -ServicePrincipalTenantId $ServicePrincipalTenantId `
        -ServicePrincipalId $ServicePrincipalId `
        -ServicePrincipalSecret $ServicePrincipalSecret `
        -ClusterName $ClusterName `
        -ClusterRegion $ClusterRegion `
        -DatabaseName $DatabaseName `
        -TableName $LiveTestTableName `
        -CsvFile $liveTestResults
}
else {
    Write-Warning "No live test data generated."
}

$testCoverageDirectory = Join-Path -Path $TestCoverageLocation -ChildPath "TestCoverageAnalysis" | Join-Path -ChildPath "Raw"
if (Test-Path -LiteralPath $testCoverageDirectory) {
    $testCoverageResults = Get-ChildItem -Path $testCoverageDirectory -Filter "*.csv" -File | Select-Object -ExpandProperty FullName
    Import-KustoDataFromCsv `
        -ServicePrincipalTenantId $ServicePrincipalTenantId `
        -ServicePrincipalId $ServicePrincipalId `
        -ServicePrincipalSecret $ServicePrincipalSecret `
        -ClusterName $ClusterName `
        -ClusterRegion $ClusterRegion `
        -DatabaseName $DatabaseName `
        -TableName $TestCoverageTableName `
        -CsvFile $testCoverageResults
}
else {
    Write-Warning "No test coverage data generated."
}
