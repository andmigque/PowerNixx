function List-InternetIp {
    try {
        if ($IsLinux) {
            [string]$publicIPv4 = (curl -4 --silent ifconfig.co)
            [string]$publicIPv6 = (curl -6 --silent ifconfig.co)
            [string]$city = (curl --silent ifconfig.co/city)
            [string]$country = (curl --silent ifconfig.co/country)
        } else {
            [string]$publicIPv4 = (curl.exe -4 --silent ifconfig.co)
            [string]$publicIPv6 = (curl.exe -6 --silent ifconfig.co)
            [string]$city = (curl.exe --silent ifconfig.co/city)
            [string]$country = (curl.exe --silent ifconfig.co/country)
        }
        if ("$publicIPv4" -eq "") { $publicIPv4 = "no IPv4" }
        if ("$publicIPv6" -eq "") { $publicIPv6 = "no IPv6" }
        if ("$city" -eq "")       { $city = "unknown city" }
        if ("$country" -eq "")    { $country = "unknown country" }
        "✅ Internet IP $publicIPv4, $publicIPv6 near $city, $country"
    } catch {
            "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
    
}
