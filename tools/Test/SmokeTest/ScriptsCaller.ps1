[cmdletbinding()]
param(
  [string]
  [Parameter(Mandatory = $true, Position = 0)]
  $requiredPsVersion,
  [string]
  [Parameter(Mandatory = $true, Position = 1)]
  $script
)

$IsLinuxEnv = (Get-Variable -Name "IsLinux" -ErrorAction Ignore) -and $IsLinux
$IsMacOSEnv = (Get-Variable -Name "IsMacOS" -ErrorAction Ignore) -and $IsMacOS
$IsWinEnv = !$IsLinuxEnv -and !$IsMacOSEnv

if (-not $DestinationPowerShell) {
  if ($IsWinEnv) {
      $DestinationPowerShell = "D:\a\_work\1\s\tools\Test\SmokeTest" 
  } else {
      $DestinationPowerShell = "~/.powershell"
  }
}

Write-Host "Required Version:", $requiredPsVersion, ", script:", $script
$windowsPowershellVersion = "5.1.14"

$script += " -ErrorAction Stop"
if($requiredPsVersion -eq $windowsPowershellVersion){
    Invoke-Command -ScriptBlock { param ($command) &"powershell.exe" -Command $command } -ArgumentList $script 
}else{
    $command = "`$PSVersionTable `
                  $script `
                  Exit"
    if($requiredPsVersion -eq "preview"){
      $Current = Get-Location
      Write-Host "Destination of Powershell: $DestinationPowerShell, Current: $Current" 
      cd $DestinationPowerShell
      ./pwsh -Command $command
      cd $Current
    }else{
      dotnet tool run pwsh -c $command
    }
}