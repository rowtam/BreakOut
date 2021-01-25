TITLE   BreakOut V1.00

.MODEL compact


COMMENT *
        This is the source code for BreakOut v1.00 by
        Ronnie Tam.  This version was finalized on
        12/12/99 for CS306.
	*

;Constants

TEXT_MODE   equ 03h
SCRN_WIDTH  equ 320
SCRN_HEIGHT equ 200
SCRN_SIZE   equ SCRN_WIDTH * SCRN_HEIGHT

PUBLIC _getVideoMode, _setVideoMode, _clearScreen, _drawHLine
PUBLIC _drawVLine, _drawBox, _drawFilledBox, _setColor, _getColor
PUBLIC _saveBlock, _setBlock, _setTransBlock,
PUBLIC _checkxdirection, _checkydirection
PUBLIC _checkbrickcollision, _checkmouseposition, _resetmouse
PUBLIC _GameOverStatus, _ReDrawScreen

.DATA
        scrn_seg dw @fardata            ; Write to secondary buffer
        scrn_off dw offset myscreen
        temp dw ?
        boxstackx dw 100 dup (?)        ; Array to store x coordinate of bricks
        boxstacky dw 100 dup (?)        ; Array to store y coordinate of bricks
        boxstackclear dw 100 dup (0)    ; Array to store whether brick is hit    
        stkindex dw 0                   ; used to keep track of size of array
        stksi dw ?
        overlap dw 0                    
        boundxa dw ?                    
        boundxb dw ?
        boundx2a dw ?
        boundx2b dw ?
        boxonetlx dw ?
        boxonetly dw ?
        boxonebrx dw ?
        boxonebry dw ?
        boxtwotlx dw ?
        boxtwotly dw ? 
        boxtwobrx dw ?
        boxtwobry dw ?
        boxoverlap dw ?
        hitbottom dw ?                  ; set if ball hit the bottom of the screen
        savestksi dw ?
        isinbetween dw ?

        brickcount dw 0                 ; keeps count of bricks

.FARDATA
        myscreen db 64000 dup (0)       ; buffer

.CODE

.386                                    

; unsigned char getVideoMode()
;   Returns the current video mode.

_getVideoMode PROC
	mov ah, 0Fh
	int 10h

	mov ah, 0
	ret
_getVideoMode ENDP


; void setVideoMode(char mode)
;   Sets the video mode to the specified value.

_setVideoMode PROC
	ARG mode:BYTE
	push bp
	mov bp, sp

	mov ah, 0
	mov al, mode
	int 10h

	pop bp
	ret
_setVideoMode ENDP

; void clearScreen(char color)
;   Clears the screen to the specified color

_clearScreen PROC
	ARG color:BYTE
	push bp
	mov bp, sp

        push si
        push di

        mov es, scrn_seg        ; es points to buffer
        mov ah, 0
        mov al, color
        mov di, scrn_off
        mov cx, SCRN_SIZE        
        rep stosb

        pop di
        pop si
                
	pop bp
	ret
_clearScreen ENDP


; void drawHLine(int x, int y, int len, int color)
;   Draw a horizontal line of the specified length and color
;   starting at (x, y).

_drawHLine PROC
	ARG x:WORD, y:WORD, len:WORD, color:BYTE
	push bp
	mov bp, sp
        push si
        push di

        mov ax, SCRN_WIDTH        ; calculate di starting point
        mul y
        add ax, x                 
        add ax, scrn_off          ; add screen offset
        mov di, ax                ; save into di
        mov es, scrn_seg          ; Make es point to buffer
        mov ah, 0
        mov al, color
        mov cx, len
        rep stosb                 

        pop di
        pop si                
	pop bp
	ret
_drawHLine ENDP


; void drawVLine(int x, int y, int len, char color)
;   Draw a vertical line of the specified length and color
;   starting at (x, y).

_drawVLine PROC
	ARG x:WORD, y:WORD, len:WORD, color:BYTE
	push bp
	mov bp, sp
        push si
        push di

        mov ax, SCRN_WIDTH
        mul y
        add ax, x
        add ax, scrn_off
        mov di, ax
        mov ah, 0
        mov al, color
        mov cx, len
        mov es, scrn_seg
        mov dx, 0
  label1:
        add di, SCRN_WIDTH
        mov es:[di], al
        inc dx
        cmp dx, len
        jb label1

        pop di
        pop si
        pop bp
	ret
