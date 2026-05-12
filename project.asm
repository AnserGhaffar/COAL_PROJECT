org 100h       

jmp start       
							
correct  db '1234'           
entered  times 4 db 0       
tries    db 0              

msg_title db '========================',13,10
          db '  PIN SECURITY SYSTEM   ',13,10
          db '========================',13,10,'$'

msg_enter db 13,10,'Enter 4-digit PIN: ','$'
msg_ok    db 13,10,'>>> ACCESS GRANTED <<<',13,10,'$'
msg_deny  db 13,10,'ACCESS DENIED!',13,10,'$'
msg_left  db '    Attempts left : ','$'

msg_lock  db 13,10
          db '  ##########################',13,10
          db '  #  !!! SYSTEM LOCKED !!! #',13,10
          db '  ##########################',13,10
          db 7,'$'          

				
start:
    mov byte [tries], 0
    call clrscr
    mov  dx, msg_title
    mov  ah, 09h
    int  21h

attempt:
    mov  al, [tries]
    cmp  al, 3
    jge  lockdown

    mov  dx, msg_enter
    mov  ah, 09h
    int  21h

    mov  si, entered
    mov  cx, 4

read_loop:
    mov  ah, 07h            
    int  21h               

    cmp  al, '0'            
    jb   read_loop        

    cmp  al, '9'            
    ja   read_loop       

    mov  [si], al          
    mov  dl, al
    mov  ah, 02h
    int  21h
    inc  si
    loop read_loop          

    mov  ah, 02h           
    mov  dl, 10
    int  21h

    mov  si, entered
    mov  di, correct
    mov  cx, 4

cmp_loop:
    mov  al, [si]
    cmp  al, [di]
    jne  wrong
    inc  si
    inc  di
    loop cmp_loop

    mov  dx, msg_ok
    mov  ah, 09h
    int  21h
    mov  ah, 4ch
    mov  al, 0
    int  21h

wrong:
    inc  byte [tries]

    mov  dx, msg_deny
    mov  ah, 09h
    int  21h

    mov  dx, msg_left
    mov  ah, 09h
    int  21h

    mov  al, 3
    sub  al, [tries]
    add  al, '0'
    mov  dl, al
    mov  ah, 02h
    int  21h

    mov  dl, 10
    mov  ah, 02h
    int  21h

    jmp  attempt

lockdown:
    call clrscr

blink:
    mov  dx, msg_lock
    mov  ah, 09h
    int  21h

    mov  bx, 12
dly_a:
    xor  cx, cx
dly_b:
    loop dly_b
    dec  bx
    jnz  dly_a

    call clrscr

    mov  cx, 8000h
dly_c:
    loop dly_c

    mov  ah, 0bh            
    int  21h
    cmp  al, 0ffh
    jne  blink              

    mov  ah, 07h           
    int  21h

    cmp  al, 'R'
    je   start
    cmp  al, 'r'
    je   start
    jmp  blink

clrscr:
    mov  ah, 06h
    xor  al, al
    mov  bh, 07h
    xor  cx, cx
    mov  dx, 184fh
    int  10h

    mov  ah, 02h
    xor  bx, bx
    xor  dx, dx
    int  10h
    ret
