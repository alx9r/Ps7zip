## Output Samples

This folder contains sample outputs from different versions of `7z.exe` serialized to XML.  The archive file used to create the sample outputs is `vcredist_x64.EXE`, the x64 Visual CPP 2008 Redistributable, whose filehash as follows:

    Algorithm       Hash                                                                
    ---------       ----                                                                
    SHA256          BAAAEDDC17BCDA8D20C0A82A9EB1247BE06B509A820D65DDA1342F4010BDB4A0    

### nullSample-XX.xml

Created using the following command:

	& (Find-7zCommandPath) | Export-Clixml .\nullSample-XX.xml

### listsSample-XX.xml

Created using the following command:

    $arguments = Get-7zArgs -Command List -ArchivePath '\\path\to\vcredist_x64.EXE'
	& (Find-7zCommandPath) $arguments.Split(' ') | Export-Clixml .\listSample-XX.xml


### extractSample-XX.xml

Created using the following command:

	$arguments = Get-7zArgs -Command X -ArchivePath .\vcredist_x64.EXE -OutputFolder C:\temp -AssumeYes -IncludeFiles *
	& (Find-7zCommandPath) $arguments.Split(' ') | Export-Clixml .\extractSample-XX.xml
	
### extractErrorSample.xml

Created by first locking a file that needs to be overwritten in the output path, then invoking the following command:

	$arguments = Get-7zArgs -Command X -ArchivePath .\vcredist_x64.EXE -OutputFolder C:\temp -AssumeYes -IncludeFiles *
	& (Find-7zCommandPath) $arguments.Split(' ') | Export-Clixml .\extractSample-XX.xml