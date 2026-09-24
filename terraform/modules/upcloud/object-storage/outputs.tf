output "service_id" {
  value       = upcloud_managed_object_storage.this.id
  description = "UUID of the Managed Object Storage service."
}

output "bucket_id" {
  value       = upcloud_managed_object_storage_bucket.this.id
  description = "ID of the bucket, in {service UUID}/{bucket name} form."
}

output "bucket_name" {
  value       = upcloud_managed_object_storage_bucket.this.name
  description = "Name of the bucket."
}

output "endpoint_hostname" {
  value = one([
    for endpoint in upcloud_managed_object_storage.this.endpoint : endpoint.domain_name
    if endpoint.type == "public"
  ])
  description = "Public S3 endpoint hostname."
}

output "access_key_id" {
  value       = upcloud_managed_object_storage_user_access_key.this.access_key_id
  description = "Access key ID for the openedx object storage user."
  sensitive   = true
}

output "secret_access_key" {
  value       = upcloud_managed_object_storage_user_access_key.this.secret_access_key
  description = "Secret access key for the openedx object storage user."
  sensitive   = true
}
