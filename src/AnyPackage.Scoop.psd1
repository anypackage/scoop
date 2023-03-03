@{
    RootModule = 'AnyPackage.Scoop.psm1'
    ModuleVersion = '0.1.2'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID = 'bc4720f6-72ad-45df-aa7d-316cb313ad5e'
    Author = 'Thomas Nieto'
    Copyright = '(c) 2023 Thomas Nieto. All rights reserved.'
    Description = 'Scoop provider for AnyPackage.'
    PowerShellVersion = '5.1'
    RequiredModules = @(
        @{ ModuleName = 'AnyPackage'; ModuleVersion = '0.1.1' },
        @{ ModuleName = 'Scoop'; ModuleVersion = '0.1.1' })
    FunctionsToExport = @()
    CmdletsToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        AnyPackage = @{
            Providers = 'Scoop'
        }
        PSData = @{
            Tags = @('AnyPackage', 'Provider', 'Scoop', 'Windows')
            LicenseUri = 'https://github.com/AnyPackage/AnyPackage.Scoop/blob/main/LICENSE'
            ProjectUri = 'https://github.com/AnyPackage/AnyPackage.Scoop'
        }
    }
    HelpInfoURI = 'https://go.anypackage.dev/help'
}
