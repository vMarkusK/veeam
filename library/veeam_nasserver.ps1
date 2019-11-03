#!powershell

# Copyright: (c) 2019, Markus Kraus <markus.kraus@gmail.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -OSVersion 6.2
#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options = @{
        type = @{ type = "str"; choices = "nfs", "smb"; default = "nfs" }
        state = @{ type = "str"; choices = "absent", "present"; default = "present" }
        path = @{ type = "str" }
        cacherepository = @{ type = "str" }
        id = @{ type = "str" }

    }
    required_if = @(@("state", "present", @("type", "path", "cacherepository")),
                    @("state", "absent", @("id")))
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

# Functions
Function Connect-VeeamServer {
    try {
        Add-PSSnapin -PassThru VeeamPSSnapIn -ErrorAction Stop | Out-Null
    }
    catch {
        Fail-Json -obj @{} -message  "Failed to load Veeam SnapIn on the target: $($_.Exception.Message)"  
            
    }

    try {
        Connect-VBRServer -Server localhost
    }
    catch {
        Fail-Json -obj @{} -message "Failed to connect VBR Server on the target: $($_.Exception.Message)"  
    }
}
Function Disconnect-VeeamServer {
    try {
        Disconnect-VBRServer
    }
    catch {
        Fail-Json -obj @{} -message "Failed to disconnect VBR Server on the target: $($_.Exception.Message)"  
    }
}

# Connect
Connect-VeeamServer

switch ( $module.Params.state) {
    "present" { $Repositroy = Get-VBRBackupRepository -Name $module.Params.cacherepository
                    switch ($module.Params.type) {
                        "nfs" {     $NASServer = Add-VBRNASNFSServer -Path $module.Params.path -CacheRepository $Repositroy
                                    $module.Result.changed = $true
                                    $module.Result.id = $NASServer.id  
                                }
                        "smb" { Fail-Json -obj @{} -message "Type not yet implemented."
                            
                                    }
                        Default { }
                    }
                }
    "absent" { Fail-Json -obj @{} -message "State not yet implemented."
                }
    Default {}
}

# Disconnect
Disconnect-VeeamServer

# Return result
$module.ExitJson()
