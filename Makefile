tf-provider:
	mkdir -p ./.terraform/plugins/linux_amd64
	wget https://github.com/bmatcuk/terraform-provider-vagrant/releases/download/v1.1.2/terraform-provider-vagrant_v1.1.2_linux_amd64.tar.gz
	tar -xvzf ./terraform-provider-vagrant_v1.1.2_linux_amd64.tar.gz -C ./.terraform/plugins/linux_amd64


