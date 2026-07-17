#!/usr/bin/env bash
set -u

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "=== MODE: SINGLE-REPO ==="
  echo "Branch: $(git branch --show-current)"
  echo "Tracking: $(git status -sb | head -n 1)"
  echo
  echo "## Working tree"
  git status --short
  echo
  echo "## Staged changes"
  git diff --cached --stat
  echo
  echo "## Unstaged changes"
  git diff --stat
  echo
  echo "## Recent commits (last 10)"
  git log --oneline -10 --decorate
  echo
  echo "## Stashes"
  git stash list
else
  echo "=== MODE: OUTER-LEVEL ==="
  echo "cwd: $(pwd)"
  echo
  find . -maxdepth 4 -type d \( -name node_modules -o -name .venv -o -name venv -o -name dist -o -name build -o -name .next -o -name vendor -o -name .turbo -o -name target -o -name .cache \) -prune -o -type d -name .git -print 2>/dev/null | while read -r gitdir; do
    d="${gitdir%/.git}"
    name="${d#./}"
    [ -z "$name" ] && name="$(basename "$(pwd)")"
    branch=$(git -C "$d" branch --show-current 2>/dev/null)
    dirty=$(git -C "$d" status --short 2>/dev/null | wc -l | tr -d " ")
    last_ts=$(git -C "$d" log -1 --format="%at" 2>/dev/null)
    last=$(git -C "$d" log -1 --format="%ar | %s" 2>/dev/null)
    tracking=$(git -C "$d" status -sb 2>/dev/null | head -n 1 | sed "s/^## //")
    echo "--- $name ---"
    echo "path: $d"
    echo "branch: $branch"
    echo "tracking: $tracking"
    echo "dirty_files: $dirty"
    echo "last_ts: $last_ts"
    echo "last_commit: $last"
    echo "recent:"
    git -C "$d" log --oneline -3 --decorate 2>/dev/null | sed "s/^/  /"
    echo
  done
fi

