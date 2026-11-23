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

npc_car_sprite:
    ; Row 0: Roof (inset by 2)
    dw 0x08DB, 0x08DB, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x08DB, 0x08DB
    ; Row 1: Rear Windshield
    dw 0x08DB, 0x3320, 0x08B1, 0x08B1, 0x08B1, 0x08B1, 0x08B1, 0x08B1, 0x08B1, 0x08B1, 0x3320, 0x08DB
    ; Row 2: Main Body
    dw 0x08DB, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x08DB
    ; Row 3: Trunk + Red Taillights
    dw 0x08DB, 0x3320, 0x4CDB, 0x4CDB, 0x3320, 0x3320, 0x3320, 0x3320, 0x4CDB, 0x4CDB, 0x3320, 0x08DB
    ; Row 4: Rear Bumper + Black Tires
    dw 0x08DB, 0x3420, 0x3420, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3420, 0x3420, 0x08DB



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

draw_sky_and_land:
    call clear_screen
    push ax
    push cx
    push es
    push di
    
    mov ax, 0xb800
    mov es, ax
    mov cx, 560 ; first 7 rows
    mov di, 0
    mov ax, 0xB020 ; sky blue
    
    cld
    rep stosw
    
    mov cx, 960 ; next 12 rows
    mov ax, 0xAE20
    
    rep stosw
    
    pop di
    pop es
    pop cx
    pop ax
    ret
    
draw_road:
    push bp
    mov bp, sp
    sub sp, 8

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
    add bp, 20 ; point BP back to original stack frame (6 pushed regs * 2)

    ; Unlock bright background colors
    mov ax, 0x1003
    mov bl, 0
    int 0x10
    ; ---

    mov ax, 0xb800
    mov es, ax
    mov cx, 12 ; 12 rows
    mov di, 1200 ; center of 7th line
    mov ax, 0x08DB ; road character
    mov word [bp - 6], 24 ; initial half width

    road_loop:
        push cx
        push di

        mov cx, [bp - 6]
        mov [bp - 4], di

        ; -- Right half and outer edge
        cld
        rep stosw
        mov word [es:di], 0x8FF2
        mov word [es:di + 2], 0xAFF3

        ; Draw dashed right lane 8 cols inside the right edge
        mov bx, [bp] ; read current loop counter from stack:
        mov bx, [esp + 2] ; peek outer CX (15 down to 1)
        test bl, 2 ; draw 2 rows on, 2 rows off
        jz skip_right_lane
        push di
        sub di, 8
        mov word [es:di - 18], 0x8FF2   ; inner half of lane line
        mov word [es:di - 16], 0x8FF3   ; outer half of lane line
        pop di
        skip_right_lane:

        ; -- Left half and outer edge
        mov di, [bp - 4]
        sub di, 2
        mov cx, [bp - 6]

        std
        rep stosw
        mov word [es:di], 0x8FF1
        mov word [es:di - 2], 0xAFF0

        ; Draw dashed left lane 8 cols inside the left edge
        mov bx, [esp + 2] ; peek outer CX
        test bl, 2
        jz skip_left_lane
        push di
        add di, 4
        mov word [es:di + 16], 0x8FF0   ; outer half of lane line
        mov word [es:di + 18], 0x8FF1   ; inner half of lane line
        pop di
        skip_left_lane:

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
    push bx
    push cx
    push dx
    push es
    push di

    mov ax, 0xb800
    mov es, ax
    mov di, 804
    mov cx, 10
    mov ax, 0x0720
    
    ; -- print time string
    push di
    push ax
    push bx
    push cx
    sub di, 164 ; previous line
    mov cx, 4
    
    mov word[es:di + 2], 0xBF54
    mov word[es:di + 4], 0xBF69
    mov word[es:di + 6], 0xBF6D
    mov word[es:di + 8], 0xBF65
    
    pop cx
    pop bx
    pop ax
    pop di
    ; --
    
    time_bar_loop:
        mov [es:di], ax
        add di, 160
        
        cmp cx, 8
        jnz time_bar_loop_next
        
        mov ax, 0x04DB
        
        time_bar_loop_next:
        loop time_bar_loop

    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret

draw_remaining_distance:
    ; 1. bp + 4 -> remaining distance
    ; 2. bp + 6 -> total distance
    push bp
    mov bp, sp
    sub sp, 4 ; space for two vars
    
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    
    mov ax, 0xB800
    mov es, ax
    mov di, 6 ; 1st line, 3rd col
    
    ; 0xBF -> sky blue bg and white fg
    
    ; title
    mov word[es:di + 2], 0xBF44 ; D
    mov word[es:di + 4], 0xBF49 ; I
    mov word[es:di + 6], 0xBF53 ; S
    mov word[es:di + 8], 0xBF54 ; T
    ; mov word[es:di + 8], 0xB020 ; space
    
    ; temp numbers
    mov word[es:di + 12], 0xBF31 ; 1
    mov word[es:di + 14], 0xBF34 ; 4
    mov word[es:di + 16], 0xBF36 ; 6
    ; mov word[es:di + 18], 0xB020 ; space
    mov word[es:di + 20], 0xBF2F ; /
    ; mov word[es:di + 22], 0xB020 ; space
    mov word[es:di + 24], 0xBF31 ; 1
    mov word[es:di + 26], 0xBF30 ; 0
    mov word[es:di + 28], 0xBF30 ; 0
    mov word[es:di + 30], 0xBF30 ; 0
    
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    
    mov sp, bp
    pop bp
    ret
    
draw_score:
    push bp
    mov bp, sp
    
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    
    mov ax, 0xB800
    mov es, ax
    mov di, 324 ; 3rd line, 2nd col
    
    ; title
    mov word [es:di + 2], 0xBE53 ; S
    mov word [es:di + 4], 0xBE63 ; c
    mov word [es:di + 6], 0xBE6F ; o
    mov word [es:di + 8], 0xBE72 ; r
    mov word [es:di + 10], 0xBE65 ; e
    ; mov word[es:di + 12], 0xB020 ; space
    
    ; temp numbers
    mov word[es:di + 14], 0xBF34 ; 4
    mov word[es:di + 16], 0xBF36 ; 6
    mov word[es:di + 18], 0xBF35 ; 5
    mov word[es:di + 20], 0xBF32 ; 2
    
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    
    mov sp, bp
    pop bp
    ret
    
draw_npc_car:
    ; car location
    ; bp + 4 -> Y
    ; bp + 6 -> X
    
    push bp
    mov bp, sp
    
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    push si
    
    mov ax, 0xB800
    mov es, ax
    mov ax, [bp + 4] ; row -> Y
    mov bl, 80 ; Y * 80
    mul bl
    add ax, [bp + 6] ; sum = Y * 80 + X
    shl ax, 1 ; sum * 2
    mov di, ax
    
    mov si, npc_car_sprite  ; Point SI to our sprite table
    mov cx, 5 ; 5 rows tall
    cld
    
    print_npc_car_loop:
        push cx
        mov cx, 12 ; 12 columns wide
        rep movsw ; Copy 12 words from [DS:SI] to [ES:DI]
        add di, 136 ; Next row (160 - 24 = 136)
        pop cx
        loop print_npc_car_loop
    
    pop si
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    
    mov sp, bp
    pop bp
    ret 4
    

start:
    call draw_sky_and_land
    call draw_road
    call draw_time_bar
    call draw_remaining_distance
    call draw_score
    
    push word 14
    push word 12
    call draw_npc_car
    
    push word 48 
    push word 8
    call draw_npc_car

exit:
    mov ah, 00
    int 0x16
    mov ax, 0x4c00
    int 0x21
