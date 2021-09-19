include "hardware.inc"
include "macros.asm"
include "enemy.asm"
include "variables.asm"
include "misc.asm"
include "interrupts.asm"
include "GameLoop.asm"
include "Controls.asm"

x EQUS "+$"

Section "Entry", ROM0[$100]
Jumpstart:
    sub $11
    jr FadeOutNintendoLogo

REPT $150 - @
    db 0
ENDR

Section "Init", ROM0[$150]
FadeOutNintendoLogo:
	;Save CGB flag
		ld a, 0
		jr nz, ._no_cgb
			ld a, 1
		._no_cgb
		ld [hCGBflag], a
		jr z, Start

    ;Set VBLANK interrupt
		ld a, IEF_VBLANK
		ld [rIE], a
		ld a, 0
		ld [rIF], a
		ei

	;Nintendo logo fadeout
		ld a, $F8
		ld [rBGP], a
		ld b, 6
		:
			rst wait_vbl
			dec b
			jr nz, :-
		ld a, $F4
		ld [rBGP], a
		ld b, 6
		:
			rst wait_vbl
			dec b
			jr nz, :-
		ld a, $F0
		ld [rBGP], a

Start:
    ;Set VBLANK interrupt
		ld a, IEF_VBLANK
		ld [rIE], a
		ld a, 0
		ld [rIF], a
		ei

	;Turn off screen
		rst wait_vbl
		xor a
		ldh [rLCDC], a

	call InitVariables

	;Clear shadow oam
		ld hl, wShadowOAM
		ld c, 160 / 4
		xor a
		.clearShadowOAM
			ld [hl+], a
			ld [hl+], a
			ld [hl+], a
			ld [hl+], a
		dec c
		jr nz, .clearShadowOAM

	;Copy graphics to VRAM
		ld hl, $8000
		ld de, Gfx_Sprites
		ld bc, Gfx_Sprites_size
		call memcpy

	;Populate starfield
		ld hl, $9800
		ld b, 54
		ld a, 1
		._populate_loop
			ld [hl], 6
			inc l
			ld [hl+], a
			ld [hl+], a
			ld [hl+], a
			ld [hl+], a
			ld [hl+], a
			ld [hl], 7
			inc l
			ld [hl+], a
			ld [hl+], a
			ld [hl+], a
			ld [hl+], a
			ld [hl+], a
			ld [hl], 8
			inc l
			ld [hl+], a
			ld [hl+], a
			ld [hl+], a
			ld [hl], 9
			inc l
			ld [hl+], a
			ld [hl+], a
			ld [hl+], a
			ld [hl+], a
			ld [hl+], a
			ld [hl+], a
			jr nz, ._populate_loop

	;Copy OAM routine to HRAM
		ld hl, hOAMDMA
		ld de, romOAMDMA
		ld bc, romOAMDMA.end - romOAMDMA
		call memcpy

	;Set OBJ palette
		ld a, %00_01_10_11
		ldh [rOBP0], a
		ldh [rOBP1], a
		ldh [rBGP], a

	;Turn on screen
		ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_BG8000
		ldh [rLCDC], a

	call Start_GameLoop ; todo - state machine?

    .halt
        halt
		call Update_GameLoop ; todo - state machine?
        jr .halt

	DefineBinary Gfx_Sprites, "Graphics.2bpp"