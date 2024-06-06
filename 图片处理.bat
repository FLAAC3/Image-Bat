(chcp 65001)>nul&@echo off&setlocal&call :info||exit



rem "以下三个变量可用“%~dp0”表示脚本所在目录，“%%”来表示路径中的百分号"
rem exe文件完整路径
set "convert_exe_path=D:\New Project\out\production\ImageMagick-7.1.1-27\convert.exe"
rem 图片输出路径
set "out_dir=图片输出"
rem 配置库文件夹路径
set "conf_dir=%~dp0ImageMagick配置库"



rem 运行正常时打印消息的前缀，不能有中文或英文单引号
set "ok=[Ciallo～(∠・ω< )◠☆]"
rem 检查到错误时打印消息的前缀，不能有中文或英文单引号
set "no=[Error ～(∠・ω< )◠☆]"



rem 以下三个变量为默认值，会被配置文件覆盖
rem 是否使文件创建日期不变
set "keep_create_date=false"
rem 是否使文件修改日期不变
set "keep_revise_date=false"
rem 是否在文件处理完成后删除源文件
set "delete_source_file=false"



for /f "usebackq delims=" %%a in (`dir *.jpg *.jpeg *.bmp *.png *.tif *.tiff *.webp *.jxl /b /a-d-s-r`) do set "original_name=%%a"&call :file_loop
if NOT defined ciallo (call :color_print "Red" "%no%"&echo  没有扫描到任何图片！&pause&exit)
call :color_print "Green" "%ok%"&echo  脚本任务全部运行完成啦！&pause&exit

:file_loop
if NOT defined ciallo (call :echo_conf&call :read_instruction&call :check_out_dir)
call :color_print "Green" "%ok%"&call :print " 扫描到图片“"&call :print_original_name&echo ”，继续进行处理
call :get_short_name&call :get_output_fullname&call :exec_command
call :color_print "Green" "%ok%"&call :print " 保存输出文件到“"&call :print_output_fullname&echo ”
call :exec_keep_create_date&call :exec_keep_revise_date&call :exec_delete_source_file
exit /b

