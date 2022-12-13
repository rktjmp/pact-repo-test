git fetch
git push origin --delete $(git tag -l)
rm *.txt
rm -rf .git
