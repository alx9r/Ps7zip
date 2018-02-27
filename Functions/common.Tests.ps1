Import-Module Ps7zip -Force

$versionLineValues = @(
    @('9.20','7-Zip [64] 9.20  Copyright (c) 1999-2010 Igor Pavlov  2010-11-18'),
    @('15.12','7-Zip [64] 15.12 : Copyright (c) 1999-2015 Igor Pavlov : 2015-11-19'),
    @('18.01','7-Zip 18.01 (x64) : Copyright (c) 1999-2018 Igor Pavlov : 2018-01-28')
)

Describe Test-7zVersionNoticeLine {
    It 'false.' {
        $r = 'Not valid.' | Test-7zVersionNoticeLine
        $r | Should be $false
    }
    foreach ( $values in $versionLineValues )
    {
        $version,$line = $values
        Context $version {
            It 'true.' {
                $r = $line |
                    Test-7zVersionNoticeLine
                $r | Should be $true
            }
        }
    }
}
Describe ConvertFrom-7zVersionNoticeLine {
    foreach ( $values in $versionLineValues )
    {
        $version,$line = $values
        Context $version {
            It 'correctly extracts fields.' {
                $r = $line |
                    ConvertFrom-7zVersionNoticeLine

                $r -is [pscustomobject] | Should be $true

                $r.Platform | Should match '64|x64'
                $r.Version | Should be $version
                $r.CopyrightDate | Should match '1999-201[058]'
                $r.Date | Should match '(2010-11-18|2015-11-19|2018-01-28)'
            }
        }
    }
}

Describe Test-7zCommandNoticeLine {
    It 'false.' {
        $r = 'Not valid.' | Test-7zCommandNoticeLine
        $r | Should be $false
    }
    It 'true.' {
        $r = 'Listing archive: setup.exe' |
            Test-7zCommandNoticeLine
        $r | Should be $true
    }
}
Describe ConvertFrom-7zCommandNoticeLine {
    foreach ( $values in @(
            @('Extracting archive: .\vcredist_x64.exe',
              'Extracting',
              '.\vcredist_x64.exe'),
            @('Listing archive: setup.exe',
              'Listing',
              'setup.exe'),
            @('Processing archive: .\vcredist_x64.exe',
              'Processing',
              '.\vcredist_x64.exe')
        )
    )
    {
        $line,$command,$archiveName = $values
        Context $command {
            It 'correctly extracts fields.' {
                $r = $line |
                    ConvertFrom-7zCommandNoticeLine

                $r -is [pscustomobject] | Should be $true

                $r.Command | Should be $command
                $r.ArchiveName | Should be $archiveName
            }
        }
    }
}
Describe Test-7zMessageNoticeLine {
    It 'false.' {
        $r = 'Not valid.' | Test-7zMessageNoticeLine
        $r | Should be $false
    }
    It 'true.' {
        $r = 'ERROR: Can not delete output file eula.1028.txt' |
            Test-7zMessageNoticeLine
        $r | Should be $true
    }
}
Describe ConvertFrom-7zMessageNoticeLine {
    It 'correctly extracts fields.' {
        $r = 'ERROR: Can not delete output file eula.1028.txt' |
            ConvertFrom-7zMessageNoticeLine

        $r -is [pscustomobject] | Should be $true

        $r.Type | Should be 'ERROR'
        $r.Message | Should be 'Can not delete output file eula.1028.txt'
    }
}
