https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/

/home/slavko/personal/ESXI/W10MSEdge/W10MSEdge.ova

ieuser / Passw0rd!


By default image is not so customizable, thus would require to be prepared for further provisioning

```
# Ansible Remoting
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://bit.ly/ansible_remoting'))

# Optional, enable remote desktop if it is disabled for some reason
Set-ItemProperty -Path 'HKLM:SystemCurrentControlSetControlTerminal Server'-name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
```

Allowing copy-pasting in winrm console:

Power off the VM.

Goto Edit Settings => Advanced => Edit Configuration Specify

```
Name:                                 Value:
isolation.tools.copy.disable          FALSE
isolation.tools.paste.disable         FALSE
isolation.tools.setGUIOptions.enable  TRUE
```
