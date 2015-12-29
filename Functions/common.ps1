$versionNoticePattern = '^7-Zip \[(?<Platform>64|32|86)] (?<Version>[0-9a-zA-Z\.]*) *Copyright \(c\) +(?<CopyrightDate>[0-9,\-]*) +Igor Pavlov +(?<Date>[0-9\-]*).*$'
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
        $groups = ([regex]$versionNoticePattern).Match($Line).Groups
        $h = @{}
        'Platform','Version','CopyrightDate','Date' |
            % { $h.$_ = [string]$groups[$_] }
        New-Object psobject -Property $h
    }
}
$commandNoticePattern = '^(?<Command>Listing|Processing) archive: (?<ArchiveName>.*)$'
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
