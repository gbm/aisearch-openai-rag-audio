targetScope = 'resourceGroup'

@minLength(1)
@description('Name of the existing App Service (Web App) that will host the backend deployment.')
param backendServiceName string

resource webApp 'Microsoft.Web/sites@2023-01-01' existing = {
  name: backendServiceName
}

var backendTags = union(webApp.tags ?? {}, {
  'azd-service-name': 'backend'
})

resource webAppConfig 'Microsoft.Web/sites/config@2023-01-01' = {
  name: 'web'
  parent: webApp
  properties: {
    appCommandLine: 'python -m gunicorn "app:create_app()" --bind=0.0.0.0:8000 --worker-class aiohttp.GunicornWebWorker'
  }
}

resource webAppSettings 'Microsoft.Web/sites/config@2023-01-01' = {
  name: 'appsettings'
  parent: webApp
  properties: {
    PYTHONPATH: '/home/site/wwwroot/.python_packages/lib/site-packages'
    WEBSITE_RUN_FROM_PACKAGE: '1'
  }
}

resource webAppServiceTag 'Microsoft.Resources/tags@2021-04-01' = {
  name: 'default'
  scope: webApp
  properties: {
    tags: backendTags
  }
}

output AZURE_RESOURCE_GROUP string = resourceGroup().name
output AZURE_LOCATION string = webApp.location
output AZURE_WEBAPP_NAME string = webApp.name
output BACKEND_URI string = 'https://${webApp.properties.defaultHostName}'
