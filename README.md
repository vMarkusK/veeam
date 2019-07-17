# Veeam


This Role ships Ansible modules for the management of Veeam Backup & Replication.

## Requirements

The Veeam modules are based on the Veeam PowerShell cmdlets ([Veeam PowerShell Reference](https://helpcenter.veeam.com/docs/backup/powershell/cmdlets.html?ver=95u4)). All modules are designed to be executed on a Veeam Veeam Backup & Replication server with installed console and PowerShell Snapin, no remote connection.

## Role Variables

The settable variables depend on the individual module used.

## Dependencies

none

## Example Playbook

### Get Veeam Facts

```
- name: Get all VBR Facts
  hosts: veeam
  gather_facts: no
  roles:
  - veeam
  tasks:
  - name: Get Veeam Facts
    veeam_connection_facts:
    register: my_facts
  - name: Debug Veeam Facts
    debug:
        var: my_facts
```

### Add Veeam Credentials

```
- name: Add new Credentials to VBR Server
  hosts: veeam
  gather_facts: no
  roles:
  - veeam
  vars:
    query: "veeam_facts.veeam_credentials[?id=='{{ my_cred.id }}']"
    my_password: < Dummy >
  tasks:
  - name: Add Credential
    veeam_credential:
        state: present
        type: windows
        username: Administrator
        password: "{{ my_password }}"
        description: My dummy description
    register: my_cred
  - name: Debug Veeam Credentials
    debug:
        var: my_cred
  - name: Get Veeam Facts
    veeam_connection_facts:
    register: my_facts
  - name: Debug Veeam Credential Facts
    debug:
        var: my_facts  | json_query(query)
  - name: Remove Credential
    veeam_credential:
        state: absent
        id: "{{ my_cred.id }}"
```

### Add VMware ESXi Host to VBR Server

```
- name: Add ESXi Host to VBR Server
  hosts: veeam
  gather_facts: no
  roles:
  - veeam
  vars:
    root_password: < Dummy >
  tasks:
  - name: Add root credential
    veeam_credential:
        state: present
        type: standard
        username: root
        password: "{{ root_password }}"
        description: "Lab User for Standalone Host"
    register: root_cred
  - name: Debug root credential
    debug:
        var: root_cred
  - name: Add esxi server
    veeam_server:
        state: present
        type: esxi
        credential_id: "{{ root_cred.id }}"
        name: 192.168.234.101
    register: esxi_server
  - name: Get Veeam Facts
    veeam_connection_facts:
    register: my_facts
  - name: Debug Veeam Servers from Facts
    debug:
        var: my_facts.veeam_facts.veeam_servers
```

## License

GNU Lesser General Public License v3.0

## Author Information

Markus Kraus [@vMarkus_K](https://twitter.com/vMarkus_K)
MY CLOUD-(R)EVOLUTION [mycloudrevolution.com](http://mycloudrevolution.com/)
