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
    $DestinationPowerShell = "D:\a\_work\1\s"
  }elseif($IsLinuxEnv){
    $DestinationPowerShell = "/mnt/vss/_work/1/s"
  }elseif($IsMacOSEnv){
    $DestinationPowerShell = "/Users/runner/work/1/s"
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
      $PSNativeCommandArgumentPassing = "Legacy"
      if (-not $IsWinEnv) { chmod 755 $Destination/pwsh }
      ./pwsh -Command $command
    }else{
      dotnet tool run pwsh -c $command
    }
}