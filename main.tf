terraform {
  required_version = ">= 1.3.0"

  backend "s3" {}

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.2"
    }
  }
}

# Provider configuration
provider "libvirt" {
  uri = "qemu+ssh://${var.admin_user}@${var.remote_host}/system?keyfile=${var.ssh_private_key}&no_verify=1"
}


# Use openSUSE MicroOS cloud image
resource "libvirt_volume" "opensuse_base_image" {
  name = "openSUSE-MicroOS.qcow2"
  pool = "default"
  target = {
    format = {
      type = "qcow2"
    }
  }
  create = {
    content = {
      url = "https://download.opensuse.org/tumbleweed/appliances/openSUSE-MicroOS.x86_64-kvm-and-xen.qcow2"
    }
  }
}


# ===================================================
# MASTER NODE VOLUMES (3 nodes)
# ===================================================

resource "libvirt_volume" "master1_disk" {
  name     = "master-1-disk.qcow2"
  pool     = "default"
  capacity = var.vm_volume_size

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.opensuse_base_image.path
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_volume" "master2_disk" {
  name     = "master-2-disk.qcow2"
  pool     = "default"
  capacity = var.vm_volume_size

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.opensuse_base_image.path
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_volume" "master3_disk" {
  name     = "master-3-disk.qcow2"
  pool     = "default"
  capacity = var.vm_volume_size

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.opensuse_base_image.path
    format = {
      type = "qcow2"
    }
  }
}


# ===================================================
# WORKER NODE VOLUMES (6 nodes)
# ===================================================

resource "libvirt_volume" "worker1_disk" {
  name     = "worker-1-disk.qcow2"
  pool     = "default"
  capacity = var.vm_volume_size

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.opensuse_base_image.path
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_volume" "worker2_disk" {
  name     = "worker-2-disk.qcow2"
  pool     = "default"
  capacity = var.vm_volume_size

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.opensuse_base_image.path
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_volume" "worker3_disk" {
  name     = "worker-3-disk.qcow2"
  pool     = "default"
  capacity = var.vm_volume_size

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.opensuse_base_image.path
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_volume" "worker4_disk" {
  name     = "worker-4-disk.qcow2"
  pool     = "default"
  capacity = var.vm_volume_size

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.opensuse_base_image.path
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_volume" "worker5_disk" {
  name     = "worker-5-disk.qcow2"
  pool     = "default"
  capacity = var.vm_volume_size

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.opensuse_base_image.path
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_volume" "worker6_disk" {
  name     = "worker-6-disk.qcow2"
  pool     = "default"
  capacity = var.vm_volume_size

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.opensuse_base_image.path
    format = {
      type = "qcow2"
    }
  }
}


# ===================================================
# MASTER NODE CLOUD-INIT CONFIGURATIONS
# ===================================================

resource "libvirt_cloudinit_disk" "cloudinit_master1" {
  name = "cloudinit-master-1"

  user_data = <<-EOF
#cloud-config
hostname: TZUSDSRAPP0001

users:
  - name: student
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash
    passwd: $6$rounds=656000$randomhash$studentpasswordhash

ssh_pwauth: true
disable_root: false

chpasswd:
  list: |
    root:${var.root_password}
    student:${var.student_password}
  expire: false

packages:
  - vim
  - curl
  - wget
  - net-tools
  - iputils
  - sudo
  - python3

runcmd:
  - systemctl enable --now sshd
  - echo "openSUSE MicroOS Master Node Ready"
EOF

  meta_data = <<-EOF
instance-id: TZUSDSRAPP0001
local-hostname: TZUSDSRAPP0001
EOF

  network_config = <<-EOF
version: 2
ethernets:
  eth0:
    addresses:
      - 172.168.122.21/24
    routes:
      - to: 0.0.0.0/0
        via: 172.168.122.1
    nameservers:
      addresses: [172.168.122.1, 8.8.8.8]
EOF
}

