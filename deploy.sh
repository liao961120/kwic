#!/usr/bin/env sh
set -e

npm run build

cd dist

git init
git add -A
git commit -m 'deploy'
git push -f https://github.com/liao961120/kwic.git master:gh-pages

cd -
