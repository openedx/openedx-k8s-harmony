output "bucket_id" {
  value       = aws_s3_bucket.s3_bucket.id
  description = "The ID of the bucket that is generated during creation."
}

output "bucket_arn" {
  value       = aws_s3_bucket.s3_bucket.arn
  description = "The unique resource ID of the bucket."
}

output "bucket_name" {
   value       = aws_s3_bucket.s3_bucket.name 
   description = "The name of the S3 bucket."
}

output "bucket_domain_name" {
  value       = aws_s3_bucket.s3_bucket.bucket_domain_name
  description = "The domain name of the bucket, including the generated prefix."
}

