Function CreateWebSite($server,$Username,$Password,$WebsiteName,$Port,$HostHeader,$PhysicalPath,$Ssl){
	Write-Host "Creating WebSite with $server,$Username,$WebsiteName,$Port,$HostHeader,$PhysicalPath,$Ssl"
	$pass = ConvertTo-SecureString -AsPlainText $Password -Force
	$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
    invoke-command -computername $server -credential $Cred -scriptblock{
	param(
		   [Parameter(Position=0)]
		   $_websitename
		,
		   [Parameter(Position=1)]
		   $_port
		,
		   [Parameter(Position=2)]
		   $_hostheader
		,
		   [Parameter(Position=3)]
		   $_physicalpath
		,
		   [Parameter(Position=4)]
		   $_ssl
		)
		$mydata=@()
		Try
		{
			import-module WebAdministration
			if (Test-Path "IIS:\Sites\$_websitename") 
			{ 
				Write-Host "IIS:\Sites\$_websitename exists. Exiting..."
				#Remove-WebSite -Name $_websitename
			} else {
				if (!(Test-Path $_physicalpath)) {
					Write-Host "Folder does not exists. Creating..."
					[void](new-item $_physicalpath -itemType directory)
				}

				if($_ssl -eq "true") {
					Write-Host "Activating SSL..."
					Write-Host "New-WebSite -Name $_websitename -Port $_port -HostHeader $_hostheader -PhysicalPath $_physicalpath -Ssl"
					$dataresult = New-WebSite -Name $_websitename -Port $_port -HostHeader $_hostheader -PhysicalPath $_physicalpath -Ssl
				} else {
					Write-Host "Disabled SSL..."
					Write-Host "New-WebSite -Name $_websitename -Port $_port -HostHeader $_hostheader -PhysicalPath $_physicalpath"
					$dataresult = New-WebSite -Name $_websitename -Port $_port -HostHeader $_hostheader -PhysicalPath $_physicalpath
				}
			}
			$mydata = $true;
		} 
		Catch [Exception]
		 {
			Write-Host $_.Exception.Message
			$mydata = $false;
		 }
		return $mydata
	} -ArgumentList $WebsiteName,$Port,$HostHeader,$PhysicalPath,$Ssl
}

if ($args.Length -ne 8) {
	Write-Host "Incorrect params! Usage: CreateWebSite.ps1 <ip-server> user-deploy password DefaultWebSite 80 www.enformat.cat c:\wwwroot\inetpub\enformat-site true"
	exit 1
}
else {
	$pServer = $args[0]
	$pUser = $args[1]
	$pPass = $args[2]
	$pWEbsiteName = $args[3]
	$pPort = $args[4]
	$pHostHeader = $args[5]
	$pPhysicalPath = $args[6]
	$pSsl = $args[7]
	
	Write-Host "CreateWebSite $pServer $pUser $pPass $pWebsiteName $pPort $pHostHeader $pPhysicalPath $pSsl"
	$ret = CreateWebSite $pServer $pUser $pPass $pWebsiteName $pPort $pHostHeader $pPhysicalPath $pSsl
	if($ret -eq $true) 
	{
		return 0
	} else {
		return 1
	}
}

  



