## Installing SSH

# get available name of OpenSSH
PS C:\Users\Administrator> Get-WindowsCapability -Online | ? Name -like 'OpenSSH*' 

Name  : OpenSSH.Client~~~~0.0.1.0
State : Installed

Name  : OpenSSH.Server~~~~0.0.1.0
State : NotPresent

# install OpenSSH Server
PS C:\Users\Administrator> Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 

Path          :
Online        : True
RestartNeeded : False

# start sshd service
PS C:\Users\Administrator> Start-Service -Name "sshd" 

# set [Automatic] for Startup
PS C:\Users\Administrator> Set-Service -Name "sshd" -StartupType Automatic 

# verify settings
PS C:\Users\Administrator> Get-Service -Name "sshd" | Select-Object * 

Name                : sshd
RequiredServices    : {}
CanPauseAndContinue : False
CanShutdown         : False
CanStop             : True
DisplayName         : OpenSSH SSH Server
DependentServices   : {}
MachineName         : .
ServiceName         : sshd
ServicesDependedOn  : {}
ServiceHandle       : SafeServiceHandle
Status              : Running
ServiceType         : Win32OwnProcess
StartType           : Automatic
Site                :
Container           :


# if Windows Firewall is running, allow 22/TCP
# however, 22/TCP is generally allowed by OpenSSH installer, so it does not need to do the follows manually
PS C:\Users\Administrator> New-NetFirewallRule -Name "SSH" `
-DisplayName "SSH" `
-Description "Allow SSH" `
-Profile Any `
-Direction Inbound `
-Action Allow `
-Protocol TCP `
-Program Any `
-LocalAddress Any `
-RemoteAddress Any `
-LocalPort 22 `
-RemotePort Any 

Name                          : SSH
DisplayName                   : SSH
Description                   : Allow SSH
DisplayGroup                  :
Group                         :
Enabled                       : True
Profile                       : Any
Platform                      : {}
Direction                     : Inbound
Action                        : Allow
EdgeTraversalPolicy           : Block
LooseSourceMapping            : False
LocalOnlyMapping              : False
Owner                         :
PrimaryStatus                 : OK
Status                        : The rule was parsed successfully from the store. (65536)
EnforcementStatus             : NotApplicable
PolicyStoreSource             : PersistentStore
PolicyStoreSourceType         : Local
RemoteDynamicKeywordAddresses : {}
