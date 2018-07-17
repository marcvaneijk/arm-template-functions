# Test Azure Resource Manager template functions

Azure Resource Manager templates can contain template functions. New template functions will always be introduced in global Azure first, and subsequently amde available in the sovereign clouds and Azure Stack. It is currently not possible to list the available template functions in an given Azure Resource Manager instance.

This repository contains a PowerShell module that will test a series of Azure Resource Manager templates. Each template contains a template functions. The result of the tests will list what template functions are available in an Azure Resource Manager instance.

## Prerequisites

- Install Azure PowerShell ([Azure](https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps), [Azure Stack](https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-powershell-install))
- Connect to Azure Resource Manager ([Azure](https://docs.microsoft.com/en-us/powershell/azure/authenticate-azureps), [Azure Stack](https://docs.microsoft.com/en-us/azure/azure-stack/user/azure-stack-powershell-configure-user))

## Run test

After connecting to Azure Resource Manager, use the same PowerShell session to run the tests

``` PowerShell
cd \

# Download the repository content
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
invoke-webrequest https://github.com/marcvaneijk/arm-template-functions/archive/master.zip -OutFile .\master.zip

# Expand the downloaded zip file
expand-archive master.zip -DestinationPath . -Force


# Change to the module directory and import the module
cd arm-template-functions-master
Import-Module .\AzureRmTemplateFunctions.psm1

# Run the tests
Test-AzureRMTemplateFunctions -Path .\
```




