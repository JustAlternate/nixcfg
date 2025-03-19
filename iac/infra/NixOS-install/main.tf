# this is ./NixOS-install/main.tf
# the module executes a command on the target host, through ssh
# the command is the NixOS-infect script, which will convert the system to NixOS

resource "null_resource" "NixOS_install" {
  connection {
    type    = "ssh"
    user    = "root"
    host    = var.target_host
    timeout = 2000
  }

  provisioner "remote-exec" {
    inline = [
      "curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | PROVIDER=hetznercloud NIX_CHANNEL=nixos-24.11 bash 2>&1 | tee /tmp/infect.log",
    ]
  }
}
