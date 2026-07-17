#!/usr/bin/env python3
"""
context-router.py — UserPromptSubmit hook.

Reads the user prompt from stdin, matches against the keyword map at
~/.claude/hooks/context-router-map.json, and injects matching .context/*.md
or personal-context files as additionalContext.

Routing rules:
- "always" entries: triggered regardless of cwd. Used for personal-context
  files that are relevant from any project.
- "cwd_scoped" entries: only triggered when cwd is inside the named scope
  (e.g., ~/Desktop/project-alpha/ for the in-repo Project Alpha .context/ tree).

Matching: case-insensitive, word-boundary-aware regex against each trigger.
Multi-word triggers ("project alpha") match contiguous whitespace-separated tokens.

Budget: total injected context capped at total_budget_bytes (default 20KB);
each file individually capped at per_file_max_bytes (default 8KB).
When budget is tight, files with more keyword matches win.

Fail-safe: ANY error path → exit 0 with no output. Never blocks the prompt.
"""

import json
import os
import re
import sys
from pathlib import Path

MAP_PATH = Path.home() / ".claude" / "hooks" / "context-router-map.json"
DEFAULT_BUDGET = 20480
DEFAULT_PER_FILE = 8192


def expand(p):
    return Path(os.path.expanduser(p)).resolve()


def trigger_to_regex(trigger):
    # Escape, then unescape spaces back to whitespace match, then add word boundaries.
    escaped = re.escape(trigger)
    # re.escape turns ' ' into '\\ '; relax that to allow runs of whitespace.
    escaped = escaped.replace(r"\ ", r"\s+")
    return re.compile(r"\b" + escaped + r"\b", re.IGNORECASE)


def main():
    try:
        raw = sys.stdin.read()
        if not raw.strip():
            return
        try:
            payload = json.loads(raw)
        except json.JSONDecodeError:
            return
        prompt = (payload.get("prompt") or "").strip()
        if not prompt:
            return

        if not MAP_PATH.exists():
            return
        try:
            cfg = json.loads(MAP_PATH.read_text())
        except json.JSONDecodeError:
            return

        budget = cfg.get("config", {}).get("total_budget_bytes", DEFAULT_BUDGET)
        per_file = cfg.get("config", {}).get("per_file_max_bytes", DEFAULT_PER_FILE)

        cwd_raw = os.environ.get("CLAUDE_PROJECT_DIR") or os.environ.get("PWD") or os.getcwd()
        cwd = Path(cwd_raw).resolve()

        candidates = []
        for e in cfg.get("always", []):
            candidates.append((e["file"], e["triggers"]))

        for scope in cfg.get("cwd_scoped", []):
            scope_root = expand(scope["scope"])
            try:
                cwd.relative_to(scope_root)
                in_scope = True
            except ValueError:
                in_scope = False
            if in_scope:
                for e in scope["entries"]:
                    candidates.append((e["file"], e["triggers"]))

        matched = []
        for file_path, triggers in candidates:
            count = 0
            hit_triggers = []
            for t in triggers:
                pat = trigger_to_regex(t)
                if pat.search(prompt):
                    count += 1
                    hit_triggers.append(t)
            if count > 0:
                matched.append((count, file_path, hit_triggers))

        if not matched:
            return

        # Most matches first, ties broken by file path for determinism
        matched.sort(key=lambda x: (-x[0], x[1]))

        chunks = []
        total = 0
        loaded = []
        skipped_for_budget = []
        for count, fp, hits in matched:
            path = expand(fp)
            if not path.is_file():
                continue
            try:
                content = path.read_text()
            except Exception:
                continue
            content_bytes = content.encode("utf-8")
            if len(content_bytes) > per_file:
                content = content_bytes[:per_file].decode("utf-8", errors="ignore")
                content += "\n\n[...truncated by context-router per_file_max_bytes cap]"
                content_bytes = content.encode("utf-8")
            size = len(content_bytes)
            if total + size > budget:
                skipped_for_budget.append(fp)
                continue
            hits_str = ", ".join(repr(h) for h in hits)
            chunks.append(
                f"═══ ROUTED CONTEXT — {fp} (matched on {hits_str}) ═══\n\n{content}"
            )
            total += size
            loaded.append(fp)

        if not chunks:
            return

        header = (
            "CONTEXT-ROUTER (UserPromptSubmit hook): auto-loaded "
            f"{len(loaded)} file(s) based on keyword match in your prompt. "
            "These supplement the always-loaded SessionStart context. Read before answering."
        )
        if skipped_for_budget:
            header += (
                f" Skipped due to {budget}-byte budget: "
                + ", ".join(skipped_for_budget)
                + "."
            )

        ctx = header + "\n\n" + "\n\n".join(chunks)

        out = {
            "hookSpecificOutput": {
                "hookEventName": "UserPromptSubmit",
                "additionalContext": ctx,
            }
        }
        print(json.dumps(out))

    except Exception:
        return


if __name__ == "__main__":
    main()