resource "libvirt_cloudinit_disk" "cloudinit_master2" {
  name = "cloudinit-master-2"

  user_data = <<-EOF
#cloud-config
hostname: TZUSDSRAPP0002

users:
  - name: student
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash

ssh_pwauth: true
disable_root: false

chpasswd:
  list: |
    root:${var.root_password}
    student:${var.student_password}
  expire: false

packages:
  - vim
  - curl
  - wget
  - net-tools
  - iputils
  - sudo
  - python3

runcmd:
  - systemctl enable --now sshd
  - echo "openSUSE MicroOS Master Node Ready"
EOF

  meta_data = <<-EOF
instance-id: TZUSDSRAPP0002
local-hostname: TZUSDSRAPP0002
EOF

  network_config = <<-EOF
version: 2
ethernets:
  eth0:
    addresses:
      - 172.168.122.22/24
    routes:
      - to: 0.0.0.0/0
        via: 172.168.122.1
    nameservers:
      addresses: [172.168.122.1, 8.8.8.8]
EOF
}

resource "libvirt_cloudinit_disk" "cloudinit_master3" {
  name = "cloudinit-master-3"

  user_data = <<-EOF
#cloud-config
hostname: TZUSDSRAPP0003

users:
  - name: student
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash

ssh_pwauth: true
disable_root: false

chpasswd:
  list: |
    root:${var.root_password}
    student:${var.student_password}
  expire: false

packages:
  - vim
  - curl
  - wget
  - net-tools
  - iputils
  - sudo
  - python3

runcmd:
  - systemctl enable --now sshd
  - echo "openSUSE MicroOS Master Node Ready"
EOF

  meta_data = <<-EOF
instance-id: TZUSDSRAPP0003
local-hostname: TZUSDSRAPP0003
EOF

  network_config = <<-EOF
version: 2
ethernets:
  eth0:
    addresses:
      - 172.168.122.23/24
    routes:
      - to: 0.0.0.0/0
        via: 172.168.122.1
    nameservers:
      addresses: [172.168.122.1, 8.8.8.8]
EOF
}


# ===================================================
# WORKER NODE CLOUD-INIT CONFIGURATIONS
# ===================================================

resource "libvirt_cloudinit_disk" "cloudinit_worker1" {
  name = "cloudinit-worker-1"

  user_data = <<-EOF
#cloud-config
hostname: TZUSDSRAPP0004

users:
  - name: student
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash

ssh_pwauth: true
disable_root: false

chpasswd:
  list: |
    root:${var.root_password}
    student:${var.student_password}
  expire: false

packages:
  - vim
  - curl
  - wget
  - net-tools
  - iputils
  - sudo

runcmd:
  - systemctl enable --now sshd
  - echo "openSUSE MicroOS Worker Node Ready"
EOF

  meta_data = <<-EOF
instance-id: TZUSDSRAPP0004
local-hostname: TZUSDSRAPP0004
EOF

  network_config = <<-EOF
version: 2
ethernets:
  eth0:
    addresses:
      - 172.168.122.31/24
    routes:
      - to: 0.0.0.0/0
        via: 172.168.122.1
    nameservers:
      addresses: [172.168.122.1, 8.8.8.8]
EOF
}

resource "libvirt_cloudinit_disk" "cloudinit_worker2" {
  name = "cloudinit-worker-2"

  user_data = <<-EOF
#cloud-config
hostname: TZUSDSRAPP0005

users:
  - name: student
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash

ssh_pwauth: true
disable_root: false

chpasswd:
  list: |
    root:${var.root_password}
    student:${var.student_password}
  expire: false

packages:
  - vim
  - curl
  - wget
  - net-tools
  - iputils
  - sudo

runcmd:
  - systemctl enable --now sshd
  - echo "openSUSE MicroOS Worker Node Ready"
EOF

  meta_data = <<-EOF
instance-id: TZUSDSRAPP0005
local-hostname: TZUSDSRAPP0005
EOF

  network_config = <<-EOF
version: 2
ethernets:
  eth0:
    addresses:
      - 172.168.122.32/24
    routes:
      - to: 0.0.0.0/0
        via: 172.168.122.1
    nameservers:
      addresses: [172.168.122.1, 8.8.8.8]
EOF
}

