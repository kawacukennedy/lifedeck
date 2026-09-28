# Security Policy

## Reporting a Vulnerability

**Please do not open a public GitHub Issue for a security vulnerability.**

LifeDeck handles sensitive data by design — health metrics, financial
integrations (via Plaid), and geolocation context. A public issue would
disclose the flaw to everyone before it is fixed.

### Preferred channel: GitHub Private Vulnerability Reporting

Use **Security → Report a vulnerability** on this repository:

<https://github.com/kawacukennedy/lifedeck/security/advisories/new>

This opens a private, encrypted channel visible only to the maintainer. It is
the only channel that guarantees a report is not publicly visible. No account
on a third-party service is required.

### Fallback channel

If the above is unavailable, email the maintainer at `kawacukent@gmail.com`.
**Please encrypt your message** (PGP preferred) and include:

- Affected file(s) or endpoint(s)
- Steps to reproduce, or a proof of concept
- The impact you believe it has
- Any suggested remediation

## What to expect

| Stage | Target |
|---|---|
| Acknowledgement of receipt | 3 business days |
| Initial assessment (severity + scope) | 10 business days |
| Fix or mitigation plan | 30 business days |
| Public disclosure | Coordinated with the reporter, after a fix ships |

If a report is declined, you will receive an explanation of why. If you
disagree, you are welcome to publish.

## Severity

Reporters do not need to classify severity. For context:

| Severity | Examples |
|---|---|
| **Critical** | Authentication bypass; access to another user's health, financial, or location data; arbitrary premium entitlement; remote code execution |
| **High** | Injection (SQL, command, prompt); secret disclosure; privilege escalation across roles |
| **Medium** | Missing authorization on a single resource; rate-limit bypass; information disclosure that aids exploitation |
| **Low** | Defense-in-depth gaps; missing security headers with no concrete impact; verbose errors without sensitive data |

## Scope

**In scope**

- `backend/` — the NestJS API (authorization, data exposure, input validation)
- `LifeDeck/`, `Core/`, `Services/`, `Models/`, `Views/`, `App/` — the iOS client
  (insecure storage, transport security, entitlement integrity)
- `android/` — the Expo client
- `infrastructure/` — Terraform, Helm, and Kubernetes manifests
- `.github/workflows/` — CI/CD supply chain
- `backend/prisma/schema.prisma` — data model and sensitive-field handling

**Out of scope**

- Findings that require an attacker to already hold administrator access to
  the AWS account or the GitHub repository
- Vulnerabilities in third-party dependencies with no exploitable path through
  LifeDeck code (report those upstream; see below)
- Denial of service through sheer volume against a deployment you do not own
- Missing hardening headers with no demonstrated impact
- Reports generated solely by an automated scanner with no working proof of concept

## Dependency vulnerabilities

Dependency issues should be reported **upstream** to the maintainer of the
affected package. For visibility into LifeDeck's own dependency tree, enable
Dependabot alerts on this repository rather than filing an issue.

## Security posture

At the time of writing, the following controls are in place or in progress.
Items marked **planned** are known gaps, tracked for remediation.

| Control | Status |
|---|---|
| GitHub secret scanning | Enabled |
| Secret scanning push protection | Enabled |
| Private vulnerability reporting | Enabled |
| Branch protection on `main` (PR + review required) | Enabling with this change |
| `CODEOWNERS` review on CI/CD, infrastructure, and schema | Enabling with this change |
| Secrets excluded from version control via `.gitignore` | Enabling with this change |
| Backend input validation (schema-based DTOs) | **Planned** — validation is currently not enforced on any endpoint |
| Backend rate limiting | **Planned** — the throttler module is registered but the guard is not bound |
| Transport security (App Transport Security) in the iOS client | **Planned** — `NSAllowsArbitraryLoads` is currently enabled and needs to be removed |
| Dependency scanning (Dependabot) | **Planned** |
| Static analysis (CodeQL) | **Planned** |
| Remote Terraform state with encryption | **Planned** — state is currently local and unencrypted |

Do not assume a "Planned" control is active. Verify before relying on it.
