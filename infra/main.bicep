targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment. Used only for azd bookkeeping and tagging.')
param environmentName string

@minLength(1)
@description('Name of the existing resource group that contains the target App Service.')
param resourceGroupName string

@minLength(1)
@description('Name of the existing App Service (Web App) that will host the backend deployment.')
param backendServiceName string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

resource webApp 'Microsoft.Web/sites@2023-01-01' existing = {
  name: backendServiceName
  scope: resourceGroup
}

output AZURE_RESOURCE_GROUP string = resourceGroupName
output AZURE_LOCATION string = webApp.location
output AZURE_WEBAPP_NAME string = webApp.name
output BACKEND_URI string = 'https://${webApp.properties.defaultHostName}'
