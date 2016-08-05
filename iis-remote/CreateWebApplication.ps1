Function CreateWebApp($server,$Username,$Password,$WebApp,$WebsiteName,$PhysicalPath){
	Write-Host "Creating WebApp in $server, with parms $WebApp,$WebsiteName,$PhysicalPath"
	$pass = ConvertTo-SecureString -AsPlainText $Password -Force
	$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
    invoke-command -computername $server -credential $Cred -scriptblock{
	param(
		   [Parameter(Position=0)]
		   $_webapp
		,	
		   [Parameter(Position=1)]
		   $_websitename
		,
		   [Parameter(Position=2)]
		   $_physicalpath
		)
		$mydata=@()
		Try
		{
			import-module WebAdministration
			if(Test-Path IIS:\AppPools\$_webapp)
			{
				Write-Host "AppPool $_webapp exists."
			}
			else
			{
				Write-Host "Creating AppPool $_webapp..."
				Write-Host "New-WebAppPool $_webapp"
				New-WebAppPool $_webapp
				Sleep -Seconds 3
			}
						
			$webApplicationCreation = $false;
			do
			{
				Try
				{
					Write-Host "New-WebApplication -Name $_webapp -Site $_websitename -PhysicalPath $_physicalpath -ApplicationPool $_webapp"
					New-WebApplication -Name $_webapp -Site $_websitename -PhysicalPath $_physicalpath -ApplicationPool $_webapp
					Write-Host "Application created successfully"
					$webApplicationCreation = $true;
				}
				Catch [Exception]
				{
					Write-Host "Exception Catched"
					Write-Host $_.Exception.Message
					Write-Host "Retrying..."
					Sleep -Seconds 3
				}
			}
			while ($webApplicationCreation -eq $false)
			
			$mydata = $true;
		} 
		Catch [Exception]
		 {
			Write-Host $_.Exception.Message
			$mydata = $false;
		 }
		return $mydata
	} -ArgumentList $WebApp,$WebsiteName,$PhysicalPath
}

Write-Host $args.Length

if ($args.Length -ne 6) {
	Write-Host "Incorrect params! Usage: CreateWebApp.ps1 <ip-server> user-deployment password WebApplication DefaultWebSite c:\inetpub\wwwroot\WebApplication"
	$server,$Username,$Password,$WebApp,$WebsiteName,$PhysicalPath
	exit 1
}
else {
	$pServer = $args[0]
	$pUser = $args[1]
	$pPass = $args[2]
	$pWebApp = $args[3]
	$pWEbsiteName = $args[4]
	$pPhysicalPath = $args[5]
	
	Write-Host "CreateWebApp $pServer $pUser ****** $pWebApp $pWebsiteName $pPhysicalPath"
	$ret = CreateWebApp $pServer $pUser $pPass $pWebApp $pWebsiteName $pPhysicalPath
	Write-Host "$ret"
	if($ret -eq $true) 
	{
		return 0
	} else {
		return 1
	}
}