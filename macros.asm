DefineBinary: macro
\1:: incbin \2
.end
\1_size EQU \1.end - \1
endm