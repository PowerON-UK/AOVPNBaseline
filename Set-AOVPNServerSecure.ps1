Set-VpnServerIPsecConfiguration -RevertToDefault | Out-Null
Set-VpnServerConfiguration -CustomPolicy `
    -AuthenticationTransformConstants SHA256128 `
    -CipherTransformConstants AES128 `
    -EncryptionMethod AES128 `
    -IntegrityCheckMethod SHA256 `
    -PfsGroup PFS2048 `
    -DHGroup Group14 `
    -SADataSizeForRenegotiationKilobytes 102400 `
    -SALifeTimeSeconds 28880 `
    -PassThru | Out-Null

Restart-Service "Routing and Remote Access"
Get-VpnServerConfiguration