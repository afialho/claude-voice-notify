# Records timestamp when Claude starts using tools (Windows)
$StartFile = "$env:TEMP\.claude-response-start"
if (-not (Test-Path $StartFile)) {
    [int](Get-Date -UFormat %s) | Out-File $StartFile -NoNewline
}
