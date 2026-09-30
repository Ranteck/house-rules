## installer-symlinks-and-docs

### Quality gate
- mode: check-only
- command: sh -n install.sh
- cwd: /home/denis/Proyectos/house-rules
- provenance: no CI, contributing docs or aggregator in the repo; bare POSIX syntax check proposed by Claude and confirmed by the user through plan approval (2026-09-30)
- resolution: user-confirmed
- definition sources: install.sh; repository tree at 67e815b (no .github/, Makefile, package.json or CONTRIBUTING.md)

### Critique assurance
- mode: standard
- resolution: user-declined-trigger
- trigger matches: overwrite-user-data; changes-installer-behavior
- trigger evidence: install.sh:17 replaces $dir/HOUSE-RULES.md with mv; install.sh:21-22 appends to the user's CLAUDE.md; this feature changes when those writes happen
- lens count: 1
- lens set: standard
- exit challenger: disabled
- CRITIQUE pass cap: 3
- Codex review/debate call budget: not-applicable (standard)

### Backend
- backend: codex
- resolution: default-codex
- resolved session: not-applicable
- disclosure: not-applicable

### Checkpoint commits
- authorized: yes (local commits on fix/installer-symlinks-docs only; no push, no history rewrite)
- basis: no commit.gpgsign, no active hooks, default hooksPath, branch checked out (not detached)

### Feature contract

#### Current state

Scope: fix install.sh's handling of existing targets and correct README.md claims, in the house-rules repository. HOUSE-RULES.md must not change. Keep every change minimal and in the existing style.

**A. install.sh** (POSIX sh; keep the `main()` wrapper, `set -eu`, `CLAUDE_CONFIG_DIR` support and existing messages)

1. Before downloading, if `$dir/HOUSE-RULES.md` is a symlink (test `-L` first, because `-e` is false for a dangling link):
   - if it resolves to a readable regular file: do not download and do not replace it; print a notice that the symlink was left as is and that its target must be updated instead; continue to the existing import step so `@HOUSE-RULES.md` is still ensured in `CLAUDE.md`.
   - otherwise (dangling, or resolving to a directory or other non-regular file): print an error to stderr and exit 1 before touching `CLAUDE.md`.
2. If `$dir/HOUSE-RULES.md` is a directory that is not a symlink: print an error to stderr and exit 1 before downloading.
3. Immediately before the download, remove any existing `$dir/HOUSE-RULES.md.tmp` with `rm -f` (a stale regular file or symlink from an earlier run must never be written through). After the download starts, any failure (curl error or the existing first-line check) must leave no `HOUSE-RULES.md.tmp` behind and must not change `HOUSE-RULES.md` or `CLAUDE.md`.
4. Write the checks so they behave correctly under `set -e` (use if/then, not bare tests that abort the script).
5. Out of scope, unchanged: the download URL, the first-line validation, the import line format, and the final success message for the normal path.

**B. README.md**

1. Skills table (addyosmani `observability-and-instrumentation` and `security-and-hardening`): add a short note that these skills link checklists stored outside their own folder in the upstream repository; the tested `npx skills add` install of `security-and-hardening` does not include its checklist, and `observability-and-instrumentation` uses the same layout but was not install-tested; the inline guidance is present, but checklist-dependent steps may be unavailable. Do not claim the skill fully works.
2. Install description, Update section and "Your own rules" section: state that rerunning the installer replaces installer-managed copies, while an existing `HOUSE-RULES.md` symlink is preserved and its target has to be updated separately.
3. Uninstall section: add that if `CLAUDE.md` is a symlink, the import line should be removed in the file it points to, because `sed -i` replaces the link with a regular file.
4. Add a short Codex section: Codex does not expand `@` imports, so copy the contents of `HOUSE-RULES.md` into `~/.codex/AGENTS.md` inside a marked block, keeping the file's existing content; replace that block manually on every update; the installer does not manage Codex. Adjust the introduction's "for Claude Code" wording minimally so it no longer implies Claude Code only.
5. Plugin sections (the official-marketplace table and the Trail of Bits section): state that the `/plugin` install commands are for Claude Code (do not say the instructions are unusable elsewhere). For mutation-testing, state that running mutation campaigns requires `mewt` or `muton` installed separately and available on PATH.

