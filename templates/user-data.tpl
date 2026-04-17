#cloud-config
users:
  - name: root
    ssh_authorized_keys:
      - ${SSH_PUB_KEY}

write_files:
  - path: /etc/hostname
    content: ${HOSTNAME}

runcmd:
  - hostnamectl set-hostname ${HOSTNAME}