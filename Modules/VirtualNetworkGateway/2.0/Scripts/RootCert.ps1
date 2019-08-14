[CmdletBinding()] 
param(
[Parameter(Mandatory=$true)]
[string]$TenantId,
[Parameter(Mandatory=$true)]
[string]$ServicePrincipal_ID,
[Parameter(Mandatory=$true)]
[string]$ServicePrincipal_Secret,
[Parameter(Mandatory=$true)]
[string]$KeyVaultName,
[Parameter(Mandatory=$true)]
[string]$KeyName
)

if($IsWindows -eq $true) {

    Write-Host "Generating Root Cert for Windows";
    $certPath = "Cert:\CurrentUser\My";
    $rootCert = Get-ChildItem -Path $certPath | Where-Object { $_.Subject -eq "CN=VPN CA" };
    if($null -eq $rootCert) {
        $rootCert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
                -Subject "CN=VPN CA" -KeyExportPolicy Exportable `
                -HashAlgorithm sha256 -KeyLength 2048 `
                -CertStoreLocation $certPath -KeyUsageProperty Sign -KeyUsage CertSign;
    }
    $rootCertPublicKey = $rootCert.GetPublicKeyString();
    Export-Certificate -Cert $rootCert.PSPath -FilePath C:\certs\rootCert.cer
    $rootCertPublicKey = [Convert]::ToBase64String($rootCert.RawData);
    
    # Store the base64 encoded public key of the rootCert as KeyVault secret
    az login --service-principal --username $ServicePrincipal_ID --password $ServicePrincipal_Secret --tenant $TenantId
    az keyvault secret set --vault-name $KeyVaultName --name $KeyName --value $rootCertPublicKey
}
elseif($IsLinux -eq $true) {
    Write-Host "Generating Root Cert for Linux";
    bash -c "/usr/src/app/Modules/VirtualNetworkGateway/2.0/Scripts/ClientCert.sh $TenantId $ServicePrincipal_ID $ServicePrincipal_Secret $KeyVaultName $KeyName";
}