# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in NotiFlex, please report it responsibly.

**Do NOT open a public GitHub issue for security vulnerabilities.**

Instead, please use [GitHub's private vulnerability reporting](https://github.com/albert-mr/notiflex/security/advisories/new) to submit your report.

You can expect:
- Acknowledgment within 48 hours
- A fix or mitigation plan within 7 days for critical issues
- Credit in the release notes (unless you prefer to remain anonymous)

## Scope

- Secrets or credentials accidentally committed
- Authentication or authorization bypasses
- Injection vulnerabilities
- Any issue that could compromise user data or device security

## Out of Scope

- The app generates fake notifications by design — this is intended functionality, not a vulnerability
- Denial of service via local notification flooding (local-only impact)
- Issues in third-party dependencies (report these to the upstream project)
