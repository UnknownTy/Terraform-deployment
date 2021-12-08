data "aws_iam_policy" "cloudwatch" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_policy" "allow_s3" {
  name        = "allow_s3"
  path        = "/"
  description = "Allow EC2 instances to connect to ${var.bucket_name}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::*/*",
          "arn:aws:s3:::${var.bucket_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ec2_cloud_s3" {
  name = "ec2_cloud_s3_connection"

  # This is a role for EC2 instances
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.allow_s3.arn,
    data.aws_iam_policy.cloudwatch.arn
  ]
}

resource "aws_iam_instance_profile" "cloud_s3_instance_profile" {
  name = "Cloud-S3-Instance-Profile"
  role = aws_iam_role.ec2_cloud_s3.name
}