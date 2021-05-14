provider "vsphere" {
  user           = "administrator@test.org.in"
  password       = "Test@123"
  vsphere_server = "192.168.100.160"
  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "Datacenter"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Cluster1"
  datacenter_id = data.vsphere_datacenter.dc.id
}


data "vsphere_datastore" "datastore" {
  name          = "Datastore2"
  datacenter_id = data.vsphere_datacenter.dc.id
}


data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

#Data source for Content library
data "vsphere_content_library" "library" {
  name = "Content_Library"
}

data "vsphere_content_library_item" "item" {
  name       = "CentOS7"
  library_id = data.vsphere_content_library.library.id
  type       = "OVA"
}





resource "vsphere_virtual_machine" "vm" {
  name             = "centos7clib"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id

  num_cpus = 2
  memory   = 512
  guest_id = "centos7_64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = 10
  }

  #Included a clone attribute in the resource
  clone {
    template_uuid = data.vsphere_content_library_item.item.id

    customize {
      linux_options {
        host_name = "centos7clib"
        domain    = "test.org.in"
      }
      network_interface {
        ipv4_address = "10.206.1.112"
        ipv4_netmask = "24"
      }

      ipv4_gateway = "10.206.1.1"
    }
  }
}