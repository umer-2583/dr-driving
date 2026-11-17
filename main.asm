[org 0x0100]

jmp start

; experimental: added to make the edges of road smooth
custom_edges_for_road:
    ; 0xF0: Left Outer (0 = Green bg, 1 = White fg)
    db 0x01, 0x01, 0x03, 0x03, 0x07, 0x07, 0x0F, 0x0F
    db 0x1F, 0x1F, 0x3F, 0x3F, 0x7F, 0x7F, 0xFF, 0xFF

    ; 0xF1: Left Inner (1 = White fg, 0 = Black road bg)
    db 0xFE, 0xFE, 0xFC, 0xFC, 0xF8, 0xF8, 0xF0, 0xF0
    db 0xE0, 0xE0, 0xC0, 0xC0, 0x80, 0x80, 0x00, 0x00

    ; 0xF2: Right Inner (1 = White fg, 0 = Black road bg)
    db 0x7F, 0x7F, 0x3F, 0x3F, 0x1F, 0x1F, 0x0F, 0x0F
    db 0x07, 0x07, 0x03, 0x03, 0x01, 0x01, 0x00, 0x00

    ; 0xF3: Right Outer (0 = Green bg, 1 = White fg)
    db 0x80, 0x80, 0xC0, 0xC0, 0xE0, 0xE0, 0xF0, 0xF0
    db 0xF8, 0xF8, 0xFC, 0xFC, 0xFE, 0xFE, 0xFF, 0xFF


clear_screen:
    push ax
    push cx
    push es
    push di
    
    mov ax, 0xb800
    mov es, ax
    mov cx, 2000
    mov di, 0
    mov ax, 0x0720
    
    cld
    rep stosw
    
    pop di
    pop es
    pop cx
    pop ax
    ret

draw_sky:
    push ax
    push cx
    push es
    push di
    
    mov ax, 0xb800
    mov es, ax
    mov cx, 400 ; first 5 rows
    mov di, 0
    mov ax, 0xB020 ; sky blue
    
    cld
    rep stosw
    
    pop di
    pop es
    pop cx
    pop ax
    ret

draw_land:
    push ax
    push cx
    push es
    push di
    
    mov ax, 0xb800
    mov es, ax
    mov cx, 1360
    mov di, 800
    mov ax, 0xAE20
    
    cld
    rep stosw
    
    pop di
    pop es
    pop cx
    pop ax
    ret
    
draw_road:
    push bp
    mov bp, sp
    sub sp, 6

    push ax
    push bx
    push cx
    push dx
    push es
    push di

    ; --- experimental: added to make the road edges smooth
    push ds
    pop es
    mov bp, custom_edges_for_road
    mov cx, 4
    mov dx, 0xF0
    mov bx, 0x1000
    mov ax, 0x1100
    int 0x10

    ; Restore BP after using it for int 0x10
    mov bp, sp
    add bp, 18 ; point BP back to original stack frame 

    ; Unlock bright background colors
    mov ax, 0x1003
    mov bl, 0
    int 0x10
    ; ---

    mov ax, 0xb800
    mov es, ax
    mov cx, 15 ; 15 rows
    mov di, 880 ; center of 5th line
    mov ax, 0x08DB ; road character
    mov word [bp - 6], 13 ; initial half width

    road_loop:
        push cx
        push di

        mov cx, [bp - 6]
        mov [bp - 4], di

        ; right half of road
        cld
        rep stosw
        mov word [es:di], 0x8FF2
        mov word [es:di + 2], 0xAFF3

        mov di, [bp - 4]
        sub di, 2
        mov cx, [bp - 6]
    
        ; left half of road
        std
        rep stosw
        mov word [es:di], 0x8FF1
        mov word [es:di - 2], 0xAFF0

        pop di
        pop cx
        add di, 160
        add word [bp - 6], 1
        loop road_loop

    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret

draw_time_bar:
    push ax
    push cx
    push di
    push es

    mov ax, 0xb800
    mov es, ax

    ;  Print "Time" at Row 1, Col 1 (offset = 1*160 + 1*2 = 162)
    ; Attribute 0xBF = Light Cyan sky background + Bright White text
    mov di, 162
    mov word [es:di],     0xBF54    ; 'T'
    mov word [es:di + 2], 0xBF69    ; 'i'
    mov word [es:di + 4], 0xBF6D    ; 'm'
    mov word [es:di + 6], 0xBF65    ; 'e'

    ;  Draw Top Half of Time Bar (Black: Rows 2 to 8 at Col 2)
    ; Row 2, Col 2 offset = (2 * 160) + (2 * 2) = 324
    mov di, 324
    mov cx, 7                       ; 7 rows tall
    mov ax, 0x0020                  ; Black background space
black_loop:
    mov [es:di], ax
    add di, 160                     ; Move down 1 row
    loop .black_loop

    ;  Draw Bottom Half of Time Bar (Red/Orange: Rows 9 to 15 at Col 2)
    ; DI is already at Row 9, Col 2 (offset 1444)
    mov cx, 7                       ; 7 rows tall
    mov ax, 0xCC20                  ; Bright Red-Orange background space

;Two types of parts in time bar in photo so one loop for Red area and one for black area
red_loop:
    mov [es:di], ax
    add di, 160                     ; Move down 1 row
    loop .red_loop

    pop es
    pop di
    pop cx
    pop ax
    ret
start:
    call clear_screen
    call draw_sky
    call draw_land
    call draw_road
    call draw_time_bar
    
    l1:
        jmp l1

exit:
    mov ax, 0x4c00
    int 0x21
