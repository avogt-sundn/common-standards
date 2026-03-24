#!/usr/bin/env bash
# Manual test driver for bin/sync-standards.sh
#
# Usage: bin/test-sync-standards.sh [1|2|3|4]
#   1 — syntax check
#   2 — dry-run against empty repo (select All)
#   3 — live run against empty repo (interactive)
#   4 — Maven plugin injection test with minimal pom.xml
#   (no arg) — run all non-interactive tests (1 + 2)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC="$SCRIPT_DIR/sync-standards.sh"

RED='\033[0;31m'; GREEN='\033[0;32m'; BOLD='\033[1m'; RESET='\033[0m'

pass() { echo -e "${GREEN}PASS${RESET} $1"; }
fail() { echo -e "${RED}FAIL${RESET} $1"; exit 1; }
header() { echo -e "\n${BOLD}── $1 ────────────────────────────────────${RESET}"; }

# ── Test 1: syntax check ───────────────────────────────────────────────────────
test_syntax() {
  header "1: bash syntax check"
  bash -n "$SYNC" && pass "syntax OK"
}

# ── Test 2: dry-run against empty repo ────────────────────────────────────────
test_dryrun() {
  header "2: dry-run against empty repo (All)"
  local tmp
  tmp=$(mktemp -d)
  git -C "$tmp" init -q
  git -C "$tmp" commit --allow-empty -m "init" -q

  echo "A" | "$SYNC" "$tmp" --dry-run

  # Verify nothing was written
  if [[ -f "$tmp/.editorconfig" ]]; then
    rm -rf "$tmp"
    fail "dry-run wrote files — it should not have"
  fi
  rm -rf "$tmp"
  pass "dry-run wrote no files"
}

# ── Test 3: live run against empty repo (interactive) ─────────────────────────
test_live() {
  header "3: live run against empty repo (interactive)"
  local tmp
  tmp=$(mktemp -d)
  git -C "$tmp" init -q
  git -C "$tmp" commit --allow-empty -m "init" -q

  echo "Target created at: $tmp"
  echo "Run the script interactively:"
  echo "  $SYNC $tmp"
  echo ""
  echo "Then verify with:"
  echo "  ls -la $tmp"
  echo "  ls -la $tmp/.java-config"
  echo "  ls -la $tmp/.idea"
  echo "  ls -la $tmp/.vscode"
  echo "  git -C $tmp log --oneline"
  echo ""
  echo "Temp dir will NOT be cleaned up — remove manually: rm -rf $tmp"
}

# ── Test 4: Maven plugin injection ────────────────────────────────────────────
test_maven() {
  header "4: Maven plugin injection"
  local tmp
  tmp=$(mktemp -d)
  git -C "$tmp" init -q
  git -C "$tmp" commit --allow-empty -m "init" -q

  cat > "$tmp/pom.xml" <<'EOF'
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>test</artifactId>
  <version>1.0</version>
  <build>
    <plugins>
    </plugins>
  </build>
</project>
EOF

  echo "2" | "$SYNC" "$tmp"

  if grep -q "formatter-maven-plugin" "$tmp/pom.xml" && grep -q "impsort-maven-plugin" "$tmp/pom.xml"; then
    pass "Maven plugins injected"
    echo "--- pom.xml result ---"
    cat "$tmp/pom.xml"
  else
    cat "$tmp/pom.xml"
    rm -rf "$tmp"
    fail "Maven plugins not found in pom.xml"
  fi
  rm -rf "$tmp"
}

# ── Dispatch ──────────────────────────────────────────────────────────────────
case "${1:-all}" in
  1) test_syntax ;;
  2) test_dryrun ;;
  3) test_live ;;
  4) test_maven ;;
  all)
    test_syntax
    test_dryrun
    echo -e "\n${GREEN}Non-interactive tests passed.${RESET}"
    echo "Run with argument 3 or 4 for interactive tests."
    ;;
  *) echo "Usage: $(basename "$0") [1|2|3|4]" >&2; exit 1 ;;
esac
