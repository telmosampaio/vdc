[CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $VaultName,
        [Parameter(Mandatory=$true)]
        [string]
        $KeyName,
        [Parameter(Mandatory=$false)]
        [string]
        $Destination
    )
if ($null -eq $Destination) {
    $Destination = "HSM";
}
$result = (Add-AzKeyVaultKey `
    -VaultName $VaultName `
    -Name $KeyName `
    -Destination $Destination).Id;

return $result