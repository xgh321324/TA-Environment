@echo off
pushd %~dp0
pushd ..
(py -3.7-32 -c "import sys; exit(sys.version_info[:3] < (3, 7, 3))") || ((start /wait 3rdParty\python-3.7.3.exe /passive InstallAllUsers=1 TargetDir=C:\Progs\Python37-32 CompileAll=1 PrependPath=1 SimpleInstall=1) && (rmdir /Q /S .venv))
if not exist ".\.venv\" (py -3.7-32 -m venv --prompt=PQ "./.venv")
call .venv\Scripts\activate.bat
popd
python Setup.py --prep-dev
popd
