resource "null_resource" "webservers" {
  provisioner "local-exec" {
    command = <<EOF
      sleep 10 && ansible -i invfile pvt -m ping
    EOF
  }
  depends_on = [local_file.ansible-inventory-file]
}
