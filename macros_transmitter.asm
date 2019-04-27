/*
 * macros.asm
 *
 *  Created: 22/04/2019 13:16:57
 *   Author: Luc
 */ 

.macro WAIT_MS ; k
		ldi		w, low(@0)
		mov		u,w
		ldi		w,high(@0)+1

	wait_ms:
		push	w
		push	u
		ldi		w, low((clock/3000)-5)
		mov		u,w
		ldi		w,high((clock/3000)-5)+1
		dec		u
		brne	PC-1
		dec		u
		dec		w
		brne	PC-4
		pop		u
		pop		w
		dec		u
		brne	wait_ms
		dec		w
		brne	wait_ms
		.endmacro

.macro	OUTI ; port, k
		ldi		w,@1
		out		@0,w
		.endmacro

.macro	SPITR ; k
		mov		u, @0
		out		USIDR,u
		ldi		w, (1<<USIWM0)|(1<<USITC)
		mov		u, w
		ldi		w,(1<<USIWM0)|(1<<USICLK)|(1<<USITC)
		out		USICR,u ; MSB
		out		USICR,w
		out		USICR,u
		out		USICR,w
		out		USICR,u
		out		USICR,w
		out		USICR,u
		out		USICR,w
		out		USICR,u
		out		USICR,w
		out		USICR,u
		out		USICR,w
		out		USICR,u
		out		USICR,w
		out		USICR,u ; LSB
		out		USICR,w
		in		u,USIDR
		.endmacro
