#!/bin/bash

# Get the name of the current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Fetch all updates from all remotes
git fetch --all

# Iterate over all remotes
for remote in $(git remote); do
    echo "Branches in remote '$remote':"
    # List branches in the remote
    git branch -r | grep "$remote/" | grep -v 'HEAD ->' | while read -r remote_branch; do
        # Extract the branch name
        branch_name=${remote_branch#"$remote/"}
        # Ensure the remote branch is being tracked locally
        if ! git branch --list "$branch_name" &>/dev/null; then
            # Track the remote branch locally if not already tracked
            git branch --track $branch_name $remote_branch &> /dev/null
        fi
        # Calculate ahead/behind status
        ahead=$(git rev-list --count $current_branch..$remote_branch 2>/dev/null)
        behind=$(git rev-list --count $remote_branch..$current_branch 2>/dev/null)
        echo "$branch_name (remote: $remote): ahead by $ahead, behind by $behind"
    done
done

# Ensure we switch back to the original branch only if it was changed
if [ $(git rev-parse --abbrev-ref HEAD) != "$current_branch" ]; then
    git checkout $current_branch &> /dev/null
fi

