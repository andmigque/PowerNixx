function sysctl {
    sysctl -a  | jc --sysctl | ConvertFrom-Json | Format-List
}