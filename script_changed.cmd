REM puff@mail.ru 2022.03.11
REM puff@mail.ru 2024.08.02 added to git
REM puff@mail.ru 2024.08.05 compare OLD with NEW (not NEW with OLD)
REM puff@mail.ru 2024.08.06 autoupdate if computername=AKRAYNOV-NEW



set COMP=%COMPUTERNAME%

if "%computername:~0,8%"=="AKRAYNOV"  echo updating script_changed.cmd from local %COMPUTERNAME%
if "%computername:~0,8%"=="AKRAYNOV"  copy /Y C:\Users\akraynov\YandexDisk\Programs\Script_changed\script_changed.cmd  .
if "%computername:~0,8%"=="AKRAYNOV"  sleep 0
 


set TARGET_FILE=target_file.txt

set TARGET_FILE=%1

if not exist %1 echo file %1 not exists! 
REM if not exist %1 exit

if not exist Backups mkdir Backups 
                    
   
fc .\Backups\%TARGET_FILE% %TARGET_FILE% 
if %errorlevel% NEQ 0 (
echo changes found
echo %DATE% %TIME% Script_changed.cmd ver. 2024/08/05 12:06 from computername: %COMPUTERNAME% by USERNAME : %USERNAME% in PATH: %CD% >>                              .\Backups\%TARGET_FILE%_changes.log


echo fc code: >>                                   .\Backups\%TARGET_FILE%_changes.log

fc .\Backups\%TARGET_FILE% %TARGET_FILE%  
echo %errorlevel% >>                               .\Backups\%TARGET_FILE%_changes.log

echo fc /N output: >>                               .\Backups\%TARGET_FILE%_changes.log
fc .\Backups\%TARGET_FILE% %TARGET_FILE%      /N >>  .\Backups\%TARGET_FILE%_changes.log
 
copy /Y %TARGET_FILE% .\Backups\%TARGET_FILE%
renamer .\Backups\%TARGET_FILE%
)
copy /Y %TARGET_FILE% .\Backups\%TARGET_FILE%


                                 