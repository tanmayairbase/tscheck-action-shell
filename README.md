# no new `@ts-nocheck`

Checks if new `@ts-nocheck` is introduced in a PR or not.

- It looks at `git diff` between the source branch and the destination branch of a pull request
- Then, it separates out the additions and deletions and counts the instances of `@ts-nocheck` in each of them
- Finally, it would fail with `exit 1` if the count in additions is more than count in deletions (which would mean the PR has introduced new `@ts-nocheck` isntances)