_drawVLine ENDP


; void drawBox(int x1, int y1, int x2, int y2, char color)
;   Draw a hollow box of the specified color with upper-left
;   at (x1, y1) and lower-right at (x2, y2).

_drawBox PROC
	ARG x1:WORD, y1:WORD, x2:WORD, y2:WORD, color:BYTE
	push bp
	mov bp, sp
        push si
        push di
                         
        mov al, color
        mov ah, 0
        push ax     
        mov ax, x2
        sub ax, x1      ;get width of box
        inc ax
        push ax         ;push length of box on stack
        push y1         ;
        push x1
        call _drawHLine  ; draw the top horizone line of box
        pop bx
        pop bx
        pop bx
        pop bx
                        ; draw left vertical line of box
        mov cl, color   
        mov ch, 0
        push cx         ; push color
        mov ax, y2
        sub ax, y1
        ;inc ax
        push ax         ; push length         
        push y1         ; push y of lower left hand corner of box
        push x1
        call _drawVLine
        pop bx
        pop bx
        pop bx
        pop bx

        mov cl, color
        mov ch, 0
        push cx         ; push color
        mov ax, x2
        sub ax, x1
        inc ax
        push ax         ; push length
        push y2
        push x1
        call _drawHLine
        pop bx
        pop bx
        pop bx
        pop bx        

        mov cl, color
        mov ch, 0
        push cx         ; push color
        mov ax, y2
        sub ax, y1      ;
        push ax         ; push length
        push y1
        push x2
        call _drawVLine
        pop bx
        pop bx
        pop bx
        pop bx

        pop di
        pop si
	pop bp
	ret
_drawBox ENDP

; pushBox places the x and y coordinate of each brick into arrays.

pushBox PROC
        mov bx, stkindex
        mov boxstackx[bx], ax
        mov boxstacky[bx], cx
        inc brickcount        
        add stkindex, 2
        ret
pushBox ENDP

; void drawFilledBox(int x1, int y1, int x2, int y2, char color)
;   Draw solid box of the specified color with upper-left at
;   (x1, y1) and lower-right at (x2, y2).

_drawFilledBox PROC
	ARG x1:WORD, y1:WORD, x2:WORD, y2:WORD, color:BYTE
	LOCAL len:WORD =AUTO_SIZE
	push bp
	mov bp, sp
	sub sp, AUTO_SIZE
        push si
        push di

        mov ax, x1
        mov cx, y1
        call pushBox    ; place box coordinates in array
        mov ax, x2
        sub ax, x1
        inc ax
        mov len, ax
        mov bx, y2
        mov temp, bx
  label2:
        mov al, color
        mov ah, 0
        push ax
        push len
        push y1
        push x1
        call _drawHLine
        inc y1
        pop bx
        pop bx
        pop bx
        pop bx
        mov ax, y1
        cmp ax, temp
        jb label2

        pop di
        pop si
	mov sp, bp
	pop bp
	ret
_drawFilledBox ENDP

; ClearBrick clears a brick off the screen after it has been hit

_ClearBrick PROC
	ARG x1:WORD, y1:WORD, x2:WORD, y2:WORD, color:BYTE
	LOCAL len:WORD =AUTO_SIZE
	push bp
	mov bp, sp
	sub sp, AUTO_SIZE        
        push si
        push di
        mov ax, x2
        sub ax, x1
        inc ax
        
        mov len, ax
        mov bx, y2
        mov temp, bx
  label2c:
        mov al, color
        mov ah, 0
        push ax
        push len
        push y1
        push x1
        call _drawHLine
        inc y1
        pop bx
        pop bx
        pop bx
        pop bx
        mov ax, y1
        cmp ax, temp
        jb label2c
        pop di
        pop si
	mov sp, bp
	pop bp
	ret
_ClearBrick ENDP


; void setColor(unsigned char color, unsigned char red,
;               unsigned char green, unsigned char blue)
;   Set the specified entry in the color table to the
;   specified RGB values.

