

resource "aws_s3_bucket" "site" {
  bucket = var.s3bucketname
  force_destroy = true
}

#############################################
resource "aws_s3_bucket_object" "html" {
  for_each = fileset("../output/dist/", "**/*.html")
  bucket = aws_s3_bucket.site.id
  key = each.value
  source = "../output/dist/${each.value}"
  etag = filemd5("../output/dist/${each.value}")
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "svg" {
  for_each = fileset("../output/dist/", "**/*.svg")
  bucket = aws_s3_bucket.site.id
  key = each.value
  source = "../output/dist/${each.value}"
  etag = filemd5("../output/dist/${each.value}")
  content_type = "image/svg+xml"
}

resource "aws_s3_bucket_object" "css" {
  for_each = fileset("../output/dist/", "**/*.css")
  bucket = aws_s3_bucket.site.id
  key = each.value
  source = "../output/dist/${each.value}"
  etag = filemd5("../output/dist/${each.value}")
  content_type = "text/css"
}

resource "aws_s3_bucket_object" "js" {
  for_each = fileset("../output/dist/", "**/*.js")
  bucket = aws_s3_bucket.site.id
  key = each.value
  source = "../output/dist/${each.value}"
  etag = filemd5("../output/dist/${each.value}")
  content_type = "application/javascript"
}

resource "aws_s3_bucket_object" "png" {
  for_each = fileset("../output/dist/", "**/*.png")
  bucket = aws_s3_bucket.site.id
  key = each.value
  source = "../output/dist/${each.value}"
  etag = filemd5("../output/dist/${each.value}")
  content_type = "image/png"
}

resource "aws_s3_bucket_object" "json" {
  for_each = fileset("../output/dist/", "**/*.json")
  bucket = aws_s3_bucket.site.id
  key = each.value
  source = "../output/dist/${each.value}"
  etag = filemd5("../output/dist/${each.value}")
  content_type = "application/json"
}

resource "aws_s3_bucket_object" "url_content" {
  bucket = aws_s3_bucket.site.id  
  key = "extra/url.json"
  content = "{\"url\": \"https://${aws_cloudfront_distribution.distribution.domain_name}\"}"
  content_type = "application/json"
}
##############################

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_acl" "site" {
  bucket = aws_s3_bucket.site.id
  acl = "public-read"
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.site.arn,
          "${aws_s3_bucket.site.arn}/*",
        ]
      },
    ]
  })
}

#####################

data "archive_file" "website" {
  output_path = "../output/zip/website.zip"
  source_dir  = "../output/dist"
  type        = "zip"
}

resource "null_resource" "website" {
  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.s3_distribution.id} --paths /*"
  }

  triggers = {
    index = filebase64sha256(data.archive_file.website.output_path)
  }

  depends_on = [
    aws_s3_bucket_object.url_content
  ]
}

resource "null_resource" "website-url" {
  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.s3_distribution.id} --paths /*"
  }

  triggers = {
    index = aws_cloudfront_distribution.distribution.domain_name
  }

  depends_on = [
    aws_s3_bucket_object.url_content
  ]
}

################################################################################################
locals {
  s3_origin_id = "mysite"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "mysite"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "vuejs-cloudfront"
  default_root_object = "index.html"

  # Configure logging here if required 	
  #logging_config {
  #  include_cookies = false
  #  bucket          = "mylogs.s3.amazonaws.com"
  #  prefix          = "myprefix"
  #}

  # If you have domain configured use it here 
  #aliases = ["mywebsite.example.com", "s3-static-web-dev.example.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "IN", "IR", "IT"]
    }
  }

  tags = {
    Environment = "development"
    Name        = "my-tag"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
