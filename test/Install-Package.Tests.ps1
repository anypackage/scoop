#Requires -Modules AnyPackage.Scoop

Describe Install-Package {
    AfterEach {
        Get-ScoopApp -Name 7zip |
        Uninstall-ScoopApp
    }

    Context 'with -Name parameter' {
        It 'should install' {
            { Install-Package -Name 7zip } |
            Should -Not -Throw
        }
    }

    Context 'with -Version parameter' -Skip {
        It 'should install' {
            # TODO: Fix 22.0 parse
            { Install-Package -Name 7zip -Version '22.01' -ErrorAction Stop } |
            Should -Not -Throw
        }
    }

    Context 'with -Architecture parameter' {
        It 'should install <_>' -TestCases '32bit', '64bit', 'arm64' {
            { Install-Package -Provider Scoop -Name 7zip -Architecture $_ -ErrorAction Stop } |
            Should -Not -Throw
        }
    }

    Context 'with -SkipDependencies parameter' {
        It 'should install without dependency' {
            { Install-Package -Provider Scoop -Name z.lua -SkipDependencies -ErrorAction Stop } |
            Should -Not -Throw

            Get-ScoopApp -Name lua |
            Should -BeNullOrEmpty
        }

        AfterEach {
            Get-ScoopApp -Name z.lua, lua |
            Uninstall-ScoopApp
        }
    }

    Context 'with -NoCache parameter' {
        It 'should install' {
            { Install-Package -Provider Scoop -Name 7zip -NoCache -ErrorAction Stop } |
            Should -Not -Throw
        }
    }

    Context 'with -SkipHashCheck parameter' {
        It 'should install' {
            { Install-Package -Provider Scoop -Name 7zip -SkipHashCheck -ErrorAction Stop } |
            Should -Not -Throw
        }
    }
}
