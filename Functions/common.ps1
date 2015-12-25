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