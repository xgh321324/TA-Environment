@echo off
pushd %~dp0
pushd ..
call .venv\Scripts\activate.bat
popd
python Setup.py --gen-variables
popd
