#Requires -Modules AnyPackage.Scoop

Describe Find-Package {
    Context 'with -Prerelease parameter' {
        It 'should have correct count' {
            $count = & scoop bucket list |
            Measure-Object -Property Manifests -Sum |
            Select-Object -ExpandProperty Sum

            Find-Package -Prerelease -WarningAction SilentlyContinue |
            Should -HaveCount $count
        }
    }

    Context 'with -Name parameter' {
        It 'single name' {
            Find-Package -Name 7zip |
            Should -Not -BeNullOrEmpty
        }

        It 'multiple names' {
            Find-Package -Name 7zip, abc |
            Should -HaveCount 2
        }
    }

    Context 'with -Version parameter' {
        It 'should return value' {
            $package = Find-Package -Name 7zip
            Find-Package -Name 7zip -Version $package.Version.ToString() |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Source parameter' {
        BeforeAll {
            Register-ScoopBucket -Official nirsoft
        }

        AfterAll {
            Unregister-ScoopBucket -Name nirsoft
        }

        It 'should return nirsoft packages' {
            Find-Package -Source nirsoft |
            Select-Object -ExpandProperty Source -Unique |
            Should -Be nirsoft
        }
    }
}