# Complete CI/CD & DevSecOps Homework

## Demo Project: Secure API Pipeline

DevSecOps puts security checks into the same pipeline as build and test, so a security problem stops a release the way a failing test does. The app is a small Flask API in `app/`, and the pipeline is `.github/workflows/session-17-devsecops.yml`.

## Pipeline Flow

Tests run first, then SAST, SCA and secret scanning in parallel, then the image build and scan. Push and deploy only run after the security gate.

```text
Code -> Build -> Unit Test -> SAST -> SCA -> Secret Scan -> Docker Build
     -> Container Image Scan -> Security Gate -> Push Image -> Deploy to Kubernetes
```

## Security Tools Explained

**SAST (Bandit).** Reads our own source code for insecure patterns. Fails on medium or high severity.

**SCA (pip-audit).** Checks third-party dependencies against vulnerability databases. Fails on any known vulnerability.

**Secret scanning (Gitleaks).** Looks for committed keys, tokens and passwords.

**Container image scanning (Trivy).** Scans the OS and Python packages in the final image. Fails on fixable HIGH or CRITICAL CVEs.

**Security gate.** One job that needs every scan to pass. Push and deploy depend on it.

## Kubernetes Hardening

The pod runs as non-root user 10001 with a read-only root filesystem, no privilege escalation, all capabilities dropped, the default seccomp profile, no service account token, and resource limits with probes.

## Local Checks Before Pushing

```bash
cd app
python3 -m venv .venv && source .venv/bin/activate
pip install -q -r requirements-dev.txt
flake8 . && pytest -v
bandit -r . -x ./tests,./.venv --severity-level medium
pip-audit -r requirements.txt
```

Lint and tests passed, Bandit found no issues, and pip-audit found no known vulnerabilities.

![](image1.png)

## Successful Pipeline Execution

All 8 jobs green in 3m 44s.

![](image2.png)

Security gate summary, with every check passed.

![](image3.png)

Trivy found no fixable HIGH or CRITICAL vulnerabilities.

![](image4.png)

`Verify` step: the rollout finished and curl got answers from `/` and `/health`.

![](image5.png)

## Proving the Gate Blocks Bad Code

A pull request pinning `flask==3.1.2` failed the SCA job, and the later jobs were skipped.

![](image6.png)
