#WinRM Setup

You need to configure the WinRM service so that Ansible can connect to it. There are two main components of the WinRM service that governs how Ansible can interface with the Windows host: the listener and the service configuration settings.

## WinRM Listener
The WinRM services listen for requests on one or more ports. Each of these ports must have a listener created and configured.

To view the current listeners that are running on the WinRM service:

```
winrm enumerate winrm/config/Listener
```

This will output something like:

```
Listener
    Address = *
    Transport = HTTP
    Port = 5985
    Hostname
    Enabled = true
    URLPrefix = wsman
    CertificateThumbprint
    ListeningOn = 10.0.2.15, 127.0.0.1, 192.168.56.155, ::1, fe80::5efe:10.0.2.15%6, fe80::5efe:192.168.56.155%8, fe80::
ffff:ffff:fffe%2, fe80::203d:7d97:c2ed:ec78%3, fe80::e8ea:d765:2c69:7756%7

Listener
    Address = *
    Transport = HTTPS
    Port = 5986
    Hostname = SERVER2016
    Enabled = true
    URLPrefix = wsman
    CertificateThumbprint = E6CDAA82EEAF2ECE8546E05DB7F3E01AA47D76CE
    ListeningOn = 10.0.2.15, 127.0.0.1, 192.168.56.155, ::1, fe80::5efe:10.0.2.15%6, fe80::5efe:192.168.56.155%8, fe80::
ffff:ffff:fffe%2, fe80::203d:7d97:c2ed:ec78%3, fe80::e8ea:d765:2c69:7756%7
```

In the example above there are two listeners activated. One is listening on port 5985 over HTTP and the other is listening on port 5986 over HTTPS. Some of the key options that are useful to understand are:

`Transport`: Whether the listener is run over HTTP or HTTPS. We recommend you use a listener over HTTPS because the data is encrypted without any further changes required.

`Port`: The port the listener runs on. By default it is 5985 for HTTP and 5986 for HTTPS. This port can be changed to whatever is required and corresponds to the host var ansible_port.

`URLPrefix`: The URL prefix to listen on. By default it is wsman. If you change this option, you need to set the host var ansible_winrm_path to the same value.

`CertificateThumbprint`: If you use an HTTPS listener, this is the thumbprint of the certificate in the Windows Certificate Store that is used in the connection. To get the details of the certificate itself, run this command with the relevant certificate thumbprint in PowerShell:

```
$thumbprint = "E6CDAA82EEAF2ECE8546E05DB7F3E01AA47D76CE"
Get-ChildItem -Path cert:\LocalMachine\My -Recurse | Where-Object { $_.Thumbprint -eq $thumbprint } | Select-Object *
``
## Setup WinRM Listener
There are three ways to set up a WinRM listener:

Using winrm quickconfig for HTTP or winrm quickconfig -transport:https for HTTPS. This is the easiest option to use when running outside of a domain environment and a simple listener is required. Unlike the other options, this process also has the added benefit of opening up the firewall for the ports required and starts the WinRM service.

Using Group Policy Objects (GPO). This is the best way to create a listener when the host is a member of a domain because the configuration is done automatically without any user input. For more information on group policy objects, see the Group Policy Objects documentation.

Using PowerShell to create a listener with a specific configuration. This can be done by running the following PowerShell commands:

```
$selector_set = @{
    Address = "*"
    Transport = "HTTPS"
}
$value_set = @{
    CertificateThumbprint = "E6CDAA82EEAF2ECE8546E05DB7F3E01AA47D76CE"
}

New-WSManInstance -ResourceURI "winrm/config/Listener" -SelectorSet $selector_set -ValueSet $value_set
```

To see the other options with this PowerShell command, refer to the New-WSManInstance documentation.

### Note

When creating an HTTPS listener, you must create and store a certificate in the LocalMachine\My certificate store.

## Delete WinRM Listener
To remove all WinRM listeners:

```
Remove-Item -Path WSMan:\localhost\Listener\* -Recurse -Force
```

To remove only those listeners that run over HTTPS:

```
Get-ChildItem -Path WSMan:\localhost\Listener | Where-Object { $_.Keys -contains "Transport=HTTPS" } | Remove-Item -Recurse -Force
```

### Note

The Keys object is an array of strings, so it can contain different values. By default, it contains a key for Transport= and Address= which correspond to the values from the winrm enumerate winrm/config/Listeners command.

## WinRM Service Options
You can control the behavior of the WinRM service component, including authentication options and memory settings.

To get an output of the current service configuration options, run the following command:

```
winrm get winrm/config/Service
winrm get winrm/config/Winrs
```

This will output something like:

```
Service
    RootSDDL = O:NSG:BAD:P(A;;GA;;;BA)(A;;GR;;;IU)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)
    MaxConcurrentOperations = 4294967295
    MaxConcurrentOperationsPerUser = 1500
    EnumerationTimeoutms = 240000
    MaxConnections = 300
    MaxPacketRetrievalTimeSeconds = 120
    AllowUnencrypted = false
    Auth
        Basic = true
        Kerberos = true
        Negotiate = true
        Certificate = true
        CredSSP = true
        CbtHardeningLevel = Relaxed
    DefaultPorts
        HTTP = 5985
        HTTPS = 5986
    IPv4Filter = *
    IPv6Filter = *
    EnableCompatibilityHttpListener = false
    EnableCompatibilityHttpsListener = false
    CertificateThumbprint
    AllowRemoteAccess = true

Winrs
    AllowRemoteShellAccess = true
    IdleTimeout = 7200000
    MaxConcurrentUsers = 2147483647
    MaxShellRunTime = 2147483647
    MaxProcessesPerShell = 2147483647
    MaxMemoryPerShellMB = 2147483647
    MaxShellsPerUser = 2147483647
