#!/usr/bin/env bash
# Bump one formula in this tap to a new version.
#
#   scripts/bump-formula.sh <formula-name> <new-version>
#   scripts/bump-formula.sh repo-metrics 0.3.0
#
# The script finds the current version in the release URLs, replaces it
# everywhere in the formula, then downloads each URL and writes the new sha256
# next to it. The formulae carry no `version` line, because Homebrew reads the
# version from the URL and `brew audit` rejects the duplicate.
set -euo pipefail

name=${1:?usage: bump-formula.sh <formula-name> <new-version>}
new=${2:?usage: bump-formula.sh <formula-name> <new-version>}
new=${new#v}
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
formula="${root}/Formula/${name}.rb"

[[ -f "${formula}" ]] || {
  echo "no such formula: ${formula}" >&2
  exit 1
}

sha256_of() {
  if command -v shasum >/dev/null 2>&1
  then
    shasum -a 256 "$1" | cut -d' ' -f1
  else
    sha256sum "$1" | cut -d' ' -f1
  fi
}

urls_in() { sed -n 's/^[[:space:]]*url "\([^"]*\)".*/\1/p' "$1"; }

# The tag sits between /releases/download/ and the asset name.
old=$(urls_in "${formula}" | sed -n 's|.*/releases/download/v\{0,1\}\([^/]*\)/.*|\1|p' | head -1)
[[ -n "${old}" ]] || {
  echo "cannot read the current version from the URLs in ${formula}" >&2
  exit 1
}
[[ "${old}" != "${new}" ]] || {
  echo "${name} is already at ${new}" >&2
  exit 0
}
echo "${name}: ${old} -> ${new}"

# 1. Put the new version into every URL.
perl -pi -e "s/\Q${old}\E/${new}/g" "${formula}"

# 2. Download each URL and collect its checksum, in file order.
shas=()
while read -r url
do
  echo "  fetching ${url}"
  tmp=$(mktemp)
  curl -sSfL "${url}" -o "${tmp}"
  shas+=("$(sha256_of "${tmp}")")
  rm -f "${tmp}"
done < <(urls_in "${formula}")

[[ "${#shas[@]}" -gt 0 ]] || {
  echo "no url lines in ${formula}" >&2
  exit 1
}

# 3. Write the checksums back, in the same order.
awk -v list="${shas[*]}" '
  BEGIN { split(list, s, " "); i = 0 }
  /^[[:space:]]*sha256 "/ { i++; sub(/"[0-9a-f]*"/, "\"" s[i] "\"") }
  { print }
' "${formula}" >"${formula}.new"
mv "${formula}.new" "${formula}"

ruby -c "${formula}" >/dev/null
echo "${name} is now at ${new}"
