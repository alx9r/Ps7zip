Import-Module Ps7zip -Force

Describe Assert-Valid7zExtractArgsParams {
    It 'throws on missing archive file.' {
        {Get-7zExtractArgs x} |
            Should throw 'You must specify ArchivePath, IncludeArchiveFiles, or IncludeArchiveListFiles'
    }
    It 'throws on bad TypeOfArchive.' {
        $splat = @{
            ArchivePath = 'archive.zip'
            TypeOfArchive = 'bad.type.of.archive'
        }
        {Get-7zExtractArgs x @splat} |
            Should throw 'TypeOfArchive bad in not valid.'
    }
}

Describe Get-7zExtractArgs {
    It 'no Files' {
        $r = Get-7zExtractArgs x 'archive.zip'

        $r | Should be 'x archive.zip'
    }
    It 'switches' {
        $splat = @{
            ArchivePath = 'archive.zip'
            OverwriteMode = $true
        }
        $r = Get-7zExtractArgs x @splat

        $r | Should be 'x archive.zip -ao'
    }
    It 'list of files' {
        $splat = @{
            ArchivePath = 'archive.zip'
            IncludeFiles = 'file1.txt','file2.txt'
        }
        $r = Get-7zExtractArgs x @splat

        $r | Should be 'x archive.zip -i!file1.txt -i!file2.txt'
    }
    It 'single parameter' {
        $splat = @{
            ArchivePath = 'archive.zip'
            Password = 'password'
        }
        $r = Get-7zExtractArgs x @splat

        $r | Should be 'x archive.zip -ppassword'
    }
    It 'no ArchivePath' {
        $splat = @{
            IncludeArchiveFiles = 'archive.zip'
        }
        $r = Get-7zExtractArgs x @splat

        $r | Should be 'x -an -ai!archive.zip'
    }
}
