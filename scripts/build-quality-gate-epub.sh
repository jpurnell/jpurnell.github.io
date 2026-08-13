#!/bin/bash
# Rebuild "The Gate and the Mirror" from Content/QualityGate/.
#
# The chapter order lives here, in one list, because the alternative is what we had:
# a prose description in a session summary that nobody re-reads, and an epub that
# silently fell seven chapters behind the site.
#
# Output goes to Assets/epub/, which Ignite copies to docs/epub/ on `swift run`.
# Do not write into docs/ directly — that copy is overwritten on every build.

set -euo pipefail
cd "$(dirname "$0")/.."

CONTENT="Content/QualityGate"
OUT="Assets/epub/The-Gate-and-the-Mirror.epub"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

BOOK="$WORK/QualityGate-Complete.md"

# Strip YAML frontmatter, emit body.
chapter() {
    local path="$CONTENT/$1.md"
    if [ ! -f "$path" ]; then
        echo "missing chapter: $path" >&2
        exit 1
    fi
    awk 'BEGIN { fm = 0 }
         NR == 1 && $0 == "---" { fm = 1; next }
         fm == 1 && $0 == "---" { fm = 2; next }
         fm != 1 { print }' "$path"
    printf '\n\n'
}

part() { printf '\n# %s\n\n' "$1" >> "$BOOK"; }

cat "$CONTENT/metadata.yaml" > "$BOOK"
printf '\n' >> "$BOOK"

chapter intro >> "$BOOK"

part "Part I — The Gate"
for c in rules-are-not-your-project \
         gate/a-gate-not-a-linter \
         correctness/recursion correctness/concurrency correctness/pointer-escape \
         correctness/fp-safety correctness/memory-lifecycle correctness/unreachable \
         correctness/process-safety correctness/complexity correctness/legibility \
         safety-security/safety safety-security/keychain-secrets \
         safety-security/stochastic-determinism safety-security/temporal-determinism \
         safety-security/hig-auditor \
         hygiene/logging hygiene/test-quality hygiene/context hygiene/accessibility \
         hygiene/idiom hygiene/smells hygiene/duplication \
         gate/documentation-that-cannot-lie \
         documentation/doc-coverage documentation/doc-lint documentation/doc-code \
         documentation/doc-comment-code documentation/doc-run documentation/doc-claims \
         documentation/doc-generated \
         project-health/build project-health/test project-health/status \
         project-health/dependency-audit project-health/release-readiness \
         project-health/swift-version project-health/memory-builder \
         project-health/submodule-audit \
         specialty/mcp-readiness specialty/appintents-readiness specialty/xcode-build \
         specialty/disk-clean specialty/consistency
do chapter "$c" >> "$BOOK"; done

part "Part II — The Mirror"
for c in mirror/the-mirror mirror/the-corpus mirror/the-pulse mirror/policy-discovery \
         mirror/calibration-and-the-workbench mirror/the-trust-service \
         mirror/principles-as-software
do chapter "$c" >> "$BOOK"; done

part "Part III — Compliance"
for c in compliance/coverage-not-a-badge compliance/control-mapping \
         compliance/privacy-manifest compliance/standards-watch \
         compliance/three-frameworks-one-honesty
do chapter "$c" >> "$BOOK"; done

# Every chapter must be in the list above. Silence here would mean the epub
# quietly ships a subset of the site, which is the bug this script exists to prevent.
listed=$(grep -cE '^# ' "$BOOK" || true)
onsite=$(find "$CONTENT" -name '*.md' | wc -l | tr -d ' ')
included=$(( listed - 3 ))   # minus the three part dividers
if [ "$included" -ne "$onsite" ]; then
    echo "chapter count mismatch: epub has $included, $CONTENT has $onsite" >&2
    echo "add the missing chapter to the ordered list in $0" >&2
    exit 1
fi

pandoc "$BOOK" --css "$CONTENT/epub.css" --toc --toc-depth=1 -o "$OUT"
echo "wrote $OUT — $included chapters"
