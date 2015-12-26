function Find-7zCommandPath
{
    [CmdletBinding()]
    param()
    process
    {
        $candidates = @(
            '7z.exe'
            "$Env:ProgramFiles",
            "${Env:ProgramFiles(x86)}",
            "$Env:APPDATA",
            "$Env:LOCALAPPDATA" |
                Join-Path -ChildPath '7-Zip' |
                Join-Path -ChildPath '7z.exe'
        )

        foreach ( $candidate in $candidates )
        {
            try
            {
                return Get-Command $candidate -ErrorAction Stop
            }
            catch {}
        }

        throw New-Object System.Management.Automation.CommandNotFoundException(
            '7z.exe was not found in any of the usual places.'
        )
    }
}
function Test-7zExe
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyname=$true)]
        [string]
        [Alias('Path')]
        $ExePath
    )
    process
    {
        Get-Command $ExePath -ErrorAction Stop | Out-Null

        try
        {
            $result = Invoke-Command {& $ExePath}
        }
        catch
        {
            Write-Verbose "Invoke-Command $ExePath failed with exception: $($_.Exception)"
            return $false
        }

        try
        {
            $result | ConvertFrom-7zNullCommandStream | Out-Null
        }
        catch
        {
            Write-Verbose "ConvertFrom-7zNullCommandStream failed with exception: $($_.Exception)"
            return $false
        }

        return $true
    }
}
