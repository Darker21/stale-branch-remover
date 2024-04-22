<#
.SYNOPSIS
    A PowerShell function that deletes Git branches.

.DESCRIPTION
    The `Remove-Branches` function deletes the specified Git branches. It uses the `git branch -d` command to delete each branch.

.PARAMETER BranchNames
    An array of branch names to delete. This parameter is mandatory and can accept values from the pipeline.

.EXAMPLE
    Remove-Branches -BranchNames @("branch1", "branch2", "branch3")

    This example deletes the branches named "branch1", "branch2", and "branch3".

.EXAMPLE
    @("branch1", "branch2", "branch3") | Remove-Branches

    This example also deletes the branches named "branch1", "branch2", and "branch3". It demonstrates how to use the pipeline to pass branch names to the function.

.NOTES
    The function assumes that Git is installed and available in the system's PATH. It uses the `git branch -d` command to delete branches, which will not delete a branch if it has unmerged changes. To force delete branches, you could modify the function to use the `git branch -D` command instead.
#>
function Remove-Branches {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [array]$BranchNames
    )

    if ($branchNames.Count -lt 1) {
        Write-Host -ForegroundColor Red "No branches provided"
        return
    }

    $branchNames | ForEach-Object {
        Write-Host -ForegroundColor Blue "Deleting branch $PSItem"
        git branch -d $PSItem
    }
}

Export-ModuleMember -Function 'Remove-Branches'