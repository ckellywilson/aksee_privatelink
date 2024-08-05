targetScope = 'resourceGroup'

param sshKeyName string
param location string
param keyData string
param tags object


resource sshKey 'Microsoft.Compute/sshPublicKeys@2023-09-01' = {
  name: sshKeyName
  location: location
  tags: tags
  properties: {
    publicKey: keyData
  }
}

output sshKey string = sshKey.properties.publicKey