:read_instruction
call :color_print "Green" "%ok%"&call :print " 输入配置文件的数字编号"&set /p command=
if NOT defined command (call :color_print "Red" "%no%"&echo  输入为空！&goto read_instruction)
call :check_command
for /f "usebackq delims=" %%a in (`powershell -ExecutionPolicy Bypass -Command "$json = [System.IO.File]::ReadAllLines('%conf_dir%\temp.json', [System.Text.Encoding]::UTF8)[0]; $json = '{'+$json+'}'; $object = $json | ConvertFrom-Json; [System.Console]::Write($object.'%command%')"`) do set "conf_name=%command%.%%a.txt"
if NOT defined conf_name (call :color_print "Red" "%no%"&echo  找不到编号对应的配置！&goto read_instruction)
call :color_print "Green" "%ok%"&echo  开始转换配置文件到JSON格式
for /f "usebackq delims=" %%a in ("%conf_dir%\%conf_name%") do (
	for /f "eol=; tokens=1,* delims==" %%b in ("%%a") do (
		if defined ciallo (
			(powershell -ExecutionPolicy Bypass -Command "& {$q=[char]34; $qq='\'+$q; $out = '%%c' -replace $q, $qq; [System.Console]::Write(',{0}{1}{0}:{0}{2}{0}', $q, '%%b', $out)}")>>"%conf_dir%\temp.json"
		) else (
			set "ciallo=1"&(set /p={<nul)>"%conf_dir%\temp.json"
			(powershell -ExecutionPolicy Bypass -Command "& {$q=[char]34; $qq='\'+$q; $out = '%%c' -replace $q, $qq; [System.Console]::Write('{0}{1}{0}:{0}{2}{0}', $q, '%%b', $out)}")>>"%conf_dir%\temp.json"
		)
	)
)
if defined ciallo ((echo })>>"%conf_dir%\temp.json") else (call :color_print "Red" "%no%"&echo  无法识别的配置文件！&pause&exit)
call :color_print "Green" "%ok%"&echo  转换成功，开始读取
for /f "usebackq delims=" %%a in (`powershell -ExecutionPolicy Bypass -Command "$json = [System.IO.File]::ReadAllLines('%conf_dir%\temp.json', [System.Text.Encoding]::UTF8)[0]; $object = $json | ConvertFrom-Json; $ciallo = $object.'command'; if ($ciallo -eq $null){ exit 0 }; if ($ciallo.Trim() -eq ''){ exit 0 }; $out = $object.'output_suffix'; if ($out -eq $null){ exit 0 } else { [System.Console]::Write($out.Trim()) }"`) do set "output_suffix=%%a"
if NOT defined output_suffix (call :color_print "Red" "%no%"&echo  无法识别的配置文件！&pause&exit)
call :color_print "Green" "%ok%"&echo  已读取 command、output_suffix
for /f "usebackq delims=" %%a in (`powershell -ExecutionPolicy Bypass -Command "$json = [System.IO.File]::ReadAllLines('%conf_dir%\temp.json', [System.Text.Encoding]::UTF8)[0]; $object = $json | ConvertFrom-Json; $out = $object.'keep_create_date'; if ($out -eq $null){ exit 0 } else { [System.Console]::Write($out.Trim()) }"`) do (
	if "%%a" EQU "true" (
		set "keep_create_date=true"
		call :color_print "Green" "%ok%"&echo  已读取 keep_create_date ,值为真
	) else (
		set "keep_create_date=false"
		call :color_print "Green" "%ok%"&echo  已读取 keep_create_date ,值为假
	)
)
for /f "usebackq delims=" %%a in (`powershell -ExecutionPolicy Bypass -Command "$json = [System.IO.File]::ReadAllLines('%conf_dir%\temp.json', [System.Text.Encoding]::UTF8)[0]; $object = $json | ConvertFrom-Json; $out = $object.'keep_revise_date'; if ($out -eq $null){ exit 0 } else { [System.Console]::Write($out.Trim()) }"`) do (
	if "%%a" EQU "true" (
		set "keep_revise_date=true"
		call :color_print "Green" "%ok%"&echo  已读取 keep_revise_date ,值为真
	) else (
		set "keep_revise_date=false"
		call :color_print "Green" "%ok%"&echo  已读取 keep_revise_date ,值为假
	)
)
for /f "usebackq delims=" %%a in (`powershell -ExecutionPolicy Bypass -Command "$json = [System.IO.File]::ReadAllLines('%conf_dir%\temp.json', [System.Text.Encoding]::UTF8)[0]; $object = $json | ConvertFrom-Json; $out = $object.'delete_source_file'; if ($out -eq $null){ exit 0 } else { [System.Console]::Write($out.Trim()) }"`) do (
	if "%%a" EQU "true" (
		set "delete_source_file=true"
		call :color_print "Green" "%ok%"&echo  已读取 delete_source_file ,值为真
	) else (
		set "delete_source_file=false"
		call :color_print "Green" "%ok%"&echo  已读取 delete_source_file ,值为假
	)
)
exit /b

:color_print
powershell -ExecutionPolicy Bypass -Command "& {$oldColor = [System.Console]::ForegroundColor; [System.Console]::ForegroundColor = '%~1'; [System.Console]::Write('%~2'); [System.Console]::ForegroundColor = $oldColor}"
exit /b

:print
powershell -ExecutionPolicy Bypass -Command "& {[System.Console]::Write('%~1')}"
exit /b

:echo_conf
powershell -ExecutionPolicy Bypass -Command "if (Test-Path '%conf_dir%') { exit 0 } else { exit 1 }"
if %errorlevel% EQU 1 (call :color_print "Red" "%no%"&echo  配置文件夹不存在！请检查 conf_dir 是否存储了正确的路径信息&pause&exit)
for /f "usebackq tokens=1,* delims=." %%a in (`powershell -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%conf_dir%' -File | Where-Object { $_.Name -match '^\d{2}\..+\.txt$' } | Sort-Object Name | ForEach-Object { Write-Output $_.BaseName }"`) do (
if NOT defined ciallo (set "ciallo=1"&call :color_print "Green" "%ok%"& echo  识别到以下配置文件：)
set "cache=%%a"&set "__cache=%%b"&call :_echo_conf&set "_cache=%%a"
)
if NOT defined ciallo (call :color_print "Red" "%no%"&echo  没有扫描到任何有效的配置！&pause&exit)
set "ciallo="
exit /b
:_echo_conf
if defined _cache (
	if "%_cache%" NEQ "%cache%" (
		(powershell -ExecutionPolicy Bypass -Command "& {$q=[char]34; [System.Console]::Write(',{0}{1}{0}:{0}{2}{0}', $q, '%cache%', '%__cache%')}")>>"%conf_dir%\temp.json"
		call :color_print "Magenta" "[%cache%]"&powershell -ExecutionPolicy Bypass -Command "Write-Output ' %__cache%'"
	)
) else (
	(powershell -ExecutionPolicy Bypass -Command "& {$q=[char]34; [System.Console]::Write('{0}{1}{0}:{0}{2}{0}', $q, '%cache%', '%__cache%')}")>"%conf_dir%\temp.json"
	call :color_print "Magenta" "[%cache%]"&powershell -ExecutionPolicy Bypass -Command "Write-Output ' %__cache%'"
)
exit /b

