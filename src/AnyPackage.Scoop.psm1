# Copyright (c) Thomas Nieto - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the MIT license.

using module AnyPackage
using namespace AnyPackage.Provider
using namespace NuGet.Versioning
using namespace System.Management.Automation

[PackageProvider('Scoop')]
class ScoopProvider : PackageProvider, IFindPackage, IGetPackage,
    IInstallPackage, IUpdatePackage, IUninstallPackage, IGetSource, ISetSource {
    ScoopProvider() : base('28111522-ea7a-4e8a-b598-85389c17f8be') { }

    [PackageProviderInfo] Initialize([PackageProviderInfo] $providerInfo) {
        return [ScoopProviderInfo]::new($providerInfo)
    }

    [void] FindPackage([PackageRequest] $request) {
        Find-ScoopApp -Name $request.Name |
        Write-Package -Request $request -OfficialSources $this.ProviderInfo.OfficialSources
    }

    [void] GetPackage([PackageRequest] $request) {
        Get-ScoopApp -Name $request.Name |
        Write-Package -Request $request -OfficialSources $this.ProviderInfo.OfficialSources
    }

    [void] InstallPackage([PackageRequest] $request) {
        $installScoopAppParams = @{ }

        if ($request.DynamicParameters.Architecture) {
            $installScoopAppParams['Architecture'] = $request.DynamicParameters.Architecture
        }

        if ($request.DynamicParameters.SkipDependencies) {
            $installScoopAppParams['SkipDependencies'] = $request.DynamicParameters.SkipDependencies
        }

        if ($request.DynamicParameters.NoCache) {
            $installScoopAppParams['NoCache'] = $request.DynamicParameters.NoCache
        }

        if ($request.DynamicParameters.SkipHashCheck) {
            $installScoopAppParams['SkipHashCheck'] = $request.DynamicParameters.SkipHashCheck
        }

        if ($request.DynamicParameters.Scope -eq 'AllUsers') {
            $installScoopAppParams['Global'] = $true
        }

        $findPackageParameters = @{ Name = $request.Name }

        if ($request.Source) { $findPackageParameters['Bucket'] = $request.Source }

        Find-ScoopApp @findPackageParameters |
        Where-Object { $request.IsMatch([PackageVersion]$_.Version) } |
        Select-Object -Property Name |
        Install-ScoopApp @installScoopAppParams

        Get-ScoopApp -Name $request.Name |
        Write-Package -Request $request -OfficialSources $this.ProviderInfo.OfficialSources
    }

    [void] UpdatePackage([PackageRequest] $request) {
        $installScoopAppParams = @{ }

        if ($request.DynamicParameters.SkipDependencies) {
            $installScoopAppParams['SkipDependencies'] = $request.DynamicParameters.SkipDependencies
        }

        if ($request.DynamicParameters.NoCache) {
            $installScoopAppParams['NoCache'] = $request.DynamicParameters.NoCache
        }

        if ($request.DynamicParameters.SkipHashCheck) {
            $installScoopAppParams['SkipHashCheck'] = $request.DynamicParameters.SkipHashCheck
        }

        if ($request.DynamicParameters.Scope -eq 'AllUsers') {
            $installScoopAppParams['Global'] = $true
        }

        if ($request.DynamicParameters.Reinstall) {
            $installScoopAppParams['Force'] = $true
        }

        $getPackageParameters = @{ Name = $request.Name}
        $findPackageParameters = @{ }

        if ($request.Source) { $findPackageParameters['Bucket'] = $request.Source }

        Get-ScoopApp @getPackageParameters |
        Find-ScoopApp @findPackageParameters |
        Where-Object { $request.IsMatch([PackageVersion]$_.Version) } |
        Select-Object -Property Name |
        Update-ScoopApp @installScoopAppParams

        Get-ScoopApp -Name $request.Name |
        Write-Package -Request $request -OfficialSources $this.ProviderInfo.OfficialSources
    }

    [void] UninstallPackage([PackageRequest] $request) {
        $uninstallScoopAppParams = @{ }

        if ($request.DynamicParameters.RemoveData) {
            $uninstallScoopAppParams['Purge'] = $request.DynamicParameters.RemoveData
        }

        if ($request.DynamicParameters.Scope -eq 'AllUsers') {
            $uninstallScoopAppParams['Global'] = $true
        }

        $package = Get-ScoopApp -Name $request.Name |
        Where-Object { $request.IsMatch([PackageVersion]$_.Version) }

        $package | Uninstall-ScoopApp @uninstallScoopAppParams

        if (-not ($package | Get-ScoopApp)) {
            $package |
            Write-Package -Request $request -OfficialSources $this.PackageInfo.OfficialSources
        }
    }

    [void] GetSource([SourceRequest] $sourceRequest) {
        Get-ScoopBucket |
        Write-Source -Request $sourceRequest -OfficialSources $this.ProviderInfo.OfficialSources
    }

    [void] RegisterSource([SourceRequest] $sourceRequest) {
        if ($sourceRequest.Trusted) {
            throw 'Scoop provider does not support Trusted parameter.'
        }

        $registerBucketParams = @{
            Force = $sourceRequest.Force
        }

        if ($sourceRequest.Name) {
            $name = $sourceRequest.Name
            $registerBucketParams['Name'] = $sourceRequest.Name
            $registerBucketParams['Uri'] = $sourceRequest.Location
        }
        else {
            if (-not ($sourceRequest.DynamicParameters.Official -in $this.ProviderInfo.OfficialSources.Keys)) {
                throw "'$($sourceRequest.DynamicParameters.Official)' is not an official source."
            }

            $name = $sourceRequest.DynamicParameters.Official
            $registerBucketParams['Official'] = $sourceRequest.DynamicParameters.Official
        }

        if ((Get-ScoopBucket -Name $name) -and -not $sourceRequest.Force) {
            throw "Source '$name' already exists. Use -Force to recreate the source."
        }

        Register-ScoopBucket @registerBucketParams

        Get-ScoopBucket -Name $name |
        Write-Source -Request $sourceRequest -OfficialSources $this.ProviderInfo.OfficialSources
    }

    [void] SetSource([SourceRequest] $sourceRequest) {
        if ($sourceRequest.Trusted) {
            throw 'Scoop provider does not support Trusted parameter.'
        }

        Register-ScoopBucket -Name $sourceRequest.Name -Uri $sourceRequest.Location -Force

        $this.GetSource($sourceRequest)
    }

    [void] UnregisterSource([SourceRequest] $sourceRequest) {
        $source = Get-ScoopBucket -Name $sourceRequest.Name

        if (-not $source) { return }

        Unregister-ScoopBucket -Name $sourceRequest.Name

        $source |
        Write-Source -Request $sourceRequest -OfficialSources $this.ProviderInfo.OfficialSources
    }

    [object] GetDynamicParameters([string] $commandName) {
        return $(switch ($commandName) {
            'Register-PackageSource' { [RegisterPackageSourceDynamicParameters]::new() }
            'Install-Package' { [InstallPackageDynamicParameters]::new() }
            'Uninstall-Package' { [UninstallPackageDynamicParameters]::new() }
            'Update-Package' { [UpdatePackageDynamicParameters]::new() }
            default { $null }
        })
    }
}

