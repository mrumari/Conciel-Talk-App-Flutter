Write-Output "$WINDOWN_PFX"
Move-Item -Path $WINDOWS_PFX -Destination concieltalk.pem
certutil -decode concieltalk.pem concieltalk.pfx

flutter pub run msix:create -c concieltalk.pfx -p $WINDOWS_PFX_PASS --sign-msix true --install-certificate false
