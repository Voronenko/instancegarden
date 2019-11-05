resource "vagrant_vm" "my_vagrant_vm" {
  vagrantfile_dir = "ubuntu/trusty"
  env = {
    KEY = "value",
  }
}
