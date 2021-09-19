Section "vblank", ROM0[$40]
	ldh a, [hFrameCounter]
	inc a
	ldh [hFrameCounter], a
	reti