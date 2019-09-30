#!/bin/bash

# usage: gitminder <root-dir...>

# Find all Git repos within <root-dir> (.git)
REPOS=($(find $@ -name ".git" -type d | xargs -I% readlink -f %/..))

# Find all the worktrees related to the Git repos
WTS=()
for repo in ${REPOS[@]}; do
  # append worktrees that aren't this repo to the worktrees array
  WTS+=($(git -C "$repo" worktree list --porcelain | grep worktree \
            | cut -d" " -f 2 | grep -vx "$repo"))
done
REPOS+=(${WTS[*]})

# Find all unstaged files within each
for repo in ${REPOS[@]}; do
  # count all the modified working tree state
  SUMMARY=$(git -C "$repo" status --porcelain=v1)
  # count how many changes to tracked files (?? denotes untracked)
  TRACK_COUNT=$(echo "$SUMMARY" | egrep -v "^$" | fgrep -cv "??")
  # count how many changes to untracked files
  UNTRACK_COUNT=$(echo "$SUMMARY" | fgrep -c "??")
  # get the branch name
  BRANCH=$(git -C "$repo" name-rev HEAD --name-only)

  # If we have uncommitted work loose, give a summary
  if [ $(expr $TRACK_COUNT + $UNTRACK_COUNT) -ne 0 ]; then
    # /path/to/repo
    echo "$repo"
    #   4 unstaged files in branch mybranch
    echo "  $TRACK_COUNT tracked and $UNTRACK_COUNT untracked files in $BRANCH"
    #   last commit on 4/20/2019
    echo "  last commit was" $(git -C "$repo" show -s --pretty="%ar")
  fi
done
