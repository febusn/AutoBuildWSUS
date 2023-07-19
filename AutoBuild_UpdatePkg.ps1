
## Automated procedure for Building pkg of microsoft updates KBs for WSUS deployment ##

################################
#### 2022 R6 for public     ####
#### Athor Fivos NISTAZAKIS ####
################################

Write-Host "Security Package build automation app" -ForegroundColor Green
#Name of current WSUS server
$wsusserver = "EXTERNALWSUS"
[void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer()

## Inputs ##
#Name of Package and root path we run it
$rootpathexec = ($MyInvocation.MyCommand).Path
$rootpath = Split-Path $rootpathexec -Parent
$pkgname= Read-Host "Please enter Security Package name (eg: MS_updates_package):"
$pkgpath= $rootpath+"\"+$pkgname
Write-Host "The rootpath is:" $rootpath
Write-Host "The pkgpath is:" $pkgpath
#Set Location to the directory the executed script runs
Set-Location $rootpath

## Funcs ##
$fExp = {
       &"C:\Program Files\Update Services\Tools\WsusUtil.exe" export "$pkgpath\Updates\WSUS-Export.xml.gz" "$pkgpath\Updates\WSUS-Export.log"
        Write-Host "Info: Check if script is run correctly!" -ForegroundColor Yellow
}
$fRobo = {
        Copy-Item E:\WSUS\WsusContent $pkgpath"\Updates" -ErrorAction SilentlyContinue -Recurse -Force
        Write-Host "Info: Check if script run correctly!" -ForegroundColor Yellow
}

Write-Host "Manuall syncronization of WSUS server from MICROSOFT is needed"
# Automatic Sync not fully tested yet for general products, classifications. Yet to be included
# From current path "WsusUpdateSync.ps1" will automaticly update DB of WSUS server
## .\WsusUpdateSync.ps1 # NOT TESTED YET! Update WSUS server DB with appropriate needed updates from MICROSOF

## INPUTs & CHECKs ##
    Write-Host "Info: Place on INPUT folder all information needed. Lists for the two groups (GROUPA.txt, GROUPB.txt) " -ForegroundColor Yellow
    Write-Host "Info: Synch should already have finished, running the .\SPWsusUpdate.ps1 . Check on GUI and continue" -ForegroundColor Yellow
    pause

## Decline all ## 
$input = Read-Host "Continue with decline all? anwser y for Yes or n for No"
if ($input -eq 'y'){pause
    Write-Host "Decline updates started" + (Get-date).DateTime 
    Get-WsusUpdate -Classification All -Approval AnyExceptDeclined -Status Any | Deny-WsusUpdate
    Write-Host "Decline updates finished" + (Get-date).DateTime 
    Pause
    }

## Delete WSUS_Content all ##
$input = "null"
$input = Read-Host "Continue with Delete WSUS_Content? anwser y for Yes or n for No"
if ($input -eq 'y'){
    #Stop Services
    Write-Host "Info: Stopping Background Intelligent Transfer Service" -ForegroundColor Yellow
    Get-Service -DisplayName "Background Intelligent Transfer Service" | Stop-Service -Force
    Write-Host "Info: Stopping Windows Update Service" -ForegroundColor Yellow
    Get-Service -DisplayName "Windows Update" | Stop-Service -Force    
    #Close WSUS GUI:
    Write-Host "Info: Close WSUS GUI" -ForegroundColor Yellow
    Get-Process -Name "mmc" | Stop-Process -Force | Out-Null
    #Delete WSUSContent
    Remove-Item -Path E:\WSUS\WsusContent\* -Force -Recurse
    $dirinf = Get-ChildItem E:\WSUS\WsusContent
    If($dirinf.count -ne 0){
        Write-host "Error: Dir is not Empty, check manually" -ForegroundColor Red
        }
    # Recomended to check folder is empty "E:\WSUS\WsusContent"
    Write-Host "Info: Recomended to check folder is empty: E:\WSUS\WsusContent" -ForegroundColor Yellow
    pause
    ##Start Services
    Write-Host "Info: Starting Background Intelligent Transfer Service" -ForegroundColor Yellow
    Get-Service -DisplayName "Background Intelligent Transfer Service" | Start-Service
    Write-Host "Info: Starting Windows Update Service" -ForegroundColor Yellow
    Get-Service -DisplayName "Windows Update" | Start-Service
    }

## ApproveAll (according to lists) ##
$input = "null"
$input = Read-Host "Continue with Approve of selectes updates? anwser y for Yes or n for No"
if ($input -eq 'y'){pause
    Do{
        $input = "null"
        Write-Host "Info: Approving updates" -ForegroundColor Yellow
        .\ApproveSelected_Reference.ps1
        pause
        #Wait untill action finish
        Write-Host Recomended: Check on the script command line no errors on approved. With Red colour -ForegroundColor Yellow
        Write-Host Recomended: Check on WSUS GUI the number of Approved, Any -ForegroundColor Yellow
        Write-Host Check ApprovedUpdates scripts!! -ForegroundColor Yellow
        Write-Host Check if download status is ZERO -ForegroundColor Yellow
        pause
        $input = Read-Host "If approve executed without failures (red lines) or you want to continue press y, otherwise press enter"
        }While($input -ne 'y')
    }

## Create Updates directory Structure ##
#Create base SecPkg folder with given name
$input = "null"
$input = Read-Host "Continue with Create SecPkg directory? anwser y for Yes or n for No"
if ($input -eq 'y'){pause
    Write-Host Info: Create SecPkg directory -ForegroundColor Yellow
    If (Test-Path $pkgpath){
        Write-Host "Warning: Security Package folder with the same name already exist. It will be removed and create again" -ForegroundColor Orange
        pause
        Remove-Item $pkgpath -Recurse -Force
        }
    New-Item $pkgpath -Type Directory | Out-Null
    New-Item $pkgpath"\Updates" -Type Directory | Out-Null
    New-Item $pkgpath"\Updates\WsusContent" -Type Directory | Out-Null
    pause

    #Copy installation Script and inputs
    Copy-Item -Path "$rootpath\INPUT\*" -Destination "$pkgpath" -Recurse
    Copy-Item -Path "$rootpath\TRANSFER\*" -Destination "$pkgpath" -Recurse
    }

## [Export, copy WSUS content, etc] ##
$input = "null"
$input = Read-Host "Continue with copy and exporting WSUS data? anwser y for Yes or n for No"
if ($input -eq 'y'){pause
    Write-Host "Info: Close WSUS GUI and stopping services" -ForegroundColor Yellow
    pause
    #Server preparation. Close WSUS Console:
    Get-Process -Name "mmc" | Stop-Process -Force | Out-Null

    #Stop Services
    Write-Host "Info: Stopping Background Intelligent Transfer Service" -ForegroundColor Yellow
    pause
    Get-Service -DisplayName "Background Intelligent Transfer Service" | Stop-Service -Force
    Write-Host "Info: Stopping Windows Update Service" -ForegroundColor Yellow
    Get-Service -DisplayName "Windows Update" | Stop-Service -Force

    #Robo
    #robocopy E:\WSUS\WsusContent $pkgpath\Updates\WsusContent /E
    Write-Host "Info: . This may take some munutes" -ForegroundColor Yellow
    pause
    Write-Host "Coping WSUS content started" + (Get-date).DateTime 
    &$fRobo
    Write-Host "Coping WSUS content finished" + (Get-date).DateTime

    #WSUS content exporting
    Write-Host "Info: Extracting WSUS data. This may take some minutes" -ForegroundColor Yellow
    pause
    Write-Host "Exporting started" + (Get-date).DateTime
    &$fExp
    Write-Host "Exporting finished" + (Get-date).DateTime

    ##Start Services
    Write-Host "Info: Starting Background Intelligent Transfer Service" -ForegroundColor Yellow
    Get-Service -DisplayName "Background Intelligent Transfer Service" | Start-Service
    Write-Host "Info: Starting Windows Update Service" -ForegroundColor Yellow
    Get-Service -DisplayName "Windows Update" | Start-Service
    }

    Write-Host " FINISHED " -ForegroundColor Green

# ZIPING!!!
Write-Host "Info: Zipping " -ForegroundColor Yellow
$Zipinfo = @{
Path = "$Pkgpath\*" 
CompressionLevel = "Fastest" 
DestinationPath = "$rootpath\$pkgname.zip"}

Compress-Archive @Zipinfo

Write-Host " FINISHED ZIPPING" -ForegroundColor Green


#############################################################_#

