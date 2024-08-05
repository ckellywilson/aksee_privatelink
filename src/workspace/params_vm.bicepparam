using 'vm.bicep'

param prefix = 'aksee'
param networkInterfaceName = 'aksee-vm1652'
param enableAcceleratedNetworking = true
param networkSecurityGroupName = 'aksee-vm1-nsg'
param networkSecurityGroupRules = [
  {
    name: 'RDP'
    properties: {
      priority: 300
      protocol: 'TCP'
      access: 'Allow'
      direction: 'Inbound'
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '3389'
    }
  }
]

param subnetName = 'default'
param virtualNetworkId = '/subscriptions/494116cb-e794-4266-98e5-61c178d62cb4/resourceGroups/aksee-rg/providers/Microsoft.Network/virtualNetworks/aksee-vnet'
param publicIpAddressName = 'aksee-vm1-ip'
param publicIpAddressType = 'Static'
param publicIpAddressSku = 'Standard'
param pipDeleteOption = 'Detach'
param virtualMachineComputerName = 'aksee-vm1'
param osDiskType = 'Premium_LRS'
param osDiskDeleteOption = 'Delete'
param virtualMachineSize = 'Standard_D4s_v3'
param nicDeleteOption = 'Detach'
param adminUsername = 'aksee-admin'
param adminPassword = 'password123'
param patchMode = 'AutomaticByOS'
param enableHotpatching = false