class RegisterPackageSourceDynamicParameters {
    [Parameter(Mandatory,
        ParameterSetName = 'Official')]
    [ValidateNotNullOrEmpty()]
    [string]
    $Official
}

class ScopeDynamicParameters {
    [Parameter()]
    [ValidateSet('CurrentUser', 'AllUsers')]
    [string]
    $Scope = 'CurrentUser'
}

class OptionalDynamicParameters : ScopeDynamicParameters {
    [Parameter()]
    [switch]
    $SkipDependencies

    [Parameter()]
    [switch]
    $NoCache

    [Parameter()]
    [switch]
    $SkipHashCheck
}

class InstallPackageDynamicParameters : OptionalDynamicParameters {
    [Parameter()]
    [ValidateSet('32bit', '64bit', 'arm64')]
    [string]
    $Architecture
}

class UpdatePackageDynamicParameters : OptionalDynamicParameters {
    [Parameter()]
    [switch]
    $Reinstall
}

class UninstallPackageDynamicParameters : ScopeDynamicParameters {
    [Parameter()]
    [switch]
    $RemoveData
}

class ScoopProviderInfo : PackageProviderInfo {
    [hashtable] $OfficialSources

    ScoopProviderInfo([PackageProviderInfo] $providerInfo) : base($providerInfo) {
        $this.SetOfficialSources()
    }

