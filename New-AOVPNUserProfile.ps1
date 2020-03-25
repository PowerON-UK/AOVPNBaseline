$ProfilePath = 'C:\Temp\AOVPN_User_Profile.xml'
$ExternalDNSName = "AOVPN.poweronplatforms.com"
$DNSSuffix = "PowerON.local"
$NPSServerName = "NPS-01.poweron.local"
$RootCAThumbprint = "05 49 D9 E2 D6 8C 0E 18 48 9F AD 29 8C 03 62 62 1D 33 42 28"
$IssuingCAThumbprintList = @("5E E1 D7 2E AC 4A D3 23 57 C3 3E FF 1F 8C 7A 25 3C 1E 74 7A")
$UserRouteList = @("10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16")

$xmlWriter = New-Object System.XMl.XmlTextWriter($ProfilePath,$Null)
$xmlWriter.Formatting = 'Indented'
$xmlWriter.Indentation = 2
$XmlWriter.IndentChar = " "
$xmlWriter.WriteStartElement('VPNProfile')

    $xmlWriter.WriteElementString('AlwaysOn','true')
    $xmlWriter.WriteElementString('DnsSuffix',$DNSSuffix)
    $xmlWriter.WriteElementString('TrustedNetworkDetection',$DNSSuffix)

    $xmlWriter.WriteStartElement('NativeProfile')
        $xmlWriter.WriteElementString('Servers',$ExternalDNSName)
        $xmlWriter.WriteElementString('RoutingPolicyType','SplitTunnel')
        $xmlWriter.WriteElementString('NativeProtocolType','IKEv2')
        $xmlWriter.WriteStartElement('Authentication')
            $xmlWriter.WriteElementString('UserMethod','Eap')
            $xmlWriter.WriteStartElement('Eap')
                $xmlWriter.WriteStartElement('Configuration')
                    $xmlWriter.WriteStartElement('EapHostConfig')
                    $XmlWriter.WriteAttributeString('xmlns', 'http://www.microsoft.com/provisioning/EapHostConfig')
                        $xmlWriter.WriteStartElement('EapMethod')
                            $xmlWriter.WriteElementString('Type',"http://www.microsoft.com/provisioning/EapCommon",25)
                            $xmlWriter.WriteElementString('VendorId',"http://www.microsoft.com/provisioning/EapCommon",0)
                            $xmlWriter.WriteElementString('VendorType',"http://www.microsoft.com/provisioning/EapCommon",0)
                            $xmlWriter.WriteElementString('AuthorId',"http://www.microsoft.com/provisioning/EapCommon",0)
                        $xmlWriter.WriteEndElement()
                        $xmlWriter.WriteStartElement('Config')
                        $XmlWriter.WriteAttributeString('xmlns', 'http://www.microsoft.com/provisioning/EapHostConfig')
                            $xmlWriter.WriteStartElement('Eap')
                            $XmlWriter.WriteAttributeString('xmlns', 'http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1')
                                $xmlWriter.WriteElementString('Type',25)
                                $xmlWriter.WriteStartElement('EapType')
                                $XmlWriter.WriteAttributeString('xmlns', 'http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV1')
                                    $xmlWriter.WriteStartElement('ServerValidation')
                                        $xmlWriter.WriteElementString('DisableUserPromptForServerValidation','true')
                                        $xmlWriter.WriteElementString('ServerNames',$NPSServerName)
                                        $xmlWriter.WriteElementString('TrustedRootCA',$RootCAThumbprint)
                                    $xmlWriter.WriteEndElement()
                                    $xmlWriter.WriteElementString('FastReconnect','true')
                                    $xmlWriter.WriteElementString('InnerEapOptional','false')
                                    $xmlWriter.WriteStartElement('Eap')
                                    $XmlWriter.WriteAttributeString('xmlns', 'http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1')
                                        $xmlWriter.WriteElementString('Type',13)
                                        $xmlWriter.WriteStartElement('EapType')
                                        $XmlWriter.WriteAttributeString('xmlns', 'http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV1')
                                            $xmlWriter.WriteStartElement('CredentialsSource')
                                                $xmlWriter.WriteStartElement('CertificateStore')
                                                    $xmlWriter.WriteElementString('SimpleCertSelection','true')
                                                $xmlWriter.WriteEndElement()
                                            $xmlWriter.WriteEndElement()
                                            $xmlWriter.WriteStartElement('ServerValidation')
                                                $xmlWriter.WriteElementString('DisableUserPromptForServerValidation','true')
                                                $xmlWriter.WriteElementString('ServerNames',$NPSServerName)
                                                $xmlWriter.WriteElementString('TrustedRootCA',$RootCAThumbprint)
                                            $xmlWriter.WriteEndElement()
                                            $xmlWriter.WriteElementString('DifferentUsername','false')
                                            $xmlWriter.WriteElementString('PerformServerValidation',"http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV2",'true')
                                            $xmlWriter.WriteElementString('AcceptServerName',"http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV2",'true')
                                            $xmlWriter.WriteStartElement('TLSExtensions')
                                            $XmlWriter.WriteAttributeString('xmlns', 'http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV2')
                                                $xmlWriter.WriteStartElement('FilteringInfo')
                                                $XmlWriter.WriteAttributeString('xmlns', 'http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV3')
                                                    $xmlWriter.WriteStartElement('CAHashList')
                                                    $XmlWriter.WriteAttributeString('Enabled', 'true')
                                                        foreach ($Hash in $IssuingCAThumbprintList)
                                                        {
                                                        $xmlWriter.WriteElementString('IssuerHash',$Hash)
                                                        }
                                                    $xmlWriter.WriteEndElement()
                                                $xmlWriter.WriteEndElement()
                                            $xmlWriter.WriteEndElement()
                                        $xmlWriter.WriteEndElement()
                                    $xmlWriter.WriteEndElement()
                                    $xmlWriter.WriteElementString('EnableQuarantineChecks','false')
                                    $xmlWriter.WriteElementString('RequireCryptoBinding','false')
                                    $xmlWriter.WriteStartElement('PeapExtensions')
                                        $xmlWriter.WriteElementString('PerformServerValidation',"http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV2",'true')
                                        $xmlWriter.WriteElementString('AcceptServerName',"http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV2",'true')
                                    $xmlWriter.WriteEndElement()
                                $xmlWriter.WriteEndElement()
                            $xmlWriter.WriteEndElement()
                        $xmlWriter.WriteEndElement()
                    $xmlWriter.WriteEndElement()
                $xmlWriter.WriteEndElement()
            $xmlWriter.WriteEndElement()
        $xmlWriter.WriteEndElement()
        $xmlWriter.WriteElementString('DisableClassBasedDefaultRoute','true')
        $xmlWriter.WriteStartElement('CryptographySuite')
            $xmlWriter.WriteElementString('AuthenticationTransformConstants','SHA256128')
            $xmlWriter.WriteElementString('CipherTransformConstants','AES128')
            $xmlWriter.WriteElementString('EncryptionMethod','AES128')
            $xmlWriter.WriteElementString('IntegrityCheckMethod','SHA256')
            $xmlWriter.WriteElementString('DHGroup','Group14')
            $xmlWriter.WriteElementString('PfsGroup','PFS2048')
        $xmlWriter.WriteEndElement()
    $xmlWriter.WriteEndElement()

    $xmlWriter.WriteElementString('RememberCredentials','true')

    foreach ($Route in $UserRouteList)
    {
        $SplitRoute = $Route.Split('/')
        if ($SplitRoute.count -ne 2)
        {
            if ($SplitRoute[0].Split('.').count -ne 4)
            {
                throw "Routes must be in the format x.x.x.x/x"
            }
            else
            {
                #Assume the address is an individual IPv4 address
                $Address = $SplitRoute[0]
                $Prefix = 32
            }
        }
        else
        {
            $Address = $SplitRoute[0]
            $Prefix = $SplitRoute[1]
        }
        $xmlWriter.WriteStartElement('Route')
            $xmlWriter.WriteElementString('Address',$Address)
            $xmlWriter.WriteElementString('PrefixSize',$Prefix)
        $xmlWriter.WriteEndElement()
    }
$xmlWriter.WriteEndElement()

#Finish the Profile
$xmlWriter.Flush()
$xmlWriter.Close()