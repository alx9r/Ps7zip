$versionNoticePattern = '((?<Version>[0-9][0-9]?\.[0-9]{2}?)|((\[|\()(?<Platform>x?[0-9]{2})(\]|\)))|(Copyright \(c\) (?<CopyRightDate>[0-9,\-]*))|(Igor Pavlov :? (?<Date>[0-9\-]*)))'
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
        $Line -match $versionNoticePattern
    }
}
function ConvertFrom-7zVersionNoticeLine
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
        $output = @{}
        ([regex]$versionNoticePattern).Matches($Line) |
            % Groups |
            ? {$_.Name -in 'Version','Platform','CopyRightDate','Date'} |
            ? {$_.Value} |
            % { $output[$_.Name] = $_.Value }
        [pscustomobject]$output
    }
}
$commandNoticePattern = '^(?<Command>Extracting|Listing|Processing) archive: (?<ArchiveName>.*)$'
function Test-7zCommandNoticeLine
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
        $Line -match $commandNoticePattern
    }
}
function ConvertFrom-7zCommandNoticeLine
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
        $groups = ([regex]$commandNoticePattern).Match($Line).Groups
        $h = @{}
        'Command','ArchiveName' |
            % { $h.$_ = [string]$groups[$_] }
        New-Object psobject -Property $h
    }
}
$messageNoticePattern = '^(?<Type>ERROR|WARNING): *(?<Message>.*)$'
function Test-7zMessageNoticeLine
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
        $Line -match $messageNoticePattern
    }
}
function ConvertFrom-7zMessageNoticeLine
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
        $groups = ([regex]$messageNoticePattern).Match($Line).Groups
        $h = @{}
        'Type','Message' |
            % { $h.$_ = [string]$groups[$_] }
        New-Object psobject -Property $h
    }
}
function Get-7zSupportedArchives
{
    [CmdletBinding()]
    param()
    process
    {
        '7z','XZ','ZIP','GZIP','BZIP2','TAR','WIM','LZMA',
        'RAR','CAB','ARJ','Z','CPIO','RPM','DEB','LZH',
        'SPLIT','CHM','ISO','UDF','COMPOUND','DMG','XAR',
        'HFS','NSIS','NTFS','FAT','VHD','MBR','SquashFS','CramFS'
    }
}
