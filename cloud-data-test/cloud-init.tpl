#cloud-config
package_upgrade: true
packages:
  - jq
  - unzip
write_files:
  - owner: ${username}:${username}
    path: /home/${username}/.ssh/identity
    permissions: '700'
    content: |
      ${priv_key}

runcmd:
  - wget https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssl -O /home/${username}/cfssl
  - wget https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssljson -O /home/${username}/cfssljson
  - wget https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl -O /home/${username}/kubectl
  - chmod +x /home/${username}/cfssl
  - chmod +x /home/${username}/cfssljson
  - chmod +x /home/${username}/kubectl
  - mv /home/${username}/cfssl /usr/bin/cfssl
  - mv /home/${username}/cfssljson /usr/bin/cfssljson
  - mv /home/${username}/kubectl /usr/bin/kubectl