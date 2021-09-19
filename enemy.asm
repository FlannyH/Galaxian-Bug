include "structs.asm"

	struct Enemy
		bytes 1, type
		bytes 1, pos_x
		bytes 1, pos_y
		bytes 1, state
		bytes 1, sprite_index
	end_struct

;Enemy types
def ENEMY_TYPE_DIVE equ $01

;Enemy states
def ENEMY_STATE_MOVE_HOR equ $01

Section "Enemy Dive", ROM0
;HL = pointer to object in array
;BC = X, Y position
ObjStart_EnemyDive:
	;Init object
		ld [hl], ENEMY_TYPE_DIVE
		inc l
		ld [hl], b
		inc l
		ld [hl], c
		inc l
		ld [hl], ENEMY_STATE_MOVE_HOR
		inc l
		ld [hl], 0 ; default sprite
		inc l
		inc l
		inc l 
		inc hl
	ret

;BC = pointer to object array entry
ObjUpdate_EnemyDive:
	push bc
	pop hl

	;Check timer if we should even be moving
	ldh a, [hFrameCounter]
	and %00000011
	ret nz

	;Find X position
	inc l

	;Check which direction to go based on horizontal wave counter
		ldh a, [hGlobalEnemyHorWaveCounter]
		bit 4, a
		jr z, ._left
		._right
			inc [hl]
			jr ._after
		._left
			dec [hl]
		._after

	ret


;BC = pointer to object array entry
ObjDraw_EnemyDive:
	push bc
	pop hl
	;Get pointer to OAM
		ldh a, [hOAMlowPointer]
		ld d, high(wShadowOAM)
		ld e, a

	;Fill OAM
		;c = x
			inc l
			ld a, [hl+]
			ld b, a
		;a = y
			ld a, [hl+]
			ld c, a
		;write to OAM
			;y1
			ld [de], a
			inc e
			;x1
			ld a, b
			sub 4
			ld [de], a
			inc e
			;tile
			ldh a, [hFrameCounter]
			rra
			rra
			rra
			and $02
			ld [de], a
			;attrib
			inc e
			ld [de], a
			inc e
	
	ld a, e
	ldh [hOAMlowPointer], a

	ret