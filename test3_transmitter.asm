/*
 * test3.asm
 *
 *  Created: 24/04/2019 14:04:09
 *   Author: Luc
 */ 

.include "tn85def.inc"
.include "macros_transmitter.asm"

; definitions de variables 
.def u		= r3
.def w		= r16
.equ CSN	= 4
.equ BUTTON = 3

; fréquence de l'horloge (Hz)
.equ clock = 1000000

; fréquence de transmission
.set channel = 0b00000100   ; 2404 MHz

WAIT_MS 2000

OUTI	DDRB, 0b00010110	; DO,USCK,CSN as output
sbi		PORTB, CSN			; set CSN high


cbi		PORTB, CSN			; CSN = 0 => start command -------------------------------- power up --------------------------------------------

ldi		r18, 0b00100000		;command write in CONFIG
SPITR	r18					;transmission
ldi		r18, 0b00001010		;write in CONFIG: PWR_UP = 1 and EN_CRC = 1 (default)
SPITR	r18					;transmission

sbi		PORTB, CSN			; CSN = 1 => end command -----------------------------------

WAIT_MS 2					; wait on start up of 1.5ms

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

cbi		PORTB, CSN			;----------------------------------------------------------- SET TX ADDRESS (TX_ADDR) default: 0xE7E7E7E7E7 -----------------

ldi		r18, 0b00110000		; write in TX_ADDR
SPITR	r18
ldi		r18, 0xC3
SPITR	r18
SPITR	r18
SPITR	r18
SPITR	r18
SPITR	r18					; address is now 0xC3C3C3C3C3 (must be the same as RX_ADDR)

sbi		PORTB, CSN			;-----------------------------------------------------------

cbi		PORTB, CSN			;----------------------------------------------------------- SET TRANSMISSION POWER ------------------------------

ldi		r18, 0b00100110		;write RF_SETUP
SPITR	r18
ldi		r18, 0b00001000		;low power (30cm appart) WARNING: to much power leads to packet loss
SPITR	r18

sbi		PORTB, CSN			;-----------------------------------------------------------

cbi		PORTB, CSN			;----------------------------------------------------------- SETUP OF AUTOMATIC RETRANSMISSION -------------------------------

ldi		r18, 0b00100100		; write in SETUP_RETR
SPITR	r18
ldi		r18, 0xFF			; 4ms auto retransmit delay and up to 15 re-transmits, to have maximum reliability
SPITR	r18

sbi		PORTB, CSN			;-----------------------------------------------------------

button_input:
sbis	PINB, BUTTON		; if button pressed send message, if button released send message
rjmp	PC-1

cbi		PORTB, CSN			;------------------------------------------------------------ MESSAGE button pressed --------------------------------------------------------

ldi		r18, 0b10100000		; write in W_TX_PAYLOAD
SPITR	r18
ldi		r18, 0b00000001		; message to be transmitted
SPITR	r18

sbi		PORTB, CSN			;-----------------------------------------------------------

WAIT_MS 100					; wait on ACK

sbic	PINB, BUTTON
rjmp	PC-1

cbi		PORTB, CSN			;----------------------------------------------------------- Message button release ---------------------------------------------------------

ldi		r18, 0b10100000
SPITR	r18
ldi		r18, 0b00000010
SPITR	r18

sbi		PORTB, CSN			;------------------------------------------------------------

WAIT_MS 100

rjmp	button_input
