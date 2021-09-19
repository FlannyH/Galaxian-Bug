Section "Variables WRAM", WRAM0
	wVARIABLES:
		
	wDummy: ds 1

	wVARIABLES_END:

Section "Variables HRAM", HRAM
	hVARIABLES:
		
	hCGBflag: ds 1
	hOAMlowPointer: ds 1
	hPlayerShipX: ds 1
	hJoypadLast: ds 1
	hJoypadCurrent: ds 1
	hJoypadPressed: ds 1
	hJoypadReleased: ds 1
	hStarSparkleTimer: ds 1
	hStarMoveTimer1: ds 1
	hStarMoveTimer2: ds 1
	hSparklePalette: ds 1
	hStarScroll1: ds 1
	hStarScroll2: ds 1
	hFrameCounter: ds 1

	hGlobalTimer: ds 1
	hGlobalEnemyDiveCounter: ds 1
	hGlobalEnemyHorWaveCounter: ds 1

	hCurrObjectPointer: ds 2

	hVARIABLES_END:

Section "Objects", WRAM0
	dstructs 64, Enemy, wEnemies

Section "InitVariables", ROM0
InitVariables:
	ld a, 80
	ldh [hPlayerShipX], a

	ld a, %00_01_10_01
	ldh [hSparklePalette], a

	ld a, 1
	ldh [hStarSparkleTimer], a
	ldh [hStarMoveTimer1], a
	ldh [hStarMoveTimer2], a
	ldh [hGlobalTimer], a

	xor a
	ldh [hGlobalEnemyHorWaveCounter], a

	xor a
	ld hl, wEnemies0
	ld c, 0
	.loop
		ld [hl+], a
		dec c
		jr nz, .loop

	ret