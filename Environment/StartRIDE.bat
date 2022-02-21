@echo off
pushd %~dp0
if exist "..\.venv\" (call "..\.venv\Scripts\activate.bat")
if exist ".\.venv\" (call ".\.venv\Scripts\activate.bat")
python -m robotide.__init__
popd
