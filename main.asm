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

npc_car_blue:
    ; Row 0: Roof (inset by 2)
    dw 0x08DB, 0x08DB, 0x9920, 0x9920, 0x9920, 0x9920, 0x9920, 0x9920, 0x9920, 0x9920, 0x08DB, 0x08DB
    ; Row 1: Rear Windshield
    dw 0x08DB, 0x9920, 0x08B1, 0x08B1, 0x08B1, 0x08B1, 0x08B1, 0x08B1, 0x08B1, 0x08B1, 0x9920, 0x08DB
    ; Row 2: Main Body
    dw 0x08DB, 0x9920, 0x9920, 0x9920, 0x9920, 0x9920, 0x9920, 0x9920, 0x9920, 0x9920, 0x9920, 0x08DB
    ; Row 3: Trunk + Red Taillights
    dw 0x08DB, 0x9920, 0x4CDB, 0x4CDB, 0x9920, 0x9920, 0x9920, 0x9920, 0x4CDB, 0x4CDB, 0x9920, 0x08DB
    ; Row 4: Rear Bumper + Black Tires
    dw 0x08DB, 0x0020, 0x0020, 0x9920, 0x9920, 0x9920, 0x9920, 0x9920, 0x9920, 0x0020, 0x0020, 0x08DB

npc_car_green:
    ; Row 0: Roof (inset by 2)
    dw 0x08DB, 0x08DB, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x08DB, 0x08DB
    ; Row 1: Rear Windshield
    dw 0x08DB, 0x3320, 0x08B1, 0x08B1, 0x08B1, 0x08B1, 0x08B1, 0x08B1, 0x08B1, 0x08B1, 0x3320, 0x08DB
    ; Row 2: Main Body
    dw 0x08DB, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x08DB
    ; Row 3: Trunk + Red Taillights
    dw 0x08DB, 0x3320, 0x4CDB, 0x4CDB, 0x3320, 0x3320, 0x3320, 0x3320, 0x4CDB, 0x4CDB, 0x3320, 0x08DB
    ; Row 4: Rear Bumper + Black Tires
    dw 0x08DB, 0x0020, 0x0020, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x3320, 0x0020, 0x0020, 0x08DB

; Bonnet height (in HALF rows) for the right half of the screen.
; Index 0 = column 40 (centre) ... index 39 = column 79 (right edge).
; The left half is a mirror image (column 39 - i). 6 half rows = 3 rows
; at the centre, 2 half rows = 1 row at the edges -> smooth dome shape.
bonnet_profile:
    db 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6   ; i = 0..16
    db 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5                   ; i = 17..28
    db 4, 4, 4, 4, 4, 4                                     ; i = 29..34
    db 3, 3, 3                                              ; i = 35..37
    db 2, 2                                                 ; i = 38..39


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
    
    ; temp numbers
    mov word[es:di + 12], 0xBF31 ; 1
    mov word[es:di + 14], 0xBF34 ; 4
    mov word[es:di + 16], 0xBF36 ; 6
    mov word[es:di + 20], 0xBF2F ; /
    mov word[es:di + 24], 0xBF31 ; 1
    mov word[es:di + 26], 0xBF30 ; 0
    mov word[es:di + 28], 0xBF30 ; 0
    mov word[es:di + 30], 0xBF30 ; 0
    mov word[es:di + 34], 0xBF6D ; m
    
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
    ; car location (SI must point to car sprite)
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

; ==========================================
; PHASE 1 COCKPIT ELEMENTS (5 - 8)
; ==========================================

; ------------------------------------------------------------
; blend_cell
; Treats one text cell as two stacked "pixels" (top half and
; bottom half) and paints them while keeping what is already
; underneath.
;   ES:DI = cell address
;   AL    = colour for top half    (0xFF = keep what is there)
;   AH    = colour for bottom half (0xFF = keep what is there)
; Colours are 0..15 (text attribute colours).
; ------------------------------------------------------------
blend_cell:
    push bx
    push dx

    mov dx, [es:di]      ; dl = character, dh = attribute

    ; work out the colours currently shown in top (bl) / bottom (bh)
    mov bl, dh
    shr bl, 4            ; default: whole cell = background colour
    mov bh, bl

    cmp dl, 0xDB         ; full block -> foreground colour
    jne .not_full
    mov bl, dh
    and bl, 0x0F
    mov bh, bl
    jmp .overlay

.not_full:
    cmp dl, 0xDC         ; lower half block: top = bg, bottom = fg
    jne .not_lower
    mov bh, dh
    and bh, 0x0F
    jmp .overlay

.not_lower:
    cmp dl, 0xDF         ; upper half block: top = fg, bottom = bg
    jne .overlay
    mov bl, dh
    and bl, 0x0F

.overlay:
    cmp al, 0xFF
    je .skip_top
    mov bl, al
