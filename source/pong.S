.global main
.global __do_copy_data
#include<avr/io.h>

.data 

playerPaddle:
  .byte 0
compPaddle:
  .byte 0
ballX:
  .byte 0
ballY:
  .byte 0
speedX:
  .byte 0 
speedY:
  .byte 0
gameOver:
  .byte 0

.text

init_globals:
  ldi r24, 1
  sts playerPaddle, r24
  ldi r24, 1
  sts compPaddle, r24
  ldi r24, 8
  sts ballX, r24
  ldi r24, 4
  sts ballY, r24
  ldi r24, 1
  sts speedX, r24
  ldi r24, -1
  sts speedY, r24
  ldi r24, 0
  sts gameOver, r24
  ret

spiTransfer:
  ;SPDR = data;
  out	0x2e, r24
  ;while(!(SPSR & (1<<SPIF)));
1:
  in	r0, 0x2d
  sbrs	r0, 7
  rjmp 1b
  ret

sendAll:
  push r28
  push r29
  mov	r29, r24
  mov	r28, r22
  ;bitClear(PORTB, 2);
  cbi	0x05, 2
  ;spiTransfer(registerIndex);
  call	spiTransfer
  ;spiTransfer(value);
  mov	r24, r28
  call	spiTransfer
  ;spiTransfer(registerIndex);
  mov	r24, r29
  call	spiTransfer
  ;spiTransfer(value);
  mov	r24, r28
  call	spiTransfer
  ;bitSet(PORTB, 2);
  sbi	0x05, 2
	pop	r29
  pop	r28
  ret

clearDisplays:
  push r28
  ldi	r28, 0x01	; int row = 1
  1:
  ;sendAll(row, 0);
  ldi	r22, 0x00	; 
  mov	r24, r28
  call sendAll
  inc r28 ; ++row 
  cpi	r28, 0x09	; row <= 8
  brne 1b
  pop	r28
  ret

testDisplay:
  ;bitClear(PORTB, 2);
  cbi	0x05, 2
  ;spiTransfer(registerIndex);
  ldi r24, 0x02
  call	spiTransfer
  ;spiTransfer(value);
  ldi r24, 0xff
  call	spiTransfer
  ;spiTransfer(registerIndex);
  ldi r24, 0x02
  call	spiTransfer
  ;spiTransfer(value);
  ldi r24, 0xff
  call	spiTransfer
  ;bitSet(PORTB, 2);
  sbi	0x05, 2

delay_millis:
  ldi r26, 4000 & 0xff
  ldi r27, 4000 >> 8
1:  
  sbiw r26, 1
  brne 1b
  sbiw r24, 1
  brne delay_millis
  ret

;bit()
bitCreate:
  push r16
  ldi r16, 1
notDone:
  cp r21, r1
  breq done  
  lsl r16
  dec r21
  rjmp notDone
done:
  mov r21, r16
  pop r16
  ret

main:
  call init_globals
  ;DDRB = bit(5)|bit(3)|bit(2);
  ldi	r24, 0x2C 
  out	0x04, r24 
  ;PORTB = bit(2);
  ldi	r24, 0x04 
  out	0x05, r24 
  ;SPCR = 0b01010000;
  ldi	r24, 0x50
  out	0x2c, r24
  ;DDRD = 0;
  out	0x0a, r1
  ;PORTD = bit(7)|bit(6) ;
  ldi	r24, 0xC0
  out	0x0b, r24
  ;sendAll(0xf, 0); // Disable test mode
  ldi	r22, 0x00
  ldi	r24, 0x0F
  call sendAll
  ;sendAll(0xb, 7); // Set scanlines to 8
  ldi	r22, 0x07
  ldi	r24, 0x0B
  call sendAll
  ;clearDisplays();
  call clearDisplays 
  ;sendAll(0xc, 1); // Enable display
  ldi	r22, 0x01	; 1
  ldi	r24, 0x0C	; 12
  call sendAll	
  ;call testDisplay

  rjmp loop

loop:
  ;updateBall();
  call updateBall

  lds r24, gameOver
  ;if(gameOver)
  ;  lose();
  sbrc r24, 0
  call lose
  
  ;ballChaser();
  call ballChaser

  ;if(!bitRead(PIND, LB))
  sbis 0x09, 7
  call movePaddleLeft
  ;if(!bitRead(PIND, RB))
  sbis 0x09, 6
  call movePaddleRight

  ;delay(100);
  ldi r24, lo8(100)
  ldi r25, hi8(100)
  call delay_millis
  
  ;refresh();
  call refresh

  rjmp loop


ballChaser:
  lds	r24, compPaddle
  lds r22, ballY
  ;if(compPaddle > bally)
  cp r22, r24
  brge 1f
  ;--compPaddle;
  dec r24
  sts	compPaddle, r24
  rjmp 2f
 1: 
  ;if((compPaddle + 2) < bally)
  inc r24
  inc r24
  cp r24, r22
  brge 2f                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
  ;++compPaddle;
  dec r24
  sts	compPaddle, r24
 2:
  ret

