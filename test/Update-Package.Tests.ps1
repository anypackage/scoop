#Requires -Modules AnyPackage.Scoop

Describe Update-Package {
    BeforeEach {
        Install-ScoopApp -Name 7zip -Version '22.00'
    }

    AfterEach {
        Uninstall-ScoopApp -Name 7zip -ErrorAction Ignore
    }

    Context 'with no paramters' {
        It 'should update' {
            { Update-Package -ErrorAction Stop } |
            Should -Not -Throw
        }
    }

    Context 'with -Name parameter' {
        It 'should update' {
            { Update-Package -Name 7zip -ErrorAction Stop } |
            Should -Not -Throw
        }
    }

    Context 'with -SkipDependencies parameter' {
        It 'should update wihout dependency' {
            { Update-Package -Provider Scoop -SkipDependencies -ErrorAction Stop } |
            Should -Not -Throw
        }
    }

    Context 'with -NoCache parameter' {
        It 'should update' {
            { Update-Package -Provider Scoop -NoCache -ErrorAction Stop } |
            Should -Not -Throw
        }
    }

    Context 'with -SkipHashCheck parameter' {
        It 'should update' {
            { Update-Package -Provider Scoop -SkipHashCheck -ErrorAction Stop } |
            Should -Not -Throw
        }
    }

    Context 'with -Reinstall parameter' {
        It 'should update' {
            { Update-Package -Provider Scoop -Reinstall -ErrorAction Stop } |
            Should -Not -Throw
        }
    }
}
