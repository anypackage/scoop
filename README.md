# AnyPackage.Scoop

AnyPackage.Scoop is an AnyPackage provider that facilitates installing Scoop apps from any Scoop bucket.

## Install AnyPackage.Scoop

```PowerShell
Install-PSResource AnyPackage.Scoop
```

## Import AnyPackage.Scoop

```PowerShell
Import-Module AnyPackage.Scoop
```

## Sample usages

### Search for a package

```PowerShell
Find-Package -Name 7zip

Find-Package -Name 7zip*
```

### Install a package

```PowerShell
Find-Package 7zip | Install-Package

Install-Package -Name 7zip
```

### Get list of installed packages

```PowerShell
Get-Package -Name 7zip
```

### Uninstall a package

```PowerShell
Get-Package -Name 7zip | Uninstall-Package

Uninstall-Package -Name 7zip
```

### Update a package

```PowerShell
Get-Package -Name 7zip | Update-Package

Uninstall-Package
```

### Manage official package sources

```PowerShell
Register-PackageSource -Provider Scoop -Official versions
Find-Package -Name cuda10 | Install-Package
Unregister-PackageSource -Name versions
```

### Manage unofficial package sources

```PowerShell
Register-PackageSource -Name TheRandomLabs_scoop-nonportable -Location https://github.com/TheRandomLabs/scoop-nonportable
Find-Package -Name 8gadgetpack-np | Install-Package
Unregister-PackageSource -Name TheRandomLabs_scoop-nonportable
```

## Known Issues

### Finding/Installing different package versions

Scoop does not maintain multiple versions for a single package name.
You can pass the version you wish to install but it does a find/replace on the version in the app manifest.
Then Scoop will try to use that to install the app but only at install time.
As such AnyPackage.Scoop does not allow for this arbitrary method.
To install versions than the latest use the versions official package source.
