Section "rst $00", ROM0[$00]
wait_vbl:
	halt			; 1 byte
	ldh a, [rLY]	; 2 bytes
	cp 144			; 2 bytes
	jr c, wait_vbl	; 2 bytes
	ret				; 1 byte
assert (@ - wait_vbl <= 8)

Section "rst $08", ROM0[$08]
call_hl:
	jp hl

Section "rst $38", ROM0[$38]
crash:
	stop
	nop
	jr crash
assert (@ - crash <= 8)

Section "MemCpy", ROM0
memcpy:
	;copy byte, move to next byte
	ld a, [de]
	ld [hl+], a
	inc de
	;decrement counter
	dec bc
	;if counter not zero, go again
	ld a, b
	or c 
	jr nz, memcpy
	ret

Section "copy oam routine to hram", ROM0
romOAMDMA:
	ld a, high(wShadowOAM)
	ldh [rDMA], a
	ld a, 40
	.wait
		dec a
		jr nz, .wait
	ret
.end

Section "hOAMDMA", HRAM
hOAMDMA: ds romOAMDMA.end - romOAMDMA

Section "wShadowOAM", WRAM0, ALIGN[8]
wShadowOAM: ds 160