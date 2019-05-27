provider "azurerm" {
	version = "=1.27.0"
}

resource "azurerm_resource_group" "rg" {
    name     = "myTFResourceGroup"
    location = "westus2"
	tags = {
	environment = "test"
	custom_tag = "ephimeral"
	}
}


# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "myTFVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "westus2"
    resource_group_name = "${azurerm_resource_group.rg.name}"
}
# Create subnet
resource "azurerm_subnet" "subnet" {
    name                 = "myTFSubnet"
    resource_group_name  = "${azurerm_resource_group.rg.name}"
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
    name                         = "myTFPublicIP"
    location                     = "westus2"
    resource_group_name          = "${azurerm_resource_group.rg.name}"
    allocation_method		 = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
    name                = "myTFNSG"
    location            = "westus2"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
    name                      = "myNIC"
    location                  = "westus2"
    resource_group_name       = "${azurerm_resource_group.rg.name}"
    network_security_group_id = "${azurerm_network_security_group.nsg.id}"

    ip_configuration {
        name                          = "myNICConfg"
        subnet_id                     = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.publicip.id}"
    }
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
    name                  = "myTFVM"
    location              = "westus2"
    resource_group_name   = "${azurerm_resource_group.rg.name}"
    network_interface_ids = ["${azurerm_network_interface.nic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myTFVM"
        admin_username = "plankton"
        admin_password = "Password1234!"
    }

    os_profile_linux_config {
        disable_password_authentication = true
	ssh_keys {
		key_data="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQClo8MANVrbTtlscAht4IiVGfT0nbcJRbTeVsjxnT3f9u+ergWRZKUkt07mvrxy/9KtOVUepMIqHjVtJhvhna/QcRoMWEyYs/u82nAW63+M3LBwdW8tBpUh6+G6zOnT49m9wNaX3EE5XPD9u//ArnpUDsw0nPv3xn4jhHMZckij++sZBnpYGjliG/0OqX8MEMWxjKvMuj98eGW2/m0QiANoLC9hi6LqnjNnxyc0RDM4fOHuGHxPWrnL6O0ugb1qqzdMlb+TVE9KYCJhQME4683Igfw8TJ6dSLJsIt/Ir63+dPab9sv8ZYh85EkGmMKxWL5jE4wOhMe9WnlC4BH2iQhh dmurga@gratefuldead"
	#	path=("/home/plankton/.ssh/authorized_keys")
    	}
    }
   provisioner "local-exec" {
    	command = <<EOH
	sudo apt-get update
	sudo apt-get install -y nginx
	EOH
   }

}
