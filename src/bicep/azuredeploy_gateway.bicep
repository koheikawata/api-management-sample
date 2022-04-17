param base_name string
param environment_symbol string
param aad_objectid_svc string
param aad_appid_client string
param aad_appid_backend string
param aad_tenantid string
param basic_auth_user string
param kvcert_name_api string
param kvsecret_name_basic_pass string
param kvsecret_name_cert_thumbprint string
param kvsecret_name_clientsecret string
param kvsecret_name_subscription_key string
param apim_api_name_ad string
param apim_api_path_ad string
param apim_api_name_basic string
param apim_api_path_basic string
param apim_api_name_cert string
param apim_api_path_cert string
@secure()
param basic_auth_pass string
@secure()
param client_secret string
@secure()
param cert_thumbprint string

param apim_nv_authserver string
param apim_nv_clientid string
param apim_nv_scope string
param apim_nv_clientsecret string
param apim_nv_basicauthuser string
param apim_nv_basicauthpass string
param apim_nv_thumbprint string
param apim_certificate_id string

param location string = resourceGroup().location
param tenant_id string = subscription().tenantId

var appsrvplan_name_ad = 'aplan-a-${base_name}-${environment_symbol}'
var appsrv_name_ad = 'app-a-${base_name}-${environment_symbol}'
var appsrvplan_name_basic = 'aplan-b-${base_name}-${environment_symbol}'
var appsrv_name_basic = 'app-b-${base_name}-${environment_symbol}'
var appsrvplan_name_cert = 'aplan-c-${base_name}-${environment_symbol}'
var appsrv_name_cert = 'app-c-${base_name}-${environment_symbol}'
var kv_name = 'kv-${base_name}-${environment_symbol}'
var apim_name = 'apim-${base_name}-${environment_symbol}'
var apim_service_url_ad = 'https://${appsrv_name_ad}.azurewebsites.net'
var apim_service_url_basic = 'https://${appsrv_name_basic}.azurewebsites.net'
var apim_service_url_cert = 'https://${appsrv_name_cert}.azurewebsites.net'

resource AppServicePlanBasic 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appsrvplan_name_basic
  location: location
  kind: 'app'
  sku: {
    name: 'S1'
  }
}

resource AppServiceBasic 'Microsoft.Web/sites@2021-03-01' = {
  name: appsrv_name_basic
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: AppServicePlanBasic.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: '6.0'
      http20Enabled: true
      minTlsVersion: '1.2'
    }
  }
}

resource AppServiceConfigBasic 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${AppServiceBasic.name}/appsettings'
  properties: {
    'BasicAuth:UserName': basic_auth_user
    'BasicAuth:Password': '@Microsoft.KeyVault(VaultName=${kv_name};SecretName=${kvsecret_name_basic_pass})'
    'WEBSITE_RUN_FROM_PACKAGE': 1
  }
}

resource AppServicePlanCert 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appsrvplan_name_cert
  location: location
  kind: 'app'
  sku: {
    name: 'S1'
  }
}

resource AppServiceCert 'Microsoft.Web/sites@2021-03-01' = {
  name: appsrv_name_cert
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: AppServicePlanCert.id
    httpsOnly: true
    clientCertEnabled: true
    clientCertMode: 'Required'
    siteConfig: {
      netFrameworkVersion: '6.0'
      http20Enabled: true
      minTlsVersion: '1.2'
    }
  }
}

resource AppServiceConfigCert 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${AppServiceCert.name}/appsettings'
  properties: {
    'Certificate:PfxFilePath': ''
    'Certificate:PfxFilePassword': ''
    'Certificate:Thumbprint': '@Microsoft.KeyVault(VaultName=${kv_name};SecretName=${kvsecret_name_cert_thumbprint})'
    'WEBSITE_RUN_FROM_PACKAGE': 1
  }
}

resource AppServicePlanAd 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appsrvplan_name_ad
  location: location
  kind: 'app'
  sku: {
    name: 'S1'
  }
}

resource AppServiceAd 'Microsoft.Web/sites@2021-03-01' = {
  name: appsrv_name_ad
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: AppServicePlanAd.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: '6.0'
      http20Enabled: true
      minTlsVersion: '1.2'
    }
  }
}

