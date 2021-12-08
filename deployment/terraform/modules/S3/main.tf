// Creates a bucket with the given name.
// Force_destroy is enabled to allow terraform to easily break it down. Keep it disabled to ensure data will be kept.
resource "aws_s3_bucket" "social_stuff" {
  bucket        = var.bucket_name
  force_destroy = true
}

// Disables public access to the S3 bucket, ensuring only the EC2 instances can access images
resource "aws_s3_bucket_public_access_block" "social_bucket_access" {
  bucket = aws_s3_bucket.social_stuff.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}