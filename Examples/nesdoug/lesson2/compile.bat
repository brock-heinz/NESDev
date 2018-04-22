@echo off

set name="lesson2"

set CC65_HOME=C:\NESDev\Tools\cc65\

if "%PATH%"=="%PATH:cc65=%" @PATH=%PATH%;%CC65_HOME%bin\

cc65 -Oi %name%.c --add-source
ca65 reset.s
ca65 %name%.s

ld65 -C nes.cfg -o %name%.nes reset.o %name%.o nes.lib

del *.o

pause

%name%.nes