_setColor PROC
	ARG color:BYTE, red:BYTE, green:BYTE, blue:BYTE
	push bp
	mov bp, sp

	mov bh, 0
	mov bl, color

	mov dh, red
	mov ch, green
	mov cl, blue

	mov ah, 10h
	mov al, 10h
	int 10h

	pop bp
	ret
_setColor ENDP


; void getColor(unsigned char color, unsigned char *red,
;               unsigned char *green, unsigned char *blue)
;   Read the RGB values of the specified entry in the
;   color table.

_getColor PROC
	ARG color:BYTE, red_ptr:WORD, green_ptr:WORD, blue_ptr:WORD
	push bp
	mov bp, sp

	mov bh, 0
	mov bl, color

	mov ah, 10h
	mov al, 15h
	int 10h

	mov ah, 0

	mov al, dh
	mov bx, red_ptr
	mov word ptr [bx], ax

	mov al, ch
	mov bx, green_ptr
	mov word ptr [bx], ax

	mov al, cl
	mov bx, blue_ptr
	mov word ptr [bx], ax

	pop bp
	ret
_getColor ENDP


; void saveBlock(int x, int y, int width, int height, char *buffer)
;   Save the block from the screen starting at (x, y) of the
;   specified width and height to the supplied buffer.

_saveBlock PROC
        ARG x:WORD, y:WORD, width:WORD, height:WORD, buffer:DWORD
        LOCAL leng:WORD =AUTO_SIZE
	push bp        
	mov bp, sp
        sub sp, AUTO_SIZE
        push si
        push di
        mov ax, SCRN_WIDTH
        mov bx, width
        sub ax, bx              ; find length between rows
        mov leng, ax            ; save into leng
        mov es, scrn_seg        ; es points to buffer
        mov ax, SCRN_WIDTH      ; find starting di in video segment
        mul y                   
        add ax, x
        add ax, scrn_off        ; add the screen offset to ax
        mov di, ax              ; save starting point into di
        push ds
        lds si, buffer          ; make si point to the buffer
        mov cx, 0               ; reset character counter
        mov dx, 0               ; reset row counter
  label3:
        mov al, es:[di]         
        mov [si], al
        inc cx          ; increment character counter
        inc si          ; increment position in buffer
        inc di          ; increment position in video segment
        cmp cx, width   ; check to see if you've copied one line
        jb label3       
        mov cx, 0       ; reset counter
        inc dx          ; increment row counter
        add di, leng    ; increment to next row
        cmp dx, height
        jb label3

        pop ds
        pop di
        pop si
        mov sp, bp
	pop bp
	ret
_saveBlock ENDP


; void setBlock(int x, int y, int width, int height, char *buffer)
;   Copy the block of values from the given buffer to the
;   specified screen coordinates.

_setBlock PROC
        ARG x:WORD, y:WORD, width:WORD, height:WORD, buffer:DWORD
        LOCAL lengt:WORD =AUTO_SIZE
	push bp
	mov bp, sp
        sub sp, AUTO_SIZE
        push si
        push di                       
        mov ax, SCRN_WIDTH
        mov bx, width
        sub ax, bx        
        mov lengt, ax           ; save the length between rows
        mov es, scrn_seg        ; es points to A000:000
        mov ax, SCRN_WIDTH      ; ax register stores 320  
        mul y                   ; multiply ax by y
        add ax, x               ; add x to ax to find di
        add ax, scrn_off
        mov di, ax              ; load ax into di
        push ds
        lds si, buffer          ; make si point to the buffer
        mov cx, width           ; cx is counter for REP command
        mov dx, 0               ; use dx as a row counter
        cld
  label4:                
        rep movsb               ; copy CX # of terms from ds:[si] to es:[di]
        mov cx, width           ; RESET the width counter
        inc dx                  ; increment the row counter
        add di, lengt           ; move to the next row in video segment
        cmp dx, height          ; compare to see if # of rows = height
        jb label4

        pop ds
        pop di
        pop si
        mov sp, bp
	pop bp
	ret
_setBlock ENDP


; void setTransBlock(int x, int y, int width, int height, char *buffer,
;		     unsigned char color)
;   Copy the block of values from the given buffer to the
;   specified screen coordinates, without copying the bytes
;   of the specified color.

