#Requires -Modules AnyPackage.Scoop

Describe Uninstall-Package {
    BeforeEach {
        Install-ScoopApp -Name 7zip
    }

    Context 'with -Name parameter' {
        It 'should uninstall' {
            { Uninstall-Package -Name 7zip } |
            Should -Not -Throw
        }
    }

    Context 'with -Version parameter' -Skip {
        It 'should install' {
            # TODO: Fix 22.0 parse
            { Uninstall-Package -Name 7zip -Version '22.01' -ErrorAction Stop } |
            Should -Not -Throw
        }

        It 'should install' {
            # TODO: Fix 22.0 parse
            { Uninstall-Package -Name 7zip -Version '22.00' -ErrorAction Stop } |
            Should -Throw
        }
    }

    Context 'with -RemoveData parameter' {
        It 'should uninstall' {
            { Uninstall-Package -Provider Scoop -Name 7zip -RemoveData -ErrorAction Stop } |
            Should -Not -Throw
        }
    }
}
