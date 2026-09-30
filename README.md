# House-Rules

**House rules for AI coding agents. Stop the vibe-coding mess.**

A short, opinionated, language-agnostic set of coding rules for AI coding agents:
search before writing, stay in scope, never swallow errors, log once and
structured, validate config up front, never weaken a test to make it pass.
See [`HOUSE-RULES.md`](HOUSE-RULES.md).

## Why an import and not a skill

A skill is loaded only when the model decides the task matches its
description, so rules shipped as a skill get skipped exactly when you need
them. house-rules is imported from your `CLAUDE.md`, the same way
[rtk](https://github.com/rtk-ai/rtk) adds `@RTK.md`, so it is in context in
every session.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/Ranteck/house-rules/main/install.sh | sh
```

[`install.sh`](install.sh) downloads `HOUSE-RULES.md` into `~/.claude` and adds
the line `@HOUSE-RULES.md` to your `~/.claude/CLAUDE.md` if it is missing, so
it is safe to run more than once. Rerunning replaces installer-managed copies;
an existing `HOUSE-RULES.md` symlink is preserved, and its target must be
updated separately. Start a new Claude Code session afterwards.

**Several profiles?** The script honors `CLAUDE_CONFIG_DIR`. Run it once per
profile, setting the variable for `sh`:

```bash
curl -fsSL https://raw.githubusercontent.com/Ranteck/house-rules/main/install.sh | CLAUDE_CONFIG_DIR=/path/to/profile sh
```

Or paste this into Claude Code:

```text
Install house-rules by running: curl -fsSL https://raw.githubusercontent.com/Ranteck/house-rules/main/install.sh | sh
```

## Update

Rerun the install command to replace installer-managed copies. An existing
`HOUSE-RULES.md` symlink is preserved; update its target separately.

## Uninstall

```bash
DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
sed -i.bak '/^@HOUSE-RULES\.md$/d' "$DIR/CLAUDE.md" && rm "$DIR/HOUSE-RULES.md"
```

This leaves a `CLAUDE.md.bak` backup next to your `CLAUDE.md`.

If `CLAUDE.md` is a symlink, remove the import line in the file it points to
instead: `sed -i` replaces the link with a regular file.

## Codex

Codex does not expand `@` imports. Copy the contents of `HOUSE-RULES.md`
into `~/.codex/AGENTS.md` inside a marked block, keeping the file's existing
content:

```markdown
<!-- house-rules:start -->
Paste the contents of HOUSE-RULES.md here.
<!-- house-rules:end -->
```

Replace that block manually on every update. The installer does not manage
Codex.

## Your own rules

Installer-managed copies of `HOUSE-RULES.md` are replaced on every update,
so don't edit them. An existing symlink is preserved; update its target
separately. Keep your own additions in your `CLAUDE.md`. When you correct an
agent for the same thing twice, that correction is a rule worth writing down
there.

Rules are numbered, so you can tell an agent "you broke 3.4" without
explaining it again.

## Recommended skills and plugins

These complement house-rules: it sets the always-on minimum, they carry the
detail when a task needs it.

### Process and security (official marketplace)

The `/plugin install` commands below are for Claude Code.

| Plugin | What it adds | Install |
| --- | --- | --- |
| superpowers | Working process: TDD, systematic debugging, verify before claiming done, code review | `/plugin install superpowers@claude-plugins-official` |
| security-guidance | Security review of Claude-written code: pattern warnings on edits, diff review on Stop, commit reviewer (injection, XSS, SSRF, hardcoded secrets…) | `/plugin install security-guidance@claude-plugins-official` |

### Skills

| Skill | What it adds | Install |
| --- | --- | --- |
| pragmatic-programmer | Design principles: DRY as knowledge, orthogonality, design by contract | `npx skills add wondelai/skills@pragmatic-programmer -g` |
| logging-best-practices | Wide events / canonical log lines | `npx skills add boristane/agent-skills@logging-best-practices -g` |
| observability-and-instrumentation | Log levels, correlation IDs, metrics, tracing, alerting | `npx skills add addyosmani/agent-skills@observability-and-instrumentation -g` |
| security-and-hardening | OWASP-oriented hardening, secrets, supply chain | `npx skills add addyosmani/agent-skills@security-and-hardening -g` |

The two addyosmani skills link checklists stored outside their own folders
in the upstream repository. The tested `npx skills add` installation of
`security-and-hardening` does not include its checklist.
`observability-and-instrumentation` uses the same layout but was not
install-tested. Their inline guidance is present, but checklist-dependent
steps may be unavailable.

### Plugins (Trail of Bits)

These `/plugin install` commands are for Claude Code. Add the marketplace
once:

```
/plugin marketplace add trailofbits/skills
```

| Plugin | What it adds | Install |
| --- | --- | --- |
| insecure-defaults | Detects hardcoded credentials, fallback secrets, weak auth defaults, dangerous production values | `/plugin install insecure-defaults@trailofbits` |
| supply-chain-risk-auditor | Audits npm, PyPI and Go dependencies: advisories, abandoned upstreams, install scripts | `/plugin install supply-chain-risk-auditor@trailofbits` |
| property-based-testing | Write, review and triage property-based tests (Hypothesis, fast-check, proptest…) | `/plugin install property-based-testing@trailofbits` |
| mutation-testing | Mutation testing campaigns and analysis of surviving mutants | `/plugin install mutation-testing@trailofbits` |

Running mutation campaigns requires `mewt` or `muton` installed separately
and available on `PATH`.

On logging, house-rules wins where these disagree: `logging-best-practices`
allows only `info` and `error` and logs `user.email` in one of its "correct"
examples; rules 4.2 and 4.3 say so explicitly and override both.

## License

[MIT](LICENSE)