:check_command
powershell -ExecutionPolicy Bypass -Command "if ('%command%' -match '^\d{1,2}$') { exit 0 } else { exit 1 }"
if %errorlevel% EQU 1 (call :color_print "Red" "%no%"&echo  无法识别的输入值！&goto read_instruction)
powershell -ExecutionPolicy Bypass -Command "if ('%command%' -match '^\d$') { exit 1 } else { exit 0 }"
if %errorlevel% EQU 1 (set "command=0%command%")
exit /b 0

:check_out_dir
(powershell -ExecutionPolicy Bypass -Command "mkdir -Force '%out_dir%'")>nul
powershell -ExecutionPolicy Bypass -Command "if ('%out_dir%' -match '^[C-Z]:[/|\\]') { exit 0 } else { exit 1 }"
if %errorlevel% EQU 1 (if "%cd:~-1%" EQU "\" (set "out_dir=%cd%%out_dir%") else (set "out_dir=%cd%\%out_dir%"))
exit /b 0

:exec_command
powershell -ExecutionPolicy Bypass -Command "$json = [System.IO.File]::ReadAllLines('%conf_dir%\temp.json', [System.Text.Encoding]::UTF8)[0]; $object = $json | ConvertFrom-Json; $com = $object.'command'.Trim(); $q = [char]34; $m = '(?:\S*?(?<!\\)'+$q+'.*?(?<!\\)'+$q+'(?:[^'+$q+'\s]*(?:\\'+$q+'))*|\S)+'; $in = $q+'%original_name%'+$q; $out = $q+'%output_fullname%'+$q; $com = $com -replace '\[\*in\]', $in; $com = $com -replace '\[\*out\]', $out; $com = ($com | Select-String -Pattern $m -AllMatches).Matches.Value; & '%convert_exe_path%' $com"
exit /b

:print_original_name
powershell -ExecutionPolicy Bypass -Command "& {$oldColor = [System.Console]::ForegroundColor; [System.Console]::ForegroundColor = 'Blue'; [System.Console]::Write('%original_name%'); [System.Console]::ForegroundColor = $oldColor}"
exit /b

:get_short_name
for /f "usebackq delims=" %%a in (`powershell -ExecutionPolicy Bypass -Command "$input='%original_name%'; $split = $input -split '\.'; $first = $split[0..($split.Length-2)] -join '.'; [System.Console]::Write($first)"`) do set "short_name=%%a"
exit /b

:get_output_fullname
set "output_fullname=%out_dir%\%short_name%.%output_suffix%"
exit /b

:print_output_fullname
powershell -ExecutionPolicy Bypass -Command "& {$oldColor = [System.Console]::ForegroundColor; [System.Console]::ForegroundColor = 'Blue'; [System.Console]::Write('%output_fullname%'); [System.Console]::ForegroundColor = $oldColor}"
exit /b

:exec_keep_create_date
if "%keep_create_date%" EQU "true" (powershell -ExecutionPolicy Bypass -Command "$date = (Get-Item '%original_name%').CreationTime.ToString('yyyy-MM-dd HH:mm:ss'); (Get-Item '%output_fullname%').CreationTime = $date")
exit /b

:exec_keep_revise_date
if "%keep_revise_date%" EQU "true" (powershell -ExecutionPolicy Bypass -Command "$date = (Get-Item '%original_name%').LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'); (Get-Item '%output_fullname%').LastWriteTime = $date")
exit /b

:exec_delete_source_file
if "%delete_source_file%" EQU "true" (del "%original_name%")
exit /b

:info
echo *******************************************************************
echo *                         Power By FLAAC3                         *
echo *               https://github.com/FLAAC3/Image-Bat               *
echo *******************************************************************
echo *     注意：任何路径、配置文件内容都不能含有中文或英文的单引号    *
echo *******************************************************************
echo.
exit /b