resource "libvirt_cloudinit_disk" "cloudinit_worker3" {
  name = "cloudinit-worker-3"

  user_data = <<-EOF
#cloud-config
hostname: TZUSDSRAPP0006

users:
  - name: student
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash

ssh_pwauth: true
disable_root: false

chpasswd:
  list: |
    root:${var.root_password}
    student:${var.student_password}
  expire: false

packages:
  - vim
  - curl
  - wget
  - net-tools
  - iputils
  - sudo

runcmd:
  - systemctl enable --now sshd
  - echo "openSUSE MicroOS Worker Node Ready"
EOF

  meta_data = <<-EOF
instance-id: TZUSDSRAPP0006
local-hostname: TZUSDSRAPP0006
EOF

  network_config = <<-EOF
version: 2
ethernets:
  eth0:
    addresses:
      - 172.168.122.33/24
    routes:
      - to: 0.0.0.0/0
        via: 172.168.122.1
    nameservers:
      addresses: [172.168.122.1, 8.8.8.8]
EOF
}

resource "libvirt_cloudinit_disk" "cloudinit_worker4" {
  name = "cloudinit-worker-4"

  user_data = <<-EOF
#cloud-config
hostname: TZUSDSRAPP0007

users:
  - name: student
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash

ssh_pwauth: true
disable_root: false

chpasswd:
  list: |
    root:${var.root_password}
    student:${var.student_password}
  expire: false

packages:
  - vim
  - curl
  - wget
  - net-tools
  - iputils
  - sudo

runcmd:
  - systemctl enable --now sshd
  - echo "openSUSE MicroOS Worker Node Ready"
EOF

  meta_data = <<-EOF
instance-id: TZUSDSRAPP0007
local-hostname: TZUSDSRAPP0007
EOF

  network_config = <<-EOF
version: 2
ethernets:
  eth0:
    addresses:
      - 172.168.122.34/24
    routes:
      - to: 0.0.0.0/0
        via: 172.168.122.1
    nameservers:
      addresses: [172.168.122.1, 8.8.8.8]
EOF
}

resource "libvirt_cloudinit_disk" "cloudinit_worker5" {
  name = "cloudinit-worker-5"

  user_data = <<-EOF
#cloud-config
hostname: TZUSDSRAPP0008

users:
  - name: student
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash

ssh_pwauth: true
disable_root: false

chpasswd:
  list: |
    root:${var.root_password}
    student:${var.student_password}
  expire: false

packages:
  - vim
  - curl
  - wget
  - net-tools
  - iputils
  - sudo

runcmd:
  - systemctl enable --now sshd
  - echo "openSUSE MicroOS Worker Node Ready"
EOF

  meta_data = <<-EOF
instance-id: TZUSDSRAPP0008
local-hostname: TZUSDSRAPP0008
EOF

  network_config = <<-EOF
version: 2
ethernets:
  eth0:
    addresses:
      - 172.168.122.35/24
    routes:
      - to: 0.0.0.0/0
        via: 172.168.122.1
    nameservers:
      addresses: [172.168.122.1, 8.8.8.8]
EOF
}

resource "libvirt_cloudinit_disk" "cloudinit_worker6" {
  name = "cloudinit-worker-6"

  user_data = <<-EOF
#cloud-config
hostname: TZUSDSRAPP0009

users:
  - name: student
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash

ssh_pwauth: true
disable_root: false

chpasswd:
  list: |
    root:${var.root_password}
    student:${var.student_password}
  expire: false

packages:
  - vim
  - curl
  - wget
  - net-tools
  - iputils
  - sudo

runcmd:
  - systemctl enable --now sshd
  - echo "openSUSE MicroOS Worker Node Ready"
EOF

  meta_data = <<-EOF
instance-id: TZUSDSRAPP0009
local-hostname: TZUSDSRAPP0009
EOF

  network_config = <<-EOF
version: 2
ethernets:
  eth0:
    addresses:
      - 172.168.122.36/24
    routes:
      - to: 0.0.0.0/0
        via: 172.168.122.1
    nameservers:
      addresses: [172.168.122.1, 8.8.8.8]
EOF
}


# ===================================================
# MASTER NODE CLOUD-INIT VOLUMES (ISOs)
# ===================================================

resource "libvirt_volume" "cloudinit_master1_volume" {
  name = "${libvirt_cloudinit_disk.cloudinit_master1.name}.iso"
  pool = "default"

  create = {
    content = {
      url = libvirt_cloudinit_disk.cloudinit_master1.path
    }
  }
}

