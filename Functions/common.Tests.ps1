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
Describe Test-7zArchiveNoticeLine {
    It 'false.' {
        $r = 'Not valid.' | Test-7zArchiveNoticeLine
        $r | Should be $false
    }
    It 'true.' {
        $r = 'Listing archive: setup.exe' |
            Test-7zArchiveNoticeLine
        $r | Should be $true
    }
}