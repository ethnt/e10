resource "tls_private_key" "deploy_key" {
  algorithm = "RSA"
}

resource "local_sensitive_file" "deploy_key" {
  content         = tls_private_key.deploy_key.private_key_pem
  filename        = "${path.module}/../../keys/id_rsa"
  file_permission = "0600"
}

resource "local_sensitive_file" "deploy_public_key" {
  content         = tls_private_key.deploy_key.public_key_openssh
  filename        = "${path.module}/../../keys/id_rsa.pub"
  file_permission = "0600"
}

resource "tls_private_key" "builder_key" {
  algorithm = "RSA"
}

resource "local_sensitive_file" "builder_key" {
  content         = tls_private_key.builder_key.private_key_openssh
  filename        = "${path.module}/../../keys/builder_rsa"
  file_permission = "0600"
}

resource "local_sensitive_file" "builder_public_key" {
  content         = tls_private_key.builder_key.public_key_openssh
  filename        = "${path.module}/../../keys/builder_rsa.pub"
  file_permission = "0600"
}

resource "tls_private_key" "rsync_net_key" {
  algorithm = "RSA"
}

resource "local_sensitive_file" "rsync_net_key" {
  content         = tls_private_key.rsync_net_key.private_key_openssh
  filename        = "${path.module}/../../keys/rsync_net_rsa"
  file_permission = "0600"
}

resource "local_sensitive_file" "rsync_net_public_key" {
  content         = tls_private_key.rsync_net_key.public_key_openssh
  filename        = "${path.module}/../../keys/rsync_net_rsa.pub"
  file_permission = "0600"
}

resource "hcloud_ssh_key" "deploy" {
  name       = "deploy"
  public_key = file("${path.module}/../../keys/id_rsa.pub")
}