resource "libvirt_volume" "cloudinit_master2_volume" {
  name = "${libvirt_cloudinit_disk.cloudinit_master2.name}.iso"
  pool = "default"

  create = {
    content = {
      url = libvirt_cloudinit_disk.cloudinit_master2.path
    }
  }
}

resource "libvirt_volume" "cloudinit_master3_volume" {
  name = "${libvirt_cloudinit_disk.cloudinit_master3.name}.iso"
  pool = "default"

  create = {
    content = {
      url = libvirt_cloudinit_disk.cloudinit_master3.path
    }
  }
}


# ===================================================
# WORKER NODE CLOUD-INIT VOLUMES (ISOs)
# ===================================================

resource "libvirt_volume" "cloudinit_worker1_volume" {
  name = "${libvirt_cloudinit_disk.cloudinit_worker1.name}.iso"
  pool = "default"

  create = {
    content = {
      url = libvirt_cloudinit_disk.cloudinit_worker1.path
    }
  }
}

resource "libvirt_volume" "cloudinit_worker2_volume" {
  name = "${libvirt_cloudinit_disk.cloudinit_worker2.name}.iso"
  pool = "default"

  create = {
    content = {
      url = libvirt_cloudinit_disk.cloudinit_worker2.path
    }
  }
}

resource "libvirt_volume" "cloudinit_worker3_volume" {
  name = "${libvirt_cloudinit_disk.cloudinit_worker3.name}.iso"
  pool = "default"

  create = {
    content = {
      url = libvirt_cloudinit_disk.cloudinit_worker3.path
    }
  }
}

resource "libvirt_volume" "cloudinit_worker4_volume" {
  name = "${libvirt_cloudinit_disk.cloudinit_worker4.name}.iso"
  pool = "default"

  create = {
    content = {
      url = libvirt_cloudinit_disk.cloudinit_worker4.path
    }
  }
}

resource "libvirt_volume" "cloudinit_worker5_volume" {
  name = "${libvirt_cloudinit_disk.cloudinit_worker5.name}.iso"
  pool = "default"

  create = {
    content = {
      url = libvirt_cloudinit_disk.cloudinit_worker5.path
    }
  }
}

resource "libvirt_volume" "cloudinit_worker6_volume" {
  name = "${libvirt_cloudinit_disk.cloudinit_worker6.name}.iso"
  pool = "default"

  create = {
    content = {
      url = libvirt_cloudinit_disk.cloudinit_worker6.path
    }
  }
}


# ===================================================
# MASTER NODE VIRTUAL MACHINES
# ===================================================

resource "libvirt_domain" "master1" {
  name   = "TZUSDSRAPP0001"
  memory = var.master_memory
  vcpu   = var.master_vcpu
  type   = "kvm"

  os = {
    type    = "hvm"
    arch    = "x86_64"
    machine = "q35"
    boot_devices = [
      { dev = "hd" }
    ]
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            pool   = libvirt_volume.master1_disk.pool
            volume = libvirt_volume.master1_disk.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vda"
        }
        driver = {
          type = "qcow2"
        }
      },
      {
        source = {
          volume = {
            pool   = libvirt_volume.cloudinit_master1_volume.pool
            volume = libvirt_volume.cloudinit_master1_volume.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vdb"
        }
        readonly = true
      }
    ]

    interfaces = [
      {
        type  = "network"
        model = { type = "virtio" }
        source = {
          network = {
            network = "lab"
          }
        }
      }
    ]

    graphics = [
      {
        vnc = {
          auto_port = true
          listen    = "0.0.0.0"
        }
      }
    ]

    consoles = [
      {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
      }
    ]
  }

  running = true
}

