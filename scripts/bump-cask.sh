#!/usr/bin/env bash
# Bump one cask in this tap to a new version.
#
#   scripts/bump-cask.sh <cask-name> <new-version>
#   scripts/bump-cask.sh tasks-ui 1.1.0
#
# Every source repository is public, so the release download URL interpolates
# the version and needs no credentials. Only the version and the checksum move.
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

url=$(sed -n 's/^[[:space:]]*url "\([^"]*\)".*/\1/p' "${cask}" | head -1)
[[ -n "${url}" ]] || {
  echo "cannot read a url from ${cask}" >&2
  exit 1
}

# The URL in the file still interpolates the old version. Resolving it here
# rather than rewriting the cask first keeps every edit to the file below,
# after the download has succeeded, so a failed fetch leaves the cask alone.
download=$(printf '%s' "${url}" | sed "s/#{version}/${new}/g")
echo "${name}: -> ${new}"
echo "  fetching ${download}"
payload=$(mktemp)
curl -sSfL --retry 3 --retry-delay 2 --connect-timeout 20 --max-time 300 \
  -o "${payload}" "${download}"
sha=$(sha256_of "${payload}")
rm -f "${payload}"

perl -pi -e "s|^(\s*)version \"[^\"]*\"|\${1}version \"${new}\"|" "${cask}"
perl -pi -e "s|^(\s*)sha256 \"[0-9a-f]*\"|\${1}sha256 \"${sha}\"|" "${cask}"

ruby -c "${cask}" >/dev/null
echo "${name} is now at ${new}"
