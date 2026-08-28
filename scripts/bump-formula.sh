#!/usr/bin/env bash
# Bump one formula in this tap to a new version.
#
#   scripts/bump-formula.sh <formula-name> <new-version>
#   scripts/bump-formula.sh repo-metrics 0.3.0
#
# The script replaces the old version string everywhere in the formula,
# then downloads each `url` and writes the new sha256 next to it.
set -euo pipefail

name=${1:?usage: bump-formula.sh <formula-name> <new-version>}
new=${2:?usage: bump-formula.sh <formula-name> <new-version>}
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
formula="$root/Formula/$name.rb"

[ -f "$formula" ] || { echo "no such formula: $formula" >&2; exit 1; }

old=$(sed -n 's/^[[:space:]]*version "\([^"]*\)".*/\1/p' "$formula" | head -1)
[ -n "$old" ] || { echo "no version line in $formula" >&2; exit 1; }
echo "$name: $old -> $new"

# 1. Put the new version into the version line and into every URL.
perl -pi -e "s/\Q$old\E/$new/g" "$formula"

# 2. Download each URL and collect its checksum, in file order.
shas=()
while read -r url; do
  echo "  fetching $url"
  tmp=$(mktemp)
  curl -sSfL "$url" -o "$tmp"
  shas+=("$(shasum -a 256 "$tmp" | cut -d' ' -f1)")
  rm -f "$tmp"
done < <(sed -n 's/^[[:space:]]*url "\([^"]*\)".*/\1/p' "$formula")

[ "${#shas[@]}" -gt 0 ] || { echo "no url lines in $formula" >&2; exit 1; }

# 3. Write the checksums back, in the same order.
awk -v list="${shas[*]}" '
  BEGIN { split(list, s, " "); i = 0 }
  /^[[:space:]]*sha256 "/ { i++; sub(/"[0-9a-f]*"/, "\"" s[i] "\"") }
  { print }
' "$formula" > "$formula.new"
mv "$formula.new" "$formula"

ruby -c "$formula" >/dev/null
echo "$name is now at $new"
