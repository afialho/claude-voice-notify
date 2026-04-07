# Voice + banner notification for Claude Code (Windows)
# Speaks project name + status when Claude finishes or needs input

param(
    [string]$Mode = "done"
)

$StartFile = "$env:TEMP\.claude-response-start"
$Threshold = if ($env:CLAUDE_NOTIFY_THRESHOLD) { [int]$env:CLAUDE_NOTIFY_THRESHOLD } else { 15 }
$Rate = if ($env:CLAUDE_NOTIFY_RATE) { [int]$env:CLAUDE_NOTIFY_RATE } else { 2 }

if ($Mode -eq "done") {
    if (-not (Test-Path $StartFile)) { exit 0 }
    $start = [int](Get-Content $StartFile)
    $now = [int](Get-Date -UFormat %s)
    Remove-Item $StartFile -Force
    if (($now - $start) -lt $Threshold) { exit 0 }
}

$DonePhrases = @("Done.", "All done.", "Task complete.", "Finished.", "Ready.")
$WaitPhrases = @("I need you.", "Your input is needed.", "Waiting for you.")

if ($Mode -eq "waiting") {
    $Phrases = $WaitPhrases
} else {
    $Phrases = $DonePhrases
}

$Project = Split-Path -Leaf (Get-Location)
$Msg = $Phrases | Get-Random

# --- Banner notification ---
try {
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    $template = @"
<toast>
  <visual>
    <binding template="ToastGeneric">
      <text>Claude Code</text>
      <text>$Project — $Msg</text>
    </binding>
  </visual>
</toast>
"@
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($template)
    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Claude Code").Show($toast)
} catch {
    # Fallback: BurntToast module
    if (Get-Module -ListAvailable -Name BurntToast) {
        New-BurntToastNotification -Text "Claude Code — $Project", $Msg
    }
}

# --- Voice notification ---
Add-Type -AssemblyName System.Speech
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$synth.Rate = $Rate
$synth.Speak("$Project. $Msg")
