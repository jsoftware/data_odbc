NB. fix

CNB=: 0{a.         NB. always 1 byte even in unicode interface

char_trctnb=: ]`trctnb @. (2:=3!:0)

NB. remove row null bytes then overtake to original shape less last column
trctnb=: <:@{:@$ {."1 (i.&({.a.) {. ])"1
trctnbw=: trctnb

NB. trim boxed character lists up to first null byte
trbuclnb=: (] i.&> ({.a.)"_) {.&.> ]

NB. trim trailing blank char table columns
rebtbcol=: ] #"1~ [: -. [: *./ [: *./\."1 ' '&=

NB. remove row null bytes and trailing blank columns
trctnob=: [: rebtbcol ] -."1 (0{a.)"_

NB. trims GUID's to proper length
trctguid=: 36&{."1

nullvec2mat=: 3 : '> a: -.~ deb each <;._2 y,{.a.'
