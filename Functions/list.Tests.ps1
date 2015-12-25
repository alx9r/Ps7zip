Import-Module Ps7zip -Force

Describe ConvertFrom-7zListStream {
    It 'converts.' {
        $stream = "$($PSCommandPath | Split-Path -Parent)\..\Resources\listSample.xml" |
            Resolve-Path |
            Import-Clixml

        $r = $stream | ConvertFrom-7zListStream -ParentData

        $r -is [pscustomobject] | Should be $true

        $r.VersionNotice | Should be '7-Zip [64] 9.20  Copyright (c) 1999-2010 Igor Pavlov  2010-11-18'
        $r.CommandNoticeLine | Should be 'Listing archive: .\vcredist_x64.exe'
        $r.CommandNotice.Command | Should be 'Listing'
        $r.CommandNotice.ArchiveName | Should be '.\vcredist_x64.exe'

        $r.AttributeSections.Count | Should be 3
        $r.AttributeSections[0].Attributes.Count | Should be 25
        $r.AttributeSections[0].AttributeLines.Count | Should be 25
        $r.AttributeSections[1].Attributes.Count | Should be 4
        $r.AttributeSections[1].AttributeLines.Count | Should be 4
        $r.AttributeSections[2].Attributes.Count | Should be 5
        $r.AttributeSections[2].AttributeLines.Count | Should be 5
        $r.AttributeSections[0].Attributes.CPU | Should be 'x86'
        $r.AttributeSections[0].Attributes.Type | Should be 'PE'

        $r.Files[0].Name | Should be 'vc_red.cab'
        $r.Files[0].Size | Should be '1927956'
        $r.Files.Count | Should be '40'
    }
    It 'throws.' {
        $stream = 'line 1','line 2'
        {$stream | ConvertFrom-7zListStream} |
            Should throw 'Error parsing 7zStream.'
    }
    It 'outputs list of file attribute objects.' {
        $stream = "$($PSCommandPath | Split-Path -Parent)\..\Resources\listSample.xml" |
            Resolve-Path |
            Import-Clixml

        $r = $stream | ConvertFrom-7zListStream

        $r -is [array] | Should be $true
        $r.Count | Should be 40
        $r[0] -is [pscustomobject] | Should be $true
    }
}
Describe Test-7zFileListHeadings {
    It 'false.' {
        $r = 'Not valid.' | Test-7zFileListHeadings
        $r | Should be $false
    }
    It 'true.' {
        $r = '   Date      Time    Attr         Size   Compressed  Name' |
            Test-7zFileListHeadings
        $r | Should be $true
    }
    It 'does not match empty string.' {
        $r = [string]::Empty | Test-7zFileListHeadings
        $r | Should be $false
    }
}
Describe Test-7zAttributeLine {
    It 'false.' {
        $r = 'Not valid.' | Test-7zAttributeLine
        $r | Should be $false
    }
    It 'true.' {
        $r = 'Characteristics = Executable 32-bit NoRelocs NoLineNums NoLocalSyms' |
            Test-7zAttributeLine
        $r | Should be $true
    }
}
Describe ConvertFrom-7zAttributeLine {
    It 'correctly extracts key and value.' {
        $r = 'Characteristics = Executable 32-bit NoRelocs NoLineNums NoLocalSyms' |
            ConvertFrom-7zAttributeLine

        $r.Key | Should be 'Characteristics'
        $r.Value | Should be 'Executable 32-bit NoRelocs NoLineNums NoLocalSyms'
    }
}
Describe Test-7zFileListLine {
    It 'false.' {
        $r = 'Not valid.' | Test-7zFileListLine
        $r | Should be $false
    }
    It 'true.' {
        $r = '2014-05-29 15:19:35 ....A      4249928      1516467  setup.exe' |
            Test-7zFileListLine
        $r | Should be $true
    }
}
Describe ConvertFrom-7zFileListLine {
    It 'correctly extracts fields.' {
        $r = '2014-05-29 15:19:35 ....A      4249928      1516467  setup.exe' |
            ConvertFrom-7zFileListLine

        $r -is [pscustomobject] | Should be $true

        $r.Date | Should be '2014-05-29'
        $r.Time | Should be '15:19:35'
        $r.Attr | Should be '....A'
        $r.Size | Should be '4249928'
        $r.Compressed | Should be '1516467'
        $r.Name | Should be 'setup.exe'
    }
    It 'correctly handles missing "Compressed" field.' {
        $r = '2007-11-07 08:44:20 ....A       855040               .\install.exe' |
            ConvertFrom-7zFileListLine

        $r.Date | Should be '2007-11-07'
        $r.Time | Should be '08:44:20'
        $r.Attr | Should be '....A'
        $r.Size | Should be '855040'
        $r.Compressed | Should beNullOrEmpty
        $r.Name | Should be '.\install.exe'
    }
}
Describe Test-7zFileListSummaryLine {
    It 'false.' {
        $r = 'Not valid.' | Test-7zFileListSummaryLine
        $r | Should be $false
    }
    It 'true.' {
        $r = '                              50782596     41805376  36 files, 1 folders' |
            Test-7zFileListSummaryLine
        $r | Should be $true
    }
}