;R24 => playerPaddle
movePaddleRight:
  ;if(playerPaddle!=6)
  lds	r24, playerPaddle
  cpi	r24, 0x06
  breq nope1
  ;++playerPaddle;
  inc r24
  sts	playerPaddle, r24	
nope1:
  ret

;R24 => playerPaddle
movePaddleLeft:
  ;if(playerPaddle!=1)
  lds r24, playerPaddle
  cpi r24, 0x01
  breq nope2
  ;--playerPaddle;
  dec r24
  sts playerPaddle, r24 
nope2:
  ret

lose:
  call clearDisplays
  ldi r24, lo8(500)
  ldi r25, hi8(500)
  call delay_millis
  call refresh
  ldi r24, lo8(500)
  ldi r25, hi8(500)
  call delay_millis
  rjmp lose
  ret

;R28 => Counter i
;R24 => hi8(buffer)
;R23 => lo8(buffer)
;R22 => playerPaddle, compPaddle, ballY
;R21 => ballX
refresh:
  push r28
  ;int i = 1
  ldi r28, 0x01
refreshLoop:
  ;int buffer [r24:r23] = 0
  clr r24
  clr r23
  lds r22, playerPaddle
  ;if(playerPaddle==i)
  cp r28, r22
  breq PP 
  ;if(playerPaddle+1==i)
  inc r22
  cp r28, r22
  breq PP
  ;if(playerPaddle+2==i)
  inc r22
  cp r28, r22
  brne notPP
;playerPaddle
PP:
  ;bitSet(buffer,0)
  ori	r23, 0x01	;
notPP:
  lds r22, compPaddle
  ;if(compPaddle==i)
  cp r28, r22
  breq CPP 
  ;if(compPaddle+1==i)
  inc r22
  cp r28, r22
  breq CPP
  ;if(compPaddle+2==i)
  inc r22
  cp r28, r22
  brne notCPP
;compPlayerPaddle
CPP:
  ;bitSet(buffer,0)
  ori	r24, 0x80	;
notCPP:
  lds r22, ballY
  cp r28, r22
  brne notBall
  lds r21, ballX
  ;if(ballX<8)
  cpi r21, 0x08
  brlt lowBuffer
  ;What to do when high buffer
  subi r21, 0x08
  call bitCreate
  or r24, r21
  rjmp notBall
lowBuffer:
  ;What to do when low buffer
  call bitCreate
  or r23, r21 
notBall:
  ;bitClear(PORTB, 2);
  cbi	0x05, 2	; 5
  ;spiTransfer(i);
  push r24
  mov	r24, r28
  call	spiTransfer
  ;spiTransfer(lo8(buffer));
  mov r24, r23
  call	spiTransfer
  ;spiTransfer(i);
  mov	r24, r28
  call	spiTransfer
  ;spiTransfer(hi8(buffer));
  pop r24
  call	spiTransfer
  ;bitSet(PORTB, 2);
  sbi	0x05, 2	
  ;++i
  inc r28
  ;i<=8
  cpi r28, 0x09
  brne refreshLoop 
  pop r28
  ret

updateBall:
  lds r22, playerPaddle
  lds r21, compPaddle
  lds r20, ballX
  lds r19, ballY
  lds r18, speedX
  lds r17, speedY
  lds r16, gameOver
  ldi r23, 13

  ;if(speedX==1)
  cpi r18, 1
  brne B
  ;if(ballX>13)
  cp r23, r20 
  brsh B; exit if condition if ballX <= 13
  ;speedx=-1
  ldi r24, -1
  mov r18, r24
  rjmp C 
  
  ;Since the compPaddle is a ballChaser, it would never lose
  ;Redundant to make a GAME OVER protocol for computer

B:
  ;if(speedX==-1)
  cpi r18, -1
  brne C
  ;if(ballX<2)
  ldi r23, 2
  cp r20, r23 
  brsh C ; exit if condition if 2 <= ballx
  ;if(ballY >= playerPaddle)
  cp r19, r22
  brlo B1 ; exit if condition if ballY < playerPaddle
  ;if(ballY <= playerPaddle+2)
  inc r22
  inc r22
  cp r22, r19
  brlo B1 ; exit if condition if ballY > playerPaddle+2
  ;speedx=1
  ldi r24, 1
  mov r18, r24
  rjmp C
B1:
  ;if(ballX<1)
  cpi r20, 0
  brne C ; exit if condition if 1 <= ballx
  ;GAME OVER
  clr r18
  clr r17
  ser r16 

C:
  ;if (bally == 8) 
  cpi r19, 8
  brne C1
  ;  speedy = -1;
  ldi r23, -1
  mov r17, r23
  rjmp C2
C1:
  ;if (bally == 1) 
  cpi r19, 1
  brne C2
  ;  speedy = 1;
  ldi r23, 1
  mov r17, r23
C2:
  ;ballx += speedx;
  add r20, r18
  ;bally += speedy;
  add r19, r17

  sts ballX, r20
  sts ballY, r19
  sts speedX, r18
  sts speedY, r17
  sts gameOver, r16
  
  ret
