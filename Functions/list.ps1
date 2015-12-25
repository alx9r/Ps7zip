function ConvertFrom-7zListStream
{
<#
.SYNOPSIS
Converts the output of 7z l to a rich object.
#>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        # The stream object output by 7z when invoked from PowerShell.
        [parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyname=$true)]
        [object[]]
        $7zListStream,

        # ParentData builds a parent object with objects resultant from parsing of 7zListStream.
        [switch]
        $ParentData
    )
    begin
    {
        $accumulator = [System.Collections.ArrayList]@()
    }
    process
    {
        $7zListStream |
            % {
                $accumulator.Add($_) | Out-Null
            }
    }
    end
    {
        $h = @{
            AttributeSections = [System.Collections.ArrayList]@()
            Files = [System.Collections.ArrayList]@()
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
                $phase = 'find archive notice'
                continue
            }

            if
            (
                $phase -eq 'find archive notice' -and
                ($line | Test-7zArchiveNoticeLine)
            )
            {
                $h.ArchiveNotice = $line
                $phase = 'extract attributes'
                continue
            }

            if
            (
                $phase -eq 'extract attributes' -and
                $line -match '^\-+$'
            )
            {
                $h.AttributeSections.Add(
                    @{
                        Attributes = @{}
                        AttributeLines = [System.Collections.ArrayList]@()
                    }
                ) | Out-Null
                continue
            }

            if
            (
                $phase -eq 'extract attributes' -and
                ($line | Test-7zAttributeLine)
            )
            {
                $thisSection = $h.AttributeSections[-1]
                $thisSection.AttributeLines.Add($line) | Out-Null
                $keyvalue = $line | ConvertFrom-7zAttributeLine
                $thisSection.Attributes.($keyvalue.Key) = $keyvalue.Value
                continue
            }

            if
            (
                $phase -eq 'extract attributes' -and
                ($line | Test-7zFileListHeadings)
            )
            {
                $h.FileListHeading = $line
                $phase = 'extract file list'
                continue
            }

            if
            (
                $phase -eq 'extract file list' -and
                ($line | Test-7zFileListLine)
            )
            {
                $h.Files.Add(($line | ConvertFrom-7zFileListLine)) | Out-Null
                continue
            }

            if
            (
                $phase -eq 'extract file list' -and
                ($line | Test-7zFileListSummaryLine)
            )
            {
                $h.FileListSummary = $line
                $phase = 'complete'
                continue
            }
        }

        if ( $phase -ne 'complete' )
        {
            throw New-Object System.ArgumentException(
                "Error parsing 7zListStream. Ended in phase $phase",
                '7zListStream'
            )
        }

        if ( $ParentData )
        {
            return New-Object psobject -Property $h
        }

        return $h.Files
    }
}
function Test-7zVersionNoticeLine
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
        $Line -match '^7-Zip \[(64|32|86)][0-9\. ]*Copyright \(c\)[0-9,\- ]*Igor Pavlov[0-9\- ]*$'
    }
}
function Test-7zArchiveNoticeLine
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
        $Line -match '^Listing archive: .*$'
    }
}
function Test-7zFileListHeadings
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
        $Line -match '^ *Date *Time * Attr *Size *Compressed *Name$'
    }
}

$attributePattern = '^(?<key>[a-zA-Z0-9 ]*) = (?<value>.*)$'
function Test-7zAttributeLine
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
        $Line -match $attributePattern
    }
}
function ConvertFrom-7zAttributeLine
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyname=$true)]
        [string]
        $Line
    )
    process
    {
        $groups = ([regex]$attributePattern).Match($line).Groups
        @{
            Key = [string]$groups['key']
            Value = [string]$groups['value']
        }
    }
}
$fileListPattern = '^(?<Date>[0-9\-]+) +(?<Time>[0-9:]+) (?<Attr>[A-Za-z\.]{5}) +(?<Size>[0-9]+) +((?<Compressed>[0-9]*) +)?(?<Name>.*)$'
function Test-7zFileListLine
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
        $Line -match $fileListPattern
    }
}
function ConvertFrom-7zFileListLine
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyname=$true)]
        [string]
        $Line
    )
    process
    {
        $groups = ([regex]$fileListPattern).Match($line).Groups
        $h = @{}
        'Date','Time','Attr','Size','Compressed','Name' |
            % { $h.$_ = [string]$groups[$_] }
        New-Object psobject -Property $h
    }
}
function Test-7zFileListSummaryLine
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
        $Line -match '^ +[0-9]+ +[0-9]+ +[0-9]+ files, [0-9]+ folders$'
    }
}
