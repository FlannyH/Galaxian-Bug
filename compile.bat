"./RGBDS/rgbasm" --preserve-ld --halt-without-nop -o Galaxians.o Galaxians.asm
"./RGBDS/rgblink" -p 255 -n Galaxians.sym -o Galaxians.gbc Galaxians.o
"./RGBDS/rgbfix" -j -t FlanTest -m 27 -v -p 255 -r 1 Galaxians.gbc
rem start Galaxians.gbc
pause