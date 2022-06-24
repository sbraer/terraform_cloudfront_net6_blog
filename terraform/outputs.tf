
output "cloudfront_lambda_url" {
  description = "DNS output from cloudfront for the lambda (example)"
  value = "https://${aws_cloudfront_distribution.distribution.domain_name}/api/calc/add?x=5&y=3"
}

output "cloudfront-site-url" {
  description = "DNS site"
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

output "site-domain-url" {
  description = "Site domain url"
  value = "https://${var.domain}"
}

output "site-domain-url-alternative" {
  description = "Site domain url alternative"
  value = "https://www.${var.domain}"
}

output "site-domain-url-api" {
  description = "Site domain url api"
  value = "https://${var.apisubdomain}.${var.domain}/api/calc/add?x=5&y=3"
}

