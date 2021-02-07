#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#
jmp     st1
nop
dw      0000
dw      0000

dw      ad_isr
dw      0000
db     1012 dup(0)
st1:      cli
mov       ax,0200h
mov       ds,ax
mov       es,ax
mov       ss,ax
mov       sp,0FFFEH
mov       si,0000

mov al,90h            ;initialization of 8255 and 8253
out 06h,al
mov al,00110110b
out 0Eh,al            ; count given 4
mov al,4
out 08h,al
mov al,0
out 08h,al
mov bh,1               ;1-doors closed, 0- doors open
x2:    mov dh,0    ;no of sensors checked
mov [si],0       ;no of sensors above danger level


x0:    mov di,1         ;1-interrupt not yet raised,0- interrrupt raised and executed
    mov al,dh           
    out 04h,al
    or al,00100000b     ;ale given
    out 04h,al
    or al,00010000b     ;soc given
    out 04h,al
    nop                 
    nop
    nop
    nop
    and al,11101111b    ;soc removed
    out 04h,al
    and al,11011111b     ;ale removed
    out 04h,al
x4:    cmp di,0         ;wait till interrput has been raised
    jnz x4
    inc dh              ;check next sensor
    cmp dh,3            ;check whether all 3 sensors have been read
    jnz x0



x11:
    push ax
    cmp       [si],2           ;checks if no of sensors (at danger level) is above 2
    jae     xmm
    cmp bh,0                   ;check status of door
    jz     xr                  ;jump if door is already open
    mov al,00000001b           ;door is closed hence display 1
    jmp xaa
xr:    mov al,11000001b        ;enable motor,clockwise for closing and display 1
    mov bh,1                   ;store status of door
xaa:    cmp [si],1             ;check for malfunction (if only 1 sensor is active)
    jnz xn1                    ;jump if no sensor is at danger level
    or al,00010000b            ;sound warning alarm,blue led lights
xn1:    out 02h,al
    call sub1                  ;delay given to provide enough time for motor rotation
    and al,00110001b           ;disable motor after rotation
    jmp xxx
xmm:    cmp bh,1               ;check status of door
    jz xs                      ;jump if door already closed
    mov al,00100000b           ;display 0,disable motor as door already open
    jmp xab
xs:    mov al,01100000b       ;enable motor,anticlockwise for opening,display 0
    mov bh,0                  ;store status of door
xab:    out 02h,al
    call sub1               ;delay given to provide enough time for motor rotation
    and al,00110001b        ;disable motor after rotation
xxx:    out 02h,al
    pop ax

x10:  ;call sub1                      ;delay not given as simulation is slow and difficult to observe in proteus

    jmp x2




sub1:    mov dl,4            ;sub-routine for delay
xm:    mov cx,50000
xn:    loop xn
    dec dl
    jnz xm
    ret



ad_isr:    push ax
    push bx
    mov di,0
    or    al,00001000b            ;give output enable to ADC
    out 04h,al


    in al,00h                     ;read converted digital value from port A
    cmp al,30                     ;compare with arbitrary value taken (threshold)
    jb     xx
    add [si],1                    ;increment variable if sensor at danger level
xx:    pop bx
    pop ax
    and al,11110111b              ;remove output enable
    out 04h,al
    iret
























