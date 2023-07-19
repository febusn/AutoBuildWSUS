[void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")	
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer()			
$groupA = $wsus.GetComputerTargetGroups() | ? {$_.Name -like 'GROUPA_Computers'}      
$groupB = $wsus.GetComputerTargetGroups() | ? {$_.Name -like 'GROUPB_Computers'}

## GROUPA_Computers
Write-Host "###GROUPA_Computers###" -ForegroundColor Cyan
Write-Host "Searching and approving updates..." -ForegroundColor DarkCyan
foreach($KB in Get-Content .\GroupA.txt) {
    $update=$wsus.SearchUpdates($KB)
    if(!$update){
        Write-Host "!! $KB for GROUPA_Computerss not found !!" -ForegroundColor Red
        Write-Host "!! Search on WSUS and Approve manually !!" -ForegroundColor Red
    }
    else {
         $update.Approve("Install",$groupA)
         Write-Host "!! $KB Approved for GROUPA_Computers !!" -ForegroundColor Green       
    }
}

### GROUPB_Computers
Write-Host "###GROUPB_Computers###" -ForegroundColor Cyan
Write-Host "Searching and approving updates..." -ForegroundColor DarkCyan
foreach($KB in Get-Content .\GroupB.txt) {
    $update=$wsus.SearchUpdates($KB)
    if(!$update){
        Write-Host "!! $KB for GROUPB_Computers not found !!" -ForegroundColor Red
        Write-Host "!! Search on WSUS and Approve manually !!" -ForegroundColor Red
    }
    else {
         $update.Approve("Install",$groupB)
         Write-Host "!! $KB Approved for GROUPB_Computers !!" -ForegroundColor Green
    }
}