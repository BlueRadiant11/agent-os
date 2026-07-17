---
name: Permissions — deny list
description: Flat-blocked entries. No override possible without editing settings.json directly.
type: registry
canonical: false
owner: chief-of-staff
last_verified: 2026-05-02
---

# Deny (flat-blocked)

| Category | Entries |
| --- | --- |
| Filesystem catastrophe | `rm -rf /`, `rm -rf ~`, `rm -rf ~/` |
| Privilege escalation | `sudo` |
| Pipe-to-shell | `curl/wget * | sh` or `| bash` |
| Force-push to canon | `git push --force` to `main` or `master` |
| Public publish | `npm publish` |