_setTransBlock PROC
        ARG x:WORD, y:WORD, width:WORD, height:WORD, buffer:DWORD, color:BYTE
        LOCAL lengt:WORD =AUTO_SIZE
	push bp
	mov bp, sp
        sub sp, AUTO_SIZE
        push si
        push di                
        mov ax, SCRN_WIDTH
        mov bx, width
        sub ax, bx                      ; find the length between rows
        mov lengt, ax                   ; save it
        mov es, scrn_seg                ; es points to video segment
        mov ax, SCRN_WIDTH              ; calculate starting point in es        
        mul y
        add ax, x
        add ax, scrn_off
        mov di, ax                      ; store starting point into di
        push ds
        lds si, buffer                  ; make si point to buffer
        mov cx, 0                       ; reset character counter
        mov dx, 0                       ; reset row counter
  label5:
        mov al, [si]
        cmp al, color
        je next
        mov es:[di], al
  next:
        inc cx          ; increment counter
        inc si          ; increment position in buffer
        inc di          ; increment position in video segment
        cmp cx, width   ; check to see if you've copied one line
        jb label5
        mov cx, 0       ; reset counter
        inc dx          ; increment row counter
        add di, lengt    ; increment to next row
        cmp dx, height
        jb label5
                
        pop ds
        pop di
        pop si
        mov sp, bp
	pop bp
	ret
_setTransBlock ENDP

_ReDrawScreen PROC
        push bp
        mov bp, sp
        push si
        push di
        push ds
        call waitForRetrace     ; wait for vertical retrace
        mov ax, 0A000H          
        mov es, ax              ; make es:[di] point to video
        mov di, scrn_off
        mov ax, @fardata
        mov ds, ax
        mov si, offset myscreen
        mov cx, 16000           ; 16000 x 4 = 64000 = size of video mem
        cld
        rep movsd               ; copy from buffer into video memory
        pop ds
        pop di
        pop si
        pop bp
        ret
_ReDrawScreen ENDP

; checkxdirection takes in the top left hand coordinate of the
; ball and determines whether or not the ball has hit a wall and
; returns the x-increment, deflected or not.
; currentx is the x-increment

_checkxdirection PROC
        ARG xa:WORD, xb:WORD, currentx:WORD
	push bp
	mov bp, sp
        push si
        push di

        mov ax, xa              ; the following lines check to see if 
        mov bx, 0               ; xa and xb are somewhere on the screen
        add ax, currentx
        cmp ax, bx              ; compare xa with 0
        jle switch
        mov ax, xb
        mov bx, SCRN_WIDTH
        add ax, currentx
        cmp ax, bx              ; compare xb with 320
        jge switch
        mov ax, currentx
        jmp end
  switch:
        mov bx, 4000
        call beep
        mov ax, currentx
        neg ax

  end:        
        pop di
        pop si
        pop bp
        ret
_checkxdirection ENDP

; checkydirection does the same thing as checkxdirection, but for the
; vertical direction and determines whether or not to deflect y based on
; whether a wall was hit or not, also
; sets a flag that determines whether or not the brick has hit the
; ground

_checkydirection PROC
        ARG ya:WORD, yb:WORD, currenty:WORD
	push bp
	mov bp, sp
        push si
        push di

        mov hitbottom, 0                ; reset hitbottom flag
        mov ax, ya
        mov bx, 10
        add ax, currenty
        cmp ax, bx                      ; check if ya is less than 10
        jbe yswitch
        mov ax, yb
        mov bx, SCRN_HEIGHT
        add ax, currenty
        cmp ax, bx                      ; check if yb is more than 200
        jae yswitchhit
        mov ax, currenty
        jmp yend
  yswitchhit:
        mov bx, 4000                    ; generate a beep if wall hit
        call beep
        mov hitbottom, 1
        mov ax, currenty
        neg ax
        jmp yend
  yswitch:
        mov bx, 4000
        call beep
        mov hitbottom, 0
        mov ax, currenty
        neg ax

  yend:
        pop di
        pop si
        pop bp
        ret
_checkydirection ENDP