resource "libvirt_domain" "master2" {
  name   = "TZUSDSRAPP0002"
  memory = var.master_memory
  vcpu   = var.master_vcpu
  type   = "kvm"

  os = {
    type    = "hvm"
    arch    = "x86_64"
    machine = "q35"
    boot_devices = [
      { dev = "hd" }
    ]
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            pool   = libvirt_volume.master2_disk.pool
            volume = libvirt_volume.master2_disk.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vda"
        }
        driver = {
          type = "qcow2"
        }
      },
      {
        source = {
          volume = {
            pool   = libvirt_volume.cloudinit_master2_volume.pool
            volume = libvirt_volume.cloudinit_master2_volume.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vdb"
        }
        readonly = true
      }
    ]

    interfaces = [
      {
        type  = "network"
        model = { type = "virtio" }
        source = {
          network = {
            network = "lab"
          }
        }
      }
    ]

    graphics = [
      {
        vnc = {
          auto_port = true
          listen    = "0.0.0.0"
        }
      }
    ]

    consoles = [
      {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
      }
    ]
  }

  running = true
}

resource "libvirt_domain" "master3" {
  name   = "TZUSDSRAPP0003"
  memory = var.master_memory
  vcpu   = var.master_vcpu
  type   = "kvm"

  os = {
    type    = "hvm"
    arch    = "x86_64"
    machine = "q35"
    boot_devices = [
      { dev = "hd" }
    ]
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            pool   = libvirt_volume.master3_disk.pool
            volume = libvirt_volume.master3_disk.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vda"
        }
        driver = {
          type = "qcow2"
        }
      },
      {
        source = {
          volume = {
            pool   = libvirt_volume.cloudinit_master3_volume.pool
            volume = libvirt_volume.cloudinit_master3_volume.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vdb"
        }
        readonly = true
      }
    ]

    interfaces = [
      {
        type  = "network"
        model = { type = "virtio" }
        source = {
          network = {
            network = "lab"
          }
        }
      }
    ]

    graphics = [
      {
        vnc = {
          auto_port = true
          listen    = "0.0.0.0"
        }
      }
    ]

    consoles = [
      {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
      }
    ]
  }

  running = true
}


# ===================================================
# WORKER NODE VIRTUAL MACHINES
# ===================================================

resource "libvirt_domain" "worker1" {
  name   = "TZUSDSRAPP0004"
  memory = var.worker_memory
  vcpu   = var.worker_vcpu
  type   = "kvm"

  os = {
    type    = "hvm"
    arch    = "x86_64"
    machine = "q35"
    boot_devices = [
      { dev = "hd" }
    ]
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            pool   = libvirt_volume.worker1_disk.pool
            volume = libvirt_volume.worker1_disk.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vda"
        }
        driver = {
          type = "qcow2"
        }
      },
      {
        source = {
          volume = {
            pool   = libvirt_volume.cloudinit_worker1_volume.pool
            volume = libvirt_volume.cloudinit_worker1_volume.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vdb"
        }
        readonly = true
      }
    ]

    interfaces = [
      {
        type  = "network"
        model = { type = "virtio" }
        source = {
          network = {
            network = "lab"
          }
        }
      }
    ]

    graphics = [
      {
        vnc = {
          auto_port = true
          listen    = "0.0.0.0"
        }
      }
    ]

    consoles = [
      {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
      }
    ]
  }

  running = true
}

resource "libvirt_domain" "worker2" {
  name   = "TZUSDSRAPP0005"
  memory = var.worker_memory
  vcpu   = var.worker_vcpu
  type   = "kvm"

  os = {
    type    = "hvm"
    arch    = "x86_64"
    machine = "q35"
    boot_devices = [
      { dev = "hd" }
    ]
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            pool   = libvirt_volume.worker2_disk.pool
            volume = libvirt_volume.worker2_disk.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vda"
        }
        driver = {
          type = "qcow2"
        }
      },
      {
        source = {
          volume = {
            pool   = libvirt_volume.cloudinit_worker2_volume.pool
            volume = libvirt_volume.cloudinit_worker2_volume.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vdb"
        }
        readonly = true
      }
    ]

    interfaces = [
      {
        type  = "network"
        model = { type = "virtio" }
        source = {
          network = {
            network = "lab"
          }
        }
      }
    ]

    graphics = [
      {
        vnc = {
          auto_port = true
          listen    = "0.0.0.0"
        }
      }
    ]

    consoles = [
      {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
      }
    ]
  }

  running = true
}

