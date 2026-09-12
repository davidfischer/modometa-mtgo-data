#!/usr/bin/env bash
set -euo pipefail

# Repository root directory
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

CACHE_DIR="Tournaments/MTGO"

# Resolve scraper package source:
# 1. SCRAPER_SOURCE environment variable if set
# 2. Sibling directory ../modometa-scraper if it exists
# 3. Upstream GitHub repository
if [[ -n "${SCRAPER_SOURCE:-}" ]]; then
  SOURCE="$SCRAPER_SOURCE"
elif [[ -d "$REPO_ROOT/../modometa-scraper" ]]; then
  SOURCE="$REPO_ROOT/../modometa-scraper"
else
  SOURCE="git+https://github.com/davidfischer/modometa-scraper.git"
fi

echo "==> Scraper source: $SOURCE"
echo "==> Cache directory: $CACHE_DIR"

EXTRA_ARGS=("$@")
HAS_RESUME_OR_DATE=false

for arg in "$@"; do
  if [[ "$arg" == "--auto-resume" || "$arg" == "--start-date" || "$arg" == "-h" || "$arg" == "--help" ]]; then
    HAS_RESUME_OR_DATE=true
    break
  fi
done

if [[ "$HAS_RESUME_OR_DATE" == "false" ]]; then
  EXTRA_ARGS=("--auto-resume" "${EXTRA_ARGS[@]}")
fi

# If using the scraper locally, don't cache it
# This is important for local development
# so the most up-to-date version is run
UVX_ARGS=()
if [[ -d "$SOURCE" ]]; then
  UVX_ARGS+=("--no-cache")
fi

exec uvx "${UVX_ARGS[@]}" --from "$SOURCE" modometa-scraper \
  --cache-dir "$CACHE_DIR" \
  "${EXTRA_ARGS[@]}"
