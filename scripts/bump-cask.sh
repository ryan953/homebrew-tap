#!/usr/bin/env bash
# Bump one cask in this tap to a new version.
#
#   scripts/bump-cask.sh <cask-name> <new-version>
#   scripts/bump-cask.sh tasks-ui 1.1.0
#
# The casks here name a GitHub release asset by its numeric ID, because their
# source repositories are private and only the API endpoint accepts a token.
# That ID changes with every release, so the script looks the new one up,
# downloads the asset, and writes the version, the ID and the sha256 back.
#
# Needs HOMEBREW_GITHUB_API_TOKEN, or a logged-in `gh`. The token needs
# Contents: Read on the source repository, which is more than a fine-grained
# token gets by default.
set -euo pipefail

name=${1:?usage: bump-cask.sh <cask-name> <new-version>}
new=${2:?usage: bump-cask.sh <cask-name> <new-version>}
new=${new#v}
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cask="${root}/Casks/${name}.rb"

sha256_of() {
  if command -v shasum >/dev/null 2>&1
  then
    shasum -a 256 "$1" | cut -d' ' -f1
  else
    sha256sum "$1" | cut -d' ' -f1
  fi
}

[[ -f "${cask}" ]] || {
  echo "no such cask: ${cask}" >&2
  exit 1
}

token=${HOMEBREW_GITHUB_API_TOKEN:-}
if [[ -z "${token}" ]] && command -v gh >/dev/null 2>&1
then
  token=$(gh auth token 2>/dev/null || true)
fi
[[ -n "${token}" ]] || {
  echo "set HOMEBREW_GITHUB_API_TOKEN, or log in with gh, to read the release" >&2
  exit 1
}

repo=$(sed -n 's|^[[:space:]]*homepage "https://github.com/\([^"]*\)".*|\1|p' "${cask}" | head -1)
repo=${repo%/}
[[ -n "${repo}" ]] || {
  echo "cannot read a github.com homepage from ${cask}" >&2
  exit 1
}
echo "${name}: ${repo} -> ${new}"

# 1. Find the one downloadable asset on the release for this version.
release=$(mktemp)
curl -sSfL --retry 3 --retry-delay 2 --connect-timeout 20 --max-time 120 \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${token}" \
  -o "${release}" \
  "https://api.github.com/repos/${repo}/releases/tags/v${new}"

asset=$(python3 "${root}/scripts/pick_release_asset.py" "${release}" "${new}")
rm -f "${release}"

asset_id=${asset%% *}
asset_name=${asset#* }
echo "  asset ${asset_name} (id ${asset_id})"

# 2. Download it to get the checksum.
payload=$(mktemp)
curl -sSfL --retry 3 --retry-delay 2 --connect-timeout 20 --max-time 300 \
  -H "Accept: application/octet-stream" \
  -H "Authorization: Bearer ${token}" \
  -o "${payload}" \
  "https://api.github.com/repos/${repo}/releases/assets/${asset_id}"
sha=$(sha256_of "${payload}")
rm -f "${payload}"

# 3. Write the version, the asset ID and the checksum back.
perl -pi -e "s|^(\s*)version \"[^\"]*\"|\${1}version \"${new}\"|" "${cask}"
perl -pi -e "s|releases/assets/[0-9]+|releases/assets/${asset_id}|" "${cask}"
perl -pi -e "s|^(\s*)sha256 \"[0-9a-f]*\"|\${1}sha256 \"${sha}\"|" "${cask}"

ruby -c "${cask}" >/dev/null
echo "${name} is now at ${new}"
