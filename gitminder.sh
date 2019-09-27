#!/bin/bash

# usage: gitminder <root-dir...>

# Find all Git repos within <root-dir> (.git)
REPOS=($(find $@ -name ".git" -type d))

# Find all unstaged files within each
# TODO make it work with worktreeeeeeee
for repo in ${REPOS[@]}; do
  # canonicalize the path of the repo, not the .git/
  GITDIR=$(readlink -f "$repo/..")
  # count all the modified working tree state
  SUMMARY=$(git -C "$GITDIR" status --porcelain=v1)
  # count how many changes to tracked files (?? denotes untracked)
  TRACK_COUNT=$(echo "$SUMMARY" | fgrep -cv "??")
  # count how many changes to untracked files
  UNTRACK_COUNT=$(echo "$SUMMARY" | fgrep -c "??")
  # get the branch name
  BRANCH=$(git -C "$GITDIR" name-rev HEAD --name-only)

  # If we have uncommitted work loose, give a summary
  if [ $(expr $TRACK_COUNT + $UNTRACK_COUNT) -ne 0 ]; then
    # /path/to/repo
    echo "$GITDIR"
    #   4 unstaged files in branch mybranch
    echo "  $TRACK_COUNT tracked and $UNTRACK_COUNT untracked files in $BRANCH"
    #   last commit on 4/20/2019
    echo "  last commit was" $(git -C "$GITDIR" show -s --pretty="%ar")
  fi
done
