
output "lambda_base_url" {
  description = "Lambda base URL"
  value = aws_api_gateway_deployment.example.invoke_url
}

output "lambda_domain" {
  description = "Domain"
  value = local.regobject1
}

output "lambda_cloudfront_url" {
  description = "DNS output from cloudfront for the lambda (example)"
  value = "https://${aws_cloudfront_distribution.distribution.domain_name}/api/calc/add?x=5&y=3"
}

output "site-url" {
  description = "DNS site"
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}