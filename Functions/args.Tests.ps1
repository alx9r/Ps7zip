Import-Module Ps7zip -Force

Describe Assert-Valid7zArgsParams {
    It 'throws on missing archive file.' {
        {Get-7zArgs x} |
            Should throw 'You must specify ArchivePath, IncludeArchiveFiles, or IncludeArchiveListFiles'
    }
    It 'throws on bad TypeOfArchive.' {
        $splat = @{
            ArchivePath = 'archive.zip'
            TypeOfArchive = 'bad.type.of.archive'
        }
        {Get-7zArgs x @splat} |
            Should throw 'TypeOfArchive bad in not valid.'
    }
    It 'throws on invalid parameter for command.' {
        $splat = @{
            ArchivePath = 'archive.zip'
            Command = 'List'
            OutputFolder = 'outputfolder'
        }
        {Get-7zArgs @splat} |
            Should throw 'Parameter o is not valid for List command.'
    }
}

Describe Get-7zArgs {
    It 'no Files' {
        $r = Get-7zArgs x 'archive.zip'

        $r | Should be 'x archive.zip'
    }
    It 'switches' {
        $splat = @{
            ArchivePath = 'archive.zip'
            OverwriteMode = $true
        }
        $r = Get-7zArgs x @splat

        $r | Should be 'x archive.zip -ao'
    }
    It 'list of files' {
        $splat = @{
            ArchivePath = 'archive.zip'
            IncludeFiles = 'file1.txt','file2.txt'
        }
        $r = Get-7zArgs x @splat

        $r | Should be 'x archive.zip -i!file1.txt -i!file2.txt'
    }
    It 'single parameter' {
        $splat = @{
            ArchivePath = 'archive.zip'
            Password = 'password'
        }
        $r = Get-7zArgs x @splat

        $r | Should be 'x archive.zip -ppassword'
    }
    It 'no ArchivePath' {
        $splat = @{
            IncludeArchiveFiles = 'archive.zip'
        }
        $r = Get-7zArgs x @splat

        $r | Should be 'x -an -ai!archive.zip'
    }
}
