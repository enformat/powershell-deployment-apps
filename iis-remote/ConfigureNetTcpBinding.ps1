param 
(
	[parameter(Mandatory = $true)] 
    [string]$Server = "",
	[parameter(Mandatory = $true)]
	[string]$Username = "", 
	[parameter(Mandatory = $true)]
	[string]$Password = "", 
	[parameter(Mandatory = $true)]
	[string]$WebsiteName = "", 
	[parameter(Mandatory = $true)]
    [string]$WebappName = ""
)

Function ConfigureNetTcpBinding($server,$Username,$Password,$WebsiteName,$WebappName){
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
					Write-Host "IIS:\Sites\$_websitename\$_webappname exists. Enabling net-tcp binding..."
					Set-ItemProperty "IIS:\Sites\$_websitename\$_webappname" -name applicationDefaults.enabledProtocols -value "http,net.tcp"
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

$pServer = $Server
$pUser = $Username
$pPass = $Password
$pWebsiteName = $WebsiteName
$pWebappName = $WebappName
	
Write-Host "ConfigureNetTcpBinding $pServer $pUser ***** $pWebsiteName $pWebappName"
$ret = ConfigureNetTcpBinding $pServer $pUser $pPass $pWebsiteName $pWebappName
if($ret -eq $true) 
{
	return 0
} else {
	return 1
}