$ProfilePath = 'AOVPN_Device_Profile.xml'
$ExternalDNSName = "AOVPN.poweronplatforms.com"
$DNSSuffix = "PowerON.local"
$DeviceRouteList = @("10.0.0.15", "10.0.0.16/32")

$xmlWriter = New-Object System.XMl.XmlTextWriter($ProfilePath,$Null)
$xmlWriter.Formatting = 'Indented'
$xmlWriter.Indentation = 2
$XmlWriter.IndentChar = " "
$xmlWriter.WriteStartElement('VPNProfile')

    $xmlWriter.WriteElementString('AlwaysOn','true')
    $xmlWriter.WriteElementString('DeviceTunnel','true')
    $xmlWriter.WriteElementString('DnsSuffix',$DNSSuffix)
    $xmlWriter.WriteElementString('RegisterDNS','true')
    $xmlWriter.WriteElementString('TrustedNetworkDetection',$DNSSuffix)

    $xmlWriter.WriteStartElement('NativeProfile')
        $xmlWriter.WriteElementString('Servers',$ExternalDNSName)
        $xmlWriter.WriteElementString('RoutingPolicyType','SplitTunnel')
        $xmlWriter.WriteElementString('NativeProtocolType','IKEv2')
        $xmlWriter.WriteStartElement('Authentication')
            $xmlWriter.WriteElementString('MachineMethod','Certificate')
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

    foreach ($Route in $DeviceRouteList)
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