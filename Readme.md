For better experience add to `/etc/sudoers.d/YOURUSER` replacing slavko with your username

```
#slavko ALL=(ALL) NOPASSWD: ALL

# vagrant-hostsupdater
Cmnd_Alias VAGRANT_HOSTS_ADD = /bin/sh -c echo "*" >> /etc/hosts
Cmnd_Alias VAGRANT_HOSTS_REMOVE = /usr/bin/sed -i -e /*/ d /etc/hosts
slavko ALL=(root) NOPASSWD: VAGRANT_HOSTS_ADD, VAGRANT_HOSTS_REMOVE

# vagrant-nfs
Cmnd_Alias VAGRANT_EXPORTS_ADD = /usr/bin/tee -a /etc/exports
Cmnd_Alias VAGRANT_NFSD = /sbin/nfsd restart
Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /usr/bin/sed -E -e /*/ d -ibak /etc/exports
slavko ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE

slavko ALL=(ALL) NOPASSWD: /usr/bin/truecrypt
slavko ALL=(ALL) NOPASSWD: /bin/systemctl
slavko ALL=(ALL) NOPASSWD: /sbin/poweroff, /sbin/reboot, /sbin/shutdown
slavko ALL=(ALL) NOPASSWD: /etc/init.d/nginx, /etc/init.d/mysql, /etc/init.d/mongod, /etc/init.d/redis, /etc/init.d/php-fpm, /usr/bin/pritunl-client-pk-start
slavko ALL=(ALL) NOPASSWD:SETENV: /usr/bin/docker, /usr/sbin/docker-gc, /usr/bin/vagrant

```


# cloud-init perks

Password can be created with

```
openssl passwd -1 -salt SaltSalt secret
```

example

```
openssl passwd -1 -salt slavko Passw0rd1
$1$slavko$mhTAXUOoJfrnQeSlO2AVR.
```

# ESXi notes

For ESXi following cloud-init package needs to be installed

https://github.com/vmware/cloud-init-vmware-guestinfo

## Dealing with naked centos-es

Check adapters

```
nmcli d
```

if exist, type “nmtui” command in your terminal to open Network manager. After opening Network manager chose “Edit connection” 


After activated,  use 
```
ip a
```

to validate, that address was really assigned.

If you are going to use that image as further ESXi template,
consider installing vmware cloud init 

```
curl -L -O ./cloudinit.rpm https://bit.ly/esxi-cloud-init
yum install ./cloudinit.rpm
```

target machine can be exported as ova template using

```
ovftool vi://$GOVC_USERNAME:$GOVC_PASSWORD@$GOVC_URL/VMNAME ./
```

target output can be packed into OVA image using 

```
tar -cvf centos7.ova *.ovf *.vmdk *.nvram *.mf
```

Note: order ovf, vmdk, nvram mf might be important

## ESXi terraform-provider-esxi plugin

I am using patched version of the great terraform-provider-esxi by https://github.com/josenk/terraform-provider-esxi
My original PR was slightly modified by author, and in a current master solution does not work (at least for me)

I have that in a backlog, but until that I am sticking to my version 1.5.4bis

https://github.com/Voronenko/terraform-provider-esxi/tree/1.5.4.bis 

which works nicely on my HomeLab environment


## ESXi and windows

Unless `ovftool --hideEula YourWindows.ova` shows you some useful properties for auto provisioning,
you will need to configure your virtual windows for provisioning manually

```powershell
# VMWare tools
choco install vmware-tools

# WinFiles
Set-ExecutionPolicy Bypass -Scope Process -Force; 
iex ((New-Object System.Net.WebClient).DownloadString('https://bit.ly/winfiles'))

# Ansible Remoting
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://bit.ly/ansible_remoting'))

# Optional, enable remote desktop if it is disabled for some reason
Set-ItemProperty -Path 'HKLM:SystemCurrentControlSetControlTerminal Server'-name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
```


# Inconsistent vms


Connect to the ESXi host using SSH client (Putty, mputty, etc.);

To get the ID of the problem virtual machine, run this command: 

```
vim-cmd vmsvc/getallvms | grep invalid
```

A list of all VMs with the Invalid status registered on this host will be displayed. 
There should be a string like: Skipping invalid VM '22'. In this case, 22 is the ID of the virtual machine;

If you want to try and restore this VM in vSphere, run the command: vim-cmd vmsvc/reload 22 (in a minute refresh the client interface and check the VM status);

If you want to unregister (delete) a problem virtual machine, run the following command: vim-cmd /vmsvc/unregister 22
