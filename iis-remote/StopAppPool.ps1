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
    [string]$Environment = ""
)

Function StopAppPool($server,$Username,$Password,$AppPool,$Environment){
	Write-Host "StopAppPool in $server with user $Username, apppool: $AppPool, environment: $Environment"
	$pass = ConvertTo-SecureString -AsPlainText $Password -Force
	$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
    invoke-command -computername $server -credential $Cred -scriptblock{
	param(
		   [Parameter(Position=0)]
		   $_apppool,
		   [Parameter(Position=1)]
		   $_environment
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
				Write-Host "Application Pool $_apppool$_environment exists... Stopping..."
				Stop-WebAppPool -Name $_apppool$_environment
				$mydata = $true;	
			} else {
				Write-Host "Application Pool $_apppool$_environment not exists... Exiting..."
				$mydata = $true;	
			}
		} 
		Catch [Exception]
		 {
			Write-Host $_.Exception.Message
			$mydata = $false;
		 }
		return $mydata
	} -ArgumentList $AppPool,$Environment
}

Write-Host "StopAppPool $Server $Username **** $AppPool $Environment"
$ret = StopAppPool $Server $Username $Password $AppPool $Environment
if($ret -eq $true) 
{
	return 0
} else {
	return 1
}