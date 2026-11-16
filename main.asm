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
    add bp, 12 ; point BP back to original stack frame (6 pushed regs * 2)

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

start:
    call clear_screen
    call draw_sky
    call draw_land
    call draw_road
    
    ; to remove, added just so we have the last line on the screen empty
    l1:
        jmp l1

exit:
    mov ax, 0x4c00
    int 0x21
