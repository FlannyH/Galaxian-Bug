Section "Main Game Loop", ROM0
Start_GameLoop:
	;Spawn a single enemy
	ld hl, wEnemies0

	;Top layer
		ld bc, $4420
		call ObjStart_EnemyDive
		ld bc, $5420
		call ObjStart_EnemyDive
		ld bc, $6420
		call ObjStart_EnemyDive
		ld bc, $7420
		call ObjStart_EnemyDive
		ld bc, $8420
		call ObjStart_EnemyDive

	;Top middle layer
		ld bc, $3430
		call ObjStart_EnemyDive
		ld bc, $4430
		call ObjStart_EnemyDive
		ld bc, $5430
		call ObjStart_EnemyDive
		ld bc, $6430
		call ObjStart_EnemyDive
		ld bc, $7430
		call ObjStart_EnemyDive
		ld bc, $8430
		call ObjStart_EnemyDive
		ld bc, $9430
		call ObjStart_EnemyDive

	;Bottom middle layer
		ld bc, $3440
		call ObjStart_EnemyDive
		ld bc, $4440
		call ObjStart_EnemyDive
		ld bc, $5440
		call ObjStart_EnemyDive
		ld bc, $6440
		call ObjStart_EnemyDive
		ld bc, $7440
		call ObjStart_EnemyDive
		ld bc, $8440
		call ObjStart_EnemyDive
		ld bc, $9440
		call ObjStart_EnemyDive

	;Bottom layer
		ld bc, $3450
		call ObjStart_EnemyDive
		ld bc, $4450
		call ObjStart_EnemyDive
		ld bc, $5450
		call ObjStart_EnemyDive
		ld bc, $6450
		call ObjStart_EnemyDive
		ld bc, $7450
		call ObjStart_EnemyDive
		ld bc, $8450
		call ObjStart_EnemyDive
		ld bc, $9450
		call ObjStart_EnemyDive

	ret

Update_GameLoop:
	;New frame, new slots to fill
	ld a, 0
	ldh [hOAMlowPointer], a

	call GetJoypadStatus
	call UpdatePlayerShip
	call DrawPlayerShip
	call HandleSparkles
	call UpdateTimers
	call UpdateObjects
	call hOAMDMA

KnownRet:
	ret

UpdatePlayerShip:
	ldh a, [hJoypadCurrent]
	ld hl, hPlayerShipX

	;If left pressed
		bit PADB_LEFT, a
		jr z, ._no_left
			;Move left
			dec [hl]
			dec [hl]
			jr ._after_move_ship
		._no_left

	;If right pressed
		bit PADB_RIGHT, a
		jr z, ._no_right
			;Move right
			inc [hl]
			inc [hl]
			jr ._after_move_ship
		._no_right

	._after_move_ship
	;Clamp to screen bounds
		;If x <= 8, clamp left
			ld a, $08
			cp [hl]
			jr c, ._no_clamp_left
				ld [hl], 8
			._no_clamp_left

		;If x > 98, clamp right
			ld a, $98
			cp [hl]
			jr nc, ._no_clamp_right
				ld [hl], $98
			._no_clamp_right

	;Handle bullet shooting
		; todo
	ret

DrawPlayerShip:
	;HL = OAM + current offset
	ld h, high(wShadowOAM)
	ldh a, [hOAMlowPointer]
	ld l, a

	;----LEFT SIDE----
		;Set ship Y position
		; todo - not hardcode this?
		ld a, 136
		ld [hl+], a

		;Set ship X position
		ldh a, [hPlayerShipX]
		;sub 0 ; offset
		ld [hl+], a

		;Set tile ID
		ld a, 4
		ld [hl+], a

		;Set attribute
		xor a
		ld [hl+], a

	;----RIGHT SIDE----
		;Set ship Y position
		; todo - not hardcode this?
		ld a, 136
		ld [hl+], a 

		;Set ship X position
		ldh a, [hPlayerShipX]
		add 7 ; offset
		ld [hl+], a

		;Set tile ID
		ld a, 4
		ld [hl+], a

		;Set attribute
		ld a, OAMF_XFLIP
		ld [hl+], a

	ld a, l
	ldh [hOAMlowPointer], a
	ret

HandleSparkles:
	;if (--sparkleTimer == 0)
	ldh a, [hStarSparkleTimer]
	dec a
	jr nz, ._skip
		;Cycle colours
		ldh a, [hSparklePalette]
		rlca
		rlca
		ldh [hSparklePalette], a
		and %11111100
		ld b, a
		ldh a, [rBGP]
		and %00000011
		or b
		ldh [rBGP], a

		ld a, 12 ; todo - not hardcode this?
	._skip

	ldh [hStarSparkleTimer], a

	;if (--sparkleTimer == 0)
	ldh a, [hStarMoveTimer1]
	dec a
	jr nz, ._skip2
		;Move down
		ld hl, hStarScroll1
		dec [hl]
		ld a, 2 ; todo - not hardcode this?
	._skip2
	ldh [hStarMoveTimer1], a
	
	;if (--sparkleTimer == 0)
	ldh a, [hStarMoveTimer2]
	dec a
	jr nz, ._skip3
		;Move down
		ld hl, hStarScroll2
		dec [hl]
		ld a, 3 ; todo - not hardcode this?
	._skip3
	ldh [hStarMoveTimer2], a

	ldh a, [hStarScroll1]
	ldh [rSCY], a
	ld a, 0
	ldh [rSCX], a

	ld a, [hFrameCounter]
	bit 0, a
	jr z, ._skip4
		ldh a, [hStarScroll2]
		ldh [rSCY], a
		ld a, 12
		ldh [rSCX], a
	._skip4

	ret

UpdateTimers:
	;Dec hGlobalTimer
	ld hl, hGlobalTimer
	dec [hl]

	;Return if not counted down fully
	ret nz

	;Otherwise, set it back to 8, and handle the rest
	; todo - not hardcode this?
	ld [hl], 8

	;Dive counter - enemy handles zero state
	inc l
	dec [hl]

	;HorWave counter - no limit, just says when enemies move
	inc l
	inc [hl]

	ret

UpdateObjects:
	ld hl, wEnemies0
	.loop
		;read type
		ld a, [hl]

		;skip to next if no object marker ($FF)
		inc a
		jr z, ._skip_object

		;return if end of list marker ($00)
		dec a
		ret z

		;Store pointer to object in BC
		ld b, h
		ld c, l

		;Also push it cuz we are going to thrash HL in just a sec
		push hl
			;otherwise, run appropriate update and draw routines
			add a
			ld d, 0
			ld e, a

			;Get update function pointer and jump to it
			push de
				ld hl, ObjectUpdateFunctionPointerTable
				add hl, de
				ld a, [hl+]
				ld h, [hl]
				ld l, a
				rst call_hl
			pop de
		pop bc
		push hl
			;Get the draw function pointer and jump to it
			ld hl, ObjectDrawFunctionPointerTable
			add hl, de
			ld a, [hl+]
			ld h, [hl]
			ld l, a
			rst call_hl
		pop hl

	._skip_object
		ld a, l
		and $F8
		add 8
		ld l, a
		adc h
		sub l
		ld h, a
		
		jr .loop
	
ObjectStartFunctionPointerTable:
	dw KnownRet
	dw ObjStart_EnemyDive
ObjectUpdateFunctionPointerTable:
	dw KnownRet
	dw ObjUpdate_EnemyDive
ObjectDrawFunctionPointerTable:
	dw KnownRet
	dw ObjDraw_EnemyDive