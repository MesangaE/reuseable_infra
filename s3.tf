# ---s3/module/main.tf---


data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "primusl_backend"{
  bucket = var.bucket_name
  
  # Lifecycle rules
 
  tags = {
    Name        = var.bucket_name
    Environment = var.Environment
  }
}
# Bucket versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.primusl_backend.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}


# Bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.primusl_backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# Enable public access block for S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.primusl_backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy to allow load balancer access
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.primusl_backend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "s3/*"
        Resource = [
          "${aws_s3_bucket.primusl_backend.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}",
          "${aws_s3_bucket.primusl_backend.arn}/*"
        ]
      }
    ]
  })
}

