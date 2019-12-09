variable "cloud_provider" {
    type = string
    description = "Name of the cloud provider that will be used for the lab. Will write SSH key data to the subfolder of the cloud provider selected."
} 

resource "tls_private_key" "main" {
  algorithm   = "RSA"
  rsa_bits = "2048"
}

resource "local_file" "priv_key" {
    content = tls_private_key.main.private_key_pem
    filename = "${path.module}/${var.cloud_provider}/kthw_priv.pem"
}

resource "local_file" "pub_key" {
    content = tls_private_key.main.public_key_openssh
    filename = "${path.module}/${var.cloud_provider}/kthw_pub.pem"
}

output "file_location" {
    value = "Public and Private key written out to the directory ${path.cwd}/${var.cloud_provider}. DO NOT USE FOR PRODUCTION!"
}