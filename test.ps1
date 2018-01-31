## Get Token from existing powershell session

$tenantId = (Get-AzureRmSubscription -SubscriptionName 'mavane').TenantId
$context = Get-AzureRmContext
$cache = $context.TokenCache
$token = $cache.ReadItems() | where {$_.tenantId -eq $tenantId }

## validate a template against the rest api
try {

$mainTemplateUri = "https://raw.githubusercontent.com/marcvaneijk/arm-template-functions/master/string/base64ToJson.json"
$subscriptionId = "c18cac5d-e2c2-47d7-877a-71e17b3bfad1"
$apiVersion = "2016-09-01"
$deploymentName = ([guid]::NewGuid()).guid
$resourceGroupName = "TemplateValidation"
$url = {https://management.azure.com/subscriptions/{0}/resourcegroups/{1}/providers/Microsoft.Resources/deployments/{2}/validate?api-version={3}} -f $subscriptionId, $resourceGroupName, $deploymentName, $apiVersion

        $body = @{
            "properties"=@{
                "mode"="Incremental"
                "debugSetting"=@{"detailLevel"="none"} ## "detailLevel"="requestContent,responseContent"
                "templateLink"=@{"uri"=$mainTemplateUri}
            }
        }

        $deploymentArgs = @{
            "ContentType" = "application/json"
            "Headers" = @{
            "authorization"="Bearer $($token.AccessToken)"
            }
            "Body" = ($Body | ConvertTo-Json)
            "Method" = "Post"
            "Uri" = $url
        }

        Invoke-RestMethod @deploymentArgs

}
catch{}

$result.properties.provisioningState


### Using Test-AzureRmDeployment

Login-AzureRmAccount
Get-AzureRmSubscription -SubscriptionName "mavane" | Select-AzureRmSubscription 


$templatefunctions = Get-ChildItem -Path C:\git\arm-template-functions -File -Filter "*.json" -Recurse
$templatefunctions[45..48] | ForEach {
write-host ""
write-host $_.Name -ForegroundColor Yellow
Test-AzureRmResourceGroupDeployment -ResourceGroupName "TemplateValidation" -TemplateFile $_.FullName -Verbose
}