# Import the module containing the function
# Import the function script
BeforeAll {
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    Import-Module $ModuleRoot/PowerNixx.psd1 -Force
}

# Define the test suite
Describe 'ConvertTo-GzipParallel' {
    # Define the source and destination directories
    $script:srcDirPath = '/tmp/testsrcdir'
    $script:destDirPath = '/tmp/testdestdir'


    # Create the source and destination directories, and test files, before each test
    BeforeEach {
        # Create the source and destination directories
        $srcDir = New-Item -Path $srcDirPath -ItemType Directory -Force
        New-Item -Path $destDirPath -ItemType Directory -Force

        # Create some test files in the source directory
        $testFiles = @()
        for ($i = 0; $i -lt 5; $i++) {
            $testFile = New-Item -Path $srcDir.FullName -Name "TestFile$i.txt" -ItemType File
            $testFiles += $testFile
        }
    }

    # Clean up after each test
    AfterEach {
        # Remove the source and destination directories
        Remove-Item -Path $srcDirPath -Recurse -Force
        Remove-Item -Path $destDirPath -Recurse -Force
    }

    # Test the function
    It 'Compresses files in parallel' {
        ConvertTo-GzipParallel -SrcDir $srcDirPath -DestDir $destDirPath

        # Check if the compressed files exist in the destination directory
        foreach ($i in 0..4) {
            $compressedFile = Join-Path -Path $destDirPath -ChildPath ("TestFile$i.txt.gz")
            $compressedFile | Should -Exist
        }
    }

    # Test error handling
    It 'Throws an error if the source directory does not exist' {
        { ConvertTo-GzipParallel -SrcDir 'NonExistentDir' -DestDir $destDirPath } | Should -Throw
    }

    It 'Throws an error if the destination directory does not exist' {
        { ConvertTo-GzipParallel -SrcDir $srcDirPath -DestDir 'NonExistentDir' } | Should -Throw
    }
}