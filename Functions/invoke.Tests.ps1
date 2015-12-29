Import-Module Ps7zip -Force

InModuleScope Ps7zip {
    Describe Find-7zCommandPath {
        Context 'success' {
            Mock Get-Command {
                if ($Name -eq "$Env:ProgramFiles\7-Zip\7z.exe")
                {
                    return @{
                        Path = 'commandpath'
                    }
                }
                throw
            }
            It 'returns command object' {
                $r = Find-7zCommandPath

                $r | Should be 'commandpath'
            }
        }
        Context 'throws' {
            Mock Get-Command {throw }
            It 'throws correct exception' {
                {Find-7zCommandPath} |
                    Should throw '7z.exe was not found in any of the usual places.'
            }
        }
    }
    Describe Test-7zExe {
        Context 'success' {
            Mock Get-Command -Verifiable {'junk'}
            Mock Invoke-Command -Verifiable { 'stream' }
            Mock ConvertFrom-7zNullCommandStream -Verifiable
            It 'returns true.' {
                $r = Test-7zExe 'path'

                $r.Count | Should be 1
                $r | Should be $true

                Assert-MockCalled Get-Command -Times 1 {
                    $Name -eq 'path'
                }
                Assert-MockCalled Invoke-Command -Times 1
                Assert-MockCalled ConvertFrom-7zNullCommandStream -Times 1 {
                    $7zStream -eq 'stream'
                }
            }
        }
        Context 'fail' {
            Mock Get-Command
            Mock Invoke-Command { throw }
            It 'returns false.' {
                $r = Test-7zExe 'path'

                $r | Should be $false
            }
        }
    }
}
