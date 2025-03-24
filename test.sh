npm i -g @antfu/ni
PACKAGE_NAME=$(nlx json -f package.json -a name)
PACKAGE_VERSION=$(nlx json -f package.json -a version)
VERSIONS=$(npm view $PACKAGE_NAME dist-tags --json)
LATEST_VERSION=$(echo $VERSIONS | nlx json latest)
if [[ $PACKAGE_VERSION != $LATEST_VERSION ]]; then
  RELEASE_VERSION=$PACKAGE_VERSION
  HAS_TAG=$(echo $PACKAGE_VERSION | grep -o '[a-zA-Z]*' | head -n 1)
  TAG=$([[ -n "$HAS_TAG" ]] && echo $HAS_TAG || echo "latest")
else
  TAG="canary"
  RELEASE_VERSION=$(nlx semver $LATEST_VERSION -i minor)
  TAGGED_VERSION=$(echo $VERSIONS | nlx json $TAG)
  RELEASE_VERSION=$([[ $TAGGED_VERSION == $RELEASE_VERSION* ]] && nlx semver $TAGGED_VERSION -i prerelease || echo $RELEASE_VERSION-$TAG.0)
fi
nlx json -I -f package.json -e "this.version=\"$RELEASE_VERSION\""
npm publish --provenance --access public --no-git-checks --tag $TAG
PACKAGE_URL="https://www.npmjs.com/package/$PACKAGE_NAME/v/$RELEASE_VERSION"