.skip_top:
    cmp ah, 0xFF
    je .skip_bottom
    mov bh, ah
.skip_bottom:

    cmp bl, bh
    jne .split

    ; both halves same colour -> plain space with that background
    shl bl, 4
    mov byte [es:di], 0x20
    mov [es:di + 1], bl
    jmp .done

.split:
    ; upper half block: fg = top colour, bg = bottom colour
    shl bh, 4
    or bh, bl
    mov byte [es:di], 0xDF
    mov [es:di + 1], bh

.done:
    pop dx
    pop bx
    ret

; ------------------------------------------------------------
; Bonnet: smooth orange dome across the whole width (rows 16-18)
; Colour 6 is turned into orange in "start".
; ------------------------------------------------------------
draw_bonnet:
    push ax
    push bx
    push cx
    push dx
    push si
    push es
    push di

    mov ax, 0xB800
    mov es, ax

    xor bx, bx                  ; bx = column 0..79

.col:
    ; pick the profile index (mirror the left half)
    cmp bx, 40
    jb .left
    mov si, bx
    sub si, 40
    jmp .got_index
.left:
    mov si, 39
    sub si, bx
.got_index:
    mov dl, [bonnet_profile + si]   ; height in half rows

    mov di, 2880                    ; start at row 18 (18 * 160)
    add di, bx
    add di, bx                      ; + column * 2

    mov cl, dl
    shr cl, 1                       ; number of full orange rows
    xor ch, ch

.full:
    mov ax, 0x0606                  ; top = orange, bottom = orange
    call blend_cell
    sub di, 160                     ; go one row up
    loop .full

    test dl, 1                      ; odd height -> extra half cell on top
    jz .next
    mov ax, 0x06FF                  ; keep top, bottom half = orange
    call blend_cell

.next:
    inc bx
    cmp bx, 80
    jb .col

    pop di
    pop es
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

draw_dashboard:
    push ax
    push cx
    push es
    push di

    mov ax, 0xB800
    mov es, ax
    mov di, 3040 ; row 19, col 0
    mov cx, 480  ; rows 19..24
    mov ax, 0x8020 ; dark grey dashboard
    cld
    rep stosw

    pop di
    pop es
    pop cx
    pop ax
    ret

draw_speed_box:
    push ax
    push cx
    push es
    push di

    mov ax, 0xB800
    mov es, ax
    cld

    ; Top border (row 20, cols 23..36)
    mov di, 3246
    mov word [es:di], 0x0FDA
    add di, 2
    mov cx, 12
    mov ax, 0x0FC4
    rep stosw
    mov word [es:di], 0x0FBF

    ; Row 21: black interior + "078"
    mov di, 3406
    mov word [es:di], 0x0FB3
    add di, 2
    mov cx, 12
    mov ax, 0x0020 ; black fill
    rep stosw
    mov word [es:di], 0x0FB3
    mov word [es:3406 + 10], 0x0E30 ; '0' (yellow)
    mov word [es:3406 + 12], 0x0E37 ; '7' (yellow)
    mov word [es:3406 + 14], 0x0E38 ; '8' (yellow)

    ; Row 22: black interior + "km/h"
    mov di, 3566
    mov word [es:di], 0x0FB3
    add di, 2
    mov cx, 12
    mov ax, 0x0020 ; black fill
    rep stosw
    mov word [es:di], 0x0FB3
    mov word [es:3566 + 10], 0x0F6B ; 'k'
    mov word [es:3566 + 12], 0x0F6D ; 'm'
    mov word [es:3566 + 14], 0x0F2F ; '/'
    mov word [es:3566 + 16], 0x0F68 ; 'h'

    ; Bottom border (row 23, cols 23..36)
    mov di, 3726
    mov word [es:di], 0x0FC0
    add di, 2
    mov cx, 12
    mov ax, 0x0FC4
    rep stosw
    mov word [es:di], 0x0FD9

    pop di
    pop es
    pop cx
    pop ax
    ret

draw_fuel_bar:
    push ax
    push cx
    push es
    push di

    mov ax, 0xB800
    mov es, ax
    cld

    ; "FUEL" label (white on dark grey)
    mov di, 3284
    mov word [es:di], 0x8F46     ; F
    mov word [es:di + 2], 0x8F55 ; U
    mov word [es:di + 4], 0x8F45 ; E
    mov word [es:di + 6], 0x8F4C ; L

    ; Fuel bar (8 green + 8 black)
    mov di, 3444
    mov cx, 8
    mov ax, 0x0ADB ; bright green
    rep stosw

    mov cx, 8
    mov ax, 0x0020 ; black (empty half)
    rep stosw

    ; "E" and "F" labels (white on dark grey)
    mov di, 3604
    mov word [es:di], 0x8F45      ; E
    mov word [es:di + 30], 0x8F46 ; F

    pop di
    pop es
    pop cx
    pop ax
    ret

