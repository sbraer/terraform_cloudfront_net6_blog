data "aws_route53_zone" "myzone" {
  name = var.domain
}

data "aws_acm_certificate" "cert" {
  domain   = var.domain
  provider = aws.us-east-1
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.myzone.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }

  provider = aws.us-east-1
}

resource "aws_route53_record" "www2" {
  zone_id = data.aws_route53_zone.myzone.zone_id
  name    = "www.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_route53_record.www.fqdn
    zone_id                = aws_route53_record.www.zone_id
    evaluate_target_health = false
  }

  provider = aws.us-east-1
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.myzone.zone_id
  name    = "${var.apisubdomain}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }

  provider = aws.us-east-1
}
