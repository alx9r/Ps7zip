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
