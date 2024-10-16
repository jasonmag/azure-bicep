param location string
param networkInterfaceName1 string
param networkInterfaceName2 string
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
param virtualMachineName string
param virtualMachineName1 string
param virtualMachineComputerName1 string
param virtualMachineRG string
param osDiskType string
param osDiskDeleteOption string
param virtualMachineSize string
param nicDeleteOption string
param hibernationEnabled bool
param adminUsername string

@secure()
param adminPublicKey string
param virtualMachineName2 string
param virtualMachineComputerName2 string
param virtualMachine1Zone string
param virtualMachine2Zone string
param healthExtensionProtocol string
param healthExtensionPort int
param healthExtensionRequestPath string
param loadBalancerName string
param loadbalancingRuleFrontEndPort int
param loadbalancingRuleBackendEndPort int
param loadbalancingRuleProtocol string
param InboundNATRuleFrontEndPortRangeStart int

var nsgId = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
var vnetName = virtualNetworkName
var vnetId = resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', virtualNetworkName)
var subnetRef = '${vnetId}/subnets/${subnetName}'
var instanceCount = '2'

resource networkInterface1 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: networkInterfaceName1
  location: location
  tags: {
    project: 'positivum'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpAddressName1)
            properties: {
              deleteOption: pipDeleteOption
            }
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId(
                'Microsoft.Network/loadBalancers/backendAddressPools',
                loadBalancerName,
                '${take(loadBalancerName,(80-length('-backendpool01')))}-backendpool01'
              )
            }
          ]
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    networkSecurityGroup
    virtualNetwork
    publicIpAddress1
    loadBalancer
  ]
}

resource networkInterface2 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: networkInterfaceName2
  location: location
  tags: {
    project: 'positivum'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          loadBalancerBackendAddressPools: [
            {
              id: resourceId(
                'Microsoft.Network/loadBalancers/backendAddressPools',
                loadBalancerName,
                '${take(loadBalancerName,(80-length('-backendpool01')))}-backendpool01'
              )
            }
          ]
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    networkSecurityGroup
    virtualNetwork
    loadBalancer
  ]
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: networkSecurityGroupName
  location: location
  tags: {
    project: 'positivum'
  }
  properties: {
    securityRules: networkSecurityGroupRules
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  tags: {
    project: 'positivum'
  }
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
  tags: {
    project: 'positivum'
  }
  sku: {
    name: publicIpAddressSku
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
}

resource virtualMachine1 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: virtualMachineName1
  location: location
  tags: {
    project: 'positivum'
  }
  zones: [
    virtualMachine1Zone
  ]
  plan: {
    name: '3-0'
    publisher: 'bitnami'
    product: 'moodle'
  }
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
        publisher: 'bitnami'
        offer: 'moodle'
        sku: '3-0'
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
    securityProfile: {}
    additionalCapabilities: {
      hibernationEnabled: false
    }
    osProfile: {
      computerName: virtualMachineComputerName1
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminPublicKey
            }
          ]
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource virtualMachine2 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: virtualMachineName2
  location: location
  tags: {
    project: 'positivum'
  }
  zones: [
    virtualMachine2Zone
  ]
  plan: {
    name: '3-0'
    publisher: 'bitnami'
    product: 'moodle'
  }
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
        publisher: 'bitnami'
        offer: 'moodle'
        sku: '3-0'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface2.id
          properties: {
            deleteOption: nicDeleteOption
          }
        }
      ]
    }
    securityProfile: {}
    additionalCapabilities: {
      hibernationEnabled: false
    }
    osProfile: {
      computerName: virtualMachineComputerName2
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminPublicKey
            }
          ]
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource loadBalancerName_publicip 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: '${loadBalancerName}-publicip'
  location: location
  sku: {
    name: 'Standard'
  }
  zones: [
    '1'
    '2'
  ]
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 15
  }
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2021-05-01' = {
  name: loadBalancerName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: '${take(loadBalancerName,(80-length('-frontendconfig01')))}-frontendconfig01'
        properties: {
          publicIPAddress: {
            id: loadBalancerName_publicip.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: '${take(loadBalancerName,(80-length('-backendpool01')))}-backendpool01'
      }
    ]
    loadBalancingRules: [
      {
        name: '${loadBalancerName}-lbrule01'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/frontendIPConfigurations',
              loadBalancerName,
              '${take(loadBalancerName,(80-length('-frontendconfig01')))}-frontendconfig01'
            )
          }
          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/backendAddressPools',
              loadBalancerName,
              '${take(loadBalancerName,(80-length('-backendpool01')))}-backendpool01'
            )
          }
          frontendPort: loadbalancingRuleFrontEndPort
          backendPort: loadbalancingRuleBackendEndPort
          enableFloatingIP: false
          idleTimeoutInMinutes: 15
          disableOutboundSnat: true
          loadDistribution: 'Default'
          protocol: loadbalancingRuleProtocol
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, '${loadBalancerName}-probe01')
          }
        }
      }
    ]
    probes: [
      {
        name: '${loadBalancerName}-probe01'
        properties: {
          intervalInSeconds: 15
          numberOfProbes: 2
          requestPath: ((loadbalancingRuleProtocol == 'Tcp') ? json('null') : '/')
          port: ((loadbalancingRuleProtocol == 'Tcp') ? loadbalancingRuleBackendEndPort : '80')
          protocol: ((loadbalancingRuleProtocol == 'Tcp') ? 'Tcp' : 'Http')
        }
      }
    ]
    inboundNatRules: [
      {
        name: '${loadBalancerName}-natRule01'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/frontendIPConfigurations',
              loadBalancerName,
              '${take(loadBalancerName,(80-length('-frontendconfig01')))}-frontendconfig01'
            )
          }
          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/backendAddressPools',
              loadBalancerName,
              '${take(loadBalancerName,(80-length('-backendpool01')))}-backendpool01'
            )
          }
          protocol: 'TCP'
          enableFloatingIP: false
          enableTcpReset: false
          backendPort: 22
          frontendPortRangeStart: InboundNATRuleFrontEndPortRangeStart
          frontendPortRangeEnd: (InboundNATRuleFrontEndPortRangeStart + ((instanceCount == json('null')) ? 0 : 3599))
        }
      }
    ]
  }
  dependsOn: [
    'Microsoft.Network/publicIpAddresses/${loadBalancerName}-publicip'
  ]
}

resource virtualMachineName1_HealthExtension 'Microsoft.Compute/virtualMachines/extensions@2024-03-01' = {
  parent: virtualMachine1
  name: 'HealthExtension'
  location: location
  tags: {
    project: 'positivum'
  }
  properties: {
    publisher: 'Microsoft.ManagedServices'
    type: 'ApplicationHealthLinux'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: false
    settings: {
      protocol: healthExtensionProtocol
      port: healthExtensionPort
      requestPath: healthExtensionRequestPath
    }
  }
  dependsOn: [
    virtualMachine2
  ]
}

resource virtualMachineName2_HealthExtension 'Microsoft.Compute/virtualMachines/extensions@2024-03-01' = {
  parent: virtualMachine2
  name: 'HealthExtension'
  location: location
  tags: {
    project: 'positivum'
  }
  properties: {
    publisher: 'Microsoft.ManagedServices'
    type: 'ApplicationHealthLinux'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: false
    settings: {
      protocol: healthExtensionProtocol
      port: healthExtensionPort
      requestPath: healthExtensionRequestPath
    }
  }
  dependsOn: [
    virtualMachineName1_HealthExtension
  ]
}

output adminUsername string = adminUsername