resource AppServiceConfigAd 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${AppServiceAd.name}/appsettings'
  properties: {
    'AzureAd:Instance': '${environment().authentication.loginEndpoint}'
    'AzureAd:ClientId': aad_appid_backend
    'AzureAd:TenantId': aad_tenantid
    'AzureAd:CallbackPath': '/signin-oidc'
    'AllowWebApiToBeAuthorizedByACL': true
    'WEBSITE_RUN_FROM_PACKAGE': 1
  }
}

resource KeyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: kv_name
  location: location
  properties: {
    tenantId: tenant_id
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: [
      {
        tenantId: tenant_id
        objectId: aad_objectid_svc
        permissions: {
          secrets: [
            'get'
            'set'
          ]
          certificates: [
            'get'
          ]
        }
      }
    ]
  }
}

resource KeyVaultAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2021-10-01' = {
  name: '${KeyVault.name}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: tenant_id
        objectId: AppServiceBasic.identity.principalId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
      {
        tenantId: tenant_id
        objectId: AppServiceCert.identity.principalId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
      {
        tenantId: tenant_id
        objectId: ApiManagement.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

resource KeyVaultSecretBaPass 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: '${KeyVault.name}/${kvsecret_name_basic_pass}'
  properties: {
    value: basic_auth_pass
  }
}

resource KeyVaultSecretCertThumb 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: '${KeyVault.name}/${kvsecret_name_cert_thumbprint}'
  properties: {
    value: cert_thumbprint
  }
}

resource KeyVaultSecretClientSecret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: '${KeyVault.name}/${kvsecret_name_clientsecret}'
  properties: {
    value: client_secret
  }
}

resource KeyVaultSecretApimSubscriptionKey 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: '${KeyVault.name}/${kvsecret_name_subscription_key}'
  properties: {
    value: listSecrets('${ApiManagement.id}/subscriptions/master', ApiManagement.apiVersion).primaryKey
  }
}

resource ApiManagement 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apim_name
  location: location
  sku: {
    name: 'Developer'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    notificationSenderEmail: 'apimgmt-noreply@mail.windowsazure.com'
    publisherEmail: 'dummy@email.com'
    publisherName: 'dummy'
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: '${apim_name}.azure-api.net'
        negotiateClientCertificate: true
      }
    ]
  }
}

resource ApiManagementApiAzureAd 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: '${ApiManagement.name}/${apim_api_name_ad}'
  properties: {
    displayName: apim_api_name_ad
    subscriptionRequired: false
    serviceUrl: apim_service_url_ad
    protocols: [
      'https'
    ]
    path: apim_api_path_ad
  }
}

resource ApiManagementApiBasic 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: '${ApiManagement.name}/${apim_api_name_basic}'
  properties: {
    displayName: apim_api_name_basic
    subscriptionRequired: false
    serviceUrl: apim_service_url_basic
    protocols: [
      'https'
    ]
    path: apim_api_path_basic
  }
}

resource ApiManagementApiCert 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: '${ApiManagement.name}/${apim_api_name_cert}'
  properties: {
    displayName: apim_api_name_cert
    subscriptionRequired: false
    serviceUrl: apim_service_url_cert
    protocols: [
      'https'
    ]
    path: apim_api_path_cert
  }
}

resource ApiManagementNamedValueAuthServer 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  name: '${ApiManagement.name}/${apim_nv_authserver}'
  properties: {
    displayName: apim_nv_authserver
    value: '${environment().authentication.loginEndpoint}${aad_tenantid}/oauth2/v2.0/token'
  }
}

resource ApiManagementNamedValueClientId 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  name: '${ApiManagement.name}/${apim_nv_clientid}'
  properties: {
    displayName: apim_nv_clientid
    value: aad_appid_client
  }
}

resource ApiManagementNamedValueScope 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  name: '${ApiManagement.name}/${apim_nv_scope}'
  properties: {
    displayName: apim_nv_scope
    value: 'api://${aad_appid_backend}/.default'
  }
}

