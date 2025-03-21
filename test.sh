# Check if package exists in npm registry

package_name=$(bunx json -f package.json -a name)
npm view "$package_name" 2>/dev/null || {
  echo "$package_name does not exist in the npm registry. Skipping publish."
  exit 0
}

current_version=$(bunx json -f package.json -a version)
IFS='.' read -r major minor patch <<<"$current_version"
future_latest="$major.$((minor + 1)).0"
current_canary=$(npm view "$package_name" dist-tags.canary 2>/dev/null)
if [ -z "$current_canary" ]; then
  future_canary="$future_latest-canary.0"
else
  IFS='.-' read -r canary_major canary_minor canary_patch canary_tag canary_version <<<"$current_canary"
  future_canary="$canary_major.$canary_minor.$canary_patch-canary.$((canary_version + 1))"
fi
bunx json -I -f package.json -e "this.version=\"$future_canary\""
bun publish --provenance --access public --tag canary

curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/$GITHUB_REPOSITORY/releases" \
  -d "$(printf '{"tag_name": "%s", "name": "%s", "body": "%s", "prerelease": true}' "$future_canary" "$future_canary" "$changelog")"
