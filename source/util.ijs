NB. util

NB. The odbc locale is designed to be independent of the contents of
NB. the (z) locale.  Hence there will be a few utilities that overlap
NB. the standard utilities that are loaded in the (z) locale.

NB. handy ddl argument utils
b0=: <"0
bs=: ];#

NB. bits to index #'s

NB. first atom - the dll interface likes pure atoms
fat=: ''&$@:,

NB. tests of sql dll returns - small ints forced to standard form
src=: _1: ic 1: ic ]
sqlbad=: 13 : '(src >{. y) e. DD_ERROR'
sqlok=: 13 : '(src >{. y) e. DD_SUCCESS'
sqlsuccess=: 13 : '(src >{. y) e. SQL_SUCCESS'

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

NB. decode C datetime structures
NB. dts=: 13 : '((#y),6) $ _1&ic , 12{."1 y'
dts=: 3 : 0
a=. ((#y),6) $ _1&ic , 12{."1 y
frac=. _2&ic , 12 13 14 15{("1) y
((1e_9 * frac) + 5{"1 a) (<a:;5)}a
)

NB. decode C datetime structures (date only)
ddts=: 13 : '((#y),3) $ _1&ic , 6{.("1) y'

NB. decode C datetime structures (time only)
tdts=: 13 : '((#y),3) $ _1&ic , 6{.("1) y'

NB. typedef struct tagSS_TIME2_STRUCT {
NB.    SQLUSMALLINT hour;
NB.    SQLUSMALLINT minute;
NB.    SQLUSMALLINT second;
NB.    SQLUINTEGER fraction;
NB. } SQL_SS_TIME2_STRUCT;

NB. decode C datetime structures (time2 only)
tdts2=: 3 : 0
a=. ((#y),3) $ _1&ic , 6{.("1) y
frac=. _2&ic , 8 9 10 11{("1) y
((1e_9 * frac) + 2{"1 a) (<a:;2)}a
)

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

date2db=: 3 : 0
y=. >y
y=. <.y
if. (DateTimeNull=y) *. 1=#y do. NB. singleton null
  if. 0&= #@$ y do.
    <16{.'NULL'  NB. same length as not null for easy packing in column mode
  else.
    <,: 16{.'NULL'  NB. shape
  end.
else.
  a=. 8&":@(1&todate)("0) 0 (I. DateTimeNull=y)}y
  z=. <'{d ''' ,("1) (0 1 2 3&{("1) a) ,("1) '-' ,("1) (4 5&{("1) a) ,("1) '-' ,("1) (6 7&{("1) a) ,("1) '''}'  NB. ODBC escape sequence
end.
)

datetime2db=: 3 : 0
y=. >y
if. (DateTimeNull=y) *. 1=#y do. NB. singleton null
  if. 0&= #@$ y do.
    <30{.'NULL'  NB. same length as not null for easy packing in column mode
  else.
    <,: 30{.'NULL'  NB. shape
  end.
else.
  <'{ts ''' ,("1) (isotimestamp 1 tsrep *&(24*60*60*1000) 0 (I. DateTimeNull=y)}y) ,("1) '''}'  NB. ODBC escape sequence  {ts '2002-09-22 21:58:08.176'}
end.
)

time2db=: 3 : 0
y=. >y
if. (DateTimeNull=y) *. 1=#y do. NB. singleton null
  if. 0&= #@$ y do.
    <18{.'NULL'  NB. same length as not null for easy packing in column mode
  else.
    <,: 18{.'NULL'  NB. shape
  end.
else.
  <'{t ''' ,("1) (fmttdtsn 0 (I. DateTimeNull=y)}y) ,("1) '''}'  NB. ODBC escape sequence  {t '21:58:08.176'}
end.
)
