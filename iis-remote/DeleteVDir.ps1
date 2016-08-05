Function DeleteVDir($server,$Username,$Password,$WebsiteName,$WebappName){
	Write-Host "Deleting Virtual Directory in $server with user $Username, website: $WebsiteName, webappname: $WebappName"
	$pass = ConvertTo-SecureString -AsPlainText $Password -Force
	$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
    invoke-command -computername $server -credential $Cred -scriptblock{
	param(
		   [Parameter(Position=0)]
		   $_websitename
		,
		   [Parameter(Position=1)]
		   $_webappname
		)
		$mydata=@()
		Try
		{
			import-module WebAdministration
			if (Test-Path "IIS:\Sites\$_websitename") 
			{ 
				Write-Host "IIS:\Sites\$_websitename exists. Continue..."
				if(Test-Path "IIS:\Sites\$_websitename\$_webappname")
				{
					Write-Host "IIS:\Sites\$_websitename\$_webappname exists. Deleting..."
					Remove-Item "IIS:\Sites\$_websitename\$_webappname" -recurse
				}
				$mydata = $true;	
			} else {
				Write-Host "IIS:\Sites\$_websitename not exists. Exiting..."
				$mydata = $true
			}
		} 
		Catch [Exception]
		 {
			Write-Host $_.Exception.Message
			$mydata = $false;
		 }
		return $mydata
	} -ArgumentList $WebsiteName,$WebAppName
}

if ($args.Length -ne 5) {
	Write-Host "Incorrect params! Usage: DeleteVDir.ps1 <ip-server> user-deploy password DefaultWebSite WebApplication"
	exit 1
}
else {
	$pServer = $args[0]
	$pUser = $args[1]
	$pPass = $args[2]
	$pWebsiteName = $args[3]
	$pWebappName = $args[4]
	
	Write-Host "DeleteVDir $pServer $pUser ******* $pWebsiteName $pWebappName"
	$ret = DeleteVDir $pServer $pUser $pPass $pWebsiteName $pWebappName
	if($ret -eq $true) 
	{
		return 0
	} else {
		return 1
	}
}

  



