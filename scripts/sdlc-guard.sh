#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="${1:-projects/gitlab-ai-hackathon-2026}"
RUN_TESTS="${RUN_TESTS:-1}"

if [[ "$PROJECT" != /* ]]; then
  PROJECT="$ROOT/$PROJECT"
fi

pass=0
fail=0
warn=0

ok() { echo "  ✅ $1"; pass=$((pass+1)); }
ng() { echo "  ❌ $1"; fail=$((fail+1)); }
wn() { echo "  ⚠️  $1"; warn=$((warn+1)); }

req_file() {
  local p="$1"; local label="$2"
  if [[ -f "$p" ]]; then ok "$label"; else ng "$label (missing: $p)"; fi
}

req_dir() {
  local p="$1"; local label="$2"
  if [[ -d "$p" ]]; then ok "$label"; else ng "$label (missing: $p)"; fi
}

echo
printf '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
printf '  SDLC Guard\n'
printf '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
echo "Project: $PROJECT"

if [[ ! -d "$PROJECT" ]]; then
  ng "Project directory not found"
  echo
  echo "Results: ✅ $pass  ❌ $fail  ⚠️  $warn"
  exit 2
fi

echo
echo "[1/7] Communication & Scope"
req_file "$PROJECT/MISSION.md" "MISSION.md present"
req_file "$PROJECT/AGENT-TASKS.md" "AGENT-TASKS.md present"

echo
echo "[2/7] Planning"
req_file "$PROJECT/PLAN.md" "PLAN.md present"
req_file "$PROJECT/CHECKLIST.md" "CHECKLIST.md present"
req_file "$PROJECT/deliverables/TECH-SPEC.md" "TECH-SPEC.md present"
req_file "$PROJECT/deliverables/IMPLEMENTATION-PLAN.md" "IMPLEMENTATION-PLAN.md present"

echo
echo "[3/7] Implementation"
req_dir "$PROJECT/mvp" "mvp directory present"
if [[ -d "$PROJECT/mvp" ]]; then
  if find "$PROJECT/mvp" -type f \( -name '*.py' -o -name '*.js' -o -name '*.ts' \) | grep -q .; then
    ok "runtime source files detected"
  else
    ng "runtime source files missing"
  fi
fi

echo
echo "[4/7] Verification"
if [[ -d "$PROJECT/mvp/tests" || -d "$PROJECT/mvp/tests_py" ]]; then
  ok "test directories present"
else
  ng "test directories missing"
fi

if [[ "$RUN_TESTS" == "1" ]]; then
  if [[ -f "$PROJECT/mvp/package.json" ]]; then
    if (cd "$PROJECT/mvp" && npm test --silent >/tmp/sdlc-guard-node.log 2>&1); then
      ok "npm test passed"
    else
      ng "npm test failed (see /tmp/sdlc-guard-node.log)"
    fi
  else
    wn "package.json missing; skipped Node tests"
  fi

  if [[ -d "$PROJECT/mvp/tests_py" ]]; then
    if (cd "$PROJECT/mvp" && python3 -m unittest discover -s tests_py -p 'test_*.py' -q >/tmp/sdlc-guard-py.log 2>&1); then
      ok "python unit tests passed"
    else
      ng "python unit tests failed (see /tmp/sdlc-guard-py.log)"
    fi
  fi
fi

echo
echo "[5/7] Security"
req_file "$PROJECT/SECURITY_RULES.md" "project SECURITY_RULES.md present"
if [[ -f "$PROJECT/mvp/SECURITY_RULES.md" ]]; then
  ok "mvp SECURITY_RULES.md present"
else
  wn "mvp SECURITY_RULES.md missing"
fi

echo
echo "[6/7] Deployment"
if [[ -f "$PROJECT/deploy.sh" || -f "$PROJECT/cloudbuild.yaml" || -f "$PROJECT/terraform/main.tf" ]]; then
  ok "deployment path detected (deploy.sh or cloudbuild or terraform)"
else
  ng "deployment path missing"
fi

echo
echo "[7/7] Submission Packaging"
req_file "$PROJECT/deliverables/SUBMISSION-NARRATIVE.md" "submission narrative present"
if [[ -f "$PROJECT/CHECKLIST.md" ]]; then
  open_items="$(rg -n "^- \[ \]" "$PROJECT/CHECKLIST.md" | wc -l | tr -d ' ')"
  if [[ "$open_items" == "0" ]]; then
    ok "checklist has no open items"
  else
    wn "checklist has $open_items open item(s)"
  fi
fi

echo
printf '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
printf 'Results: ✅ %s passed  ❌ %s failed  ⚠️  %s warnings\n' "$pass" "$fail" "$warn"
printf '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'

echo
if [[ "$fail" -gt 0 ]]; then
  exit 1
fi