```

You do not need to change the majority of these options. However, some of the important ones to know about are:

`Service\AllowUnencrypted` - specifies whether WinRM will allow HTTP traffic without message encryption. Message level encryption is only possible when the ansible_winrm_transport variable is ntlm, kerberos or credssp. By default, this is false and you should only set it to true when debugging WinRM messages.

`Service\Auth\*` - defines what authentication options you can use with the WinRM service. By default, Negotiate (NTLM) and Kerberos are enabled.

`Service\Auth\CbtHardeningLevel` - specifies whether channel binding tokens are not verified (None), verified but not required (Relaxed), or verified and required (Strict). CBT is only used when connecting with NT LAN Manager (NTLM) or Kerberos over HTTPS.

`Service\CertificateThumbprint` - thumbprint of the certificate for encrypting the TLS channel used with CredSSP authentication. By default, this is empty. A self-signed certificate is generated when the WinRM service starts and is used in the TLS process.

`Winrs\MaxShellRunTime` - maximum time, in milliseconds, that a remote command is allowed to execute.

`Winrs\MaxMemoryPerShellMB` - maximum amount of memory allocated per shell, including its child processes.

To modify a setting under the Service key in PowerShell, you need to provide a path to the option after winrm/config/Service:

```
Set-Item -Path WSMan:\localhost\Service\{path} -Value {some_value}
```

For example, to change `Service\Auth\CbtHardeningLevel`:

```
Set-Item -Path WSMan:\localhost\Service\Auth\CbtHardeningLevel -Value Strict
```

To modify a setting under the Winrs key in PowerShell, you need to provide a path to the option after winrm/config/Winrs:

```
Set-Item -Path WSMan:\localhost\Shell\{path} -Value {some_value}
```

For example, to change Winrs\MaxShellRunTime:

```
Set-Item -Path WSMan:\localhost\Shell\MaxShellRunTime -Value 2147483647
```

### Note

If you run the command in a domain environment, some of these options are set by GPO and cannot be changed on the host itself. When you configured a key with GPO, it contains the text [Source="GPO"] next to the value.

## Common WinRM Issues
WinRM has a wide range of configuration options, which makes its configuration complex. As a result, errors that Ansible displays could in fact be problems with the host setup instead.

To identify a host issue, run the following command from another Windows host to connect to the target Windows host.

To test HTTP:

```
winrs -r:http://server:5985/wsman -u:Username -p:Password ipconfig
```

To test HTTPS:

```
winrs -r:https://server:5986/wsman -u:Username -p:Password -ssl ipconfig
```
The command will fail if the certificate is not verifiable.

To test HTTPS ignoring certificate verification:

```
$username = "Username"
$password = ConvertTo-SecureString -String "Password" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

$session_option = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
Invoke-Command -ComputerName server -UseSSL -ScriptBlock { ipconfig } -Credential $cred -SessionOption $session_option
```

If any of the above commands fail, the issue is probably related to the WinRM setup.

### HTTP 401/Credentials Rejected
An HTTP 401 error indicates the authentication process failed during the initial connection. You can check the following to troubleshoot:

The credentials are correct and set properly in your inventory with the ansible_user and ansible_password variables.

The user is a member of the local Administrators group, or has been explicitly granted access. You can perform a connection test with the winrs command to rule this out.

The authentication option set by the ansible_winrm_transport variable is enabled under Service\Auth\*.

If running over HTTP and not HTTPS, use ntlm, kerberos or credssp with the ansible_winrm_message_encryption: auto custom inventory variable to enable message encryption. If you use another authentication option, or if it is not possible to upgrade the installed pywinrm package, you can set Service\AllowUnencrypted to true. This is recommended only for troubleshooting.

The downstream packages pywinrm, requests-ntlm, requests-kerberos, and/or requests-credssp are up to date using pip.

For Kerberos authentication, ensure that Service\Auth\CbtHardeningLevel is not set to Strict.

For Basic or Certificate authentication, make sure that the user is a local account. Domain accounts do not work with Basic and Certificate authentication.

### HTTP 500 Error
An HTTP 500 error indicates a problem with the WinRM service. You can check the following to troubleshoot:

The number of your currently open shells has not exceeded either WinRsMaxShellsPerUser. Alternatively, you did not exceed any of the other Winrs quotas.

### Timeout Errors
Sometimes Ansible is unable to reach the host. These instances usually indicate a problem with the network connection. You can check the following to troubleshoot:

The firewall is not set to block the configured WinRM listener ports.

A WinRM listener is enabled on the port and path set by the host vars.

The winrm service is running on the Windows host and is configured for the automatic start.

### Connection Refused Errors
When you communicate with the WinRM service on the host you can encounter some problems. Check the following to help the troubleshooting:

The WinRM service is up and running on the host. Use the (Get-Service -Name winrm).Status command to get the status of the service.

The host firewall is allowing traffic over the WinRM port. By default this is 5985 for HTTP and 5986 for HTTPS.

Sometimes an installer may restart the WinRM or HTTP service and cause this error. The best way to deal with this is to use the win_psexec module from another Windows host.

### Failure to Load Builtin Modules
Sometimes PowerShell fails with an error message similar to:

The 'Out-String' command was found in the module 'Microsoft.PowerShell.Utility', but the module could not be loaded.
In that case, there could be a problem when trying to access all the paths specified by the PSModulePath environment variable.

A common cause of this issue is that PSModulePath contains a Universal Naming Convention (UNC) path to a file share. Additionally, the double hop/credential delegation issue causes that the Ansible process cannot access these folders. To work around this problem is to either:

Remove the UNC path from PSModulePath.

or

Use an authentication option that supports credential delegation like credssp or kerberos. You need to have the credential delegation enabled.

See KB4076842 for more information on this problem.

