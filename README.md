# SystemTools-BatchKit

A collection of Windows batch and PowerShell scripts for system optimization, performance analysis, and hardware information reporting.

## Repository URL

[https://github.com/Ziad-Abaza/SystemTools-BatchKit.git](https://github.com/Ziad-Abaza/SystemTools-BatchKit.git)

---

## Scripts Overview

| Script File                      | Description                                                                                                                 |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **System\_Hardware\_Report.bat** | Gathers detailed hardware information (CPU, RAM, motherboard, BIOS, GPU, disks, network) and opens the report in Notepad.   |
| **PerformanceOptimizer.bat**     | Batch-based performance optimizer with menu: full cleanup, performance scan, view log. Saves report to Windows Temp folder. |
| **PerformanceOptimizer.ps1**     | PowerShell version of the performance optimizer with an interactive menu, detailed logging, and colorized output.           |
| **SystemCleaner.bat**            | Advanced cleaning tool for Windows 11: cleans temp, recycle bin, disk cleanup with manual/automatic options.                |
| **CleanDisk.bat**                | Disk management tool: display info, CHKDSK repair, format, clean and recreate partitions via menu.                          |

---

## How to Run `.bat` Scripts

1. **Open Command Prompt as Administrator**

   * Search for `cmd` in the Start menu, right-click, and choose **Run as administrator**.

2. **Navigate to the repository folder**

   ```bat
   cd "C:\path\to\SystemTools-BatchKit"
   ```

3. **Execute the desired script** by typing its filename and pressing Enter:

   ```bat
   System_Hardware_Report.bat
   PerformanceOptimizer.bat
   SystemCleaner.bat
   CleanDisk.bat
   ```

4. **Follow on-screen instructions** and menus.

---

## How to Run PowerShell Scripts (`.ps1`)

> **Note:** PowerShell scripts require an appropriate execution policy and Administrator rights.

1. **Open PowerShell as Administrator**

   * Search for `PowerShell`, right-click, and choose **Run as administrator**.

2. **Set temporary execution policy** (allows script execution in the current session):

   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope Process
   ```

3. **Navigate to the repository folder**:

   ```powershell
   cd "C:\path\to\SystemTools-BatchKit"
   ```

4. **Run the PowerShell script**:

   ```powershell
   .\PerformanceOptimizer.ps1
   ```

5. **Use the interactive menu** to select options.

---

## Logging and Reports

* **Batch scripts** write logs under:

  ```text
  C:\Windows\Temp\<ScriptName>.log
  ```

* **Hardware report** is saved in your Temp folder:

  ```text
  %TEMP%\System_Hardware_Report.txt
  ```

* **PowerShell optimizer** writes to:

  ```text
  C:\Windows\Temp\PerformanceOptimizer.log
  ```

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m "Add new script..."`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

---

## License

This project is released under the MIT License. Feel free to use and modify these scripts as needed.
