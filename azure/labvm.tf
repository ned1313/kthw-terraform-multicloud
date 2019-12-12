resource "azurerm_public_ip" "lab" {
  name                         = "${var.naming_prefix}-publicIP"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.main.name
  allocation_method = "Dynamic"
}

resource "azurerm_network_security_group" "lab" {
  name                = "${var.naming_prefix}-labvm-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow_remote_port22_in_all"
    description                = "Allow remote protocol in from all locations"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface" "lab" {
  name                = "${var.naming_prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  network_security_group_id = azurerm_network_security_group.lab.id

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.main.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.lab.id
  }
}

resource "azurerm_virtual_machine" "lab" {
  name                  = "${var.naming_prefix}labvm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.lab.id]
  vm_size               = "Standard_B2s"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.naming_prefix}labvm-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name  = "${var.naming_prefix}labvm"
    admin_username = var.username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
        key_data = "${path.module}/kthw_pub.pem"
        path = "/home/${var.username}/.ssh/authorized_keys"
    }
  }

    connection {
        type     = "ssh"
        user     = var.username
        private_key = file("${path.module}/kthw_priv.pem")
        host     = azurerm_public_ip.lab.ip_address
    }

    provisioner "file" {
      source      = "${path.module}/kthw_priv.pem"
      destination = "/home/${username}/.ssh/identity"
    }

    provisioner "remote-exec" {
        inline = [
            "chown ${var.username} /home/${username}/.ssh/identity",
            "chgrp ${var.username} /home/${username}/.ssh/identity",
            "chmod 700 /home/${username}/.ssh/identity",
            "wget https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssl -O /run/kthw/cfssl",
            "wget https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssljson -O /run/kthw/cfssljson",
            "wget https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl -O /run/kthw/kubectl",
            "chmod, +x /run/kthw/cfssl",
            "chmod, +x /run/kthw/cfssljson",
            "chmod, +x /run/kthw/kubectl",
            "mv, /run/kthw/cfssl /usr/bin/cfssl",
            "mv, /run/kthw/cfssljson /usr/bin/cfssljson",
            "mv, /run/kthw/kubectl /usr/bin/kubectl"
        ]
    }
}