function ConvertFrom-7zProcessingStream
{
<#
.SYNOPSIS
Converts the output of 7z e|x to a rich object.
#>
    [CmdletBinding()]
    param
    (
        # The stream object output by 7z when invoked from PowerShell.
        [parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyname=$true)]
        [object[]]
        $7zStream,

        # ParentData builds a parent object with objects resultant from parsing of 7zStream.
        [switch]
        $ParentData
    )
    begin
    {
        $accumulator = [System.Collections.ArrayList]@()
    }
    process
    {
        $7zStream |
            % {
                $accumulator.Add($_) | Out-Null
            }
    }
    end
    {
        $h = @{
            MessageNoticeLines = [System.Collections.ArrayList]@()
            ResultLines = [System.Collections.ArrayList]@()
            Results = @{}
            Files = [System.Collections.ArrayList]@()
            Messages = @{
                Errors = [System.Collections.ArrayList]@()
                Warnings = [System.Collections.ArrayList]@()
            }
        }
        $phase = 'find version notice'
        foreach ( $line in $accumulator )
        {
            if
            (
                $phase -eq 'find version notice' -and
                ($line | Test-7zVersionNoticeLine)
            )
            {
                $h.VersionNotice = $line
                $phase = 'find command notice'
                continue
            }

            if
            (
                $phase -eq 'find command notice' -and
                ($line | Test-7zCommandNoticeLine)
            )
            {
                $h.CommandNoticeLine = $line
                $h.CommandNotice = $line | ConvertFrom-7zCommandNoticeLine
                $phase = 'extract processing line'
                continue
            }

            if
            (
                $phase -eq 'extract processing line' -and
                ($line | Test-7zMessageNoticeLine)
            )
            {
                $notice = $line | ConvertFrom-7zMessageNoticeLine
                $h.MessageNoticeLines.Add($line) | Out-Null
                $h.Messages.$(
                    @{
                        ERROR = 'Errors'
                        WARNING = 'Warnings'
                    }.$($notice.Type)
                ).Add($notice.Message) |
                    Out-Null
                continue
            }

            if
            (
                $phase -eq 'extract processing line' -and
                ($line | Test-7zProcessingLine)
            )
            {
                $h.Files.Add(($line | ConvertFrom-7zProcessingLine)) | Out-Null
                continue
            }

            if
            (
                $phase -eq 'extract processing line' -and
                ($line | Test-7zProcessingSuccessSummaryLine)
            )
            {
                $h.SummaryLine = $line
                $h.Summary = 'Success'
                $phase = 'extract result lines'
            }

            if
            (
                $phase -eq 'extract processing line' -and
                ($line | Test-7zProcessingFailSummaryLine)
            )
            {
                $h.SummaryLine = $line
                $h.Summary = 'Failure'
                $phase = 'failed'
                continue
            }

            if
            (
                $phase -eq 'extract result lines' -and
                ($line | Test-7zProcessingResultLine)
            )
            {
                $result = $line | ConvertFrom-7zProcessingResultLine
                $h.ResultLines.Add($result) | Out-Null
                $h.Results.$($result.Key) = $result.Value
                continue
            }
        }

        if ( $phase -notin 'failed','extract result lines' )
        {
            throw New-Object System.ArgumentException(
                "Error parsing 7zStream. Ended in phase $phase",
                '7zStream'
            )
        }

        if ( $ParentData )
        {
            return New-Object psobject -Property $h
        }

        if ( $h.Messages.Errors )
        {
            throw New-Object System.ArgumentException(
                $h.Messages.Errors[0],
                '7zStream'
            )
        }

        return $h.Files
    }
}

$processingLinePattern = '^(?<Action>Extracting|Skipping) +(?<Name>.*)$'
function Test-7zProcessingLine
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyname=$true)]
        [AllowEmptyString()]
        [string]
        $Line
    )
    process
    {
        $Line -match $processingLinePattern
    }
}
function ConvertFrom-7zProcessingLine
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyname=$true)]
        [AllowEmptyString()]
        [string]
        $Line
    )
    process
    {
        $groups = ([regex]$processingLinePattern).Match($Line).Groups
        $h = @{}
        'Action','Name' |
            % { $h.$_ = [string]$groups[$_] }
        New-Object psobject -Property $h
    }
}
function Test-7zProcessingSuccessSummaryLine
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyname=$true)]
        [AllowEmptyString()]
        [string]
        $Line
    )
    process
    {
        $Line -match '^Everything is Ok$'
    }
}
function Test-7zProcessingFailSummaryLine
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyname=$true)]
        [AllowEmptyString()]
        [string]
        $Line
    )
    process
    {
        $Line -match '^.*Errors:.*$'
    }
}
$processingResultLinePattern = '^(?<Key>.*): +(?<Value>.*)$'
function Test-7zProcessingResultLine
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyname=$true)]
        [AllowEmptyString()]
        [string]
        $Line
    )
    process
    {
        $Line -match $processingResultLinePattern
    }
}
function ConvertFrom-7zProcessingResultLine
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyname=$true)]
        [AllowEmptyString()]
        [string]
        $Line
    )
    process
    {
        $groups = ([regex]$processingResultLinePattern).Match($Line).Groups
        $h = @{}
        'Key','Value' |
            % { $h.$_ = [string]$groups[$_] }
        New-Object psobject -Property $h
    }
}
function Get-7zExtractArgs
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyname=$true)]
        [string]
        $ArchivePath,

        [parameter(Position = 2,
                   ValueFromPipelineByPropertyname=$true)]
        [string[]]
        $Files,

        [parameter(Position = 3,
                   ValueFromPipelineByPropertyname=$true)]
        [string[]]
        $OutputFolder
    )
    process
    {
        "x $ArchivePath$(
                if ( $OutputFolder )
                {
                    " -o$OutputFolder"
                }
            )$(
                if ( $Files )
                {
                    ' -i!'
                }
            )$(
                $Files -join ' -i!'
            )"
    }
}
