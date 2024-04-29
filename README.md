# Image-Bat
一个简单的bat脚本，用于批量处理图片格式，基于ImageMagick。

目前只添加了图片无损转换为jpeg-xl (.jxl) 的功能

●使用方法
1.修改脚本中的“convert_exe_path”变量，其值为“convert.exe”的完整路径
2.把要处理的图片拖到.bat文件上，会把当前目录的所有图片（不包含子目录）都转换为jxl文件，保存到“输出”文件夹内
