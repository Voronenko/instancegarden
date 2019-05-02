resource "vagrant_vm" "my_vagrant_vm" {
  vagrantfile_dir = "unix"
  env = {
    KEY = "value",
  }
}
