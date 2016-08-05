param 
(
	[parameter(Mandatory = $true)] 
    [string]$Server = "",
	[parameter(Mandatory = $true)]
	[string]$Username = "", 
	[parameter(Mandatory = $true)]
	[string]$Password = "", 
	[parameter(Mandatory = $true)]
	[string]$AppPool = "" 
)

Function RestartAppPool($server,$Username,$Password,$AppPool){
	Write-Host "RestartAppPool in $server with user $Username, apppool: $AppPool"
	$pass = ConvertTo-SecureString -AsPlainText $Password -Force
	$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
    invoke-command -computername $server -credential $Cred -scriptblock{
	param(
		   [Parameter(Position=0)]
		   $_apppool
		)
		$mydata=@()
		Try
		{
			import-module WebAdministration
			if(Test-Path "IIS:\AppPools\$_apppool")
			{
				Write-Host "Application Pool $_apppool exists... Restarting..."
				Restart-WebAppPool -Name $_apppool
				$mydata = $true;	
			} else {
				Write-Host "Application Pool $_apppool not exists... Exiting..."
				$mydata = $false;	
			}
		} 
		Catch [Exception]
		 {
			Write-Host $_.Exception.Message
			$mydata = $false;
		 }
		return $mydata
	} -ArgumentList $AppPool
}
	
Write-Host "RestartAppPool $Server $Username **** $AppPool"
$ret = RestartAppPool $Server $Username $Password $AppPool
if($ret -eq $true) 
{
	return 0
} else {
	return 1
}

  



