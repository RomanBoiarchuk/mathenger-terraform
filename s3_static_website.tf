resource "aws_s3_bucket" "s3-frontend" {
  bucket = "${var.app_name}-frontend-bucket"
  website {
    index_document = "index.html"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity" {
  comment = "The origin access identity required by CloudFront to access the S3 bucket"
}

data "aws_iam_policy_document" "s3-frontend-policy-document" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3-frontend.arn}/*"]
    principals {
      identifiers = [aws_cloudfront_origin_access_identity.origin-access-identity.iam_arn]
      type = "AWS"
    }
  }
}

resource "aws_s3_bucket_policy" "s3-frontend-policy" {
  bucket = aws_s3_bucket.s3-frontend.id
  policy = data.aws_iam_policy_document.s3-frontend-policy-document.json
}

resource "null_resource" "frontend-files" {
  provisioner "local-exec" {
    command = "aws s3 sync ${var.frontend_path} s3://${aws_s3_bucket.s3-frontend.id} --profile ${var.aws_profile}"
  }
  depends_on = [
    aws_s3_bucket.s3-frontend
  ]
}
