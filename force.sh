git remote add origin git@github.com:rktjmp/pact-repo-test.git
git fetch
git push origin --delete $(git tag -l)
git push origin --all --force
