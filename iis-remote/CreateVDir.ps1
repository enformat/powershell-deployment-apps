Function CreateVDir($server,$Username,$Password,$WebsiteName,$WebappName,$PhysicalPath){
	Write-Host "Creating Virtual Directory in $server with user $Username, website: $WebsiteName, webappname: $WebappName, physical path: $PhysicalPath"
	$pass = ConvertTo-SecureString -AsPlainText $Password -Force
	$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
    invoke-command -computername $server -credential $Cred -scriptblock{
	param(
		   [Parameter(Position=0)]
		   $_websitename
		,
		   [Parameter(Position=1)]
		   $_webappname
	   ,
		   [Parameter(Position=2)]
		   $_physicalpath
		)
		$mydata=@()
		Try
		{
			import-module WebAdministration
			if (Test-Path "IIS:\Sites\$_websitename") 
			{ 
				Write-Host "IIS:\Sites\$_websitename exists. Continue..."
				<#Creating pool#>
				if(Test-Path "IIS:\AppPools\$_webappname$_environment")
				{
					Write-Host "Application Pool $_webappname exists."
				}
				else
				{
					Write-Host "Creating AppPool $_webappname
					New-Item "IIS:\AppPools\$_webappname
					Sleep -Seconds 3				
				}	
				
				<#Creating Site#>
				if(Test-Path "IIS:\Sites\$_websitename\$_webappname")
				{
					Write-Host "IIS:\Sites\$_websitename\$_webappname exists."
				}
				else
				{
					$_physicalpath = $_physicalpath -replace '/'
					Write-Host "Creating WebApp site IIS:\Sites\$_websitename\$_webappname ..."
					New-Item "IIS:\Sites\$_websitename\$_webappname" -physicalPath $_physicalpath -type Application
					Sleep -Seconds 3			
				}
				
				<#Assigning pool to site#>
				Write-Host "Assign AppPool $_webappname$_environment to IIS:\Sites\$_websitename\$_webappname"
				Set-ItemProperty "IIS:\Sites\$_websitename\$_webappname" -name applicationPool -value $_webappname
				$mydata = $true;	
			} else {
				Write-Host "IIS:\Sites\$_websitename not exists. Exiting..."
				$mydata = $false
			}
		} 
		Catch [Exception]
		 {
			Write-Host $_.Exception.Message
			$mydata = $false;
		 }
		return $mydata
	} -ArgumentList $WebsiteName,$WebAppName,$PhysicalPath
}

if ($args.Length -ne 6) {
	Write-Host "Incorrect params! Usage: CreateVDir.ps1 <ip_server> user_deployment password DefaultWebSite WebAPI_Application c:\inetpub\wwwroot\WebAPI_Application"
	exit 1
}
else {
	$pServer = $args[0]
	$pUser = $args[1]
	$pPass = $args[2]
	$pWebsiteName = $args[3]
	$pWebappName = $args[4]
	$pPhysicalPath = $args[5]
	
	Write-Host "Create VDir $pServer $pUser ******* $pWebsiteName $pWebappName $pPhysicalPath"
	$ret = CreateVDir $pServer $pUser $pPass $pWebsiteName $pWebappName $pPhysicalPath $pEnvironment
	if($ret -eq $true) 
	{
		return 0
	} else {
		return 1
	}
}