**C. docs/design.md** (ignored by git)

1. Change only the status line (line 4, currently `Status: implemented (local, not pushed)`) to `Status: Historical design proposal; superseded by README.md and install.sh.` Leave the rest of the file untouched.

**Acceptance criteria** (checked by Claude in VERIFY with a temporary copy of install.sh whose URL points to a local file, run with `CLAUDE_CONFIG_DIR` in temporary directories):

1. Empty profile: creates `HOUSE-RULES.md` and a `CLAUDE.md` containing `@HOUSE-RULES.md`.
2. Rerun: replaces the copy and does not duplicate the import line.
3. Symlink to a readable regular file: the symlink stays intact (same target) and the import is added if missing.
4. Dangling symlink, and a directory at `HOUSE-RULES.md`: exit 1 and `CLAUDE.md` unchanged.
5. Invalid download (first line differs): exit 1, `HOUSE-RULES.md` and `CLAUDE.md` unchanged, no `.tmp` left.
6. `sh -n install.sh` passes; the README diff covers B1-B5 and nothing else; docs/design.md differs only in its status line.

#### Round log

##### IMPL-r00

- **Actors/backend**: orchestrator Claude (contract, gate, commits); writer Codex via codex:codex-rescue with --write and cwd /home/denis/Proyectos/house-rules; backend codex
- **CRITIQUE outcome**: not applicable
- **DEBATE classifications**: not applicable
- **Resulting writer work**: install.sh: symlink and directory guards before download, .tmp cleanup on failure; README.md: B1-B5; docs/design.md: status line only (ignored by git, so not part of this commit)
- **Checkpoint**: locate-by-feature-and-round
- **Decision notes**: contract derived from the 2026-09-30 review-only pass and the user-approved plan; docs/design.md verified against a pre-cycle copy kept outside the repository

##### REFACTOR-r01

- **Actors/backend**: reviewer Codex (fresh read-only CRITIQUE); writer Codex; orchestrator Claude; backend codex
- **CRITIQUE outcome**: 3 P2 findings on install.sh failure paths; README B1-B5 and docs/design.md judged in scope
- **DEBATE classifications**: valid (downgraded to P3): stale HOUSE-RULES.md.tmp symlink written through by curl -o; false positive: no cleanup on SIGTERM or failed mv (outside A3, only a stray never-loaded file, removed by the accepted fix on the next run); false positive: destination changed by another process mid-install (requires concurrent mutation of the user's own config dir; no portable POSIX atomic alternative)
- **Resulting writer work**: install.sh: `rm -f "$dir/HOUSE-RULES.md.tmp"` before the download; contract A3 updated to require it
- **Checkpoint**: locate-by-feature-and-round
- **Decision notes**: the resumed `--resume-last --write` attempt was rejected by the read-only sandbox; snapshots proved no partial write, so a fresh write session was used with an inline continuity summary

##### CRITIQUE-r02-noop

- **Actors/backend**: reviewer Codex (resumed read-only CRITIQUE with inline continuity summary); orchestrator Claude; backend codex
- **CRITIQUE outcome**: no remaining P1/P2/P3 findings at f769b9e
- **DEBATE classifications**: none to classify; prior false-positive rulings stand (no new evidence)
- **Resulting writer work**: none
- **Checkpoint**: none
- **Decision notes**: VERIFY passed: 13/13 installer cases under sh, bash --posix and zsh in sh emulation (dash, busybox and macOS sh unavailable locally); README diff covers B1-B5 only; docs/design.md differs from its pre-cycle copy only in the status line; HOUSE-RULES.md unchanged
