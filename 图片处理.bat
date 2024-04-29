chcp 65001
@echo off
setlocal

rem ####将下面的变量修改为你的convert.exe完整路径####
set "convert_exe_path=D:\ImageMagick-7.1.1-27\convert.exe"


set "error=call :red [Error]"
set "ok=call :green [Ciallo～]"

for /f "usebackq delims=" %%a in (`dir *.bmp *.png *.tif *.tiff *.jxl /b /a-d-s-r`) do call :ciallo1 "%%a"

if NOT defined ciallo (call %error%&echo  没有扫描到任何图片！&pause&exit)
call %ok%&echo  脚本任务全部运行完成啦！&pause&exit

:ciallo1
if NOT defined ciallo (call %ok%&call :ciallo2 "输入指令（1.直接无损压缩成jxl）"&md "输出")
call %ok%&call :print " 扫描到图片"&call :q&call :blue "%~1"&call :q&echo ，继续进行处理
set "ciallo=1"
if %command% EQU 1 (
	call :get_output_fullname "%~1" ".jxl"
	call "%convert_exe_path%" "%~1" -colorspace sRGB -depth 8 -quality 100 -define jxl:lossless=true "%%output_fullname%%"
	call :get_original_time "%~1"
	call :set_original_time "%%output_fullname%%" "%%original_time%%"
	call %ok%&call :print " 保存输出文件到"&call :q&call :blue "%%output_fullname%%"&call :q&echo.
) else (
	call %ok%&echo.
)
exit /b

:ciallo2
call :print " %~1"&set /p command=
if NOT defined command (call %error%&echo  命令行为空！&goto ciallo2)
exit /b

:red
powershell -ExecutionPolicy Bypass -Command "& {$oldColor = [System.Console]::ForegroundColor; [System.Console]::ForegroundColor = 'Red'; [System.Console]::Write('%~1'); [System.Console]::ForegroundColor = $oldColor}"
exit /b

:green
powershell -ExecutionPolicy Bypass -Command "& {$oldColor = [System.Console]::ForegroundColor; [System.Console]::ForegroundColor = 'Green'; [System.Console]::Write('%~1'); [System.Console]::ForegroundColor = $oldColor}"
exit /b

:blue
powershell -ExecutionPolicy Bypass -Command "& {$oldColor = [System.Console]::ForegroundColor; [System.Console]::ForegroundColor = 'Blue'; [System.Console]::Write('%~1'); [System.Console]::ForegroundColor = $oldColor}"
exit /b

:print
powershell -ExecutionPolicy Bypass -Command "& {[System.Console]::Write('%~1')}"
exit /b

:q
powershell -ExecutionPolicy Bypass -Command "& {[System.Console]::Write('""')}"
exit /b

:get_output_fullname
set "output_fullname=%cd%\输出\%~n1%~2"
exit /b

:get_original_time
for /f "usebackq delims=" %%a in (`powershell -ExecutionPolicy Bypass -Command "(Get-Item '%~1').CreationTime.ToString('yyyy-MM-dd HH:mm:ss')"`) do set "original_time=%%a"
exit /b

:set_original_time
powershell -ExecutionPolicy Bypass -Command "(Get-Item '%~1').CreationTime = '%~2'"
exit /b