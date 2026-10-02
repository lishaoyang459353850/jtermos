@echo off
chcp 65001 >nul
title JTermOS 安装程序 - 打包
echo ============================================
echo   JTermOS 安装程序  一键打包
echo ============================================
echo.

where python >nul 2>nul
if errorlevel 1 (
    echo [X] 没找到 python，请先安装 Python 3.8+ 并勾选 Add to PATH
    echo     下载：https://www.python.org/downloads/windows/
    pause
    exit /b 1
)

echo [1/2] 安装/更新 PyInstaller ...
python -m pip install --upgrade pyinstaller -q
if errorlevel 1 (
    echo [X] PyInstaller 安装失败，请检查网络
    pause
    exit /b 1
)

echo [2/2] 开始打包 ...
echo.
python build.py %*
if errorlevel 1 (
    echo [X] 打包失败
    pause
    exit /b 1
)

echo.
echo 产物在 dist\JTermOS-Installer.exe
pause