resource "libvirt_domain" "worker3" {
  name   = "TZUSDSRAPP0006"
  memory = var.worker_memory
  vcpu   = var.worker_vcpu
  type   = "kvm"

  os = {
    type    = "hvm"
    arch    = "x86_64"
    machine = "q35"
    boot_devices = [
      { dev = "hd" }
    ]
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            pool   = libvirt_volume.worker3_disk.pool
            volume = libvirt_volume.worker3_disk.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vda"
        }
        driver = {
          type = "qcow2"
        }
      },
      {
        source = {
          volume = {
            pool   = libvirt_volume.cloudinit_worker3_volume.pool
            volume = libvirt_volume.cloudinit_worker3_volume.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vdb"
        }
        readonly = true
      }
    ]

    interfaces = [
      {
        type  = "network"
        model = { type = "virtio" }
        source = {
          network = {
            network = "lab"
          }
        }
      }
    ]

    graphics = [
      {
        vnc = {
          auto_port = true
          listen    = "0.0.0.0"
        }
      }
    ]

    consoles = [
      {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
      }
    ]
  }

  running = true
}

resource "libvirt_domain" "worker4" {
  name   = "TZUSDSRAPP0007"
  memory = var.worker_memory
  vcpu   = var.worker_vcpu
  type   = "kvm"

  os = {
    type    = "hvm"
    arch    = "x86_64"
    machine = "q35"
    boot_devices = [
      { dev = "hd" }
    ]
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            pool   = libvirt_volume.worker4_disk.pool
            volume = libvirt_volume.worker4_disk.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vda"
        }
        driver = {
          type = "qcow2"
        }
      },
      {
        source = {
          volume = {
            pool   = libvirt_volume.cloudinit_worker4_volume.pool
            volume = libvirt_volume.cloudinit_worker4_volume.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vdb"
        }
        readonly = true
      }
    ]

    interfaces = [
      {
        type  = "network"
        model = { type = "virtio" }
        source = {
          network = {
            network = "lab"
          }
        }
      }
    ]

    graphics = [
      {
        vnc = {
          auto_port = true
          listen    = "0.0.0.0"
        }
      }
    ]

    consoles = [
      {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
      }
    ]
  }

  running = true
}

resource "libvirt_domain" "worker5" {
  name   = "TZUSDSRAPP0008"
  memory = var.worker_memory
  vcpu   = var.worker_vcpu
  type   = "kvm"

  os = {
    type    = "hvm"
    arch    = "x86_64"
    machine = "q35"
    boot_devices = [
      { dev = "hd" }
    ]
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            pool   = libvirt_volume.worker5_disk.pool
            volume = libvirt_volume.worker5_disk.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vda"
        }
        driver = {
          type = "qcow2"
        }
      },
      {
        source = {
          volume = {
            pool   = libvirt_volume.cloudinit_worker5_volume.pool
            volume = libvirt_volume.cloudinit_worker5_volume.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vdb"
        }
        readonly = true
      }
    ]

    interfaces = [
      {
        type  = "network"
        model = { type = "virtio" }
        source = {
          network = {
            network = "lab"
          }
        }
      }
    ]

    graphics = [
      {
        vnc = {
          auto_port = true
          listen    = "0.0.0.0"
        }
      }
    ]

    consoles = [
      {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
      }
    ]
  }

  running = true
}

resource "libvirt_domain" "worker6" {
  name   = "TZUSDSRAPP0009"
  memory = var.worker_memory
  vcpu   = var.worker_vcpu
  type   = "kvm"

  os = {
    type    = "hvm"
    arch    = "x86_64"
    machine = "q35"
    boot_devices = [
      { dev = "hd" }
    ]
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            pool   = libvirt_volume.worker6_disk.pool
            volume = libvirt_volume.worker6_disk.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vda"
        }
        driver = {
          type = "qcow2"
        }
      },
      {
        source = {
          volume = {
            pool   = libvirt_volume.cloudinit_worker6_volume.pool
            volume = libvirt_volume.cloudinit_worker6_volume.name
          }
        }
        target = {
          bus = "virtio"
          dev = "vdb"
        }
        readonly = true
      }
    ]

    interfaces = [
      {
        type  = "network"
        model = { type = "virtio" }
        source = {
          network = {
            network = "lab"
          }
        }
      }
    ]

    graphics = [
      {
        vnc = {
          auto_port = true
          listen    = "0.0.0.0"
        }
      }
    ]

    consoles = [
      {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
      }
    ]
  }

  running = true
}


