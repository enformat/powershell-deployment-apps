Function CreateAppPool($server,$Username,$Password,$AppPool){
	Write-Host "CreateAppPool in $server with user $Username, apppool: $AppPool"
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
				Write-Host "Application Pool $_apppool exists... Exiting..."
				$mydata = $true;	
			} else {
				Write-Host "Application Pool $_apppool not exists... Creating..."
				New-WebAppPool -Name $_apppool
				$mydata = $true;	
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

if ($args.Length -ne 4) {
	Write-Host "Incorrect params! Usage: CreateAppPool.ps1 hostname user-deploy password ApplicationPoolName "
	exit 1
}
else {
	$pServer = $args[0]
	$pUser = $args[1]
	$pPass = $args[2]
	$pAppPool = $args[3]
	
	Write-Host "CreateAppPool $pServer $pUser **** $pAppPool"
	$ret = CreateAppPool $pServer $pUser $pPass $pAppPool
	if($ret -eq $true) 
	{
		return 0
	} else {
		return 1
	}
}

  



