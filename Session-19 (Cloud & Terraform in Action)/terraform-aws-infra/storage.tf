resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "assets" {
  bucket        = "${var.project_name}-assets-${random_id.suffix.hex}"
  force_destroy = true

  tags = { Name = "${var.project_name}-assets" }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "architecture" {
  bucket       = aws_s3_bucket.assets.id
  key          = "notes/architecture.txt"
  content      = "VPC -> public subnet -> EC2 (nginx), plus this S3 bucket. Managed by Terraform.\n"
  content_type = "text/plain"
}
