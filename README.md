# Veeam


This Role ships Ansible modules for the management of Veeam Backup & Replication.

## Requirements

The Veeam modules are based on the Veeam PowerShell cmdlets ([Veeam PowerShell Reference](https://helpcenter.veeam.com/docs/backup/powershell/cmdlets.html?ver=95u4)). All modules are designed to be executed on a Veeam Veeam Backup & Replication server with installed console and PowerShell Snapin, no remote connection.

## Role Variables

The settable variables depend on the individual module used.

## Dependencies

none

## Release Notes

### Version 0.1

- veeam_connection_facts - Version 0.3
  - Get Veeam Server Connection
  - Get Veeam Repositories
  - Get Veeam Servers
  - Get Veeam Credentials

- veeam_credential - Version 0.2
  - Add Windows, Linux or Standard Credential
  - Remove Credential by ID

- veeam_server - Version 0.2
  - Add VMware ESXi Server

### Version 0.2
- veeam_server - Version 0.3
  - Add VMware vCenter Server

### Version 0.3
- veeam_backup - Version 0.1
  - Add VMware Backuo Job based on tags

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

### Add VMware vCenter Server to VBR Server

```
- name: Add vCenter Server to VBR Server
  hosts: veeam
  gather_facts: no
  roles:
  - veeam
  vars:
    vcenter_password: <Dummy>
  tasks:
  - name: Add vCenter credential
    veeam_credential:
        state: present
        type: standard
        username: Administrator@vSphere.local
        password: "{{ vcenter_password }}"
        description: "Lab User for vCenter Server"
    register: vcenter_cred
  - name: Debug vcenter credential
    debug:
        var: vcenter_cred
  - name: Add vCenter server
    veeam_server:
        state: present
        type: vcenter
        credential_id: "{{ vcenter_cred.id }}"
        name: 192.168.234.100
    register: vcenter_server
  - name: Get Veeam Facts
    veeam_connection_facts:
    register: my_facts
  - name: Debug Veeam Servers from Facts
    debug:
        var: my_facts.veeam_facts.veeam_servers
```
### Add VMware Backup Job based on Tags

```
- name: Add new Backup Job
  hosts: veeam
  gather_facts: no
  roles:
  - veeam
  vars:
    query: "veeam_facts.veeam_backups[?id=='{{ my_backup.id }}']"
  tasks:
  - name: Create Backup Job
    veeam_backup:
        state: present
        type: vi
        entity: tag
        tag: "Protection\\\\Default"
        name: BackupJob01
        repository: "Default Backup repository"
    register: my_backup
  - name: Get Veeam Facts
    veeam_connection_facts:
    register: my_facts
  - name: Debug Veeam Backup Job Facts
    debug:
        var: my_facts | json_query(query)
```

## License

GNU Lesser General Public License v3.0

## Author Information

Markus Kraus [@vMarkus_K](https://twitter.com/vMarkus_K)
MY CLOUD-(R)EVOLUTION [mycloudrevolution.com](http://mycloudrevolution.com/)
