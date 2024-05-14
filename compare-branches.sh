#!/bin/bash

# Get the name of the current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Iterate over all remotes
for remote in $(git remote); do
    echo "Branches in remote '$remote':"
    # Fetch the latest refs from the remote
    git fetch $remote
    # List branches in the remote starting with 'main'
    git ls-remote --heads $remote | grep "refs/heads/main$" | while read -r line; do
        # Extract the branch name
        branch_name=$(echo $line | awk '{print $2}' | sed 's/refs\/heads\///')
        remote_branch="$remote/$branch_name"
        # Ensure we have the remote branch locally
        git branch --track $branch_name $remote_branch &> /dev/null
        # Print the branch name and its status relative to the current branch
        ahead=$(git rev-list --count $current_branch..$remote_branch)
        behind=$(git rev-list --count $remote_branch..$current_branch)
        echo "$branch_name (remote: $remote): ahead by $ahead, behind by $behind"
    done
done

# Switch back to the original branch
git checkout $current_branch &> /dev/null

