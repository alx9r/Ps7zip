$commandCharLookup = @{
    a = 'a'
    Add = 'a'
    b = 'b'
    Benchmark = 'b'
    e = 'e'
    Extract = 'e'
    l = 'l'
    List = 'l'
    t = 't'
    Test = 't'
    u = 'u'
    Update = 'u'
    x = 'x'
    'eXtract with full paths' = 'x'
}
$commandSwitchLookup = @{
    'x' = 'ai','an','ao','ax','i','o','p','r','so','t','x','y'
    'e' = 'ai','an','ao','ax','i','o','p','r','so','t','x','y'
    'l' = 'ai','an','ax','i','slt','p','r','t','x'
}
function Assert-Valid7zArgsParams
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory                      =$true,
                   Position                       =1,
                   ValueFromPipelineByPropertyname=$true)]
        [string]
        [ValidateSet('e','Extract',
                     'x','eXtract with full paths',
                     'l','List')]
        $Command,

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

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [switch]
        [Alias('slt')]
        $ShowTechnicalInfo,

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

        $paramAliases = (Get-Command Get-7zArgs).Parameters.Values |
            ? {
                $_.Name -notin [System.Management.Automation.PSCmdlet]::CommonParameters -and
                $_.Name -notin 'Command','ArchivePath' -and
                (Get-Variable $_.Name -ValueOnly)
            } |
            % { $_.Aliases[0] }

        foreach ( $paramAlias in $paramAliases )
        {
            if
            (
                ($paramAlias -replace '[^a-z]*') -notin
                $commandSwitchLookup.$($commandCharLookup.$Command)
            )
            {
                throw New-Object System.ArgumentException(
                    "Parameter $paramAlias is not valid for $Command command.",
                    $paramAlias
                )
            }
        }
    }
}
function Get-7zArgs
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory                      =$true,
                   Position                       =1,
                   ValueFromPipelineByPropertyname=$true)]
        [string]
        [ValidateSet('e','Extract',
                     'x','eXtract with full paths',
                     'l','List')]
        $Command,

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

        [parameter(ValueFromPipelineByPropertyname=$true)]
        [switch]
        [Alias('slt')]
        $ShowTechnicalInfo,

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
        Assert-Valid7zArgsParams @PSBoundParameters

        $switches = (Get-Command Get-7zArgs).Parameters.Values |
            ? {
                $_.SwitchParameter -and
                $_.Name -notin [System.Management.Automation.PSCmdlet]::CommonParameters
            } |
            ? { Get-Variable $_.Name -ValueOnly } |
            % { $_.Aliases[0] }

        $psParameters = (Get-Command Get-7zArgs).Parameters.Values |
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
                % { "-$($parameter.Aliases[0])$($_ | ConvertTo-QuotedFilename)" }
        }


        $7zParameters = [System.Collections.ArrayList]@()
        $7zParameters += $commandCharLookup.$Command
        if ( $ArchivePath )
        {
            $7zParameters += $ArchivePath | ConvertTo-QuotedFilename
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
function ConvertTo-QuotedFilename
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory                      = $true,
                   Position                       = 1,
                   ValueFromPipeline              = $true,
                   ValueFromPipelineByPropertyname= $true)]
        [string]
        $Filename
    )
    process
    {
        if ( $Filename -match '[ \*]' )
        {
            return "`"$Filename`""
        }
        $Filename
    }
}
