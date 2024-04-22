using System.Collections.Concurrent;
using System.Collections.Generic;

/// <summary>
/// A class that represents a collection of Git branches categorized by their status.
/// </summary>
public class Branches
{
    private ConcurrentDictionary<string, List<string>> _properties;

    /// <summary>
    /// A `List<string>` that contains the names of branches that exist on the remote repository.
    /// </summary>
    public List<string> Ok { get; set; }

    /// <summary>
    /// A `List<string>` that contains the names of branches that do not exist on the remote 
    /// repository and have no uncommitted changes.
    /// </summary>
    public List<string> Stale { get; set; }

    /// <summary>
    /// A `List<string>` that contains the names of branches that have pending commits.
    /// </summary>
    public List<string> PendingChanges { get; set; }

    /// <summary>
    /// The constructor initializes the `ConcurrentDictionary` and adds three keys: "StaleBranches", 
    /// "BranchesWithPendingChanges", and "OkBranches". Each key is associated with a new `List<string>`.
    /// </summary>
    public Branches()
    {
        _properties = new ConcurrentDictionary<string, List<string>>();
        _properties.TryAdd("StaleBranches", new List<string>());
        _properties.TryAdd("BranchesWithPendingChanges", new List<string>());
        _properties.TryAdd("OkBranches", new List<string>());

        Ok = _properties["OkBranches"];
        Stale = _properties["StaleBranches"];
        PendingChanges = _properties["BranchesWithPendingChanges"];
    }
}