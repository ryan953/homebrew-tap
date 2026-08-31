#!/usr/bin/env bash
# Bump every formula in this tap that is behind its source repository.
#
#   scripts/sync-formulae.sh [--dry-run]
#
# Formulae are built from public repositories, so the tap can read their
# releases and pull a new version in. Casks are not covered: their sources are
# private, and those repositories push to the tap on release instead.
set -euo pipefail

dry_run=false
[[ ${1:-} == --dry-run ]] && dry_run=true

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
changed=false

for formula in "${root}"/Formula/*.rb
do
  name=$(basename "${formula}" .rb)
  repo=$(sed -n 's|^[[:space:]]*homepage "https://github.com/\([^"]*\)".*|\1|p' "${formula}" | head -1)
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

  current=$(sed -n 's|.*/releases/download/v\{0,1\}\([^/]*\)/.*|\1|p' "${formula}" | head -1)
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
  "${root}/scripts/bump-formula.sh" "${name}" "${latest}"
  changed=true
done

[[ "${changed}" == true ]] || echo "everything is up to date"
