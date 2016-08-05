Function GetVDir($server,$Username,$Password,$WebsiteName,$WebappName) {
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
			return Test-Path "IIS:\Sites\$_websitename\$_webappname"
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
	Write-Host "Incorrect params! Usage: GetVDir.ps1 <ip-server> user-deploy password DefaultWebSite WebApplicationName"
	exit 1
}
else {
	$pServer = $args[0]
	$pUsername = $args[1]
	$pPassword = $args[2]
	$pWebsiteName = $args[3]
	$pWebappName = $args[4]
	
	Write-Host "GetVDir $pServer $pUsername ******* $pWebsiteName $pWebappName"
	$ret = GetVDir $pServer $pUsername $pPassword $pWebsiteName $pWebappName
 
	if($ret -eq "") 
	{
		return ""
	} else {
		return $ret
	}
}