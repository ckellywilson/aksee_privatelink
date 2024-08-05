param location string
param networkInterfaceName1 string
param enableAcceleratedNetworking bool
param networkSecurityGroupName string
param networkSecurityGroupRules array
param subnetName string
param virtualNetworkName string
param addressPrefixes array
param subnets array
param publicIpAddressName1 string
param publicIpAddressType string
param publicIpAddressSku string
param pipDeleteOption string
param virtualMachineName1 string
param virtualMachineComputerName1 string
param osDiskType string
param osDiskDeleteOption string
param virtualMachineSize string
param nicDeleteOption string
param adminUsername string

@secure()
param adminPassword string
param virtualMachine1Zone string
param tags object
param dnsLabelPrefix string

var nsgId = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
param OSVersion string = '2022-datacenter-azure-edition'

resource networkInterface1 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: networkInterfaceName1
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)          
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpAddressName1)
            properties: {
              deleteOption: pipDeleteOption
            }
          }
        }
      }
    ]
    enableAcceleratedNetworking: enableAcceleratedNetworking
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    networkSecurityGroup
    virtualNetwork
    publicIpAddress1
  ]
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: networkSecurityGroupName
  location: location
  tags: tags
  properties: {
    securityRules: networkSecurityGroupRules
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: subnets
  }
}

resource publicIpAddress1 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: publicIpAddressName1
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: publicIpAddressType
    dnsSettings:{
      domainNameLabel: dnsLabelPrefix
    }
  }
  sku: {
    name: publicIpAddressSku
  }
  zones: [
    virtualMachine1Zone
  ]
}

resource virtualMachine1 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: virtualMachineName1
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        deleteOption: osDiskDeleteOption
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface1.id
          properties: {
            deleteOption: nicDeleteOption
          }
        }
      ]
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    osProfile: {
      computerName: virtualMachineComputerName1
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  zones: [
    virtualMachine1Zone
  ]
}

output vmName string = virtualMachine1.name
output adminUsername string = virtualMachine1.properties.osProfile.adminUsername
output adminPublicKey string = virtualMachine1.properties.osProfile.linuxConfiguration.ssh.publicKeys[0].keyData
output fqdn string = virtualMachine1.properties.osProfile.computerName
output resourceGroupName string = resourceGroup().name
