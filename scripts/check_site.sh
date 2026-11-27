#!/usr/bin/env bash
# Check that every page in the live site's sitemap.xml, plus any extra URLs given, returns HTTP 200.
# Usage: scripts/check_site.sh https://rohithkumar.dev [extra-url ...]
set -euo pipefail

site="${1:?usage: check_site.sh <site-url> [extra-url ...]}"
site="${site%/}"
shift

user_agent="site-health-check (+https://github.com/prasroku/website)"
curl_opts=(--silent --show-error --location --max-time 20 --retry 3 --retry-delay 5 --user-agent "$user_agent")

sitemap=$(curl "${curl_opts[@]}" --fail "$site/sitemap.xml")
mapfile -t urls < <(grep -oE '<loc>[^<]+</loc>' <<<"$sitemap" | sed -E 's#</?loc>##g')
urls+=("$@")

if [ "${#urls[@]}" -eq 0 ]; then
  echo "FAIL: $site/sitemap.xml lists no pages"
  exit 1
fi

failed=0
summary="| Status | URL |\n| --- | --- |\n"
for url in "${urls[@]}"; do
  code=$(curl "${curl_opts[@]}" --output /dev/null --write-out '%{http_code}' "$url" || true)
  code="${code:-000}"
  if [ "$code" = "200" ]; then
    echo "OK   $code  $url"
    summary+="| ✅ $code | $url |\n"
  else
    echo "FAIL $code  $url"
    summary+="| ❌ $code | $url |\n"
    failed=$((failed + 1))
  fi
done

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  printf '### Site health: %s of %s pages OK\n\n%b' "$((${#urls[@]} - failed))" "${#urls[@]}" "$summary" >>"$GITHUB_STEP_SUMMARY"
fi

echo "${#urls[@]} checked, $failed failed"
[ "$failed" -eq 0 ]
