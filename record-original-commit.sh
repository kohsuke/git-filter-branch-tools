#!/bin/sh
# commit message filter used with git-filter-branch to record the original commit ID
cat
echo "\nOriginally-Committed-As: $GIT_COMMIT"
