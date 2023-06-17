@echo off
setlocal enabledelayedexpansion

set "port=80"
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%port%"') do (
    set "pid=%%a"
    taskkill /F /PID !pid! >nul 2>&1
)
echo All programs on port %port% have been terminated.

set "port=8080"
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%port%"') do (
    set "pid=%%a"
    taskkill /F /PID !pid! >nul 2>&1
)
echo All programs on port %port% have been terminated.

taskkill /F /IM python.exe /T

echo Starting backend
set "PYTHONPATH=friendhub/backend/src;."
start "" /B py friendhub/backend/src/main.py

echo Starting frontend
cd ..\FriendHub-frontend
start "" /B trunk serve
start "" "http://127.0.0.1:8080"

endlocal
