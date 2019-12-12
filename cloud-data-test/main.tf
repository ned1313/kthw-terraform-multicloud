#############################################################################
# PROVIDERS
#############################################################################

provider azurerm {
  # Note this assumes you are using environment variables or
  # the Azure CLI for your credentials
}

#############################################################################
# RESOURCES
#############################################################################

data "template_file" "custom_data" {
    template = file("${path.module}/cloud-init.tpl")

    vars = {
        priv_key = indent(6, file("${path.module}/kthw_priv.pem"))
        username = var.username
    }
}

resource "local_file" "cloud_init" {
  filename = "${path.module}/cloud-init.yaml"
  content = data.template_file.custom_data.rendered
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location

  tags = {
    project = "kthw"
  }
}

module "main" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vnet_name           = "${var.naming_prefix}-vnet"
  address_space       = var.vnet_cidr_range
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names
  nsg_ids             = {}

  tags = {
    project = "kthw"
  }
}


module "labnode" {
  source                        = "Azure/compute/azurerm"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = var.location
  admin_username                = var.username
  ssh_key                       = "${path.module}/kthw_pub.pem"
  vm_hostname                   = "${var.naming_prefix}jump"
  nb_public_ip                  = "1"
  public_ip_dns                 = ["${var.naming_prefix}jump"]
  remote_port                   = "22"
  nb_instances                  = "1"
  vm_os_publisher               = "Canonical"
  vm_os_offer                   = "UbuntuServer"
  vm_os_sku                     = "18.04-LTS"
  vm_size                       = "Standard_B2s"
  vnet_subnet_id                = "${module.main.vnet_subnets[0]}"
  enable_accelerated_networking = "false"
  boot_diagnostics              = "true"
  delete_os_disk_on_termination = "true"
  data_disk                     = "true"
  data_disk_size_gb             = "64"
  data_sa_type                  = "StandardSSD_LRS"
  custom_data                   = data.template_file.custom_data.rendered

  tags = {
    project = "kthw"
  }

}
