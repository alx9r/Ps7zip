Import-Module Ps7zip -Force

Describe ConvertFrom-7zListStream {
    It 'converts.' {
        $stream = "$($PSCommandPath | Split-Path -Parent)\..\Resources\nullSample.xml" |
            Resolve-Path |
            Import-Clixml

        $r = $stream | ConvertFrom-7zNullCommandStream

        $r -is [pscustomobject] | Should be $true
        $r.Platform | Should be '64'
        $r.Version | Should be '9.20'
        $r.CopyrightDate | Should be '1999-2010'
        $r.Date | Should be '2010-11-18'
    }
    It 'throws.' {
        $stream = 'line 1','line 2'
        {$stream | ConvertFrom-7zNullCommandStream} |
            Should throw 'Error parsing 7zStream.'
    }
}
