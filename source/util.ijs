NB. util

NB. The odbc locale is designed to be independent of the contents of
NB. the (z) locale.  Hence there will be a few utilities that overlap
NB. the standard utilities that are loaded in the (z) locale.

NB. handy ddl argument utils
b0=: <"0
bs=: ];#

bitor=: 23 b.

NB. bits to index #'s

NB. first atom - the dll interface likes pure atoms
fat=: ''&$@:,

NB. tests of sql dll returns - small ints forced to standard form
src=: _1: ic 1: ic ]
sqlbad=: 13 : '(src >{. y) e. DD_ERROR'
sqlok=: 13 : '(src >{. y) e. DD_SUCCESS'
sqlok1=: 13 : '(src >{. y) e. DD_SUCCESS1'
sqlsuccess=: 13 : '(src >{. y) e. SQL_SUCCESS'
sqlstillexec=: 13 : '(src >{. y) e. SQL_STILL_EXECUTING'

NB. returns 1 if argument is a character list or atom 0 otherwise
iscl=: e.&(2 131072 262144)@(3!:0) *. 1: >: [: # $

NB. returns 1 if argument is an atom 0 otheXrwise
isua=: 0: = [: # $

NB. returns 1 if argument is integer (booleans accepted) 0 otherwise
isiu=: 3!:0 e. 1 4"_

NB. returns 1 if argument is an integer atom 0 otherwise
isia=: isua *. isiu

isnu=: 3!:0 e. 1 4 8"_
isna=: isua *. isnu
iscu=: (e.&2 131072 262144)@(3!:0)

NB. convert short integer columns to integer columns
ifs=: [: ,. [: _1&ic ,

NB. convert 4 byte integer columns to 8 byte integer columns (for 64bit)
ifi=: [: ,. [: _2&ic ,

NB. convert short float columns (real) to double float columns
ffs=: [: ,. [: _1&fc ,

NB. remove all {.a. from numeric fields when UseNumerc is false
rnnum=: (-."1 0)&({.a.)

NB.   typedef struct tagTIMESTAMP_STRUCT {
NB.     SQLSMALLINT year;
NB.     SQLUSMALLINT month;
NB.     SQLUSMALLINT day;
NB.     SQLUSMALLINT hour;
NB.     SQLUSMALLINT minute;
NB.     SQLUSMALLINT second;
NB.     SQLUINTEGER fraction;
NB.   } TIMESTAMP_STRUCT;
NB. fraction is nanosecond

NB. decode C datetime structures
NB. obsolete
NB. dts=: 13 : '((#y),6) $ _1&ic , 12{."1 y'
NB. dts=: 3 : 0
NB. a=. ((#y),6) $ _1&ic , 12{."1 y
NB. frac=. _2&ic , 12 13 14 15{("1) y
NB. ((1e_9 * frac) + 5{"1 a) (<a:;5)}a
NB. )

NB. decode C datetime structures into 7 components (exact precision)
dts=: ((6 ,~ #) $ [: _1&ic [: , 12{."1 ]) ,. ([: _2&ic [: , 12 13 14 15{"1 ])

NB. decode C datetime offset structures into 7 components (exact precision)
NB. offset ignored, so same as dts
dtsx=: ((6 ,~ #) $ [: _1&ic [: , 12{."1 ]) ,. ([: _2&ic [: , 12 13 14 15{"1 ])

NB. decode C datetime structures (date only)
ddts=: 13 : '((#y),3) $ _1&ic , 6{.("1) y'

NB. decode C datetime structures (time only)
NB. obsolete
NB. tdts=: 13 : '((#y),3) $ _1&ic , 6{.("1) y'

NB. decode C datetime structures (time only) into 4 components (last always 0)
tdts=: ((3 ,~ #) $ [: _1&ic [: , 6{."1 ]) ,. 0:"1

NB. padded to 12 bytes
NB. typedef struct tagSS_TIME2_STRUCT {
NB.    SQLUSMALLINT hour;
NB.    SQLUSMALLINT minute;
NB.    SQLUSMALLINT second;
NB.    SQLUINTEGER fraction;
NB. } SQL_SS_TIME2_STRUCT;

NB. decode C datetime structures (time2 only)
tdts2=: ((3 ,~ #) $ [: _1&ic [: , 6{."1 ]) ,. ([: _2&ic [: , 8 9 10 11{"1 ])

NB. typedef struct tagSS_TIMESTAMPOFFSET_STRUCT {
NB.    SQLSMALLINT year;
NB.    SQLUSMALLINT month;
NB.    SQLUSMALLINT day;
NB.    SQLUSMALLINT hour;
NB.    SQLUSMALLINT minute;
NB.    SQLUSMALLINT second;
NB.    SQLUINTEGER fraction;
NB.    SQLSMALLINT timezone_hour;
NB.    SQLSMALLINT timezone_minute;
NB. } SQL_SS_TIMESTAMPOFFSET_STRUCT;

NB. ---------------------------------------------------------

NB. y array of dayno, return sql-c-timestamp struct 6 bytes, short=2 bytes int=4 bytes
NB. short yy
NB. short mm
NB. short dd
date2odbc=: 4 : 0
NB. bug when y is a vector with leading zero  => always return single <'null'
NB.                              non leading zero => return as 1800-01-01
if. (0~:x) *. (0=y) *. 1=#y do. NB. singleton zero
  if. 0&= #@$ y do.
    <6#{.a.         NB. same length as not null for easy packing in column mode
  else.
    <,: 6#{.a.      NB. shape
  end.
else.
  if. 0=x do.
    < 1&ic@:,@<. 3&{.("1) (0&".)@(-.&'dts{}')"1 ('- : T Z z ') charsub y
  elseif. 1=x do.
    < 1&ic@:,@<. 3{."1 todate <. ,y
  elseif. 2=x do.
    < 1&ic@:,@<. 3{."1 todate <.@:(%&dayns) (+&(EpochOffset*dayns)) ,y
  end.
end.
)

NB. y array of dayno, return sql-c-timestamp struct 16 bytes, short=2 bytes int=4 bytes
NB. short yy
NB. short mm
NB. short dd
NB. short HH
NB. short MM
NB. short SS
NB. int billionth fraction  (% 1e9)
datetime2odbc=: 4 : 0
NB. bug when y is a vector with leading zero  => always return single <'null'
NB.                              non leading zero => return as 1800-01-01
if. (0~:x) *. (0=y) *. 1=#y do. NB. singleton zero
  if. 0&= #@$ y do.
    <16#{.a.         NB. same length as not null for easy packing in column mode
  else.
    <,: 16#{.a.      NB. shape
  end.
else.
  if. 0=x do.
    d1=. <. d0=. 6&{.("1) (0&".)@(-.&'dts{}')"1 ('- : T Z z ') charsub y
    d2=. 1&| {:"1 d0
    < (1&ic@:<.@:}: , 2&ic@:<.@((10^(9-FraSecond))&*)@<.@((10^FraSecond)&*)@(1&|)@:{:)("1) d1,.d2
  elseif. 1=x do.
    d1=. 3{."1 todate d0=. <. y=. ,y
    d2=. 24 60 60&#:@(86400&*) y-d0
    < (1&ic@:<. , 2&ic@:<.@((10^(9-FraSecond))&*)@<.@((10^FraSecond)&*)@(1&|)@:{:)("1) d1,.d2
  elseif. 2=x do.
    d1=. <. 3{."1 todate <.@:(%&86400) d0=. (%&1e9) d3=. (+&(EpochOffset*dayns)) ,y
    d2=. <. 24 60 60&#:@(86400&|) d0
    < (1&ic@:<.@:}: , 2&ic@:<.@:{:)("1) d1,.d2,. <. 1e9|d3
  end.
end.
)

NB. y array of dayno, return sql-c-timestampoffset struct 20 bytes, short=2 bytes int=4 bytes
NB. short yy
NB. short mm
NB. short dd
NB. short HH
NB. short MM
NB. short SS
NB. int billionth fraction  (% 1e9)
NB. TODO: timezone offset ignore and always 0
datetimex2odbc=: 4 : 0
NB. bug when y is a vector with leading zero  => always return single <'null'
NB.                              non leading zero => return as 1800-01-01
if. (0~:x) *. (0=y) *. 1=#y do. NB. singleton zero
  if. 0&= #@$ y do.
    <20#{.a.         NB. same length as not null for easy packing in column mode
  else.
    <,: 20#{.a.      NB. shape
  end.
else.
  if. 0=x do.
    f=. +./"1 y e.("0 1) 'Zz'
    d1=. <. d0=. 6&{.("1) (0&".)@(-.&'dts{}')"1 ('- : T Z z ') charsub y
    d2=. 1&| {:"1 d0
    < (f{OffsetMinute_bin,:1&ic 0 0),~"1 (1&ic@:<.@:}: , 2&ic@:<.@((10^(9-FraSecond))&*)@<.@((10^FraSecond)&*)@(1&|)@:{:)("1) d1,.d2
  elseif. 1=x do.
    d1=. 3{."1 todate d0=. <. y=. ,y
    d2=. 24 60 60&#:@(86400&*) y-d0
    < OffsetMinute_bin,~"1 (1&ic@:<. , 2&ic@:<.@((10^(9-FraSecond))&*)@<.@((10^FraSecond)&*)@(1&|)@:{:)("1) d1,.d2
  elseif. 2=x do.
    d1=. <. 3{."1 todate <.@:(%&86400) d0=. (%&1e9) d3=. (+&(EpochOffset*dayns)) ,y
    d2=. <. 24 60 60&#:@(86400&|) d0
    < OffsetMinute_bin,~"1 (1&ic@:<.@:}: , 2&ic@:<.@:{:)("1) d1,.d2,. <. 1e9|d3
  end.
end.
)

NB. y array of dayno, return sql-c-time struct 6 bytes, short=2 bytes int=4 bytes
NB. short HH
NB. short MM
NB. short SS
time2odbc=: 4 : 0
NB. bug when y is a vector with leading zero  => always return single <'null'
NB.                              non leading zero => return as 1800-01-01
if. (0~:x) *. (0=y) *. 1=#y do. NB. singleton zero
  if. 0&= #@$ y do.
    <6#{.a.         NB. same length as not null for easy packing in column mode
  else.
    <,: 6#{.a.      NB. shape
  end.
else.
  if. 0=x do.
    < (1&ic) , <. _3&{.("1) (0&".)@(-.&'dts{}')"1 ('- : T Z z ') charsub y
  elseif. 1=x do.
    < (1&ic) , <. 24 60 60&#:@(86400&*) (- <.) ,y
  elseif. 2=x do.
    < (1&ic) , <. 24 60 60&#:@(86400&|) (%&1e9) d3=. (+&(EpochOffset*dayns)) ,y
  end.
end.
)

NB. y array of dayno, return sql-c-ss-time2 struct 12 bytes, short=2 bytes int=4 bytes
NB. short HH
NB. short MM
NB. short SS
NB. int billionth fraction  (% 1e9)
timex2odbc=: 4 : 0
NB. bug when y is a vector with leading zero  => always return single <'null'
NB.                              non leading zero => return as 1800-01-01
if. (0~:x) *. (0=y) *. 1=#y do. NB. singleton zero
  if. 0&= #@$ y do.
    <12#{.a.         NB. same length as not null for easy packing in column mode
  else.
    <,: 12#{.a.      NB. shape
  end.
else.
  if. 0=x do.
    d1=. <. d0=. _3&{.("1) (0&".)@(-.&'dts{}')"1 ('- : T Z z ') charsub y
    d2=. 1&| {:"1 d0
    < (1&ic@:(,&0)@:<.@:}: , 2&ic@:<.@((10^(9-FraSecond))&*)@<.@((10^FraSecond)&*)@(1&|)@:{:)("1) d1,.d2
  elseif. 1=x do.
    < (1&ic@:(,&0)@:<. , 2&ic@:<.@((10^(9-FraSecond))&*)@<.@((10^FraSecond)&*)@(1&|)@:{:)("1) 24 60 60&#:@(86400&*) (- <.) ,y
  elseif. 2=x do.
    d2=. 24 60 60&#:@(86400&|) <.@(%&1e9) d3=. (+&(EpochOffset*dayns)) ,y
    < (1&ic@:(,&0)@:}: , 2&ic@:{:)("1) d2 ,. <. 1e9|d3
  end.
end.
)

NB. ---------------------------------------------------------

NB. format (getlasterror) messages as char lists
fmterr=: [: ; ([: ":&.> ]) ,&.> ' '"_

NB. test all sqlgetdata return codes for a row
badrow=: 13 : '0 e. (src ;{.&> y) e. DD_SUCCESS'

NB. returns 1 if argument is a box 0 otherwise
isbx=: 3!:0 e. 32"_

NB. returns 1 if argument is a character 0 otherwise
isca=: 3!:0 e. 2"_

NB. convert integer to string
cvt2str=: 'a'&,@":

NB. 6+10 bytes: {d 'yyyy-mm-dd'}
date2db=: 4 : 0
y=. >y
y=. <.y
if. (((2=x){::DateTimeNull;EpochNull)=y) *. 1=#y do. NB. singleton null
  if. 0&= #@$ y do.
    <16{.'NULL'  NB. same length as not null for easy packing in column mode
  else.
    <,: 16{.'NULL'  NB. shape
  end.
else.
  < (16{.'NULL' ) g} '{d ''' ,("1) (x&fmtddtsn 0 (g=. I. ((2=x){::DateTimeNull;EpochNull)=y)}y) ,("1) '''}'
end.
)

NB. 7+19+(+*)FraSecond bytes: {ts 'yyyy-mm-dd HH:MM:SS[.fff]'}
datetime2db=: 4 : 0
y=. >y
if. (((2=x){::DateTimeNull;EpochNull)=y) *. 1=#y do. NB. singleton null
  if. 0&= #@$ y do.
    <(26+(+*)FraSecond){.'NULL'  NB. same length as not null for easy packing in column mode
  else.
    <,: (26+(+*)FraSecond){.'NULL'  NB. shape
  end.
else.
  < ((26+(+*)FraSecond){.'NULL' ) g} '{ts ''' ,("1) (x&fmtdtsn 0 (g=. I. ((2=x){::DateTimeNull;EpochNull)=y)}y) ,("1) '''}'
end.
)

NB. 6+8+(+*)FraSecond bytes: {t 'HH:MM:SS[.fff]'}
time2db=: 4 : 0
y=. >y
if. (((2=x){::DateTimeNull;EpochNull)=y) *. 1=#y do. NB. singleton null
  if. 0&= #@$ y do.
    <(14+(+*)FraSecond){.'NULL'  NB. same length as not null for easy packing in column mode
  else.
    <,: (14+(+*)FraSecond){.'NULL'  NB. shape
  end.
else.
  < ((14+(+*)FraSecond){.'NULL' ) g} '{t ''' ,("1) (x&fmttdtsn 0 (g=. I. ((2=x){::DateTimeNull;EpochNull)=y)}y) ,("1) '''}'
end.
)
