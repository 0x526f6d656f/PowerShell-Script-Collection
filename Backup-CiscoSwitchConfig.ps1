# pre reqs

# install Posh-SSH 1.7.7 if not installed
if (!(Get-InstalledModule -Name "Posh-SSH" -RequiredVersion "1.7.7" -ErrorAction SilentlyContinue)) {
    #Requires -RunAsAdministrator
    Install-Module -Name "Posh-SSH" -RequiredVersion "1.7.7" -Force
}

# install Posh-Cisco 1.0.3 if not installed
if (!(Get-InstalledModule -Name "Posh-Cisco" -RequiredVersion "1.0.3" -ErrorAction SilentlyContinue)) {
    #Requires -RunAsAdministrator
    Install-Module -Name "Posh-Cisco" -RequiredVersion "1.0.3" -Force
}

# make sure we import the correct versions
Import-Module -Name "Posh-SSH" -RequiredVersion "1.7.7"
Import-Module -Name "Posh-Cisco" -RequiredVersion "1.0.3"

# multidimensional array of switches, alternatively import with Get-Content
$switches = @(
    ("switch01", "192.168.0.1"),
    ("switch02", "192.168.1.1")
)

# get credentials for switch admin
$creds = Get-Credential -Message "Please enter the switch administrator account credentials."

# create folder structure
$date = (Get-Date).tostring("yyyy-MM-dd")

$folderpath = "C:\CiscoSwitchConfigs\"
if (!(Test-Path $folderpath\$date)) {
    New-Item -ItemType Directory -Force -Path $folderpath\$date | Out-Null
}

$switches | ForEach-Object {
    Backup-CiscoRunningConfig -HostAddress "$($_[1])" -HostPort 22 -Credential $creds -FilePath "$folderpath\$date\$($_[0])_running-config.txt" -AcceptKey
}
