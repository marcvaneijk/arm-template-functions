$templateFunctions = get-childitem C:\git\arm-template-functions -File -Filter *.json -Recurse

$result = @()
$count = 1
$percentage = 100/$templateFunctions.count


ForEach ($function in $templateFunctions) {

    $test = New-Object -TypeName PSObject
    $test | Add-Member -Type NoteProperty -Name type -Value $function.Directory.Name
    $test | Add-Member -Type NoteProperty -Name templateFunction -Value $function.BaseName

    try{
        $DebugPreference = 'Continue'
        $output = Test-AzureRmResourceGroupDeployment -ResourceGroupName "TemplateValidation" -TemplateFile $function.FullName 5>&1 -ErrorAction SilentlyContinue
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

    Write-Progress -Activity "Testing $count of $($templateFunctions.count)" -Status "$($function.Directory.Name + ' | ' + $function.BaseName)" -PercentComplete ($percentage*$count)
    $count = $count+1
}

$result