output "bucket_id" {
  value = digitalocean_spaces_bucket.spaces_bucket.id
  description = "The ID of the bucket that is generated during creation."
}

output "bucket_urn" {
  value = digitalocean_spaces_bucket.spaces_bucket.urn
  description = "The unique resource ID of the bucket."
}

output "bucket_name" {
  value = digitalocean_spaces_bucket.spaces_bucket.name
  description = "The name of the bucket, including the generated suffix."
}
