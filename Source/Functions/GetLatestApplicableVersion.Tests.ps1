$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. $here\$sut

Describe 'GetLatestApplicableVersion, given a folder with version of all types' {
    function setupDirs {
        Setup -Dir settings/app
        Setup -Dir settings/app/10000
        Setup -Dir settings/app/9999
        Setup -Dir settings/app/8888
        Setup -Dir settings/app/7777
        Setup -Dir settings/app/6666.100
        Setup -Dir settings/app/6666.99
        Setup -Dir settings/app/6666.98
        Setup -Dir settings/app/6666.97.100
        Setup -Dir settings/app/6666.97.99
        Setup -Dir settings/app/6666.97.98
        Setup -Dir settings/app/6666.97.98-alpha
        Setup -Dir settings/app/6666.97.98-beta
        Setup -Dir settings/app/6666.97.98-rc
        Setup -Dir settings/app/6666.97
        Setup -Dir settings/app/6665
    }

    Context 'when a version with an exact match is requested' {
        $examples = "10000,6666.100,6666.97,6666.97.100" #,6666.97.98-alpha"

        $examples -split ',' | % {
            $example = $_
            Context "using example $example"{
                setupDirs
                $version = GetLatestApplicableVersion TestDrive:\settings\app $example

                It 'returns the version number' {
                    $version | should be $example
                }
            }
        }
    }

    Context 'when a version with a previous version match is requested' {
        $examples = @(
            "10001,10000",
            "9998,8888",
            "7777.1,7777",
            "7776,6666.100",
            "6666.101,6666.100",
            "6666.97.101,6666.97.100",
            "6666.97.97,6666.97",
            "6666.96,6665"
        )

        $examples | % {
            $parts = $_ -split ','
            $example = $parts[0]
            $expected = $parts[1]
            Context "using example $example"{
                setupDirs
                $version = GetLatestApplicableVersion TestDrive:\settings\app $example

                It 'falls back the highest previous version number' {
                    $version | should be $expected
                }
            }
        }
    }
}
