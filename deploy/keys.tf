resource "tls_private_key" "deploy_key" {
  algorithm = "RSA"
}

resource "local_sensitive_file" "deploy_key" {
  content         = tls_private_key.deploy_key.private_key_pem
  filename        = "${path.module}/../keys/id_rsa"
  file_permission = "0600"
}

resource "local_sensitive_file" "deploy_public_key" {
  content         = tls_private_key.deploy_key.public_key_openssh
  filename        = "${path.module}/../keys/id_rsa.pub"
  file_permission = "0600"
}

resource "aws_key_pair" "deploy_key" {
  key_name   = "generated-key-${sha256(tls_private_key.deploy_key.public_key_openssh)}"
  public_key = tls_private_key.deploy_key.public_key_openssh
}
