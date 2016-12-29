Import-Module Ps7zip -Force

Describe 'ConvertFrom-7zProcessingStream error' {
    Context '9.20' {
        It 'converts with error.' {
            $stream = "$($PSCommandPath | Split-Path -Parent)\..\Resources\extractErrorSample-9.20.xml" |
                Resolve-Path |
                Import-Clixml

            $r = $stream | ConvertFrom-7zProcessingStream -ParentData

            $r -is [pscustomobject] | Should be $true

            $r.VersionNotice | Should be '7-Zip [64] 9.20  Copyright (c) 1999-2010 Igor Pavlov  2010-11-18'
            $r.CommandNoticeLine | Should be 'Processing archive: .\vcredist_x64.exe'
            $r.CommandNotice.Command | Should be 'Processing'
            $r.CommandNotice.ArchiveName | Should be '.\vcredist_x64.exe'

            $r.Summary | Should be 'Failure'
            $r.Results | Should beNullOrEmpty
            $r.Messages.Errors.Count | Should be 1
            $r.Messages.Errors[0] | Should be 'Can not delete output file eula.1028.txt'
        }
        It 'throws on error.' {
            $stream = "$($PSCommandPath | Split-Path -Parent)\..\Resources\extractErrorSample-9.20.xml" |
                Resolve-Path |
                Import-Clixml

            { $stream | ConvertFrom-7zProcessingStream } |
                Should throw 'Can not delete output file eula.1028.txt'
        }
    }
    Context '15.12' {
        It 'converts with error.' {
            $stream = "$($PSCommandPath | Split-Path -Parent)\..\Resources\extractErrorSample-15.12.xml" |
                Resolve-Path |
                Import-Clixml

            $r = $stream | ConvertFrom-7zProcessingStream -ParentData

            $r -is [pscustomobject] | Should be $true

            $r.VersionNotice | Should be '7-Zip [64] 15.12 : Copyright (c) 1999-2015 Igor Pavlov : 2015-11-19'
            $r.CommandNoticeLine | Should be 'Extracting archive: .\vcredist_x64.exe'
            $r.CommandNotice.Command | Should be 'Extracting'
            $r.CommandNotice.ArchiveName | Should be '.\vcredist_x64.exe'

            $r.Summary | Should be 'Failure'
            $r.Results | Should beNullOrEmpty
            $r.Messages.Errors | Should beNullOrEmpty
        }
        It 'throws on error.' {
            $stream = "$($PSCommandPath | Split-Path -Parent)\..\Resources\extractErrorSample-9.20.xml" |
                Resolve-Path |
                Import-Clixml

            { $stream | ConvertFrom-7zProcessingStream } |
                Should throw 'Can not delete output file eula.1028.txt'
        }
    }
    It 'throws on bad file.' {
        $stream = 'line 1','line 2'
        {$stream | ConvertFrom-7zProcessingStream} |
            Should throw 'Error parsing 7zStream.'
    }
}
Describe 'ConvertFrom-7zProcessingStream' {
    foreach ( $version in '9.20','15.12' )
    {
        Context $version {
            It 'converts without error.' {
                $stream = "$($PSCommandPath | Split-Path -Parent)\..\Resources\extractSample-$version.xml" |
                    Resolve-Path |
                    Import-Clixml

                $r = $stream | ConvertFrom-7zProcessingStream -ParentData

                $r.Summary | Should be 'Success'
                $r.Results.Files | Should be '40'
                $r.Results.Size | Should be '4104207'
                $r.Messages.Errors.Count | Should be 0
            }
            if ( $version -eq '9.20' )
            {
                It 'outputs list of file attribute objects.' {
                    $stream = "$($PSCommandPath | Split-Path -Parent)\..\Resources\extractSample-$version.xml" |
                        Resolve-Path |
                        Import-Clixml

                    $r = $stream | ConvertFrom-7zProcessingStream

                    $r -is [array] | Should be $true
                    $r.Count | Should be 40
                    $r[0] -is [pscustomobject] | Should be $true
                }
            }
        }
    }
}
Describe Test-7zProcessingLine {
    It 'false.' {
        $r = 'Not valid.' | Test-7zFileListSummaryLine
        $r | Should be $false
    }
    It 'true.' {
        $r = 'Extracting  vc_red.msi' |
            Test-7zProcessingLine
        $r | Should be $true
    }
    It 'accepts skipped files.' {
        $r = 'Skipping    .\eula.1028.txt' |
            Test-7zProcessingLine
        $r | Should be $true
    }
}
Describe ConvertFrom-7zProcessingLine {
    It 'correctly extracts fields.' {
        $r = 'Extracting  vc_red.msi' |
            ConvertFrom-7zProcessingLine

        $r -is [pscustomobject] | Should be $true

        $r.Action | Should be 'Extracting'
        $r.Name | Should be 'vc_red.msi'
    }
    It 'handles skipping.' {
        $r = 'Skipping    .\eula.1028.txt' |
            ConvertFrom-7zProcessingLine

        $r -is [pscustomobject] | Should be $true

        $r.Action | Should be 'Skipping'
        $r.Name | Should be '.\eula.1028.txt'
    }
}
Describe ConvertFrom-7zProcessingResultLine {
    It 'correctly extracts key and value.' {
        $r = 'Size:       4104207' |
            ConvertFrom-7zProcessingResultLine

        $r.Key | Should be 'Size'
        $r.Value | Should be '4104207'
    }
}