# ===================================================
# OUTPUTS
# ===================================================

output "master_ips" {
  value = {
    master-1 = "172.168.122.21"
    master-2 = "172.168.122.22"
    master-3 = "172.168.122.23"
  }
  description = "IP addresses of master nodes"
}

output "worker_ips" {
  value = {
    worker-1 = "172.168.122.31"
    worker-2 = "172.168.122.32"
    worker-3 = "172.168.122.33"
    worker-4 = "172.168.122.34"
    worker-5 = "172.168.122.35"
    worker-6 = "172.168.122.36"
  }
  description = "IP addresses of worker nodes"
}

output "all_vms" {
  value = {
    masters = [
      libvirt_domain.master1.name,
      libvirt_domain.master2.name,
      libvirt_domain.master3.name
    ]
    workers = [
      libvirt_domain.worker1.name,
      libvirt_domain.worker2.name,
      libvirt_domain.worker3.name,
      libvirt_domain.worker4.name,
      libvirt_domain.worker5.name,
      libvirt_domain.worker6.name
    ]
  }
  description = "Names of all created VMs"
}

output "instructions" {
  value = <<-EOF

    ================================================
    openSUSE MicroOS Cluster Deployment Complete!
    ================================================

    Virtual machines have been created with the following configuration:
    
    RESOURCE ALLOCATION:
    - Total Host RAM: 64GB
    - Total Host CPUs: 12 cores
    
    MASTER NODES (3 nodes):
      master-1 → 172.168.122.21 (${var.master_memory}MB RAM, ${var.master_vcpu} vCPUs)
      master-2 → 172.168.122.22 (${var.master_memory}MB RAM, ${var.master_vcpu} vCPUs)
      master-3 → 172.168.122.23 (${var.master_memory}MB RAM, ${var.master_vcpu} vCPUs)
      Total Master Resources: ${var.master_memory * 3}MB RAM, ${var.master_vcpu * 3} vCPUs

    WORKER NODES (6 nodes):
      worker-1 → 172.168.122.31 (${var.worker_memory}MB RAM, ${var.worker_vcpu} vCPUs)
      worker-2 → 172.168.122.32 (${var.worker_memory}MB RAM, ${var.worker_vcpu} vCPUs)
      worker-3 → 172.168.122.33 (${var.worker_memory}MB RAM, ${var.worker_vcpu} vCPUs)
      worker-4 → 172.168.122.34 (${var.worker_memory}MB RAM, ${var.worker_vcpu} vCPUs)
      worker-5 → 172.168.122.35 (${var.worker_memory}MB RAM, ${var.worker_vcpu} vCPUs)
      worker-6 → 172.168.122.36 (${var.worker_memory}MB RAM, ${var.worker_vcpu} vCPUs)
      Total Worker Resources: ${var.worker_memory * 6}MB RAM, ${var.worker_vcpu * 6} vCPUs

    TOTAL RESOURCE USAGE:
    - RAM: ${(var.master_memory * 3) + (var.worker_memory * 6)}MB / 65536MB
    - vCPUs: ${(var.master_vcpu * 3) + (var.worker_vcpu * 6)} / 12 cores

    CONNECTION INFORMATION:
    - SSH to any node: ssh student@<IP-ADDRESS>
    - Student Password: ${var.student_password}
    - Root Password: ${var.root_password}

    VIEW VM CONSOLES:
      sudo virsh console master-1
      sudo virsh console master-2
      sudo virsh console master-3
      sudo virsh console worker-1
      sudo virsh console worker-2
      sudo virsh console worker-3
      sudo virsh console worker-4
      sudo virsh console worker-5
      sudo virsh console worker-6

    VNC ACCESS:
      Find VNC port: sudo virsh domdisplay <vm-name>
      Then connect with any VNC client

    CHECK VM STATUS:
      sudo virsh list --all

    DESTROY ALL VMS:
      terraform destroy

    NOTE: openSUSE MicroOS is a transactional update system.
    - Use 'transactional-update' for system updates
    - Reboot after updates to apply changes
    - The root filesystem is read-only by default
    
    It may take 60-90 seconds after boot for cloud-init to complete
    and SSH to become available.
  EOF
}
