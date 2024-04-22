<#
.SYNOPSIS
Removes any local branches which aren't on remote

.DESCRIPTION
Checks all branches within a repository exist on the remote, if not - will delete them

.PARAMETER Threads
The number of threads to utilise towards this task (default: 5)

.PARAMETER NoConfirmation
WARNING: enabling this will not ask for confimation of the deletion of any branches and can result in pending changes being lost

.PARAMETER Path
Set location of repository to check, if not being ran in the repo folder

.PARAMETER OutputDeletedBranchNames
Will write a file to your desktop of the branch names being deleted

.PARAMETER OutputFileLocation
The filepath to write the branch names deleting to

.PARAMETER RemoteName
The name of the remote binding typically master or origin (default: origin) 

.EXAMPLE
Remove-StaleBranches -Threads 5 -NoConfirmation $false -Path "C:\repos\TestRepository"

.NOTES
This should only be used to cleardown any branches that have been deleted on the remote and, as a user, you will be responsible for any outcomes
#>#
function Remove-StaleBranches {
    [CmdletBinding()]
    param (
        [int]$Threads = 5,
        [bool]$NoConfirmation = $false,
        [string]$Path = (Get-Location).Path,
        [bool]$OutputDeletedBranchNames = $false,
        [string]$OutputFileLocation = "$($env:USERPROFILE)\Desktop\stale-branches.txt",
        [string]$RemoteName = "origin"
    )

    if ($branchResults.notInRemote.Count -gt 0) {

        $branchNameString = ""
        foreach ($name in $branchResults.notInRemote) {
            $branchNameString += "$($branchResults.notInRemote.IndexOf($name) + 1). $name`r`n"
        }

        if ($NoConfirmation -eq $true) {
            Write-Output "`r`n`r`n Branches Deleting `r`n` ---------------------------------"
            foreach ($name in $branchResults.notInRemote) {
                Write-Output "$($branchResults.notInRemote.IndexOf($name) + 1). $name"
            }

            # Delete here
            Remove-Branches -BranchNames $branchResults.notInRemote
        }
        else {
            $confirmation = $Host.UI.PromptForChoice("Branches Deleting ", "---------------------------------`r`n$branchNameString`r`nAre you sure you want to permanently delete the branches listed above?", @("&y", "&n"), 1)
            if ($confirmation -eq 0) {
                # Delete here
                Remove-Branches -BranchNames $branchResults.notInRemote
            }
        }

        if ($OutputDeletedBranchNames -eq $true) {

            if ((Test-Path -Path $OutputFileLocation -PathType Container)) {
                $OutputFileLocation = (Join-Path -Path $OutputFileLocation -ChildPath "deleted-branches.txt")
            }

            Write-Output $branchNameString > $OutputFileLocation
        }
    }
    else {
        Write-Host -ForegroundColor Yellow "No Branches to Delete"
    }

    # Output branches with pending changes here
    if ($branchResults.pendingCommits.Count -gt 0) {

        Write-Host -ForegroundColor Blue "`r`nBranches pending commits:`r`n-------------------`r`n"
        Write-Host -Separator "`r`n" $branchResults.pendingCommits
    }

    if ($Path) {
        Write-Debug "Removing path ($Path)"
        Pop-Location
    }

}

Export-ModuleMember -Function 'Remove-StaleBranches'