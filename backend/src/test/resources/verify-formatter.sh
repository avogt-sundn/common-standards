#!/usr/bin/env bash
# Proves that `./mvnw formatter:format` correctly formats FormatterShowcaseUnformatted.java.
#
# Two assertions:
#   1. The formatter CHANGES the file (violations were real).
#   2. Running the formatter a second time produces NO further change (output conforms to the profile).
#
# The original source file is never touched: all work happens in a temp directory.
#
# Exit 0 = both assertions passed.
# Exit 1 = a failure; reason is printed to stderr.

set -euo pipefail

# ---------------------------------------------------------------------------
# Locate project root (two levels up from src/test/resources where this
# script lives, regardless of where the caller's working directory is).
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

MVNW="$PROJECT_ROOT/mvnw"
PROFILE_XML="$PROJECT_ROOT/Common-Standards-Eclipse-Code-Profile.xml"
SOURCE_FILE="$PROJECT_ROOT/src/main/java/com/example/formatter/FormatterShowcaseUnformatted.java"

# Validate prerequisites
for f in "$MVNW" "$PROFILE_XML" "$SOURCE_FILE"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: required file not found: $f" >&2
    exit 1
  fi
done

# ---------------------------------------------------------------------------
# Set up a throw-away Maven project in a temp directory.
# ---------------------------------------------------------------------------
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

JAVA_SRC_DIR="$WORK_DIR/src/main/java/com/example/formatter"
mkdir -p "$JAVA_SRC_DIR"

cp "$SOURCE_FILE" "$JAVA_SRC_DIR/FormatterShowcaseUnformatted.java"

# Determine the plugin version from the project pom.xml so this script stays in sync.
PLUGIN_VERSION=$(grep -A2 'formatter-maven-plugin' "$PROJECT_ROOT/pom.xml" | grep '<version>' | head -1 | sed 's/.*<version>\(.*\)<\/version>.*/\1/' | tr -d '[:space:]')
if [ -z "$PLUGIN_VERSION" ]; then
  echo "ERROR: could not determine formatter-maven-plugin version from pom.xml" >&2
  exit 1
fi

cat > "$WORK_DIR/pom.xml" << EOF
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example.test</groupId>
  <artifactId>formatter-verify</artifactId>
  <version>1.0</version>
  <build>
    <plugins>
      <plugin>
        <groupId>net.revelc.code.formatter</groupId>
        <artifactId>formatter-maven-plugin</artifactId>
        <version>${PLUGIN_VERSION}</version>
        <configuration>
          <configFile>${PROFILE_XML}</configFile>
          <encoding>UTF-8</encoding>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
EOF

# ---------------------------------------------------------------------------
# Assertion helper
# ---------------------------------------------------------------------------
fail() {
  echo "FAIL: $*" >&2
  exit 1
}

# ---------------------------------------------------------------------------
# Step 1 — record the hash of the unformatted copy.
# ---------------------------------------------------------------------------
COPY="$JAVA_SRC_DIR/FormatterShowcaseUnformatted.java"
HASH_BEFORE=$(md5sum "$COPY" | cut -d' ' -f1)

echo "Running first formatter:format pass..."
"$MVNW" --file "$WORK_DIR/pom.xml" --offline formatter:format -q

HASH_AFTER_1=$(md5sum "$COPY" | cut -d' ' -f1)

# ---------------------------------------------------------------------------
# Assertion 1: the file must have changed (violations were real).
# ---------------------------------------------------------------------------
if [ "$HASH_BEFORE" = "$HASH_AFTER_1" ]; then
  fail "formatter:format did not change FormatterShowcaseUnformatted.java — no violations were detected"
fi
echo "PASS (1/2): formatter:format changed the file — violations were detected and fixed"

# ---------------------------------------------------------------------------
# Step 2 — run the formatter a second time.
# ---------------------------------------------------------------------------
echo "Running second formatter:format pass (idempotency check)..."
"$MVNW" --file "$WORK_DIR/pom.xml" --offline formatter:format -q

HASH_AFTER_2=$(md5sum "$COPY" | cut -d' ' -f1)

# ---------------------------------------------------------------------------
# Assertion 2: the file must NOT change again (output conforms to the profile).
# ---------------------------------------------------------------------------
if [ "$HASH_AFTER_1" != "$HASH_AFTER_2" ]; then
  fail "formatting is not idempotent — the second pass changed the file, meaning pass 1 produced non-conforming output"
fi
echo "PASS (2/2): second pass made no changes — output conforms to the profile"

echo "OK: FormatterShowcaseUnformatted.java is correctly formatted by ./mvnw formatter:format"

# Confirm the original file was never touched.
HASH_ORIGINAL=$(md5sum "$SOURCE_FILE" | cut -d' ' -f1)
if [ "$HASH_ORIGINAL" != "$HASH_BEFORE" ]; then
  fail "original source file was modified — this should never happen"
fi
echo "OK: original FormatterShowcaseUnformatted.java was not modified"
