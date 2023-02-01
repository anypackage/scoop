#Requires -Modules AnyPackage.Scoop

Describe Get-Package {
    BeforeAll {
        Install-ScoopApp -Name 7zip, abc
    }

    AfterAll {
        Uninstall-ScoopApp -Name 7zip, abc
    }

    Context 'with no parameters' {
        It 'should return results' {
            Get-Package |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Name parameter' {
        It 'should return 7zip' {
            Get-Package -Name 7zip |
            Should -Not -BeNullOrEmpty
        }
    }
}
