#Requires -Modules AnyPackage.Scoop

Describe Get-PackageProvider {
    It 'should be type ScoopProviderInfo' {
        (Get-PackageProvider -Name Scoop).GetType() |
        Select-Object -ExpandProperty Name |
        Should -Be ScoopProviderInfo
    }

    It 'should have OfficialSources' {
        Get-PackageProvider -Name Scoop |
        Select-Object -ExpandProperty OfficialSources |
        Should -Not -BeNullOrEmpty
    }
}
