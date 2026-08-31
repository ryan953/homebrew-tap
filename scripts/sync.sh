#!/usr/bin/env bash
# Bump every entry in this tap that is behind its source repository.
#
#   scripts/sync.sh [--dry-run]
#
# Every source is a public GitHub repository, so their releases are readable
# without credentials and the tap can pull a new version in rather than waiting
# to be pushed one.
set -euo pipefail

dry_run=false
[[ ${1:-} == --dry-run ]] && dry_run=true

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
changed=false

for file in "${root}"/Formula/*.rb "${root}"/Casks/*.rb
do
  [[ -e "${file}" ]] || continue
  name=$(basename "${file}" .rb)
  case "${file}" in
    */Formula/*) kind=formula ;;
    *) kind=cask ;;
  esac

  repo=$(sed -n 's|^[[:space:]]*homepage "https://github.com/\([^"]*\)".*|\1|p' "${file}" | head -1)
  repo=${repo%/}
  [[ -n "${repo}" ]] || {
    echo "${name}: no github.com homepage, skipping" >&2
    continue
  }

  latest=$(gh api "repos/${repo}/releases/latest" --jq .tag_name 2>/dev/null || true)
  [[ -n "${latest}" ]] || {
    echo "${name}: ${repo} has no published release, skipping" >&2
    continue
  }
  latest=${latest#v}

  # A cask carries an explicit version; a formula has none, because `brew audit`
  # rejects it as redundant with the version it scans out of the URL.
  if [[ "${kind}" == cask ]]
  then
    current=$(sed -n 's|^[[:space:]]*version "\([^"]*\)".*|\1|p' "${file}" | head -1)
  else
    current=$(sed -n 's|.*/releases/download/v\{0,1\}\([^/]*\)/.*|\1|p' "${file}" | head -1)
  fi

  if [[ "${current}" == "${latest}" ]]
  then
    echo "${name}: up to date at ${current}"
    continue
  fi

  echo "${name}: ${current} -> ${latest}"
  if [[ "${dry_run}" == true ]]
  then
    changed=true
    continue
  fi
  "${root}/scripts/bump-${kind}.sh" "${name}" "${latest}"
  changed=true
done

[[ "${changed}" == true ]] || echo "everything is up to date"
