[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True,Position=0)]
	[string]$Server,
	[Parameter(Mandatory=$True,Position=1)]
	[string]$User,
	[Parameter(Mandatory=$True,Position=2)]
	[string]$Password,
	[Parameter(Mandatory=$True,Position=3)]
	[string]$Command,
	[Parameter(Mandatory=$False,Position=4)]
	[string]$Arguments = ""
)

Function invokeRemoteCommand($server, $user, $password, $command, $arguments) {
	$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user,(ConvertTo-SecureString -AsPlainText $password -Force)
	$result = Invoke-Command -computername $server -Credential $credential -ScriptBlock{
		param(
		   [Parameter(Position=0)]
		   $_command,
		   [Parameter(Position=1)]
		   $_arguments
		)
		&"$_command" $_arguments
	} -ArgumentList ($command,$arguments) -ErrorVariable errortext 

	if($errortext)
	{
		$result = "Error: $errortext"
	}

	return $result
}

#Entry Point

#Write-Host "Invoke remote cmd to server $Server"
#Write-Host "User:		$User"
#Write-Host "Command:	$Command"
#Write-Host "Arguments:	$Arguments"

$ret = invokeRemoteCommand "$Server" "$User" "$Password" "$Command" "$Arguments"
if($ret -eq $true) 
{
	return 0
} else {
	return $ret
}