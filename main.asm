[org 0x0100]

jmp start

dist_text:   db 'DIST 420 / 1000 m', 0
score_text:  db 'SCORE 4793', 0

; custom glyphs for smooth diagonal road borders
custom_edges_for_road:
    ; 0xF0: left outer
    db 0x01, 0x01, 0x03, 0x03, 0x07, 0x07, 0x0F, 0x0F
    db 0x1F, 0x1F, 0x3F, 0x3F, 0x7F, 0x7F, 0xFF, 0xFF

    ; 0xF1: left inner
    db 0xFE, 0xFE, 0xFC, 0xFC, 0xF8, 0xF8, 0xF0, 0xF0
    db 0xE0, 0xE0, 0xC0, 0xC0, 0x80, 0x80, 0x00, 0x00

    ; 0xF2: right inner
    db 0x7F, 0x7F, 0x3F, 0x3F, 0x1F, 0x1F, 0x0F, 0x0F
    db 0x07, 0x07, 0x03, 0x03, 0x01, 0x01, 0x00, 0x00

    ; 0xF3: right outer
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
    mov cx, 400
    mov di, 0
    mov ax, 0xB020

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

    ; load custom road edge characters
    push ds
    pop es
    mov bp, custom_edges_for_road
    mov cx, 4
    mov dx, 0xF0
    mov bx, 0x1000
    mov ax, 0x1100
    int 0x10

    ; restore BP to stack frame
    mov bp, sp
    add bp, 18

    ; enable bright background colors
    mov ax, 0x1003
    mov bl, 0
    int 0x10

    mov ax, 0xb800
    mov es, ax
    mov cx, 15
    mov di, 880
    mov ax, 0x08DB
    mov word [bp - 6], 13

    .road_loop:
        push cx
        push di

        mov cx, [bp - 6]
        mov [bp - 4], di

        ; right side
        cld
        rep stosw
        mov word [es:di], 0x8FF2
        mov word [es:di + 2], 0xAFF3

        mov di, [bp - 4]
        sub di, 2
        mov cx, [bp - 6]

        ; left side
        std
        rep stosw
        mov word [es:di], 0x8FF1
        mov word [es:di - 2], 0xAFF0

        pop di
        pop cx
        push cx
        push di

        ; dashed white lane dividers
        test cx, 2
        jz .skip_lane_lines

        mov ax, [bp - 6]
        mov bl, 3
        div bl
        xor ah, ah
        shl ax, 1

        mov di, [bp - 4]
        add di, ax
        mov word [es:di], 0x8FB3

        mov di, [bp - 4]
        sub di, ax
        mov word [es:di], 0x8FB3

    .skip_lane_lines:
        mov ax, 0x08DB

        pop di
        pop cx
        add di, 160
        add word [bp - 6], 1
        loop .road_loop

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

    mov di, 162
    mov word [es:di],     0xBF54    ; 'T'
    mov word [es:di + 2], 0xBF69    ; 'i'
    mov word [es:di + 4], 0xBF6D    ; 'm'
    mov word [es:di + 6], 0xBF65    ; 'e'

    ; upper black part
    mov di, 324
    mov cx, 7
    mov ax, 0x0020
    .black_loop:
        mov [es:di], ax
        add di, 160
        loop .black_loop

    ; lower red part
    mov cx, 7
    mov ax, 0xCC20
    .red_loop:
        mov [es:di], ax
        add di, 160
        loop .red_loop

    pop es
    pop di
    pop cx
    pop ax
    ret

draw_hud_text:
    push ax
    push si
    push di
    push es

    mov ax, 0xb800
    mov es, ax
    cld

    mov di, 174
    mov si, dist_text
    mov ah, 0xBF
    .dist_loop:
        lodsb
        cmp al, 0
        je .print_score
        stosw
        jmp .dist_loop

    .print_score:
        mov di, 334
        mov si, score_text
        mov ah, 0xBE
    .score_loop:
        lodsb
        cmp al, 0
        je .done
        stosw
        jmp .score_loop

    .done:
        pop es
        pop di
        pop si
        pop ax
        ret

start:
    call clear_screen
    call draw_sky
    call draw_land
    call draw_road
    call draw_time_bar
    call draw_hud_text

    mov ah, 0x00
    int 0x16

exit:
    mov ax, 0x4c00
    int 0x21
