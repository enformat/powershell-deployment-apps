param 
(
	[parameter(Mandatory = $true)] 
    [string]$Server = "",
	[parameter(Mandatory = $true)]
	[string]$Username = "", 
	[parameter(Mandatory = $true)]
	[string]$Password = "", 
	[parameter(Mandatory = $true)]
	[string]$AppPool = "", 
	[parameter(Mandatory = $true)]
    [string]$Environment = "",
	[string]$WebsiteName = "", 
	[parameter(Mandatory = $true)]
    [string]$PhysicalPath = ""
)

Function StartAppPool($server,$Username,$Password,$AppPool,$Environment,$WebsiteName,$PhysicalPath){
	Write-Host "StartAppPool in $server with user $Username, apppool: $AppPool, environment: $Environment, websitename: $WebsiteName, physicalpath: $PhysicalPath"
	$pass = ConvertTo-SecureString -AsPlainText $Password -Force
	$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
    invoke-command -computername $server -credential $Cred -scriptblock{
	param(
		   [Parameter(Position=0)]
		   $_apppool,
		   [Parameter(Position=1)]
		   $_environment,
		   [Parameter(Position=2)]
		   $_websitename
		)
		$mydata=@()
		Try
		{
			if($_environment -eq "NONE")
			{
				$_environment = "";
			}
			import-module WebAdministration
			if(Test-Path "IIS:\AppPools\$_apppool$_environment")
			{
				Write-Host "Application Pool $_apppool$_environment exists... Starting..."
				Start-WebAppPool -Name $_apppool$_environment
				$mydata = $true;	
			} else {
				Write-Host "Application Pool $_apppool$_environment not exists... Creating application..."				
			} 
			if(-Not (Test-Path "IIS:\Sites\$_websitename\$_apppool"))
			{
				Write-Host "IIS:\Sites\$_websitename\$_apppool doesn't exists. Creating application..."
				$mydata = $false;
			}
		} 
		Catch [Exception]
		 {
			Write-Host $_.Exception.Message
			$mydata = $false;
		 }
		return $mydata
	} -ArgumentList $AppPool,$Environment,$WebsiteName
}

Write-Host "StartAppPool $Server $Username **** $AppPool $Environment $WebsiteName $PhysicalPath"
$ret = StartAppPool $Server $Username $Password $AppPool $Environment $WebsiteName $PhysicalPath
if($ret -eq $true) 
{
	return 0
} else {
	$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

	. $ScriptPath\CreateWebApplication.ps1 ($server) ($Username) ($Password) ($AppPool) ($WebsiteName) ($PhysicalPath)
}