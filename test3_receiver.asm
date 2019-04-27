;
; radio_receiver.asm
;
; Created: 25/04/2019 11:38:35
; Author : Luc
;


.include "tn85def.inc"
.include "macros_receiver.asm"


; definitions de variables 
.def u		= r3
.def w		= r16
.equ CSN	= 4
.equ LED = 3

; fréquence de l'horloge (Hz)
.equ clock = 1000000

; fréquence de transmission
.set channel = 0b00000100   ; 2404 MHz

WAIT_MS	2000

; Stack Pointer init.
LDSP	RAMEND

OUTI	DDRB, 0b00011110	; DO,USCK,CSN as output and PB3 as output for LED
sbi		PORTB, CSN			; set CSN high

cbi		PORTB, CSN			; CSN = 0 => start command -------------------------------- SET RX --------------------------------------------

ldi		r18, 0b00100000		;command write in CONFIG
SPITR	r18					;transmission
ldi		r18, 0b00001001		;write in CONFIG: PWR_UP = 0 and EN_CRC = 1 (default) and PRIM_RX = 1 PWR_UP later becaus no register write if in RX mode or TX mode
SPITR	r18					;transmission

sbi		PORTB, CSN			; CSN = 1 => end command -----------------------------------

cbi		PORTB, CSN			;----------------------------------------------------------- SET CHANNEL ----------------------------------------

ldi		r18, 0b00100101		; write in RF_CH
SPITR	r18					; transmission
ldi		r18, channel		; write channel
SPITR	r18					; transmission

sbi		PORTB, CSN			;----------------------------------------------------------- (not essential, one can use default)

cbi		PORTB, CSN			;----------------------------------------------------------- ENABLE ONLY 1 DATA PIPE (enable data pipe 0) ---------------

ldi		r18, 0b00100010		; write in EN_RXADDR
SPITR	r18
ldi		r18, 0b00000001		; enable data pipe 0
SPITR	r18

sbi		PORTB, CSN			;----------------------------------------------------------- (by default, 2 pipes are enabled (namely 0 and 1), I want only pipe 0 enabled)

cbi		PORTB, CSN			;----------------------------------------------------------- SET RX ADDRESS (RX_ADDR_P0) default: 0xE7E7E7E7E7------------

ldi		r18, 0b00101010		; write in RX_ADDR_P0
SPITR	r18
ldi		r18, 0xC3
SPITR	r18
SPITR	r18
SPITR	r18
SPITR	r18
SPITR	r18					; address is now 0xC3C3C3C3C3  (five byte address, defined in SETUP_AW by default) (read note page 27 of datasheet to know what is a good address)

sbi		PORTB, CSN			;-----------------------------------------------------------

cbi		PORTB, CSN			;----------------------------------------------------------- NB	BYTES IN RX PAYLOAD ------------------

ldi		r18, 0b00110001		; write in RX_PW_P0
SPITR	r18
ldi		r18, 0b00000001		; 1 byte payload
SPITR	r18

sbi		PORTB, CSN			;-----------------------------------------------------------

cbi		PORTB, CSN			;----------------------------------------------------------- SET TRANSMISSION POWER ------------------------------

ldi		r18, 0b00100110
SPITR	r18
ldi		r18, 0b00001000		;low power (30cm appart)
SPITR	r18

sbi		PORTB, CSN			;-----------------------------------------------------------

cbi		PORTB, CSN			; CSN = 0 => start command -------------------------------- POWER UP --------------------------------------------

ldi		r18, 0b00100000		;command write in CONFIG
SPITR	r18					;transmission
ldi		r18, 0b00001011		;write in CONFIG: PWR_UP = 0 and EN_CRC = 1 (default) and PRIM_RX = 1 PWR_UP later 
SPITR	r18					;transmission

sbi		PORTB, CSN			; CSN = 1 => end command -----------------------------------

WAIT_MS	2

wait_on_on:
rcall	status
mov		r18, u
sbrc	r18, 0
rjmp	PC-3
rjmp	LED_ON

wait_on_off:
rcall	status
mov		r18, u
sbrc	r18, 0
rjmp	PC-3
rjmp	LED_OFF

LED_OFF:

cbi		PORTB, LED
rcall	read_rx_payload
WAIT_MS	100
rjmp	wait_on_on


LED_ON:

sbi		PORTB, LED
rcall	read_rx_payload
WAIT_MS 100
rjmp	wait_on_off					


read_rx_payload:
cbi		PORTB, CSN			;------------------------------------------------------------ READ RX PAYLOAD-------------------
		
ldi		r18, 0b01100001
SPITR	r18

sbi		PORTB, CSN			;-----------------------------------------------------------------------------------------------
ret


status:
cbi		PORTB, CSN			;----------------------------------------------------------- GET FIFO STATUS ------------------------------------------------------

ldi		r18, 0b00010111		; read FIFO STATUS
SPITR	r18
ldi		r18, 0b11111111
SPITR	r18

sbi		PORTB, CSN			;-----------------------------------------------------------
ret
