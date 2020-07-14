# if ansible isn't finding your vault file your can specify it like this:
# ansible-playbook  --vault-password-file ../ansible/scripts/.vault_pass.sh ../ansible/playbooks/test.yaml -e "@../ansible/group_vars/all/vault.yaml"
resource null_resource run_ansible_test {
  provisioner "local-exec" {
    command = <<-EOF
      ansible-playbook  --vault-password-file ../ansible/scripts/.vault_pass.sh ../ansible/playbooks/test.yaml -e "@../ansible/group_vars/all/vault.yaml"
    EOF
  }
}