; ------------------------------------------------------------
; get_wheel_color
;   AX = sub-pixel x (0..79), BX = sub-pixel y (0..49)
; Returns AL = 0 (black rim/spoke), 7 (grey hub) or 0xFF (nothing)
; Wheel centre = (75, 45)
; Outer ellipse 14 x 12, inner 11 x 9 (wider than tall, because
; a half-cell is taller than it is wide on screen).
; All sums stay below 65535 so they cannot overflow.
; ------------------------------------------------------------
get_wheel_color:
    push bx
    push cx
    push dx
    push si
    push di

    sub ax, 75
    mov si, ax                  ; si = dx (signed)
    sub bx, 45
    mov cx, bx                  ; cx = dy (signed)

    mov ax, si
    imul ax, ax
    mov dx, ax                  ; dx = dx^2
    mov bx, cx
    imul bx, bx                 ; bx = dy^2

    ; hub: dx^2*9 + dy^2*16 <= 144   (4 x 3 ellipse)
    mov ax, dx
    imul ax, 9
    mov di, bx
    imul di, 16
    add ax, di
    cmp ax, 144
    jbe .hub

    ; outer ellipse: dx^2*36 + dy^2*49 <= 7056   (14 x 12)
    mov ax, dx
    imul ax, 36
    mov di, bx
    imul di, 49
    add ax, di
    cmp ax, 7056
    ja .none

    ; inner ellipse: dx^2*81 + dy^2*121 <= 9801  (11 x 9)
    mov ax, dx
    imul ax, 81
    mov di, bx
    imul di, 121
    add ax, di
    cmp ax, 9801
    ja .ring                    ; between inner and outer -> rim

    ; inside the hole: horizontal spoke (2 sub-pixels thick)
    cmp cx, -1
    jl .not_h
    cmp cx, 0
    jg .not_h
    jmp .ring

.not_h:
    ; bottom spoke (3 sub-pixels wide, going down from the hub)
    cmp si, -1
    jl .none
    cmp si, 1
    jg .none
    cmp cx, 0
    jg .ring
    jmp .none

.ring:
    mov al, 0                   ; black
    jmp .out
.hub:
    mov al, 7                   ; light grey
    jmp .out
.none:
    mov al, 0xFF
.out:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret

; ------------------------------------------------------------
; Steering wheel: round black rim + grey hub, bottom right,
; cut off by the screen edges like the sample.
; ------------------------------------------------------------
draw_steering_wheel:
    push ax
    push bx
    push cx
    push dx
    push si
    push es
    push di

    mov ax, 0xB800
    mov es, ax

    mov dx, 15                  ; first text row of the wheel area

.row:
    mov cx, 60                  ; first text column of the wheel area

.col:
    ; top sub-pixel colour
    mov ax, cx
    mov bx, dx
    shl bx, 1
    call get_wheel_color
    push ax                     ; remember top colour (in AL)

    ; bottom sub-pixel colour
    mov ax, cx
    mov bx, dx
    shl bx, 1
    inc bx
    call get_wheel_color
    mov ah, al                  ; AH = bottom colour
    pop bx
    mov al, bl                  ; AL = top colour

    cmp ax, 0xFFFF              ; nothing to draw in this cell
    je .skip

    mov di, dx
    imul di, 160
    add di, cx
    add di, cx                  ; di = row * 160 + col * 2
    call blend_cell

.skip:
    inc cx
    cmp cx, 80
    jb .col

    inc dx
    cmp dx, 25
    jb .row

    pop di
    pop es
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret


start:
    ; Hide blinking text cursor
    mov ah, 0x01
    mov ch, 0x20
    int 0x10

    ; Soften sky color (DAC 0x3B) from bright turquoise to light sky blue
    mov ax, 0x1010
    mov bx, 0x003B
    mov dh, 32 ; Red
    mov ch, 48 ; Green
    mov cl, 63 ; Blue
    int 0x10

    ; Turn text colour 6 (brown, DAC 0x14) into orange for the bonnet
    mov ax, 0x1010
    mov bx, 0x0014
    mov dh, 60 ; Red
    mov ch, 30 ; Green
    mov cl, 4  ; Blue
    int 0x10

    call draw_sky_and_land
    call draw_road
    call draw_time_bar
    call draw_remaining_distance
    call draw_score
    
    ; Center car (Blue)
    mov si, npc_car_blue
    push word 34
    push word 8
    call draw_npc_car
    
    ; Right car (Green/Teal)
    mov si, npc_car_green
    push word 55
    push word 10
    call draw_npc_car

    ; Cockpit elements (Elements 5 - 8)
    call draw_bonnet
    call draw_dashboard
    call draw_speed_box
    call draw_fuel_bar
    call draw_steering_wheel

exit:
    mov ah, 00
    int 0x16
    mov ax, 0x4c00
    int 0x21
