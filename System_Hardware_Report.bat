@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

set "reportFile=%TEMP%\System_Hardware_Report.txt"
echo Generating hardware report, please wait... > "%reportFile%"
echo. >> "%reportFile%"

echo ==================== SYSTEM INFO ==================== >> "%reportFile%"
systeminfo >> "%reportFile%"
echo. >> "%reportFile%"

echo ==================== CPU INFO ==================== >> "%reportFile%"
wmic cpu get Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed /format:list >> "%reportFile%"
echo. >> "%reportFile%"

echo ==================== RAM INFO ==================== >> "%reportFile%"
wmic memorychip get Capacity,Speed,MemoryType,Manufacturer,PartNumber /format:list >> "%reportFile%"
echo. >> "%reportFile%"

echo ==================== MOTHERBOARD ==================== >> "%reportFile%"
wmic baseboard get Manufacturer,Product,Version /format:list >> "%reportFile%"
echo. >> "%reportFile%"

echo ==================== BIOS INFO ==================== >> "%reportFile%"
wmic bios get Manufacturer,SMBIOSBIOSVersion,ReleaseDate /format:list >> "%reportFile%"
echo. >> "%reportFile%"

echo ==================== GPU INFO ==================== >> "%reportFile%"
wmic path win32_VideoController get Name,DriverVersion,AdapterRAM /format:list >> "%reportFile%"
echo. >> "%reportFile%"

echo ==================== DISK INFO ==================== >> "%reportFile%"
wmic diskdrive get Model,InterfaceType,MediaType,Size /format:list >> "%reportFile%"
echo. >> "%reportFile%"

echo ==================== LOGICAL DRIVES ==================== >> "%reportFile%"
wmic logicaldisk get Name,FileSystem,Size,FreeSpace,VolumeName /format:list >> "%reportFile%"
echo. >> "%reportFile%"

echo ==================== BATTERY (if available) ==================== >> "%reportFile%"
wmic path Win32_Battery get Name,EstimatedChargeRemaining,Status /format:list >> "%reportFile%"
echo. >> "%reportFile%"

echo ==================== NETWORK ADAPTERS ==================== >> "%reportFile%"
wmic nic where "NetEnabled='true'" get Name,Speed,MACAddress /format:list >> "%reportFile%"
echo. >> "%reportFile%"

:: Show the result
notepad "%reportFile%"
exit /b
