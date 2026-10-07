# CI/CD & GitHub Actions Homework

## Demo Project: Tasks API with a Full CI/CD Pipeline

A small Flask to-do API in `app/` with unit tests and a Dockerfile, Kubernetes manifests in `k8s/`, and a GitHub Actions workflow in `.github/workflows/session-16-cicd.yml` that tests, builds, publishes and deploys it.

## Concepts, mapped to this project

**CI vs CD.** CI builds and tests every push, and CD ships the build that passed. Here `test` and `build` are CI and `deploy` is CD.

**CI/CD pipeline.** The chain from a push to a running deployment: lint, test, build, smoke test, push image, deploy, verify.

**GitHub Actions.** GitHub's built-in service that runs pipelines on events like a push or a pull request.

**Workflow.** One YAML file in `.github/workflows/` that declares the triggers and the jobs.

**Jobs.** Groups of steps on a fresh machine. They run in parallel unless chained with `needs:`.

**Steps.** Single commands (`run:`) or reusable actions (`uses:`) inside a job.

**Runners.** The machines that run jobs. `ubuntu-latest` is a fresh GitHub-hosted VM each time.

**Secrets.** Encrypted values injected at runtime and masked in logs. This pipeline uses `GITHUB_TOKEN` and an optional `APP_GREETING`.

**Artifacts.** Files saved from a job. Here that is the test report and the built image, which the deploy job downloads.

**Build and test.** flake8 for style, pytest for unit tests, `docker build` for the image, and a `/health` smoke test.

**Pipeline execution.** A push to `main` runs the 3 jobs in order, and the deploy job uses a temporary kind cluster inside the runner.

## Running it locally first

```bash
cd app
python3 -m venv .venv && source .venv/bin/activate
pip install -q -r requirements-dev.txt
flake8 .
pytest -v
docker build -t tasks-api:local .
docker run -d --rm --name tasks -p 5000:5000 tasks-api:local
sleep 3
curl -s localhost:5000/health
docker stop tasks
```

Lint clean, 4 tests passed, image built, and `/health` answered `ok`.

![](image1.png)

## Pipeline Execution on GitHub

Pushed to `main`, and all 3 jobs passed in 2m 36s.

![](image2.png)

`Run unit tests` step output, with all 4 tests passing.

![](image3.png)

The `docker-image` and `test-results` artifacts on the run.

![](image4.png)

`Verify the deployment` step: curl got answers from `/` and `/health` on the kind cluster.

![](image5.png)

The image in GitHub Container Registry, tagged `latest` and `2a8bf91`.

![](image6.png)
