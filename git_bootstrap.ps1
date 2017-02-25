Start-Transcript -path $home\system_install.log -Append
# This is necessary to execute scripts. If the system complains that it can't run this script, 
# you might have to run this line by itself first.
set-executionpolicy remotesigned -scope currentuser -force

echo 'First I need to get a few things from you...'
$projDirectory = Read-Host -Prompt 'Project Directory (relative to $home)'
$projDirectory = "$home\$projDirectory"
$gitRepo = Read-Host -Prompt 'Git Repo (w/o "https://")'
$gitUname = Read-Host -Prompt 'Git Username'
$secGitPass = Read-Host -Prompt 'Git Pass' -AsSecureString
$gitPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secGitPass))
echo "Thanks! I'm going to do my thing, check back in a while!"

iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/mwrock/boxstarter/master/BuildScripts/bootstrapper.ps1'))
Get-Boxstarter -Force
Import-Module $env:appdata\boxstarter\boxstarter.chocolatey\boxstarter.chocolatey.psd1
cinst git -y
cinst git-disable-gcm -y
$env:path += 'C:\Program Files\git\bin'
echo "Git credentials are being stored in $home\.gitconfig..."
#Add-Content "$home\.gitconfig" "`n[credential ""$gitRepo""]`n`t$gitUname = $gitPass"

git clone "https://${gitUname}:${gitPass}@$gitRepo" "$projDirectory\Repository"
Install-BoxstarterPackage -PackageName "$projDirectory\Repository\system_install\system_package.ps1"
Stop-Transcript