; _GameOverStatus does several things.
; 1. If the ball hits the ground, then check if it hit the paddle
; 2. If the ball hits the paddle, then check to see where on the paddle
;    it hit and deflect accordingly
; 3. Check if there are any bricks left
; Return a 0, 1, or 2 depending upon the checks made in 1. 2. and 3.
; (not necessarily in that respective order)

_GameOverStatus PROC
        ARG paddlex:WORD, paddley:WORD, ballx:WORD, bally:WORD, xinc_ptr:DWORD, yinc_ptr:DWORD
        push bp
        mov bp, sp
        push si
        push di

        cmp brickcount, 0       ; check brick count if zero,
        je userwon              ; jump to the end and return a 2
        cmp hitbottom, 1        ; check if bottom of screen was hit
        jb bridge               ; if so, check for collision with paddle
        cmp bally, 100
        jb bridge
        mov ax, paddlex         ; checking for collision with paddle
        mov bx, paddley
        mov boxtwotlx, ax
        mov boxtwotly, bx
        add ax, 40
        mov boxtwobrx, ax
        mov ax, paddley
        add ax, 5
        mov boxtwobry, ax
        jmp overthebridge       ; label was too far from conditional jump
  bridge:                       ; so I had to "bridge" the jump
        jmp gamegoing
  overthebridge:        
        mov ax, ballx
        mov bx, bally
        mov boxonetlx, ax
        mov boxonetly, bx
        add ax, 8
        mov boxonebrx, ax
        mov ax, bally
        add ax, 8
        mov boxonebry, ax

        call boverlap           ; call procedure to determine if box overlaps
        cmp boxoverlap, 1       ; paddle
        je gamestillgoing       ; if so, check for where the paddle was hit
  userloses:
        mov ax, 1
        jmp endgos
  userwon:
        mov ax, 2
        jmp endgos
  gamestillgoing:               ; check what region of the paddle was hit and
        mov ax, ballx           ; deflect as appropriate
        add ax, 4
        mov bx, paddlex
        mov cx, paddlex
        add cx, 10
        call pointbetween
        cmp isinbetween, 1
        jne check2quarter
        mov ax, -2
        les bx, xinc_ptr
        mov es:[bx], ax
        mov ax, -4
        les bx, yinc_ptr
        mov es:[bx], ax         ; deflect at 135 degrees
        jmp gamegoing
  check2quarter:     
        mov ax, ballx
        add ax, 4
        mov bx, paddlex
        add bx, 10
        mov cx, paddlex
        add cx, 18
        call pointbetween
        cmp isinbetween, 1
        jne check3quarter
        mov ax, -2
        les bx, xinc_ptr
        mov es:[bx], ax
        mov ax, -6
        les bx, yinc_ptr
        mov es:[bx], ax         ; deflect at steeper angle
        jmp gamegoing
  check3quarter:     
        mov ax, ballx
        add ax, 4
        mov bx, paddlex
        add bx, 18
        mov cx, paddlex
        add cx, 22
        call pointbetween
        cmp isinbetween, 1
        jne check4quarter
        mov ax, 0
        les bx, xinc_ptr
        mov es:[bx], ax
        mov ax, -3
        les bx, yinc_ptr
        mov es:[bx], ax         ; deflect at 90 degrees (straight up)
        jmp gamegoing
  check4quarter:     
        mov ax, ballx
        add ax, 4
        mov bx, paddlex
        add bx, 22
        mov cx, paddlex
        add cx, 30
        call pointbetween
        cmp isinbetween, 1
        jne check5quarter
        mov ax, 2
        les bx, xinc_ptr
        mov es:[bx], ax
        mov ax, -6
        les bx, yinc_ptr
        mov es:[bx], ax         ; deflect at steep angle
        jmp gamegoing
  check5quarter:     
        mov ax, ballx
        add ax, 4
        mov bx, paddlex
        add bx, 30
        mov cx, paddlex
        add cx, 40
        call pointbetween
        cmp isinbetween, 1
        jne gamegoing
        mov ax, 2
        les bx, xinc_ptr
        mov es:[bx], ax
        mov ax, -4
        les bx, yinc_ptr
        mov es:[bx], ax         ; deflect at 45 degrees
        jmp gamegoing
  gamegoing:
        mov ax, 0

  endgos:
        pop di
        pop si
        pop bp
        ret
