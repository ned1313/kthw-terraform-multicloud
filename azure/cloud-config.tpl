#cloud-config
# vim: syntax=yaml
#

write_files:
-   encoding: b64
    content: ${priv_key}
    owner: ${username}:${username}
    path: /home/$username/.ssh/identity
    permissions: '0700'

runcmd:
 - [ wget, "https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssl", -O, /run/kthw/cfssl ]
 - [ wget, "https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssljson", -O, /run/kthw/cfssljson ]
 - [ wget, "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl", -O, /run/kthw/kubectl]
 - [ chmod, +x /run/kthw/cfssl ]
 - [ chmod, +x /run/kthw/cfssljson ]
 - [ chmod, +x /run/kthw/kubectl ]
 - [ mv, /run/kthw/cfssl /usr/bin/cfssl ]
 - [ mv, /run/kthw/cfssljson /usr/bin/cfssljson ]
 - [ mv, /run/kthw/kubectl /usr/bin/kubectl ]