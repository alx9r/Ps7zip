function ConvertFrom-7zNullCommandStream
{
<#
.SYNOPSIS
Converts the output of 7z (no command) to a rich object.
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
        $7zStream
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
        $phase = 'find version notice'
        foreach ( $line in $accumulator )
        {
            if
            (
                $phase -eq 'find version notice' -and
                ($line | Test-7zVersionNoticeLine)
            )
            {
                return $line | ConvertFrom-7zVersionNoticeLine
            }
        }

        throw New-Object System.ArgumentException(
            "Error parsing 7zStream. Ended in phase $phase",
            '7zStream'
        )
    }
}
