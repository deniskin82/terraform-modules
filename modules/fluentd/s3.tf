# S3 bucket for logs long term retention
resource "aws_s3_bucket" "logs" {
  count = var.logs_s3_enabled ? 1 : 0

  bucket = var.logs_s3_bucket_name
  tags   = var.tags

  force_destroy = false

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_iam_policy_document" "s3_logs_policy" {
  count = var.logs_s3_enabled ? 1 : 0
  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"

    resources = [
      aws_s3_bucket.logs[0].arn,
      "${aws_s3_bucket.logs[0].arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [false]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  count = var.logs_s3_enabled ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  policy = data.aws_iam_policy_document.s3_logs_policy[0].json
}

data "aws_iam_policy_document" "logs_s3" {
  count = var.logs_s3_enabled ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.logs[0].arn}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.logs[0].arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:PutRetentionPolicy",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "logs_s3" {
  count = var.logs_s3_enabled ? 1 : 0

  name        = var.logs_s3_policy
  path        = "/"
  description = "IAM Policy to store logs in the archival S3 bucket"

  policy = data.aws_iam_policy_document.logs_s3[0].json
}
