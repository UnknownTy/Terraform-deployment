resource "aws_s3_bucket" "social_stuff" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "social_bucket_access" {
  bucket = aws_s3_bucket.social_stuff.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}