_GameOverStatus ENDP

; beep plays a beep of frequency stored in bx

beep PROC        
        mov cx, 100     ; beep for 100 cycles
        in al, 61h      ; enable computer speaker
        or al, 3        ; set PB0 and PB1 inputs
        out 61h, al
  loop1:
        mov ax, 34DCH   ; load ax with 1,129,180
        mov dx, 12h
        div bx          
        out 42h, al
        mov al, ah
        out 42h, al
        sub cx, 1
        cmp cx, 1
        jae loop1      ; keep beeping
        in al, 61h
        xor al, 3
        out 61h, al        
        ret
beep ENDP


; determines whether point ax is between bx and cx
pointbetween PROC
        mov isinbetween, 0
        cmp ax, bx
        jb notbetween
        cmp ax, cx
        ja notbetween
        mov isinbetween, 1
  notbetween:
        ret
pointbetween ENDP

;user places ax, bx, cx, dx
;user places boundxa, boundxb, boundx2a, boundx2b

; determines whether two lines bounded by boundxa, boundxb, boundx2a, and
; bound x2b.
; procedure does not work if line determined by boundxa and boundxb is
; larger than the other line and lies within boundx2a and x2b.
; however, this is easily remedied by making boundx2a/boundx2b the longer
; line, which is what this program does

isbetween PROC
        mov overlap, 0
        mov ax, boundxa
        mov cx, boundx2a
        cmp ax, cx              ; if boundxa is less than boundx2a
        jbe bnext
  anext:
        mov ax, boundxa 
        mov dx, boundx2b
        cmp ax, dx
        jae bnext               ; if boundxa is greater than boundx2b
        mov overlap, 1
        jmp endis
  bnext:
        mov bx, boundxb
        mov cx, boundx2a
        cmp bx, cx
        jbe endis
  cnext:
        mov bx, boundxb
        mov cx, boundx2b
        cmp bx, cx
        jae endis    
        mov overlap, 1
  endis:        
        ret
isbetween ENDP

; given 8 coordinates specifying two boxes, determine overlap

boverlap PROC        
        mov boxoverlap, 0
        mov ax, boxonetlx       ; load the top left x coordinate of box 1
        mov boundxa, ax
        mov ax, boxonebrx       ; load the bottom right x coordinate of box 1
        mov boundxb, ax
        mov ax, boxtwotlx       ; load the top left x coordinate of box 2
        mov boundx2a, ax
        mov ax, boxtwobrx       ; load the bottom right x coordinate of box 2
        mov boundx2b, ax        
        call isbetween
        cmp overlap, 1
        jne endoverlap
        mov ax, boxonetly       ; load the top left y coordinate of box 1
        mov boundxa, ax
        mov ax, boxonebry       ; load the bottom right y coordinate of box 1
        mov boundxb, ax
        mov ax, boxtwotly       ; load the top left y coordinate of box 2
        mov boundx2a, ax
        mov ax, boxtwobry       ; load the bottom right coordinate of box 2
        mov boundx2b, ax
        call isbetween
        cmp overlap, 1
        jne endoverlap
        mov boxoverlap, 1
  endoverlap:
        ret
boverlap ENDP


; if brick is hit, call this procedure.

clearbrickhit PROC
        mov ax, 0
        mov savestksi, bx
        push ax                 ; push color
        mov cx, boxstacky[bx]
        add cx, 10
        push cx                 ; push y2
        mov cx, boxstackx[bx]
        add cx, 30
        push cx                 ; push x2
        mov cx, boxstacky[bx]
        push cx                 ; push y1
        mov cx, boxstackx[bx]        
        push cx                 ; push x1
        call _ClearBrick
        pop ax
        pop ax
        pop ax
        pop ax
        pop ax
        mov bx, savestksi
        sub brickcount, 1
        ret
clearbrickhit ENDP

