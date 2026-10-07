#!/bin/bash
# Runs once as root on first boot
dnf install -y nginx
cat > /usr/share/nginx/html/index.html <<HTML
<h1>${project_name}</h1>
<p>Served by nginx on EC2, inside a VPC built by Terraform.</p>
<p>Companion S3 bucket: ${bucket_name}</p>
HTML
systemctl enable --now nginx
