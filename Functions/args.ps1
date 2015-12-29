function Assert-Valid7zExtractArgsParams
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory                      =$true,
                   Position                       =1,
                   ValueFromPipelineByPropertyname=$true)]
        [char]
        [ValidateSet('e','x')]
        $Mode,

        [parameter(Position                       =2,
                   ValueFromPipelineByPropertyname=$true)]
        [string]
        $ArchivePath,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('ai!')]
        $IncludeArchiveFiles,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('ai@')]
        $IncludeArchiveListFiles,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [switch]
        [Alias('ao')]
        $OverwriteMode,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('ax')]
        $ExcludeArchiveFiles,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('i!')]
        $IncludeFiles,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('i@')]
        $IncludeListFiles,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('o')]
        $OutputFolder,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string]
        [Alias('p')]
        $Password,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string]
        [ValidateSet('','-','0')]
        [Alias('r')]
        $RecurseSubdirectories,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('so')]
        $WriteDataToStdout,

        [parameter(ValueFromPipelineByPropertyName=$true)]
        [string]
        [Alias('t')]
        $TypeOfArchive,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('x!')]
        $ExcludeFiles,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('x@')]
        $ExcludeListFiles
    )
    process
    {
        if
        (
            -not ($ArchivePath,
                  $IncludeArchiveFiles,
                  $IncludeArchiveListFiles |
                      ? {$_})
        )
        {
            throw New-Object System.ArgumentException(
                'You must specify ArchivePath, IncludeArchiveFiles, or IncludeArchiveListFiles',
                'ArchivePath'
            )
        }
        foreach ( $type in ($TypeOfArchive.Split('.') | ? {$_}) )
        {
            if ( $type -notin (Get-7zSupportedArchives) )
            {
                throw New-Object System.ArgumentException(
                    "TypeOfArchive $type in not valid.",
                    'TypeOfArchive'
                )
            }
        }
    }
}
function Get-7zExtractArgs
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory                      =$true,
                   Position                       =1,
                   ValueFromPipelineByPropertyname=$true)]
        [char]
        [ValidateSet('e','x')]
        $Mode,

        [parameter(Position                       =2,
                   ValueFromPipelineByPropertyname=$true)]
        [string]
        $ArchivePath,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('ai!')]
        $IncludeArchiveFiles,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('ai@')]
        $IncludeArchiveListFiles,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [switch]
        [Alias('ao')]
        $OverwriteMode,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('ax')]
        $ExcludeArchiveFiles,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('i!')]
        $IncludeFiles,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('i@')]
        $IncludeListFiles,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('o')]
        $OutputFolder,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string]
        [Alias('p')]
        $Password,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string]
        [ValidateSet('','-','0')]
        [Alias('r')]
        $RecurseSubdirectories,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('so')]
        $WriteDataToStdout,

        [parameter(ValueFromPipelineByPropertyName=$true)]
        [string]
        [Alias('t')]
        $TypeOfArchive,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('x!')]
        $ExcludeFiles,

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [string[]]
        [Alias('x@')]
        $ExcludeListFiles
    )
    process
    {
        Assert-Valid7zExtractArgsParams @PSBoundParameters

        $switches = (Get-Command Get-7zExtractArgs).Parameters.Values |
            ? {
                $_.SwitchParameter -and
                $_.Name -notin [System.Management.Automation.PSCmdlet]::CommonParameters
            } |
            ? { Get-Variable $_.Name -ValueOnly } |
            % { $_.Aliases[0] }

        $psParameters = (Get-Command Get-7zExtractArgs).Parameters.Values |
            ? {$_.Name -notin [System.Management.Automation.PSCmdlet]::CommonParameters}

        $switches = $psParameters |
            ? {
                $_.SwitchParameter -and
                (Get-Variable $_.Name -ValueOnly)
            } |
            % {"-$($_.Aliases[0])"}
        $valueParams = foreach
        (
            $parameter in
            (
                $psParameters |
                    ? {
                        -not $_.SwitchParameter -and
                        $_.Aliases[0] -and
                        (Get-Variable $_.Name -ValueOnly)
                    }
            )
        )
        {
            Get-Variable $parameter.Name -ValueOnly |
                % {$_} |
                % { "-$($parameter.Aliases[0])$_" }
        }


        $7zParameters = [System.Collections.ArrayList]@()
        $7zParameters += $Mode
        if ( $ArchivePath )
        {
            $7zParameters += $ArchivePath
        }
        else
        {
            $7zParameters += '-an'
        }
        $7zParameters += $switches
        $7zParameters += $valueParams

        ($7zParameters | ? {$_}) -join ' '
    }
}
