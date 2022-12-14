[cmdletbinding()]
param(
  [string]
  [Parameter(Mandatory = $true, Position = 0)]
  $requiredPsVersion,
  [string]
  [Parameter(Mandatory = $true, Position = 1)]
  $script
)

Write-Host "Required Version:", $requiredPsVersion, ", script:", $script
$windowsPowershellVersion = "5.1.14"

$script += " -ErrorAction Stop"
if($requiredPsVersion -eq $windowsPowershellVersion){
    Invoke-Command -ScriptBlock { param ($command) &"powershell.exe" -Command $command } -ArgumentList $script 
}else{
    if($requiredPsVersion -eq "preview"){
      $command = "`$PSVersionTable `
                $script `
                Exit"
      pwsh-preview -c $command
    }else{
      $command = "`$PSVersionTable `
                $script `
                Exit"
      dotnet tool run pwsh -c $command
    }
}