_checkbrickcollision PROC
        ARG xleft:WORD, ytop:WORD, xright:WORD, ybottom:WORD, xincrement:DWORD, yincrement:DWORD, xinc:WORD, yinc:WORD
        push bp
        mov bp, sp
        push si
        push di
        mov ax, 0
        mov stksi, ax                   ; loop through bricks to check for collision        
  startcheck:        
        mov cx, 1                       ; originally mov cx, 1
        mov bx, stksi                   ;
        cmp boxstackclear[bx], cx       ; check if brick is already hit
        je sts                         ; ****
        mov ax, xleft           
        mov bx, xright
        add ax, xinc      
        add bx, xinc
        mov boxonetlx, ax       ; load the top left x coordinate
        mov boxonebrx, bx       ; load the bottom right x coordinate
        mov ax, ytop
        mov bx, ybottom
        add ax, yinc
        add bx, yinc
        mov boxonetly, ax       ; load the top left y coordinate
        mov boxonebry, bx       ; load the bottom right coordinate
        mov bx, stksi
        mov ax, boxstackx[bx]
        mov cx, boxstacky[bx]
        mov boxtwotlx, ax       ; load the top left x coordinate of brick
        mov boxtwotly, cx       ; load the top left y coordinate of brick
        add ax, 30              
        add cx, 10
        mov boxtwobrx, ax       ; load the bottom right x coordinate of brick
        mov boxtwobry, cx       ; load the bottom right y coordinate of brick
        call boverlap           ; Check for boxoverlap
        cmp boxoverlap, 1       ; check boxoverlap flag
        je checkdeflectx        ; if there is overlap jump
  sts:
        add stksi, 2            ; if no overlap, check for collision with next box
        mov ax, stksi        
        cmp ax, stkindex        ; see if we've looped through all the bricks
        jb startcheck           ; if not keep looping through the bricks
        jmp estly               ; otherwise no overlap at all and finish
  checkdeflectx:
        mov bx, 1400            ; beep if brick was hit
        call beep
        mov bx, stksi
        mov boxstackclear[bx], 1  ; set bit so we know brick was hit
        call clearbrickhit      ; ****
        mov ax, xleft           ; check for INITIAL x-overlap
        mov boundxa, ax         ; load left x coordinate of ball
        mov ax, xright
        mov boundxb, ax         ; load right x coordinate of ball
        mov bx, stksi
        mov cx, boxstackx[bx]   ; load left x coordinate of brick
        mov boundx2a, cx
        add cx, 30
        mov boundx2b, cx        ; load right x coordinate of brick
        call isbetween          ; check for overlap
        cmp overlap, 1
        je checkdeflecty       ; If NO INITIAL overlap (but
        les bx, xincrement
        mov ax, es:[bx]
        neg ax
        mov es:[bx], ax
  checkdeflecty:
        mov bx, stksi
        mov ax, ytop           ; check for INITIAL y-overlap
        mov boundxa, ax        ; load left y coordinate of ball
        mov ax, ybottom
        mov boundxb, ax        ; load right y coordinate of ball
        mov bx, stksi
        mov cx, boxstacky[bx]  ; load left y coordinate of brick
        mov boundx2a, cx
        add cx, 10
        mov boundx2b, cx       ; load right y coordinate of brick
        call isbetween         ; check for overlap
        cmp overlap, 1
        je estly               ; If NO INITIAL overlap (but
        les bx, yincrement     ; next movement causes overlap)
        mov ax, es:[bx]
        neg ax                 ; deflect y otherwise don't deflect
        mov es:[bx], ax        
   estly:
        pop di
        pop si
        pop bp
        ret        
_checkbrickcollision ENDP

_checkmouseposition PROC
        push bp
        mov bp, sp
        push si
        push di
        mov ax, 3               ; read mouse status
        int 33h
        mov ax, cx              ; return x-coordinate of mouse
        pop di                  ; used to determine paddle position
        pop si
        pop bp
        ret
_checkmouseposition ENDP

_resetmouse PROC                ; reset the mouse
        push bp
        mov bp, sp
        push si
        push di
        mov ax, 0
        int 33h
        mov cx, 0
        mov dx, 560             ; set the left and right bounds of mouse
        mov al, 07h
        mov ah, 00h
        int 33h
        pop di
        pop si
        pop bp
        ret
_resetmouse ENDP

waitForRetrace PROC
        mov dx, 3DAh
        wfr:
        in al, dx
        test al, 8
        jnz wfr
        ret
waitForRetrace ENDP

END
