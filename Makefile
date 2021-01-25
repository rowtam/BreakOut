all: breakout.exe

breakout.exe: breakout.cpp graphics.asm graphics.h
        bcc -mc breakout.cpp graphics.asm

clean:
	del *.obj
	del *.bak
	del *.map
        del breakout.exe
