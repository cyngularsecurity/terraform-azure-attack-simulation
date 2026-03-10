resource "tls_private_key" "attack_sim_ssh" {
  count     = var.create_vm ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  count           = var.create_vm ? 1 : 0
  content         = tls_private_key.attack_sim_ssh[0].private_key_pem
  filename        = "${path.root}/azure_attack.pem"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  count           = var.create_vm ? 1 : 0
  content         = tls_private_key.attack_sim_ssh[0].public_key_openssh
  filename        = "${path.root}/azure_attack.pub"
  file_permission = "0644"
}
