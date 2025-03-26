#Requires -Modules AnyPackage.Scoop

Describe Optimize-Package {
    BeforeAll {
        Install-ScoopApp -Name 7zip, abc
    }

    AfterAll {
        Uninstall-ScoopApp -Name 7zip, abc
    }

    Context 'with no parameters' {
        It 'should not throw' {
            { Optimize-Package -ErrorAction Stop } |
            Should -Not -Throw
        }
    }

    Context 'with -Name parameter' {
        It 'with 7zip should not throw' {
            { Optimize-Package -Name 7zip -ErrorAction Stop } |
            Should -Not -Throw
        }

        It 'with broke should throw' {
            { Optimize-Package -Name broke -ErrorAction Stop } |
            Should -Throw
        }
    }
}