    hidden [void] SetOfficialSources() {
        $path = Get-Command -Name Scoop |
        Select-Object -ExpandProperty Path |
        Split-Path |
        Split-Path |
        Join-Path -ChildPath apps\scoop\current\buckets.json

        $sources = Get-Content -Path $path |
        ConvertFrom-Json

        $keys = $sources |
        Get-Member -MemberType NoteProperty |
        Select-Object -ExpandProperty Name

        $ht = @{ }
        foreach ($key in $keys) {
            $ht[$key] = $sources.$key
        }

        $this.OfficialSources = $ht
    }
}

$ScriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    # Suppress PSReviewUnusedParameter warning since suppressing it does not work.
    $null = $commandName, $parameterName, $commandAst, $fakeBoundParameters

    Get-PackageProvider -Name Scoop |
    Select-Object -ExpandProperty OfficialSources |
    Select-Object -ExpandProperty Keys |
    Where-Object Name -Like "$wordToComplete*" |
    ForEach-Object {
        [CompletionResult]::new($_)
    }
}

Register-ArgumentCompleter -CommandName Register-PackageSource -ParameterName Official -ScriptBlock $ScriptBlock

[PackageProviderManager]::RegisterProvider([ScoopProvider], $MyInvocation.MyCommand.ScriptBlock.Module)

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    [PackageProviderManager]::UnregisterProvider([ScoopProvider])
}

function Write-Source {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Source')]
        [string]
        $Location,

        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime]
        $Updated,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int]
        $Manifests,

        [Parameter(Mandatory)]
        [SourceRequest]
        $Request,

        [Parameter()]
        [hashtable]
        $OfficialSources
    )

    process {
        if ($Name -like $Request.Name) {
            $trusted = if ($Location -in $OfficialSources.Values) { $true } else { $false }
            $Request.WriteSource($Name, $Location, $trusted, @{ Updated = $Updated; Manifests = $Manifests })
        }
    }
}

function Write-Package {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Version,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Description,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Source,

        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime]
        $Updated,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Info,

        [Parameter(Mandatory)]
        [PackageRequest]
        $Request,

        [Parameter()]
        [hashtable]
        $OfficialSources
    )

    begin {
        $buckets = Get-ScoopBucket
    }

    process {
        $metadata = @{ }
        if ($Updated) { $metadata['Updated'] = $Updated }
        if ($Info) { $metadata['Info'] = $Info }
        if ($Request.Source -and $Source -ne $Request.Source) { return }

        if ($Source -eq '<auto-generated>' -or (Test-Path -Path $Source)) {
            $sourceInfo = $null
        }
        else {
            $bucket = $buckets | Where-Object Name -eq $Source
            $trusted = if ($bucket.Source -in $OfficialSources.Values) { $true } else { $false }
            $sourceInfo = $Request.NewSourceInfo($bucket.Name,
                                                 $bucket.Source,
                                                 $trusted,
                                                 @{ Updated = $bucket.Updated; Manifests = $bucket.Manifests })
        }

        if ($Request.IsMatch($Name, $Version)) {
            $Request.WritePackage($Name, $Version, $Description, $sourceInfo, $metadata)
        }
    }
}
