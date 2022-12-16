[cmdletbinding()]
param(
  [string]
  [Parameter(Mandatory = $true, Position = 0)]
  $requiredPsVersion,
  [string]
  [Parameter(Mandatory = $true, Position = 1)]
  $script
)

if (-not $DestinationPowerShell) {
  if ($IsWinEnv) {
      $DestinationPowerShell = "$PSScriptRoot\Microsoft\powershell"
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
      cd $DestinationPowerShell
      ./pwsh -c $command
    }else{
      dotnet tool run pwsh -c $command
    }
}