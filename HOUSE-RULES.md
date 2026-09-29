# House Rules

Rules for AI coding agents. They apply to every project; if the repo has its own
convention, the repo wins.

## 1. Before writing

1.1 Search for what already exists, by name and by behavior (grep, LSP, tests). If
    something similar exists, extend it; if you still create something new, explain in
    one line why the existing one didn't fit.

1.2 Follow the repo's patterns (structure, naming, error handling) even if you prefer
    others. If one looks wrong to you, propose a change separately.
    Why: two styles living side by side is worse than one imperfect style.

1.3 Before adding a dependency, check whether the standard library or something already
    installed solves it. If you still need it, say so.
    Why: every dependency is maintenance and attack surface.

## 2. Scope

2.1 Change only what was asked (including its tests). If you see another problem, point it
    out; don't fix it without approval.

2.2 Don't generalize for hypothetical cases. Abstract when there is a genuinely shared rule
    or piece of knowledge, not because two blocks of code look alike.

2.3 Don't leave dead code, commented-out code, or TODOs without context.

## 3. Errors

3.1 Validate external data at every boundary (user input, APIs, files, environment
    variables) and fail early. Inside, trust validated values; revalidate only on a
    concrete risk of bypass or of the data changing. Permission and invariant checks
    always stay.

3.2 Translate errors into user-facing messages in one place (entrypoint, handler, main),
    without exposing internal details.

3.3 Never swallow an error: no empty catch, no silent fallback to a default value. If the
    fallback is intentional, comment why.

3.4 Either resolve an error or propagate it with its cause, adding context (what was being
    attempted) without secrets or personal data. Cleaning up resources or adding context
    is not resolving it. Log the failure once, where it is resolved.
    Why: logging and rethrowing at every layer makes the same error show up several times
    in the logs.

## 4. Logs

4.1 Configure logging in one place (child loggers, e.g. per request, are fine); no stray
    print/console calls for diagnostics. In a CLI, results go to stdout; logs, errors and
    progress go to stderr.

4.2 Log structured events with chosen fields, not whole requests or objects. Never log
    secrets or personal data, even if a skill shows them in an example.

4.3 Levels: error (an operation failed and was not recovered; someone may need to act),
    warn (degraded but handled), info (significant business event) and debug (diagnostic
    detail, off by default in production). In services, one wide event per request per
    service; extra events only when needed for diagnosis or audit.
    If an installed skill says otherwise on levels or granularity, these rules win.

## 5. Configuration and secrets

5.1 Read and validate configuration in one place and pass validated values to the rest of
    the code. Services validate what they need to serve at startup, and optional parts
    when enabled. If something required is missing, fail before the operation that needs
    it, not halfway through.

5.2 No secrets in code or in commits.

## 6. Tests

6.1 Test observable behavior, not internal details.

6.2 Never weaken a test to make it pass (deleting it, skipping it, loosening the assert).
    If the test is wrong or became outdated because of a requested change, explain why
    before changing it.

## 7. Comments

7.1 A comment explains why, not what. If you need to explain what the code does, improve
    the names.
