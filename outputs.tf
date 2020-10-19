output "cloudfront-output" {
  value = aws_cloudfront_distribution.cloud_front_distribution.domain_name
  description = "Frontend domain name"
}

output "elastic-beanstalk-output" {
  value = aws_elastic_beanstalk_environment.mathenger-env.endpoint_url
  description = "Backend URL"
}

output "rds-output" {
  value = aws_db_instance.db.endpoint
  description = "Database endpoint"
}
