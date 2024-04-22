<#
.SYNOPSIS
    A PowerShell function that manages and organizes Git branches in a repository.

.DESCRIPTION
    The function categorizes branches into different groups based on their status and can output the results to a JSON file.

.PARAMETER Path
    The path to the Git repository. Default is the current location.

.PARAMETER WriteOutput
    A boolean value indicating whether to write the output to a file. Default is `false`.

.PARAMETER OutputFileLocation
    The location where the output file will be written if `$WriteOutput` is `true`. Default is the Desktop of the current user.

.PARAMETER RemoteName
    The name of the remote repository. Default is "origin".

.PARAMETER Threads
    The number of threads to use for parallel processing. Default is 5.

.EXAMPLE
    Group-Branches -Path "C:\path\to\repo" -WriteOutput $true -OutputFileLocation "C:\path\to\output\" -RemoteName "upstream" -Threads 5

    This example will analyze the Git branches in the repository at `C:\path\to\repo`, write the output to a JSON file at `C:\path\to\output\`, use "upstream" as the remote repository name, and use 10 threads for parallel processing.

.NOTES
    The function assumes that Git is installed and available in the system's PATH. It uses Git commands like `git branch` and `git fetch`. Some parts of the code are commented out, so they won't execute unless uncommented. This includes the check for branches with pending commits.
#>
function Group-Branches {
    param (
        [string]$Path = (Get-Location).Path,
        [bool]$WriteOutput = $false,
        [string]$OutputFileLocation = "$($env:USERPROFILE)\Desktop\",
        [string]$RemoteName = "origin",
        [int]$Threads = 5
    )

    $branchResults = @{pendingCommits = @(); notInRemote = @() }
    $branchResults = New-Object Branches

    $gitBranches = git branch

    if ($Path -ne (Get-Location).Path) {
        Write-Debug "Setting location to ($Path)"
        Push-Location $Path
    }

    git fetch

    $gitBranches | Foreach-Object -Parallel {
    
        # Check for current branch asterisk
        $current = $PSItem.TrimStart().StartsWith('*')
    
        # Format branch name to remove white space and asterisk indicator    
        $branchName = $PSItem.TrimStart("*").Trim()

        if ($current) {
            Write-Output "$branchName is current branch - Skipping"
            continue;
        }

        [bool]$hasNoUncommitedChanges = $true
        # [bool]$hasNoUncommitedChanges = ([array]((git status) | Select-String "nothing to commit")).Count -lt 1

        if ((git ls-remote --heads $using:RemoteName $branchName)) {
            Write-Output "$branchName exists on remote"
            ($using:branchResults).Ok += $branchName
            continue;
        }
        elseif ($hasNoUncommitedChanges -eq $true) {
            ($using:branchResults).Stale += $branchName
            Write-Output "$branchName does not exist on remote"
        }
        # elseif ($hasNoUncommitedChanges -eq $false) {
        #     ($using:branchResults).pendingCommits += $branchName
        #     Write-Output "$branchName has pending commits"
        # }

    } -ThrottleLimit $Threads

    if ($WriteOutput) {
        $branchResults | ConvertTo-Json > "$($OutputFileLocation)Branches.json"
    }

    $properties = @('Ok', 'Stale', 'PendingChanges')
    foreach ($property in $properties) {
        Write-Host
        Write-Host "$property branches:"
        $branchResults.$property | Format-Table
    }

    return $branchResults
}

Export-ModuleMember -Function 'Group-Branches'