# Latest Amazon Linux 2023 AMI, looked up from AWS's public SSM parameter
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.al2023.insecure_value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = templatefile("${path.module}/user_data.sh", {
    project_name = var.project_name
    bucket_name  = aws_s3_bucket.assets.bucket
  })
  user_data_replace_on_change = true

  # Require IMDSv2 (session tokens) for the instance metadata service
  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  # Explicit dependency: the bootstrap script needs internet access to install nginx,
  # and nothing in this block references the route table, so Terraform cannot infer it
  depends_on = [aws_route_table_association.public]

  tags = { Name = "${var.project_name}-web" }
}
