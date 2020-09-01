# Connect to your Azure environment with PowerShell
# Select the desired subscritpion


function Test-AzTemplateFunctions {
    [cmdletbinding()]
    Param (
    [string]$Path,
    [string]$Location
    ) 
    BEGIN {

        # Create Resource Group
        $Guid = ([guid]::NewGuid()).guid
        
        $Exists = Get-AzResourceGroup -Name $Guid -Location $Location -ErrorAction SilentlyContinue  
        If ($Exists){ 
            Write-Error "Resource Group already exists"  
            Break
        }  
        Else {  
            Write-Verbose "Creating Resource Group..." -Verbose
            $rg = New-AzResourceGroup -Name $Guid -Location $Location
        } 

        # Create Storage Account
        $StorageAccountName = 'armtf' + $Guid.replace('-','').subString(0,18)

        Write-Verbose "Creating Storage Account. This can take a moment..." -Verbose
        $sa = New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $Guid -Location $Location -SkuName Standard_LRS -Verbose

            }
    PROCESS {

        $result = @()

        # Get Deployment Templates
        $templateFunctions = get-childitem $path -File -Filter *.json -Recurse

        # Initialize counter for Progress Bar
        $count = 1
        $percentage = 100/$templateFunctions.count

        # Initialize parameter object for template deployment
        $templateParameterObject = @{
            storageAccountName = $StorageAccountName
        }

        ForEach ($function in $templateFunctions) {

            $test = New-Object -TypeName PSObject
            $test | Add-Member -Type NoteProperty -Name type -Value $function.Directory.Name
            $test | Add-Member -Type NoteProperty -Name templateFunction -Value $function.BaseName

            try{
                $DebugPreference = 'Continue'
                $output = Test-AzResourceGroupDeployment -ResourceGroupName $Guid -TemplateFile $function.FullName -TemplateParameterObject $templateParameterObject 5>&1 -ErrorAction SilentlyContinue
                $DebugPreference = 'SilentlyContinue'
                $message = ($output | Where-Object { $_ -like "*HTTP RESPONSE*"}).Message
                $start = $message.IndexOf('Status Code:')+14
                $end = $message.substring($start).IndexOf('Headers:')-4
            
                $test | Add-Member -Type NoteProperty -Name result -Value $message.substring($start,$end)
            }
            catch{
                $test | Add-Member -Type NoteProperty -Name result -Value "Failed"
            }

            $result += $test

            Write-Progress -Activity "Testing template function $count of $($templateFunctions.count)" -Status "$($function.Directory.Name + ' | ' + $function.BaseName)" -PercentComplete ($percentage*$count)
            $count = $count+1
        }
    }
    END {
        Write-Verbose "Deleting temporary resource group and storage account. This can take a moment..." -Verbose
        Remove-AzResourceGroup -Name $Guid -Force | Out-Null

        return $result
    }
    
}
