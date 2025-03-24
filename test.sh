(curl -fsSL -X POST -H "Authorization: Bearer " "https://api.github.com/repos/$GITHUB_REPOSITORY/commits/$GITHUB_SHA/comments" \
  -d "{\"body\": \"Package released - [\`$PACKAGE_NAME@$RELEASE_VERSION\`]($PACKAGE_URL)\"}" && echo "🟢 Release comment added!") || true
(curl -fsSL -X POST -H "Authorization: Bearer " "https://api.github.com/repos/$GITHUB_REPOSITORY/statuses/$GITHUB_SHA" \
  -d "{\"state\": \"success\", \"context\": \"Package released\", \"description\": \"$PACKAGE_NAME@$RELEASE_VERSION\", \"target_url\": \"$PACKAGE_URL\"}" && echo "🟢 Release status added!") || true
