# Stage 1: install dependencies into a virtual environment
FROM python:3.12-slim AS builder
COPY requirements.txt .
RUN python -m venv /venv \
    && /venv/bin/pip install --no-cache-dir -r requirements.txt \
    && /venv/bin/pip uninstall -y pip

# Stage 2: small runtime image with no pip and no build tools
FROM python:3.12-slim

# Latest Debian security fixes, then remove pip, which the app never needs at runtime
RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/* \
    && python -m pip uninstall -y pip

COPY --from=builder /venv /venv
# HOME on /tmp so gunicorn can write its runtime files on a read-only root filesystem
ENV PATH="/venv/bin:$PATH" \
    HOME=/tmp

WORKDIR /app
COPY app.py .

# Numeric non-root user, so Kubernetes can verify runAsNonRoot
RUN useradd --uid 10001 --no-create-home appuser
USER 10001

EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
