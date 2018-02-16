### Using Test-AzureRmDeployment

Login-AzureRmAccount
Get-AzureRmSubscription -SubscriptionName "mavane" | Select-AzureRmSubscription 


$result = @()
$count = 1
$percentage = 100/$templatefunctions[0..5].count


ForEach ($function in $templatefunctions[0..5]) {

    try{
        $DebugPreference = 'Continue'
        $output = Test-AzureRmResourceGroupDeployment -ResourceGroupName "TemplateValidation" -TemplateFile $function.FullName 5>&1 -ErrorAction SilentlyContinue
        $DebugPreference = 'SilentlyContinue'
        $message = ($output | Where-Object { $_ -like "*HTTP RESPONSE*"}).Message
        $start = $message.IndexOf('Status Code:')+14
        $end = $message.substring($start).IndexOf('Headers:')-4
        $result += @{($function.Directory.Name + '.' + $function.BaseName) = $message.substring($start,$end)}  
    }
    catch{
        $result += @{($function.Directory.Name + '.' + $function.BaseName) = "Failed"}
    }


    Write-Progress -Activity "Search in Progress" -Status "($function.Directory.Name + '.' + $function.BaseName)" -PercentComplete [int]($percentage*$count)
    $count+1
}

$result