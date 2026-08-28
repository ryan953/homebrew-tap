"""Print the id and name of the one downloadable asset on a GitHub release.

    python3 scripts/pick_release_asset.py <release.json> <version>

`bump-cask.sh` calls this rather than parsing the JSON inline. A heredoc inside
a command substitution defeats the `shfmt` that `brew style` runs, and that
formatter truncates a file it cannot parse.
"""

import json
import sys


def main() -> None:
    release_json, version = sys.argv[1], sys.argv[2]
    with open(release_json) as handle:
        data = json.load(handle)

    assets = [a for a in data.get("assets", []) if not a["name"].endswith(".sha256")]
    match = [a for a in assets if version in a["name"]] or assets
    if len(match) != 1:
        names = ", ".join(a["name"] for a in match) or "nothing"
        sys.exit(
            f"expected one downloadable asset on v{version}, "
            f"found {len(match)}: {names}"
        )

    print(match[0]["id"], match[0]["name"])


if __name__ == "__main__":
    main()