resource ApiManagementNamedValueClientSecret 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  name: '${ApiManagement.name}/${apim_nv_clientsecret}'
  dependsOn: [
    KeyVaultAccessPolicies
  ]
  properties: {
    displayName: apim_nv_clientsecret
    keyVault: {
      secretIdentifier: 'https://${kv_name}${environment().suffixes.keyvaultDns}/secrets/${kvsecret_name_clientsecret}'
    }
    secret: true
  }
}

resource ApiManagementNamedValueBasicAuthName 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  name: '${ApiManagement.name}/${apim_nv_basicauthuser}'
  properties: {
    displayName: apim_nv_basicauthuser
    value: basic_auth_user
  }
}

resource ApiManagementNamedValueBasicAuthPass 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  name: '${ApiManagement.name}/${apim_nv_basicauthpass}'
  dependsOn: [
    KeyVaultAccessPolicies
  ]
  properties: {
    displayName: apim_nv_basicauthpass
    keyVault: {
      secretIdentifier: 'https://${kv_name}${environment().suffixes.keyvaultDns}/secrets/${kvsecret_name_basic_pass}'
    }
    secret: true
  }
}

resource ApiManagementNamedValueThumbprint 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  name: '${ApiManagement.name}/${apim_nv_thumbprint}'
  dependsOn: [
    KeyVaultAccessPolicies
  ]
  properties: {
    displayName: apim_nv_thumbprint
    keyVault: {
      secretIdentifier: 'https://${kv_name}${environment().suffixes.keyvaultDns}/secrets/${kvsecret_name_cert_thumbprint}'
    }
    secret: true
  }
}

resource ApiManagementCertificate 'Microsoft.ApiManagement/service/certificates@2021-08-01' = {
  name: '${ApiManagement.name}/${apim_certificate_id}'
  dependsOn: [
    KeyVaultAccessPolicies
  ]
  properties: {
    keyVault: {
      secretIdentifier: 'https://${kv_name}${environment().suffixes.keyvaultDns}/secrets/${kvcert_name_api}'
    }
  }
}

resource ApiManagementPolicyAzureAd 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {
  name: '${ApiManagementApiAzureAd.name}/policy'
  dependsOn: [
    ApiManagementNamedValueAuthServer
    ApiManagementNamedValueClientId
    ApiManagementNamedValueScope
    ApiManagementNamedValueClientSecret
  ]
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n    <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized. Access token is missing or invalid.">\r\n      <openid-config url="${environment().authentication.loginEndpoint}${aad_tenantid}/.well-known/openid-configuration" />\r\n      <audiences>\r\n        <audience>api://${aad_appid_backend}</audience>\r\n      </audiences>\r\n      <required-claims>\r\n        <claim name="appid" match="all">\r\n          <value>${aad_appid_client}</value>\r\n        </claim>\r\n      </required-claims>\r\n    </validate-jwt>\r\n   </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}

resource ApiManagementPolicyBasic 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {
  name: '${ApiManagementApiBasic.name}/policy'
  dependsOn: [
    ApiManagementNamedValueBasicAuthName
    ApiManagementNamedValueBasicAuthPass
  ]
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n   <set-variable name="user-pass" value="{{${apim_nv_basicauthuser}}}:{{${apim_nv_basicauthpass}}}" />\r\n    <check-header name="Authorization" failed-check-httpcode="401" failed-check-error-message="Not authorized" ignore-case="false">\r\n      <value>@("Basic " + System.Convert.ToBase64String(Encoding.UTF8.GetBytes((string)context.Variables["user-pass"])))</value>\r\n    </check-header>\r\n    </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}

resource ApiManagementPolicyCert 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {
  name: '${ApiManagementApiCert.name}/policy'
  dependsOn: [
    ApiManagementCertificate
  ]
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <base />\r\n  <validate-client-certificate validate-revocation="true" validate-trust="false" validate-not-before="true" validate-not-after="true" ignore-error="false">\r\n      <identities>\r\n        <identity thumbprint="{{${apim_nv_thumbprint}}}" />\r\n      </identities>\r\n    </validate-client-certificate>\r\n   <authentication-certificate certificate-id="${apim_certificate_id}" />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}
