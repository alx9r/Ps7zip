function Get-7zExitCodeMeaning
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyname=$true)]
        [int32]
        $ExitCode
    )
    process
    {
        $meanings = @{
            0 = 'No error'
            1 = 'Warning (Non fatal error(s)). For example, one or more files were locked by some other application, so they were not compressed.'
            2 = 'Fatal error'
            7 = 'Command line error'
            8 = 'Not enough memory for operation'
            255 = 'User stopped the process'
        }

        if ( $ExitCode -in $meanings.Keys )
        {
            return $meanings.$ExitCode
        }

        'Unknown exit code.'
    }
}