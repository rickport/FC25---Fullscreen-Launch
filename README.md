# FC25---Fullscreen-Launch
I'm not a proggramer, I just made the IA work for me.

This project provides a fully automated and seamless launch experience for EA SPORTS FC 25 on PC (launched via Steam). The goal is to completely hide all disruptive splash screens (EA Desktop, EA Anti-Cheat) and the game's own loading transitions, presenting the user with the final, fullscreen game window only when it is 100% ready to be played.

The entire process is initiated by simply clicking "Play" in Steam, providing a clean, console-like experience (loaded with only 100mb of RAM)

## Features
 * **Away from the prying eyes of the EAAntiCheat ( It's good, because I've tried some programs that could do what I wanted, but the anti-cheat doesn't accept them running. ):**
  * **Custom Animated Splash Screens:** Utilizes custom images (`start.jpg`, `end.jpg`) with fade-in/fade-out effects to create a professional splash screen experience, replacing the default black screen.
  * **Total Splash Screen Suppression:** The "Black Curtain" technique completely hides all EA Desktop and Anti-Cheat splash screens, as well as the game's own window resizing and transition to fullscreen.
  * **Intelligent Game State Detection:** The script doesn't rely on fixed timers alone. It actively monitors the game process to:
      * Identify the stable, main game process, ignoring temporary bootstrappers.
      * Confirm when the game window has successfully entered a true fullscreen state.
  * **Robust, Aggressive Focus:** A specialized Python helper script (`focus_aggressively.py`) is used to perform the final, critical step of bringing the game to the foreground, overcoming the Windows focus lock and anti-cheat interference.
  * **Seamless Post-Game Sync:** After the game is closed, a second custom splash screen appears to hide the EA Desktop's synchronization window, providing a clean exit experience.
  * **Automatic Startup:** The script is configured via Windows Task Scheduler to start silently and automatically with Windows, requiring no manual intervention from the user.
  * **System Integration:** The entire automation is started with windows (but you can turn on every time you star your windows)

## How It Works

This solution uses a hybrid architecture to ensure both stability and power:

1.  **PowerShell Orchestrator (`iniciador.ps1`):** This is the main script. It acts as the "conductor," managing the overall process. It creates the custom splash screen "curtains," monitors for game processes, and decides when to call for help.
2.  **Python Focus Specialist (`focus_aggressively.py`):** This is a small but powerful helper script. Its only job is to perform aggressive, low-level window manipulation using the `pywin32` library. This is used to reliably force the game to maximize in the background and to seize focus at the final moment.
3.  **Windows Forms Curtains:** The splash screens are dynamically generated, borderless, fullscreen windows created by PowerShell, which display the user-provided images.
4.  **Task Scheduler:** The system is initiated by a Windows Scheduled Task that runs the `iniciador.ps1` script at login. This ensures the monitor is always ready.

## Setup Instructions

Follow these steps precisely to configure the launcher on your system.

### 1\. Prerequisites (One-Time Installation)

  * **Python:** Download and install Python from [python.org](https://www.python.org/downloads/).
    **CRITICAL:** During installation, you **must** check the box that says **"Add Python.exe to PATH"**.
  * **`pywin32` Library:** Once Python is installed, open PowerShell and run the following command to install the necessary library:
    ```
    pip install pywin32
    ```

### 2\. File Placement

Create a permanent folder on your computer (e.g., `C:\Scripts\FC25_Launcher`). Place all of the following files inside this one folder:

1.  `iniciador.ps1` (The main PowerShell script)
2.  `focus_aggressively.py` (The Python helper script)
3.  `start.jpg` (Your first curtain image)
4.  `end.jpg` (Your second curtain image for the post-game sync)

### 3\. PowerShell Configuration (One-Time Setup)

To allow your system to run local scripts, you need to set the Execution Policy.

1.  Open PowerShell **as Administrator**.
2.  Run the following command and confirm with `S` (or `Y` for yes):
    ```powershell
    Set-ExecutionPolicy RemoteSigned
    ```

### 4\. Automatic Startup (Windows Task Scheduler)

This will make the script start silently with Windows without any UAC prompts.

1.  Press **`Windows + R`**, type `taskschd.msc`, and hit Enter.
2.  In the right pane, click **"Create Task..."**.
3.  **General Tab:**
      * **Name:** `FC25 Assistant Launcher`
      * Check the box **"Run with highest privileges"**.
4.  **Triggers Tab:**
      * Click **"New..."**.
      * Set "Begin the task:" to **"At log on"**.
      * Click **OK**.
5.  **Actions Tab:**
      * Click **"New..."**.
      * **Program/script:** `powershell.exe`
      * **Add arguments (optional):** `-ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Scripts\FC25_Launcher\iniciador.ps1"`
        *(Remember to replace `C:\Scripts\FC25_Launcher\` with the actual path to your folder.)*
6.  **Conditions Tab:**
      * Uncheck the box "Start the task only if the computer is on AC power".
7.  Click **OK** to save the task.

## Customization

  * **Splash Screens:** Simply replace the `start.jpg` and `end.jpg` files with your own images.
  * **Timings:** You can adjust the wait times inside the PowerShell script (`iniciador.ps1`) by editing the variables in the "CONFIGURATION" section at the top of the file.
