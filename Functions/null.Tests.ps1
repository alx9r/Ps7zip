Import-Module Ps7zip -Force

Describe ConvertFrom-7zNullCommandStream {
    foreach ( $version in ('9.20','15.12') )
    {
        Context "version $version" {
            It 'converts.' {
                $stream = "$($PSCommandPath | Split-Path -Parent)\..\Resources\nullSample-$version.xml" |
                    Resolve-Path |
                    Import-Clixml

                $r = $stream | ConvertFrom-7zNullCommandStream

                $r -is [pscustomobject] | Should be $true
                $r.Platform | Should be '64'
                $r.Version | Should be $version
                $r.CopyrightDate | Should match '1999-(2010|2015)'
                $r.Date | Should match '(2010-11-18|2015-11-19)'
            }
        }
        It 'throws.' {
            $stream = 'line 1','line 2'
            {$stream | ConvertFrom-7zNullCommandStream} |
                Should throw 'Error parsing 7zStream.'
        }
    }
}
