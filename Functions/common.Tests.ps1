Import-Module Ps7zip -Force

Describe Test-7zVersionNoticeLine {
    It 'false.' {
        $r = 'Not valid.' | Test-7zVersionNoticeLine
        $r | Should be $false
    }
    It 'true.' {
        $r = '7-Zip [64] 9.20  Copyright (c) 1999-2010 Igor Pavlov  2010-11-18' |
            Test-7zVersionNoticeLine
        $r | Should be $true
    }
}
Describe ConvertFrom-7zVersionNoticeLine {
    It 'correctly extracts fields.' {
        $r = '7-Zip [64] 9.20  Copyright (c) 1999-2010 Igor Pavlov  2010-11-18' |
            ConvertFrom-7zVersionNoticeLine

        $r -is [pscustomobject] | Should be $true

        $r.Platform | Should be '64'
        $r.Version | Should be '9.20'
        $r.CopyrightDate | Should be '1999-2010'
        $r.Date | Should be '2010-11-18'
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
    It 'correctly extracts fields.' {
        $r = 'Listing archive: setup.exe' |
            ConvertFrom-7zCommandNoticeLine

        $r -is [pscustomobject] | Should be $true

        $r.Command | Should be 'Listing'
        $r.ArchiveName | Should be 'setup.exe'
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
