## Signs a file
param([string] $file=$(throw "Please specify a filename."))
$cert = @(Get-ChildItem cert:\LocalMachine\My -codesigning)[0]
Set-AuthenticodeSignature $file $cert