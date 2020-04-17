"Typical" dotnet application builder

```
choco list dotnetcore --version=2.1
```

```
 choco install -y dotnetcore-sdk
 choco install -y netfx-4.5.2-devpack
 choco install -y nuget.commandline

 choco install -y visualstudio2019community

 # Workloads
 #Desktop development with C++
 choco install -y visualstudio2019-workload-manageddesktop
 # .NET desktop development
 choco install -y visualstudio2019-workload-nativedesktop
 #.NET Core cross-platform development
 choco install -y visualstudio2019-workload-netcoretools

 # Optional: ASP.NET and web development
 choco install -y visualstudio2019-workload-netweb

 #Individual components
 # .NET Framework 4.7 targeting pack
 choco install -y netfx-4.7-devpack
 choco install -y visualstudio2019-workload-manageddesktop
 choco install -y visualstudio2019-workload-nativedesktop
 choco install -y visualstudio2019-workload-netcoretools
 choco install -y visualstudio2019-workload-netweb
 choco install -y netfx-4.7-devpack
 choco install -y visualstudio2019-workload-nativecrossplat
 choco install -y  visualstudio2019-workload-vctools

# https://github.com/wixtoolset/wix3/releases/tag/wix3112rtm
# https://developercommunity.visualstudio.com/content/problem/448515/visual-studio-2019-building-visual-studio-2017-c-p.html :))
```

In order to load development environment in your shell scenario

```
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat"
```
