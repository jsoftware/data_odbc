NB. ddfns

NB. =========================================================
bindcol=: 4 : 0"1 1

NB. (bindcol) binds columns in the result set to J nouns.
NB. The result is a set of globals BIND_sh_col and BINDLN_sh_col
NB. bound to the statement that are used for fetched data
NB. and erased when the (sh) is freed (ddend or dddis).
NB.
NB. NIMP? currently the bound nouns are in the jdd/ODBC locale
NB. it might be better to have them created in a user locale.
NB.
NB. Datatypes referred to in this verb are the *'ed items
NB. of (SQL_SUPPORTED_NAMES).
NB.
NB. dyad:  blDll =. btGetcolinfo bindcol it

'sh col rows'=. y
'type precision'=. x
type=. fat src type

name=. (":sh),'_',":col
bname=. 'BIND_',name
blname=. 'BINDLN_',name
(blname)=: (rows,1)$2-2

NB. set target type and in buffer
if. type e. SQL_CHAR,SQL_VARCHAR do.
  len=. fat >:precision [ tartype=. SQL_C_CHAR
  (bname)=: (rows,len)$' '
elseif. type e. SQL_DECIMAL,SQL_NUMERIC do.
  if. UseNumeric do.
    len=. 8 [ tartype=. SQL_C_DOUBLE
    (bname)=: (rows,1)$1.5-1.5
  else.
    len=. fat >:precision [ tartype=. SQL_C_CHAR
    (bname)=: (rows,len)$' '
  end.
elseif. type e. SQL_BINARY,SQL_VARBINARY do.
  len=. fat >:precision [ tartype=. SQL_C_CHAR
  (bname)=: (rows,len)$' '
elseif. type e. SQL_INTEGER,SQL_SMALLINT,SQL_TINYINT,SQL_BIT do.
  if. IF64 do.
    len=. 4 [ tartype=. SQL_C_SLONG
    (bname)=: (rows,4)$CNB
  else.
    len=. 4 [ tartype=. SQL_C_SLONG
    (bname)=: (rows,1)$2-2
  end.
elseif. type e. SQL_BIGINT do.
  if. IF64*.UseBigInt do.
    len=. 8 [ tartype=. SQL_C_SBIGINT
    (bname)=: (rows,1)$2-2
  else.
    if. UseNumeric do.
      len=. 8 [ tartype=. SQL_C_DOUBLE
      (bname)=: (rows,1)$1.5-1.5
    else.
      len=. 1+ fat >:precision [ tartype=. SQL_C_CHAR   NB. ??? need extra 1 space otherwise overflow
      (bname)=: (rows,len)$' '
    end.
  end.
elseif. type e. SQL_TYPE_TIMESTAMP do.
NB. is a C structure
  len=. 16 [ tartype=. SQL_C_TYPE_TIMESTAMP
  (bname)=: (rows,len)$' '
elseif. type e. SQL_TYPE_DATE do.
  len=. 6 [ tartype=. SQL_C_TYPE_DATE
  (bname)=: (rows,len)$' '
elseif. type e. SQL_TYPE_TIME do.
  len=. 6 [ tartype=. SQL_C_TYPE_TIME
  (bname)=: (rows,len)$' '
elseif. type e. SQL_SS_TIME2 do.
  len=. 12 [ tartype=. SQL_C_BINARY
  (bname)=: (rows,len)$' '
elseif. type e. SQL_SS_TIMESTAMPOFFSET do.
  len=. 20 [ tartype=. SQL_C_BINARY
  (bname)=: (rows,len)$' '
elseif. type e. SQL_WCHAR,SQL_WVARCHAR do.
  len=. fat >: wchar2char * precision [ tartype=. SQL_C_CHAR
  (bname)=: (rows,len)$' '
elseif. type e. SQL_DOUBLE,SQL_FLOAT,SQL_REAL do.
  len=. 8 [ tartype=. SQL_C_DOUBLE
  (bname)=: (rows,1)$2.5-2.5
NB. elseif. type e. SQL_BIT do.
NB.   len=. 1 [ tartype=. SQL_C_BINARY
NB.   (bname)=: (rows,len)$' '
elseif. type e. SQL_UNIQUEID do.
  len=. 37 [ tartype=. SQL_C_CHAR
  (bname)=: (rows,len)$' '
elseif.do. SQL_ERROR return.
end.

sqlbindcol sh;col;tartype;(vad bname);len;<vad blname
)

NB. yyyy mm dd H M S nano
NB. combine nano into S
date7to6=: 3 : 0
d0=. 5{."1 d=. y
'd1 d2'=. |: 5 6{"1 d
d=. d0,.d1+d2%1e9
)

NB. H M S nano
NB. combine nano into S
time4to3=: 3 : 0
d0=. 2{."1 d=. y
'd1 d2'=. |: 2 3{"1 d
d=. d0,.d1+d2%1e9
)

NB. =========================================================
NB. main ODBC verbs
NB. words marked with --> have an external interface all
NB. other words are confined to the ODBC utility locale.

fmtdts=: 3 : 0

NB. (fmtdts) decodes and formats datetime columns.
NB.
NB. monad:  fmtdts ctDatetime

d=. date7to6@:dts y
0&fmtdtsn d
)

fmtdtsx=: 3 : 0
d=. date7to6@:dtsx y
0&fmtdtsn d
)

fmtdtsn=: 3 : 0
0 fmtdtsn y
:
if. 0=x do.    NB.  6 components
  d=. y
elseif. 1=x do.  NB. dayno
  d1=. 3{."1 todate d0=. <. y
  d2=. 24 60 60&#:@(86400&*) y-d0
  d=. d1,.d2
elseif. 2=x do.  NB. epoch
  d1=. 3{."1 todate <.@:(%&86400) d0=. (%&1e9)@:(+&(EpochOffset*dayns)) y
  d2=. 24 60 60&#:@(86400&|) d0
  d=. d1,.d2
end.

b=. ({:"1 d ) <: 60 NB. NIMP LAME QUESTION? how do we "officially" detect null values

NB. ANSWER requires a status array to be filled during the fetch (BINDST_sh)
NB. that indicates whether the data is NULL.  Without this status
NB. array the NULL'ness of data cannot be reliably inferred.
NB. Null dates usually appear as blanks but without status
NB. checking this cannot be trusted.

NB. convert to yyyy-mm-dd hr:mn:ss[.fff] format
s=. $d=. (4,(4#3),(3+(+*)FraSecond) j. FraSecond) ": b *"0 1 d
d=. , d
d=. s$'0'(I. ' '=d)}d
d=. ((#d)#,:'-- ::') (<a:;4 7 10 13 16)} d
(b * {:$d) {."0 1 d
)

NB. fmtddts (date only)
fmtddts=: 3 : 0
d=. ddts y
0&fmtddtsn d
)

fmtddtsn=: 3 : 0
0 fmtddtsn y
:
if. 0=x do.    NB.  3 components
  d=. <.y
elseif. 1=x do.  NB. dayno
  d=. todate <. y
elseif. 2=x do.  NB. epoch
  d=. todate <.@:(%&86400) d0=. (%&1e9)@:(+&(EpochOffset*dayns)) y
end.

s=. $d=. (4,2#3) ": d
d=. , d
d=. s$'0'(I. ' '=d)}d
d=. ((#d)#,:'--') (<a:;4 7)} d
({:$d) {."0 1 d
)

NB. fmttdts (time only)
fmttdts=: 3 : 0
d=. time4to3@:tdts y
0&fmttdtsn d
)

fmttdtsn=: 3 : 0
0 fmttdtsn y
:
if. 0=x do.    NB.  3 components
  d=. y
elseif. 1=x do.  NB. dayno
  d=. 24 60 60&#:@(86400&*) y
elseif. 2=x do.  NB. epoch
  d=. 24 60 60&#:@(86400&|) (%&1e9)@:(+&(EpochOffset*dayns)) y
end.

s=. $d=. (2 3,(3+(+*)FraSecond)) ": d
d=. , d
d=. s$'0'(I. ' '=d)}d
d=. ((#d)#,:'::') (<a:;2 5)} d
({:$d) {."0 1 d
)

NB. fmttdts2 (time only)
fmttdts2=: 3 : 0
d=. time4to3@:tdts2 y
0&fmttdtsn d
)

NB. fmtdts_num as dayno
fmtdts_num=: 3 : 0
d=. date7to6@:dts y
a=. todayno@(3&{.)"1 d
b=. ((% 1 60 60 24) #. |.@(0&,))@(3&}.)"1 d
,. a+b
)

NB. fmtdtsx_num as dayno
fmtdtsx_num=: 3 : 0
d=. date7to6@:dtsx y
a=. todayno@(3&{.)"1 d
b=. ((% 1 60 60 24) #. |.@(0&,))@(3&}.)"1 d
,. a+b
)

NB. fmtddts_num as dayno (date only)
fmtddts_num=: 3 : 0
d=. ddts y
,.todayno"1 d
)

NB. fmttdts_num as dayno (time only)
fmttdts_num=: 3 : 0
d=. time4to3@:tdts y
,.((% 1 60 60 24) #. |.@(0&,))"1 d
)

NB. fmttdts2_num as dayno (time only)
fmttdts2_num=: 3 : 0
d=. time4to3@:tdts2 y
,.((% 1 60 60 24) #. |.@(0&,))"1 d
)

NB. ---------------------------------------------------------
NB. fmtdts_e as epoch dayno
fmtdts_e=: 3 : 0
d=. dts y
a=. (-&EpochOffset)@todayno@(3&{.)"1 d
b=. (24 60 60 & #.)@(3 4 5&{)"1 d
f=. (2200<yy) +. 1800> yy=. {."1 d
,. <. EpochNull (I.f)} (dayns*a)+(b*1e9)+(6&{)"1 d
)

NB. fmtdtsx_e as epoch dayno
fmtdtsx_e=: 3 : 0
d=. dtsx y
a=. (-&EpochOffset)@todayno@(3&{.)"1 d
b=. (24 60 60 & #.)@(3 4 5&{)"1 d
f=. (2200<yy) +. 1800> yy=. {."1 d
,. <. EpochNull (I.f)} (dayns*a)+(b*1e9)+(6&{)"1 d
)

NB. fmtddts_e as epoch dayno (date only)
fmtddts_e=: 3 : 0
d=. ddts y
f=. (2200<yy) +. 1800> yy=. {."1 d
,. <. EpochNull (I.f)} dayns&*@(-&EpochOffset)@todayno"1 d
)

NB. fmttdts_e as epoch dayno (time only)
fmttdts_e=: 3 : 0
d=. tdts y
b=. (24 60 60 & #.)@(3&{.)"1 d
,. <. (b*1e9)+(3&{)"1 d
)

NB. fmttdts2_e as epoch dayno (time only)
fmttdts2_e=: 3 : 0
d=. tdts2 y
b=. (24 60 60 & #.)@(3&{.)"1 d
,. <. (b*1e9)+(3&{)"1 d
)

NB. =========================================================
errret=: 3 : 0

NB. (errret) error return.  Sets the last error message(s).  Some
NB. errors are generated by the (jdd) verbs (ISInn errors) all others
NB. boil up from the depths of ODBC.
NB.
NB. monad:  errret ilTypeHandle  NB. handle type and handle with last error
NB.         errret clErrmsg      NB. ISI error message text
NB.
NB.  errret ISI03
NB.  errret SQL_HANDLE_DBC,ch

r=. SQL_ERROR
LERR=: ''
ALLDM=: i. 0 0
if. iscl y do.
  LERR=: y
else.
  't h'=. y
  if. SQL_ERROR-:em=. t getlasterror h do. r return.
  elseif. c=. #em do.
    LERR=: fmterr {. em   NB. take first message
    ALLDM=: em             NB. all messages
    if. 1<c do. LERR=: LERR , ' - more error info available (1)' end.
  end.
end.
r
)


NB. =========================================================
NB. (clr) clear errors
clr=: 3 : 0
LERR=: ''
ALLDM=: i. 0 0
)

NB. =========================================================
NB. (ddconfig) set driver specific config
NB. returns 0
NB.
NB. monad: ddconfig key;value {;key;value...}
NB.

NB. =========================================================
NB. (ddconfig) set driver specific config
NB. returns 0
NB.
NB. monad: ddconfig key;value {;key;value...}
NB.
ddconfig=: 3 : 0  NB.-->
clr 0
key=. {.keynvalue=. |: _2]\ y
value=. {:keynvalue
for_i. i.#key do.
  select. tolower i{::key
  case. 'bigint' do. UseBigInt=: -. 0-: {.i{::value
  case. 'datetimenull' do. DateTimeNull=: <. {.i{::value
  case. 'frasecond' do. FraSecond=: 9 <. 0 >. <. {.i{::value
  case. 'offsetminute' do.
    if. 0>OffsetMinute=: <. {.i{::value do.
      OffsetMinute_bin=: 1&ic - 24 60 #: - OffsetMinute
    else.
      OffsetMinute_bin=: 1&ic 24 60 #: OffsetMinute
    end.
  case. 'dayno' do. UseDayNo=: 2 <. 0 >. <. {.i{::value
NB.   case. 'errret' do. UseErrRet=: -. 0-: {.i{::value
  case. 'numeric' do. UseNumeric=: -. 0-: {.i{::value
  case. 'integernull' do. IntegerNull=: <. {.i{::value
  case. 'numericnull' do. NumericNull=: <. {.i{::value
  case. 'trimbulktext' do. UseTrimBulkText=: -. 0-: {.i{::value
NB.   case. 'unicode' do. UseUnicode=: -. 0-: {.i{::value
  case. do. _1 return.
  end.
end.
settypeinfo 0
0
)

NB. =========================================================
NB. (dddriver) query driver of current jdd...
NB. returns 'JODBC'
NB.
NB. monad: bt =. dddriver uuIgnore
NB.
NB.   dddriver ''  NB. current jdd... driver
dddriver=: 3 : 0  NB.-->
clr 0
'ODBC'
)

NB. =========================================================
NB. (dddrv) lists all ODBC drivers.
NB. returns boxed table of driver names and driver types.
NB.
NB. monad: bt =. ddsrc uuIgnore
NB.
NB.   dddrv ''  NB. boxed table of drivers
dddrv=: 3 : 0  NB.-->
clr 0
d=. EH;SQL_FETCH_FIRST
n=. EH;SQL_FETCH_NEXT
r=. i.0 0
while.do.
  z=. sqldrivers d , 6$(256#' ');256;,0
  if. sqlbad z do. errret '' return. end.
  if. SQL_NO_DATA=rc=. src >0{z do. break. end.
  if. -. sqlok rc do. errret '' return. end.
  d=. n
  r=. r , 3 6{z
end.
(trbuclnb {."1 r),.nullvec2mat &.> {:"1 r
)

NB. =========================================================
ddsrc=: 3 : 0  NB.-->

NB. (ddsrc) lists all registered ODBC datasources. Result
NB. is a boxed table of dsn names and driver types.
NB.
NB. monad: bt =. ddsrc uuIgnore
NB.
NB.   ddsrc ''  NB. boxed table of data sources

clr 0
d=. EH;SQL_FETCH_FIRST
n=. EH;SQL_FETCH_NEXT
l=. >:SQL_MAX_DSN_LENGTH
r=. i.0 0

while.do.

NB.                  i   i    *c     i   *i    *c       i  *i
  z=. sqldatasources d ,(l#' ');256;(,0);(256#' ');256;,0

NB. return if errors
  if. sqlbad z do. errret '' return. end.

NB. end loop if no more data sources
  if. SQL_NO_DATA=rc=. src >0{z do. break. end.

NB. insure no unexepected codes - infinite loop risk otherwise
  if. -. sqlok rc do. errret '' return. end.
  d=. n
  r=. r , 3 6{z

end.
trbuclnb r
)


NB. =========================================================
ddtbl=: 3 : 0  NB.-->

NB. (ddtbl) lists all the tables in the data source with
NB. connection handle (y). The result is a statement handle.
NB.
NB. NIMP? maybe more useful to return the table list and behave
NB. like (ddsrc) and (ddcol) (see ddtblx)
NB.
NB. monad:  iaSh =. ddtbl iaCh
NB.
NB.  ch =. ddcon 'dsn=jaccess'
NB.  sh =. ddtbl ch
NB.  ddfet sh,_1      NB. boxed list of tables

NB. test argument
clr 0
if. -. isia y do. errret ISI08 return. end.
if. -. y e. CHALL do. errret ISI03 return. end.

NB. get statement handle - return if errors
if. SQL_ERROR=sh=. getstmt y do. errret '' return. end.

NB. <0 is the C NULL pointer in the following call
NB.            i   *c   i   *c   i   *c   i   *c  i
z=. sqltables sh;(<0);256;(<0);256;(<0);256;(<0);256
if. sqlok z do.

NB. update connection/statement pairs & return statement handle
  CSPALL=: CSPALL,y,sh
  sh
else.
  r=. errret SQL_HANDLE_STMT,sh
  r [ freestmt sh return.
end.
)


NB. =========================================================
ddtblx=: 3 : 0  NB.-->

NB. (ddtblx) like (ddtbl) except table information is immediately
NB. returned in a more readable format.
NB.
NB. monad:  ddtblx iaCh

if. SQL_ERROR-:sh=. ddtbl y do. SQL_ERROR
elseif. SQL_ERROR-:dat=. ddfch sh,_1 do. SQL_ERROR [ freestmt sh
elseif. 0<>./ #&> dat do. trctnob@:":&.> dat [ freestmt sh
elseif.do. dat [ freestmt sh
end.
)

NB. =========================================================
NB. (ddtypeinfo) lists all types in the data source with
NB. connection handle (y). The result is a statement handle.
NB.
NB. monad:  iaSh =. ddtypeinfo iaCh
NB.
NB.  ch =. ddcon 'dsn=jaccess'
NB.  sh =. ddtypeinfo ch
NB.  ddfet sh,_1      NB. boxed list of tables

ddtypeinfo=: 3 : 0
clr 0
if. -. isia y do. errret ISI08 return. end.
if. -. y e. CHALL do. errret ISI03 return. end.
if. SQL_ERROR=sh=. getstmt y do. errret SQL_HANDLE_DBC,y return. end.
if. sqlbad sqlsetstmtattr sh;SQL_ATTR_CURSOR_TYPE;SQL_CURSOR_FORWARD_ONLY ;0 do. errret SQL_HANDLE_STMT,sh return. end.
if. sqlbad sqlsetstmtattr sh;SQL_ATTR_CONCURRENCY;SQL_CONCUR_READ_ONLY;0 do. errret SQL_HANDLE_STMT,sh return. end.
z=. sqlgettypeinfo sh;SQL_ALL_TYPES
if. sqlok z do.
  CSPALL=: CSPALL,y,sh
  sh
else.
  r=. errret SQL_HANDLE_STMT,sh
  r [ freestmt sh return.
end.
)

NB. =========================================================
NB. (ddtypeinfox) like (ddtypeinfo) except information is immediately
NB. returned in a more readable format.
NB.
NB. monad:  ddtypeinfox iaCh

ddtypeinfox=: 3 : 0
clr 0
if. SQL_ERROR&-: sh=. err=. ddtypeinfo y do.
  err
elseif. SQL_ERROR&-: cnm=. err=. ddcnm sh do.
  err [ freestmt sh
elseif. do.
  if. SQL_ERROR&-: dat=. err=. ddfet sh, _1 do.
    err [ freestmt sh
  else.
    (,:cnm),dat [ freestmt sh
  end.
end.
)

NB. =========================================================
NB. ddcheck
ddcheck=: 3 : 0
if. _1=y do. (sminfo]]) dderr $0 else. y end.
)

NB. =========================================================
NB. COMPATIBLE (ddcol) simply returns a header with no
NB. error when given a column that doesn't exist in a valid table.
NB. This is also what the original 14!:4 does.  Returning
NB. an error would make more sense.

ddcol=: 4 : 0  NB. -->

NB. (ddcol) lists all the columns in table (x).
NB.
NB. dyad:  bt =. clTable ddcol iaCh
NB.
NB.  ch =. ddcon 'dsn=jaccess'
NB.  'tdata' ddcol ch

NB. test arguments
clr 0
w=. y
if. -. (iscl x) *. isia w=. fat w do. errret ISI08 return. end.
if. -. w e. CHALL do. errret ISI03 return. end.
x=. ,x

NB. get statement handle - return if errors
if. SQL_ERROR=sh=. getstmt w do. errret '' return. end.

NB.             i   *c   i   *c   i  *c   i     *c   i
z=. sqlcolumns sh;(<0);256;(<0);256;x;SQL_NTS;(<0);256
if. sqlbad z do.
  r=. errret SQL_HANDLE_STMT,sh
  r [ freestmt sh return.
end.

NB. get column definitions information or error
r=. getcoldefs sh
r [ freestmt sh
)


NB. =========================================================
getlasterror=: 3 : 0

NB. (getlasterror) returns diagnostic information (mostly errors) for handles.
NB.
NB. monad:  getlasterror iaHandle
NB.
NB.  getlasterror ch  NB. handle is on globals EH, CHALL, CSPALL
NB.
NB. dyad: iaHtype getlasterror iaHandle
NB.
NB.  NB. check new DBC connection (not on CHALL)
NB.  SQL_HANDLE_DBC getlasterror ch

(EH;CHALL;1{"1 CSPALL) getlasterror y
:
if. 0=L. x do.
  t=. fat x
else.
  b=. >(<y) e. each x
  if. 1~:+/b do. SQL_ERROR return. end.
  t=. fat b#SQL_HANDLE_ENV,SQL_HANDLE_DBC,SQL_HANDLE_STMT
end.
r=. 0 3$''
while.do.
  z=. sqlgetdiagrec t;y;(1+0{$r);(5#' ');(,0);(1024#' ');1024;,0
  if. sqlbad z do. SQL_ERROR return. end.
  if. SQL_NO_DATA=src >0{z do. break. end.
  r=. r,(2{.4}.z),<(>8{z){.>6{z
end.
r
)


NB. =========================================================
getstmt=: 3 : 0

NB. (getstmt) allocates a statement handle given a connection handle (y).
NB. Result is _1 (SQL_ERROR) if the handle cannot be allocated.
NB.
NB. monad:  iaSh =. getstmt iaCh

z=. sqlallochandle SQL_HANDLE_STMT;({.y);,0
if. sqlbad z do. SQL_ERROR else. fat >3{z end.
)


NB. =========================================================
freestmt=: 3 : 0

NB. (freestmt) frees allocated statement handles.
NB.
NB. monad:  freestmt iaSh

sqlfreehandle SQL_HANDLE_STMT;y
)


NB. =========================================================
freeenv=: 3 : 0

NB. (freeenv) frees the ODBC environment.
NB.
NB. monad:  freeinv iaEh
NB.
NB.  freeenv EH

sqlfreehandle SQL_HANDLE_ENV;y
)


NB. get and convert various datatypes ----------------------

NB. =========================================================
gc=: 0 4 6&{  NB. necessary columns in get result

NB. =========================================================
tdatchar=: 3 : 0"1
sqlgetdata (b0 y),SQL_C_CHAR;(SHORTBUF$' ');(>:SHORTBUF);,0
)


NB. =========================================================
NB. trims var data to its alleged size
trimdat=: 13 : '(<(0>.>2{y){.>1{y) 1} y'   NB. coerce _1=len (NULL) to empty string

NB. =========================================================
datchar=: 3 : 0"1
z=. gc sqlgetdata (b0 y),SQL_C_CHAR;(SHORTBUF$' ');(>:SHORTBUF);,0
if. sqlok z do. trimdat z else. z end.
)

NB. ]`trimdat@.sqlok  (fails as sqlok returns singletons not atoms)
NB. coercing to atom is more trouble than it's worth

NB. =========================================================
datwchar=: 3 : 0"1
bufln=. >:buf=. wchar2char * SHORTBUF
z=. gc sqlgetdata (b0 y),SQL_C_CHAR;(buf$' ');bufln;,0
z=. (<8&u: 6&u: 1:{z) 1} z
if. sqlok z do. trimdat z else. z end.
)

NB. =========================================================
datdouble=: 3 : 0"1
z=. gc sqlgetdata (b0 y),SQL_C_DOUBLE;(,1.5-1.5);8;,0
if. sqlok z do.
  if. SQL_NULL_DATA= _1{::z do.
    (<NumericNull) 1} z
  end.
else.
  z
end.
)

NB. =========================================================
datinteger32=: 3 : 0"1
z=. gc sqlgetdata (b0 y),SQL_C_SLONG;(,2-2);4;,0
if. sqlok z do.
  if. SQL_NULL_DATA= _1{::z do.
    (<IntegerNull) 1} z
  end.
else.
  z
end.
)

NB. =========================================================
datinteger64=: 3 : 0"1
z=. gc sqlgetdata (b0 y),SQL_C_SLONG;(4${.a.);4;,0
if. sqlok z do.
  if. SQL_NULL_DATA= _1{::z do.
    (<IntegerNull) 1} z
  else.
    (<fat _2&ic >1{z) 1} z
  end.
else.
  z
end.
)

datinteger=: ('datinteger',SFX)~ f.

NB. =========================================================
datbigint32=: 3 : 0"1
z=. gc sqlgetdata (b0 y),SQL_C_DOUBLE;(,1.5-1.5);8;,0
if. sqlok z do.
  if. SQL_NULL_DATA= _1{::z do.
    (<IntegerNull) 1} z
  end.
else.
  z
end.
)

NB. =========================================================
datbigint64=: 3 : 0"1
z=. gc sqlgetdata (b0 y),SQL_C_SBIGINT;(,2-2);8;,0
if. sqlok z do.
  if. SQL_NULL_DATA= _1{::z do.
    (<IntegerNull) 1} z
  end.
else.
  z
end.
)

datbigint=: ('datbigint',(IF64*.UseBigInt){::'32';SFX)~ f.

NB. =========================================================
datsmallint=: 3 : 0"1
z=. gc sqlgetdata (b0 y),SQL_C_SSHORT;(2${.a.);2;,0
if. sqlok z do.
  if. SQL_NULL_DATA= _1{::z do.
    (<IntegerNull) 1} z
  else.
    (<fat _1&ic >1{z) 1} z
  end.
else.
  z
end.
)

NB. =========================================================
datbit=: 3 : 0"1
z=. gc sqlgetdata (b0 y),SQL_C_BINARY;(1${.a.);1;,0
if. sqlok z do.
  if. SQL_NULL_DATA= _1{::z do.
    (<0) 1} z
  else.
    (<a.&i. fat >1{z) 1} z
  end.
else.
  z
end.
)

NB. =========================================================
datreal=: 3 : 0"1
z=. gc sqlgetdata (b0 y),SQL_C_BINARY;(4${.a.);4;,0
if. sqlok z do.
  if. SQL_NULL_DATA= _1{::z do.
    (<NumericNull) 1} z
  else.
    (<fat _1&fc >1{z) 1} z
  end.
else.
  z
end.
)

NB. =========================================================
dattimestamp=: 3 : 0"1
z=. gc sqlgetdata (b0 y),SQL_C_TYPE_TIMESTAMP;(16$CNB);17;,0
if. sqlok z do.
  if. 1=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do. NB. SQL_NULL_DATA
      (<DateTimeNull) 1}z
    else.
      (<fmtdts_num ,: 1{::z) 1}z
    end.
  elseif. 2=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do. NB. SQL_NULL_DATA
      (<EpochNull) 1}z
    else.
      (<fmtdts_e ,: 1{::z) 1}z
    end.
  elseif. 0=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do. NB. SQL_NULL_DATA
      (<(SQL_TIMESTAMP_LEN+(+*)FraSecond){.' ') 1}z
    else.
      (<,fmtdts ,:>1{z) 1}z
    end.
  end.
else.
  z
end.
)

NB. =========================================================
datsstimestampoffset=: 3 : 0"1
z=. gc sqlgetdata (b0 y),SQL_C_SS_TIMESTAMPOFFSET;(20$CNB);21;,0
if. sqlok z do.
  if. 1=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do. NB. SQL_NULL_DATA
      (<DateTimeNull) 1}z
    else.
      (<fmtdtsx_num ,: 1{::z) 1}z
    end.
  elseif. 2=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do. NB. SQL_NULL_DATA
      (<EpochNull) 1}z
    else.
      (<fmtdtsx_e ,: 1{::z) 1}z
    end.
  elseif. 0=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do. NB. SQL_NULL_DATA
      (<(SQL_TIMESTAMP_LEN+(+*)FraSecond){.' ') 1}z
    else.
      (<,fmtdtsx ,:>1{z) 1}z
    end.
  end.
else.
  z
end.
)

NB. =========================================================
datdate=: 3 : 0"1
z=. gc sqlgetdata (b0 y),SQL_C_TYPE_DATE;(6$CNB);7;,-0
if. sqlok z do.
  if. 1=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do. NB. SQL_NULL_DATA
      (<DateTimeNull) 1}z
    else.
      (<fmtddts_num ,: 1{::z) 1}z
    end.
  elseif. 2=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do. NB. SQL_NULL_DATA
      (<EpochNull) 1}z
    else.
      (<fmtddts_e ,: 1{::z) 1}z
    end.
  elseif. 0=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do. NB. SQL_NULL_DATA
      (<SQL_DATE_LEN{.' ') 1}z
    else.
      (<,fmtddts ,:>1{z) 1}z  NB. ....
    end.
  end.
else.
  z
end.
)

NB. =========================================================
dattime=: 3 : 0"1
z=. gc sqlgetdata (b0 y),SQL_C_TYPE_TIME;(6$CNB);7;,-0
if. sqlok z do.
  if. 1=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do. NB. SQL_NULL_DATA
      (<DateTimeNull) 1}z
    else.
      (<,fmttdts_num ,:>1{z) 1}z
    end.
  elseif. 2=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do. NB. SQL_NULL_DATA
      (<EpochNull) 1}z
    else.
      (<,fmttdts_e ,:>1{z) 1}z
    end.
  elseif. 0=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do. NB. SQL_NULL_DATA
      (<SQL_TIME_LEN{.' ') 1}z
    else.
      (<,fmttdts ,:>1{z) 1}z  NB. ....
    end.
  end.
else.
  z
end.
)

NB. =========================================================
datsstime2=: 3 : 0"1
z=. gc sqlgetdata (b0 y),SQL_C_SS_TIME2;(12$CNB);13;,-0
if. sqlok z do.
  if. 1=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do. NB. SQL_NULL_DATA
      (<DateTimeNull) 1}z
    else.
      (<,fmttdts2_num ,:>1{z) 1}z
    end.
  elseif. 2=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do. NB. SQL_NULL_DATA
      (<EpochNull) 1}z
    else.
      (<,fmttdts2_e ,:>1{z) 1}z
    end.
  elseif. 0=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do. NB. SQL_NULL_DATA
      (<(SQL_TIME_LEN+(+*)FraSecond){.' ') 1}z
    else.
      (<,fmttdts2 ,:>1{z) 1}z  NB. ....
    end.
  end.
else.
  z
end.
)

NB. =========================================================
datlong=: 0&$: : (4 : 0)"1

NB.*datlong v--  fetches  long types.  Unfortunately  looping  is
NB. unavoidable.  Setting the  (LONGBUF) to the largest value the
NB. ODBC driver  can  reliably  use  will  reduce the  amount  of
NB. looping.  Setting  (LONGBUF)  to  high can  result  in domain
NB. errors  being  signaled  by  (cd)  and  wrong  lengths  being
NB. returned  so be  careful! 5000 is about as high as this value
NB. can be set for most drivers.
NB.
NB. Note: Sql2000 can tolerate buffer sizes of 30000 chars (July 2002)
NB.
NB. Note: In the case of SQL Server 7/2000 short var types can be
NB. up to 8000 bytes and be fetched with (ddfch) much faster.
NB.
NB. monad:  datlong ilShCol

sc=. b0 y
NB. Oleg's fix Oct 2003
NB. get=. sc,SQL_CHAR;(LONGBUF$' ');(>:LONGBUF);,0
get=. sc,SQL_C_BINARY;(LONGBUF$' ');LONGBUF;,0

z=. sqlgetdata get
lim=. a:{ >{:z  NB. last item of first get is data length
dat=. ''
while. lim>:#dat do.
  if. sqlbad rc=. >{. z do. SQL_ERROR;'';0 return. end.
  if. SQL_NO_DATA=src rc do. break. end.

NB. last item of z contains bytes remaining before last get
  dat=. dat , (LONGBUF<.>{:z) {. , >4{z
  z=. sqlgetdata get
end.
if. x do. dat=. 8&u: 4&u: _1&(3!:4) dat end.
DD_OK ; dat ; #dat  NB. return code, data, length
)

NB. =========================================================
NB. Each get verb returns a return code, data and length.
NB. Each verb also trims and converts incoming data.
NB. Name suffix following 'get' prefix should match (SQL_SUPPORTED_NAMES)
getchar=: datchar&.>
getwchar=: datwchar&.>
getbinary=: datchar&.>
getvarbinary=: datchar&.>
getbit=: datbit&.>

NB. the followings 3 verbs will be redefined
getdecimal=: datchar&.>
getnumeric=: datchar&.>
getbigint=: datchar&.>

getdouble=: datdouble&.>
getfloat=: datdouble&.>
getreal=: datreal&.>
getvarchar=: datchar&.>
getwvarchar=: datchar&.>
getinteger=: datinteger&.>
getsmallint=: datsmallint&.>
gettinyint=: datbit&.>
getlongvarchar=: datlong&.>
getlongvarbinary=: datlong&.>
getwlongvarchar=: datlong&.>
gettype_timestamp=: dattimestamp&.>
gettype_date=: datdate&.>
gettype_time=: dattime&.>
getss_timestampoffset=: datsstimestampoffset&.>
getss_time2=: datsstime2&.>
getss_xml=: 1&datlong&.>
getuniqueid=: datchar&.>


NB. =========================================================
NB. (iad) integer address - returns pointer to a J array
NB.
NB. monad:  iaAdd =. iadd clNoun
NB.
NB.   boo =. 'some data here ehhh!'
NB.   iad 'boo'
iad=: 15!:14@boxopen   NB. integer address of real data of a J noun

NB. =========================================================
vad=: <@:iad  NB. boxed address

NB. =========================================================

NB. SQLRETURN SQLDescribeCol(
NB.       SQLHSTMT       StatementHandle,
NB.       SQLUSMALLINT    ColumnNumber,
NB.       SQLCHAR *      ColumnName,
NB.       SQLSMALLINT    BufferLength,
NB.       SQLSMALLINT *  NameLengthPtr,
NB.       SQLSMALLINT *  DataTypePtr,
NB.       SQLULEN *      ColumnSizePtr,
NB.       SQLSMALLINT *  DecimalDigitsPtr,
NB.       SQLSMALLINT *  NullablePtr);

getcolinfo=: 3 : 0"1
arg=. (b0 y),(bs 128$' '),5#<,0
z=. sqldescribecol arg
z=. (<(fat 5{::z){.3{::z) 3}z
)

NB. =========================================================
getallcolinfo=: 3 : 0

NB. (getallcolinfo) returns information about all the
NB. columns in a result set.
NB.
NB. monad:  bt =. getallcolinfo iaSh

if. sqlbad z=. sqlnumresultcols y;,0 do.
  SQL_ERROR
else.
  z=. getcolinfo y,.1+i.>2{z

NB. HARDCODE? col 6 is a critical small int type code
NB. insure that the small int is in standard form
  z=. (<"0 src;6{"1 z)(<a:;6)}z
end.
)


NB. =========================================================
SQL_DRIVER_NOPROMPT=: 0

ddcon=: 3 : 0  NB.-->

NB. (ddcon) connects to an ODBC data source and returns a connection handle.
NB. The (y) argument is an ODBC connection string.
NB.
NB. monad:  iaCh =. ddcon clCstr
NB.
NB.   ddcon 'dsn=jdata'

f=. (i.&';')({. ; }.@}.) ]

NB. test arguments:
clr 0
if. -.iscl y do. errret ISI08 return. end.
usedsn=. 'dsn=' -: tolower 4{.y

if. usedsn do.

NB. ---------------------------------------------------------
NB. assign all parameters:
NB. names that are referenced here:

  dsn=. uid=. pwd=. ''

  txt=. <;._2 y, ';' -. {:y
  ndx=. txt i.&> '='
  nms=. tolower each ndx {.each txt
  vls=. (ndx+1) }.each txt
  (nms)=. vls

  z=. sqlallochandle SQL_HANDLE_DBC;EH;,0
  if. sqlbad z do. errret SQL_HANDLE_ENV,EH return. end.

  HDBC=: fat >3{z

  z=. sqlconnect LASTCONNECT=: HDBC;(bs dsn),(bs uid),bs pwd
  if. sqlbad z do. errret SQL_HANDLE_DBC,HDBC return. end.

else.
NB. dsn-less connection
NB. ddcon 'Driver={Microsoft Access Driver (*.mdb)};Dbq=C:\Northwind.mdb;Uid=Admin;Pwd=pass;'

  z=. sqlallochandle SQL_HANDLE_DBC;EH;,0
  if. sqlbad z do. errret SQL_HANDLE_ENV,EH return. end.

  HDBC=: fat >3{z

  outstr=. 1024$' '
  z=. sqldriverconnect LASTCONNECT=: HDBC;0;(bs y),(bs outstr),(,0);SQL_DRIVER_NOPROMPT
  if. sqlbad z do. errret SQL_HANDLE_DBC,HDBC return. end.
  odsn=. ({.7{::z) {. 5{::z
end.

NB. absence of SQL errors is not sufficient to insure a valid connection
NB. must check the last error and look at the SQLSTATE.  ODBC documentation
NB. advises programmers to avoid logic based on SQLSTATE's.  In this
NB. case I ignore general warnings '01000' and return an error for all others
if. SQL_ERROR-:em=. SQL_HANDLE_DBC getlasterror HDBC do. errret '' return.
elseif. #em do.
  if. 0&e. ({."1 em) e. <SQLST_WARNING do.
    errret fmterr {.em return.
  end.
end.

CHALL=: CHALL,HDBC
dddbms HDBC
HDBC
)


NB. =========================================================
dddis=: 3 : 0"0   NB.-->

NB. (dddis) disconnects data sources.
NB.
NB. monad:  dddis i[0,1]Ch
NB.
NB.  dddis ch      NB. one handle
NB.  dddis CHALL   NB. all handles

clr 0
w=. y
if. -.isia w=. fat w do. errret ISI08 return. end.
if. -. w e. CHALL do. errret ISI03 return. end.
if. #shs=. 1{"1 CSPALL#~w=0{"1 CSPALL do. ddend shs end.
ch=. w NB. save in case dll call modifies value

NB. attempt to disconnect
if. sqlbad sqldisconnect w do. errret SQL_HANDLE_DBC,ch return. end.
if. sqlbad sqlfreehandle SQL_HANDLE_DBC;y do. errret '' return. end.

NB. remove handles from globals
CHALL=: CHALL-.ch
CSPALL=: CSPALL#~ch~:0{"1 CSPALL
DBMSALL=: DBMSALL#~ch~:>0{("1) DBMSALL
DD_OK
)


NB. =========================================================
ddsel=: 4 : 0  NB.-->

NB. (ddsel) selects data. (y) argument is a connection handle and
NB. (x) is an SQL statement that generates a result set.
NB.
NB. dyad:  iaCh =. clSql ddsel iaCh
NB.
NB.   'select * from tdata' ddsel ch
NB.
NB.   NB. can be used to call stored procedures that
NB.   NB. take simple arguments and return result sets
NB.   NB. driver must support escape {}'s and stored procs
NB.   '{call procname(''chararg'')}' ddsel ch

NB. test arguments
clr 0
if. -.(isia w=. fat y) *. iscl x do. errret ISI08 return. end.
if. -.w e. CHALL do. errret ISI03 return. end.
x=. ,x

NB. attempt to execute and return statement handle
if. SQL_ERROR=sh=. getstmt w do. errret SQL_HANDLE_DBC,w return. end.
if. sqlok sqlexecdirect sh;bs x do.
  sh [ CSPALL=: CSPALL,w,sh
else.
  r=. errret SQL_HANDLE_STMT,sh
  r [ freestmt sh
end.
)

NB. =========================================================
transact=: 4 : 0
if. sqlok sqlendtran SQL_HANDLE_DBC;y;x do.
  DD_OK [ CHTR=: CHTR-.y
else.
  SQL_ERROR
end.
)


NB. =========================================================
ddsql=: 4 : 0  NB.-->

NB. (ddsql) executes SQL statements (y) argument is a connection handle and
NB. (x) is any SQL statement.  Sets rows changed/modified for (ddcnt).
NB.
NB. dyad:  iaCh =. clSql ddsql iaCh
NB.
NB.   'delete from tdata' ddsel ch

NB. test arguments
clr DDROWCNT=: 0
if. -.(isia y) *. iscl x do. errret ISI08 return. end.
if. -.y e.CHALL do. errret ISI03 return. end.
x=. ,x

NB. attempt to get stmt handle and execute
if. SQL_ERROR=sh=. getstmt y do. errret SQL_HANDLE_DBC,y return. end.
if. sqlok sqlexecdirect sh;bs x do.

NB. set number of rows affected for (ddcnt)
  if. sqlok z=. sqlrowcount sh;,256 do. DDROWCNT=: fat >{:z end.

NB. if connection is not on pending transactions commit
  if. -. y e. CHTR do. SQL_COMMIT transact y end.
  DD_OK [ freestmt sh
else.
  r=. errret SQL_HANDLE_STMT,sh
  r [ freestmt sh
end.
)


NB. =========================================================
ddcnt=: 3 : 0  NB.-->

NB. (ddcnt) returns number of rows affected by last (ddsql) command.
NB.
NB. monad:  ddcnt uuIgnore

DDROWCNT
)


NB. =========================================================
ddend=: 3 : 0"0  NB.-->

NB. (ddend) ends statements and frees statement handles.
NB. Bound nouns are also erased.
NB.
NB. monad:  ddend i[0,1]Sh

clr 0
w=. y
if. -.isia w=. fat w do. errret ISI08 return. end.
if. -.w e.1{"1 CSPALL do. errret ISI04 return. end.
sh=. w

NB. free and clean up regardless of sql errors
z=. sqlfreehandle SQL_HANDLE_STMT;w
CSPALL=: CSPALL#~sh~:1{"1 CSPALL
erasebind sh

NB. now check for errors
if. sqlbad z do. errret SQL_HANDLE_STMT,sh else. DD_OK end.
)

NB. =========================================================
NB. ddfch
NB. BINDLN is _1 where data is null. If this is ignored,
NB. and the data is numeric, then the result is the original
NB. data stored by SQL, which is wrong. This fixed so that where
NB. BINDLN is _1, the result is __ (numeric), blanks (text)
NB. (ddfch) fetchs data by columns.  This verb uses binding
NB. which is the preferred method for fetching fixed length
NB. data types.  Binding cannot be used for long variable
NB. length columns.  Such columns are fetched with (ddfet)'s method.
NB.
NB. The dyad is an extension of the original ddfch verb. (x) specifies a
NB. a buffer size that overrides the (COLUMNBUF) global for the _1
NB. case.  Proper setting of this single value can often produce
NB. very significant performance improvements.
NB.
NB. monad:  blut =. ddfch ilShRows
NB.
NB.   sh=. 'select this,and,that from sometable' ddsel ch
NB.   ddfch sh     NB. one row
NB.   ddfch sh,10  NB. next 10 rows
NB.   ddfch sh,_1  NB. all remaining rows
NB.
NB. dyad:  blut =. iaBuffhint ddfch ilShRows
NB.
NB.   sh =. 'select these,here,integers from reallybigtable' ddsel ch
NB.
NB.   NB. get 1e5 rows with each fetch operation until all data is returned
NB.   100000 ddfch sh,_1

ddfch=: 3 : 0
COLUMNBUF ddfch y
:
clr 0
if. -.(isia x) *. isiu y do. errret ISI08 return. end.
'sh r'=. 2{.,y,1
if. -.sh e.1{"1 CSPALL do. errret ISI04 return. end.
r=. (r<0){r,_1  NB. tolerate negs other than _1

NB. column information needed to bind & convert
if. SQL_ERROR-:ci=. getallcolinfo sh do. errret '' return. end.
assert. 10={:@$ ci

NB. bind columns for _1 case use (x) buffer size
buf=. (_1=r){r,x
if. sqlbad z=. ci dbind sh,buf do. SQL_ERROR return. end.

NB. type conversion gerund
cv=. GCNM {~ GDX i. ; 6 {"1 ci
ty=. >6 {"1 ci

one=. 0<r
dat=. (#ci)#<0 0$0   NB. boolean is the lowest datatype, coerce empty arrays ...
if. r=0 do. dat return. end.
fetch=. sh;SQL_FETCH_NEXT;0
while.do.

  rc=. >{.sqlfetchscroll fetch
  if. sqlbad rc do. errret SQL_HANDLE_STMT,sh return. end.
  if. SQL_NO_DATA=src rc do. ddend sh break. end.

NB. actual rows in fetch
  c=. dddcnt sh

NB. collect & convert data
  z=. ''
  for_i. i.#ci do.
    n=. (i_index{cv) `:0 dddata sh,i+1


    if. _1 e. len=. dddataln sh,i+1 do.
      if. # ndx=. I. len = _1 do.
        if. 2 = 3!:0 n do.
          n=. (' '#~{:$n) ndx } n
        else.
          if. (i{ty) e. SQL_TYPE_TIMESTAMP,SQL_TYPE_DATE,SQL_TYPE_TIME,SQL_SS_TIME2,SQL_SS_TIMESTAMPOFFSET do.
            n=. ((2=UseDayNo){::DateTimeNull;EpochNull) ndx } n
          elseif. (i{ty) e. SQL_BIT do.
            n=. 0 ndx } n
          elseif. 8 = 3!:0 n do.
            n=. NumericNull ndx } n
          elseif. 4 = 3!:0 n do.
            n=. IntegerNull ndx } n
          end.
        end.
      end.
    end.
    z=. z,< n
  end.
  if. c<buf do. z=. (fat c) {.&.> z end.

  dat=. dat ,&.> z
  if. one do. if. c<buf do. ddend sh end. break. end.
end.
assert. 1= # ~. #&> dat
dat
)


NB. =========================================================
ddbind=: 3 : 0  NB.-->

NB. (ddbind) binds columns in statement result sets to J globals.
NB.
NB. monad: ddbind ilShRows
NB.
NB.   sh =. 'select * from bigtable' ddsel ch
NB.   ddbind sh,100000

COLUMNBUF ddbind y NB. default buffer row size
:
clr 0
if. -.(isia x) *. isiu y do. errret ISI08 return. end.
'sh r'=. 2{.,y,x
if. -.sh e.1{"1 CSPALL do. errret ISI04 return. end.

NB. bind columns
if. SQL_ERROR-:ci=. getallcolinfo sh do. errret ''
elseif. sqlbad ci dbind sh,r do. SQL_ERROR
elseif.do. DD_OK [ ('BINDTI_',":sh)=: ci  NB. save column info with bind nouns
end.
)


NB. =========================================================
dbind=: 4 : 0

NB. (dbind) binds columns in statement handle
NB.
NB. dyad:  btGetcolinfo bind ilShn
NB.
NB.   ci =. getallcolinfo sh
NB.   ci dbind sh,100  NB. fetch 100 rows


NB. test statement column types for bind'abilty
if. 0&e. b=. (;6{"1 x) e. SQL_COLBIND_TYPES do. errret ISI10 typeerr (-.b)#x return. end.

NB. set up and attempt to bind
dcolbind y
z=. (6 7{"1 x) bindcol (0{y),.(>: i.#x),.1{y
NB. did all columns bind?
if. *./(src ; 0{"1 z) e. DD_SUCCESS do. DD_OK else. errret ISI10 end.
)


NB. =========================================================
ddfetch=: 3 : 0  NB.-->

NB. (ddfetch) fetch data to bound nouns. No J datatype conversions
NB. are applied and the bound nouns are not modified in any way in J.
NB. To process bound nouns refer to the status BINDST_sh and BINDRR_sh
NB. nouns for status information and the actual number of rows fetched.
NB. BINDTI_sh holds type information for each column. Unlike
NB. (ddfch) this verb does not end statements that have
NB. been completely fetched. You must manage statement handles.
NB.
NB. Note: this is the fastest way to move large amounts of data into J
NB. using ODBC.
NB.
NB. monad:  ddfetch iaSh
w=. y
if. -.isia w=. fat w do. errret ISI08 return. end.
if. -.w e.1{"1 CSPALL do. errret ISI04 return. end.
if. sqlok sqlfetchscroll w;SQL_FETCH_NEXT;0 do. DD_OK else. errret SQL_HANDLE_STMT,y end.
)


NB. =========================================================
typeerr=: 4 : 0

NB. (typeerr) formats an error noun (BADTYPES) that describes
NB. columns in a statement handle that cannot be bound or fetched.
NB.
NB. dyad:  clErrmgs binderr btGetcolinfo

hd=. ;:'ColNumber ColName TypeCode SqlType'
dat=. 2 3 6 {"1 y
sqltypes=. (}.SQL_SUPPORTED_NAMES) , '**JDD UNKNOWN TYPE**'
tnames=. <"1 sqltypes {~ SQL_SUPPORTED_TYPES i. ; {:"1 dat
BADTYPES=: hd , (trbuclnb ":&.> dat) ,. dltb&.> tnames
x ,' - more error info available (2)'
)


NB. =========================================================
dddata=: 3 : 0  NB.-->
NB. (dddata) gets data bound to single column for a stmt handle.
NB.
NB. monad:  dddata ilShCol

".'BIND_',(":0{y),'_',":1{y
)

NB. =========================================================
NB. (dddataln) gets data length bound to single column for a stmt handle.
NB.
NB. monad:  dddataln ilShCol

dddataln=: 3 : 0
,".'BINDLN_',(":0{y),'_',":1{y
)


NB. =========================================================
dddcnt=: 3 : 0

NB. (dddcnt) actual number of rows in last fetch.
NB.
NB. monad:  dddcnt iaSh

".'BINDRR_',":y
)

NB. =========================================================
ddrow=: dddcnt NB. not sure which name to use...

NB. =========================================================
initodbcenv=: 3 : 0

NB. (initodbcenv) first time initialization of ODBC environment.
NB.
NB. monad: initodbcenv uuIgnore

NB. intial values
CHTR=: CHALL=: i.0  NB. all connection handles (pending transactions)
CSPALL=: 0 2$0      NB. all statement handles (connection,statement pairs)
DBMSALL=: 0 12$<''  NB. properties of connection handles
LERR=: ''           NB. last error message
ALLDM=: i. 0 3      NB. all last diagnostic messages
BADTYPES=: i. 0 0   NB. table of unbindable/ungetable columns
DDROWCNT=: 0        NB. number of rows affected by last (ddsql) command

if. 2 0-.@-:(libodbc ,' dummy > n')&cd ::cder'' do. (sminfo]]) dderr errret ISI11 return. end.
NB. PROBLEM QUESTION? the first item of z is not 0 or 1 (SQL_SUCCESS_CODES)
NB. It's not sqlbad either -  the EH handle returned in the third
NB. item does work

NB. get an environment handle (EH)
z=. sqlallochandle SQL_HANDLE_ENV;0;,0
EH=: fat >3{z
if. sqlbad z do.

  (sminfo]]) dderr errret ISI11
  return.
end.

NB. set environment attributes and ODBC version 3.0
if. sqlbad sqlsetenvattr EH;SQL_ATTR_ODBC_VERSION;SQL_OV_ODBC3;0 do.
  (sminfo]]) dderr errret ISI12
  return.
end.

NB. following added to ensure correct initialization
6!:3[0

DD_OK
)


NB. =========================================================
getcoldefs=: 3 : 0

NB. (getcoldefs) collects table column definition information for
NB. for (ddcol).
NB.
NB. monad:  getcoldefs iaSh

if. SQL_ERROR-:ci=. getallcolinfo y do. SQL_ERROR return. end.
assert. 10={:@$ ci

if. #dc=. ci getdata y,_1 do.
  (trbuclnb 3 {"1 ci) , ,&.> dc
else.
  trbuclnb 3 {"1 ci
end.

)


NB. =========================================================
endodbcenv=: 3 : 0

NB.  (endodbcenv) frees all statement, connection and environment handles.
NB.
NB.  QUESTION? is all this necessary - you would think just freeing the
NB.  environment would automatically clean up.
NB.
NB.  monad:  iaRc =. endodbcenv uuIgnore

set=. 0&= @: (4!:0)
if. set <'CHTR' do. if. #CHTR do. ddrbk CHTR end. end.
if. set <'CSPALL' do. if. #CSPALL do. ddend {:"1 CSPALL end. end.
if. set <'CHALL' do. if. #CHALL do. dddis CHALL end. end.
if. set <'EH' do. freeenv EH end.  NB. NIMP check errors?
erase ;:'CSPALL CHALL EH'
)


NB. =========================================================
ddcnm=: 3 : 0  NB.-->

NB. (ddcnm) returns a boxed list of column names in
NB. statement result sets.
NB.
NB. monad:  blcl =. ddcnm iaSh
NB.
NB.  sh=. 'select * from whatever' ddsel ch
NB.  ddcnm sh


NB. check argument
clr 0
w=. y
if. -. isia w=. fat w do. errret ISI08 return. end.
if. -.w e.1{"1 CSPALL do. errret ISI04 return. end.

NB. get column information and return names
if. SQL_ERROR-:ci=. getallcolinfo w do. errret SQL_HANDLE_STMT,w return. end.
assert. 10={:@$ ci
trbuclnb 3{"1 ci
)


NB. =========================================================
NB. COMPATIBLE? dderr accepts only empty arguments this verb
NB. accepts and ignores any argument.

dderr=: 3 : 0  NB.-->

NB. (dderr) returns the last error message (if any).  Optional
NB. (x) code displays additional error and diagnostic information.
NB.
NB. monad:  dderr uuIgnore
NB. dyad:   iaMore dderr uuIgnore

0 dderr y
:
select. x
case. 1 do. ALLDM
case. 2 do. BADTYPES
case.do. LERR
end.
)


NB. =========================================================
ddtrn=: 3 : 0  NB.-->

NB. (ddtrn) begins a transaction on connection handle (y)
NB.
NB. monad:  ddtrn iaCh

NB. test argument
clr 0
w=. fat y
if. -. isia w=. fat w do. errret ISI08 return. end.
if. -. w e. CHALL do. errret ISI03 return. end.
if. w e. CHTR do. errret ISI07 return. end.


NB. set the handle to manual commit mode
if. sqlok sqlsetconnectattr w;SQL_ATTR_AUTOCOMMIT;SQL_AUTOCOMMIT_OFF;SQL_IS_UINTEGER do.
  DD_OK [ CHTR=: CHTR,w
else.
  errret SQL_HANDLE_DBC,w
end.
)


NB. =========================================================
comrbk=: 4 : 0

NB. (comrbk) commits or rolls back transactions on connection handle (y)
NB.
NB. dyad:  iaType comrbk iaCh
NB.
NB.  SQL_COMMIT comrbk ch

NB. test argument
w=. y
if. -. isia w=. fat w do. errret ISI08 return. end.
if. -. w e. CHALL do. errret ISI03 return. end.
if. -. w e. CHTR do. errret ISI07 return. end.

NB. commit transaction
if. sqlok x transact w do.
NB. must also issue autocommit, other subsequently sql will still need ddcom or ddrbk
  if. sqlok sqlsetconnectattr w;SQL_ATTR_AUTOCOMMIT;SQL_AUTOCOMMIT_ON;SQL_IS_UINTEGER do.
    DD_OK; ''
  else.
    errret SQL_HANDLE_DBC,w
  end.
  DD_OK
else. errret SQL_HANDLE_DBC,w end.
)


NB. =========================================================
ddcom=: 3 : 0  NB.-->
clr 0
SQL_COMMIT comrbk y
)


NB. =========================================================
ddrbk=: 3 : 0  NB.-->
clr 0
SQL_ROLLBACK comrbk y
)


NB. =========================================================
NB. y is ch
NB. return 1 if inside transaction, otherwise (include  error conditions) return 0
NB. if y is _1, test for all ch
ddttrn=: 3 : 0"0
if. _1~: y do.
  if. y e. CHALL do.
    y e. CHTR
  else.
    0
  end.
else.
  0~:#CHTR
end.
)

NB. =========================================================
erasebind=: 3 : 0"0

NB. (erasebind) erases all bound nouns for statement handle (y).
NB. Exploits the nasty nature of statement numbers.
NB.
NB. monad: erasebind iuSh

if. b=. #n=. 'B' (4!:1) 0 do. *./(4!:55) n #~ +./"1 (,:'_',":,y) E. > n else. b end.
)


NB. =========================================================
dcolbind=: 3 : 0

NB. (dcolbind) declares and sets up for column binding.  In addition to
NB. data columns (dcolbind) sets up an array of status codes and a
NB. single integer that records the number of rows actually returned
NB. by the last fetch operation.
NB.
NB. monad:  dcolbind ilShRows

'sh r'=. y

NB. a column of small int status codes
bstname=. 'BINDST_',":sh
if. IF64 do.  NB. 64-bit oracle driver bug
  (bstname)=: r$2-2
else.
  (bstname)=: (r,2)$' '
end.

NB. a single integer for the actual # of rows fetched
brfname=. 'BINDRR_',":sh
(brfname)=: ,256

NB. set up statement handle for column-wise binding
et=. SQL_HANDLE_STMT,sh
if. sqlbad sqlsetstmtattr sh;SQL_ATTR_ROW_BIND_TYPE;SQL_BIND_BY_COLUMN;0 do. errret et
elseif. sqlbad sqlsetstmtattr sh;SQL_ATTR_ROW_ARRAY_SIZE;r;0 do. errret et
elseif. sqlbad sqlsetstmtattr sh;SQL_ATTR_ROW_STATUS_PTR;(iad bstname);0 do. errret et
elseif. sqlbad sqlsetstmtattr sh;SQL_ATTR_ROWS_FETCHED_PTR;(iad brfname);0 do. errret et
elseif.do. DD_OK
end.
)


NB. =========================================================
ddfet=: 3 : 0  NB.-->

NB. (ddfet) fetchs data by rows.  This verb must be used
NB. for long character and binary types.  For fixed length
NB. and short types (ddfch) is much faster.  The ODBC SQLGetData
NB. function is not well suited for J use because it forces you to loop.
NB. You must loop for each row and you must loop within each long
NB. column to collect large data objects.  When fetching data it's best
NB. to use (ddfch) on columns it can collect reserving (ddfet)
NB. only for those values that (ddfch) cannot fetch.
NB.
NB.
NB.   ch=. ddcon 'dsn=mydatabase'
NB.   sh=. 'select bigbinary from mytable where myprimarykey = 666' ddsel ch
NB.   data =. ddfet sh

clr 0
if. -. isiu y do. errret ISI08 return. end.
'sh r'=. 2{.,y,1
if. -. sh e.1{"1 CSPALL do. errret ISI04 return. end.
r=. (r<0){r,_1  NB. tolerate negs other than _1
if. SQL_ERROR-:ci=. getallcolinfo sh do.
  errret ''
else.
  z=. ,&.> ci getdata sh,r
  assert. 1= #@$&> ,z
  z
end.
)


NB. =========================================================
ddbtype=: 3 : 0

NB. (ddbtype) returns type information for nouns bound to stmt (y)
NB.
NB. monad:  ddbtype ilShCol

".'BINDTI_',":y
)


NB. =========================================================

SQL_DATA_SOURCE_NAME=: 2
SQL_DBMS_NAME=: 17
SQL_DBMS_VER=: 18
SQL_DRIVER_NAME=: 6
SQL_DRIVER_VER=: 7
SQL_SERVER_NAME=: 13
SQL_USER_NAME=: 47

strsqlgetinfo=: SQL_DATA_SOURCE_NAME,SQL_DBMS_NAME,SQL_DBMS_VER,SQL_DRIVER_NAME,SQL_DRIVER_VER,SQL_SERVER_NAME,SQL_USER_NAME

NB. =========================================================
NB. y ch
NB. charset getinfo2 ch
getinfo2=: 4 : 0
if. -. isia y=. fat y do. assert. 0 end.
ch=. y
'info chars'=. x
if. sqlbad z=. sqlgetinfo ch;info;(256#{.a.);256;(,-0) do. z return. end.
if. info e. strsqlgetinfo do.
  if. (UCS2=chars) do.
    rz=. 6&u: (<.&.-: _1{::z){. 3{::z
  elseif. do.
    rz=. (fat _1{::z){. 3{::z
  end.
else.
  rz=. (IF64{_2 _3)&ic SZI{. 3{::z
end.
rz
)

NB. =========================================================
NB. dddbms ch
NB. return datadriver;dsn;uid;server;name;ver;drvname;drvver;charset;chardiv;bugflag

dddbms=: 3 : 0  NB.-->
if. -. isia y=. fat y do. errret ISI08 return. end.
if. -.y e. CHALL do. errret ISI03 return. end.
ch=. y
clr 0
if. ch e. >0{("1) DBMSALL do.
  }.DBMSALL{~(>0{("1) DBMSALL)i.ch
  return.
end.
bugflag=. 0
chardiv=. 1  NB. some odbc driver need to divide column size to get the true column size in unicode characters
charset=. IFUNIX{OEMCP,UTF8
dsn=. ch getinfo2~ SQL_DATA_SOURCE_NAME, charset
uid=. ch getinfo2~ SQL_USER_NAME, charset
server=. ch getinfo2~ SQL_SERVER_NAME, charset
ver=. ch getinfo2~ SQL_DBMS_VER, charset
drvname=. ch getinfo2~ SQL_DRIVER_NAME, charset
drvver=. ch getinfo2~ SQL_DRIVER_VER, charset
name=. ch getinfo2~ SQL_DBMS_NAME, charset
NB. canonical name for some common database
name=. ('Microsoft SQL Server'-:name){:: name ; 'MSSQL'
name=. ('ACCESS'-:name){:: name ; 'MSACCESS'
name=. (((<3{.ver)e.'12.';'14.')*.'MSACCESS'-:name){:: name ; 'MSACEDB'
name=. ('firebird'-:tolower name){:: name ; 'Firebird'
name=. ('interbase'-:tolower name){:: name ; 'InterBase'
name=. ('oracle'-:tolower name){:: name ; 'Oracle'
name=. ('mysql'-:tolower name){:: name ; 'MYSQL'

if. drvname -: 'libtdsodbc.so' do.   NB. freetds odbc drirver for sybase/ms sqlsvr
  charset=. UTF8
  chardiv=. 4
  bugflag=. bugflag (23 b.) BUGFLAG_WCHAR_SUTF8
elseif. name -: 'SQLite' do.         NB. only sqliteodbc ver3 is supported
  charset=. UTF8
  chardiv=. 4
  bugflag=. bugflag (23 b.) BUGFLAG_LONGVARBINARY_BINARY
elseif. name -: 'MYSQL' do.
  charset=. UTF8
  chardiv=. 3
end.

if. ((<tolower drvname) e. <'aceodbc.dll') do. bugflag=. bugflag (23 b.) IF64 *. BUGFLAG_BINDPARMBIGINT end.

if. SQL_SUCCESS= >@{. cdrc=. sqlgetfunctions ch ; SQL_API_SQLBULKOPERATIONS ; ,_1 do.
  if. SQL_TRUE~: {. 3{:: cdrc do.
    bugflag=. bugflag bitor BUGFLAG_BULKOPERATIONS
  end.
else.
  bugflag=. bugflag bitor BUGFLAG_BULKOPERATIONS
end.
NB. if. ((12{.drvname) -.@-: 'libmsodbcsql') *. (<tolower drvname) -.@e. 'sqlsrv32.dll' ; 'sqlncli.dll' ; 'sqlncli10.dll' ; 'sqlncli11.dll' ; 'msodbcsql11.dll' ; 'msodbcsql13.dll' ; 'odbcjt32.dll' ; 'aceodbc.dll' ; 'odbcfb' ; 'libtdsodbc.so' do.
NB.   bugflag=. bugflag (23 b.) BUGFLAG_BULKOPERATIONS   NB. only a few drivers really support sqlbulkoperations
NB. end.

DBMSALL=: DBMSALL, y; r=. 'ODBC';dsn;uid;server;name;ver;drvname;drvver;charset;chardiv;bugflag
r
)

NB. =========================================================
ddgetconnectattr=: 4 : 0
clr 0
if. 'ODBC' -.@-: dddriver'' do. errret ISI14 return. end.
if. -. isia y=. fat y do. errret ISI08 return. end.
if. -. isia x=. fat x do. errret ISI08 return. end.
if. -.y e. CHALL do. errret ISI03 return. end.
ch=. y
attr=. x
if. sqlok z=. sqlgetconnectattra ch;x;(SZI#{.a.);SZI;(,-0) do.
  try.
    z=. (IF64{_2 _3)&ic SZI{. 3{::z
  catch.
    errret ISI08 return.
  end.
else.
  errret SQL_HANDLE_DBC,ch return.
end.
z
)

NB. =========================================================
ddsetconnectattr=: 4 : 0
clr 0
if. 'ODBC' -.@-: dddriver'' do. errret ISI14 return. end.
if. -. isia y=. fat y do. errret ISI08 return. end.
if. -. isiu x=. ,x do. errret ISI08 return. end.
if. 2~:#x do. errret ISI08 return. end.
if. -.y e. CHALL do. errret ISI03 return. end.
ch=. y
'attr val'=. x
if. sqlok z=. sqlsetconnectattra ch;attr;val;SQL_IS_UINTEGER do.
  z=. ''
else.
  errret SQL_HANDLE_DBC,ch return.
end.
z
)

NB. =========================================================
getdata=: 4 : 0

NB. (getdata) is the main sqlgetdata driver.
NB.
NB. dyad:  btGetcolinfo getdata ilShRows
NB.
NB.  ci =. getcolinfo sh
NB.  ci getdata sh,10   NB. ten rows
NB.  ci getdata sh,_1   NB. all rows in stmt

'sh r'=. y
assert. 10={:@$ x
ty=. ; 6 {"1 x

NB. quit if any unsupported datatypes
if. -.*./b=. ty e. SQL_SUPPORTED_TYPES do. errret ISI09 typeerr (-.b)#x return. end.

NB. build gerund that fetches & converts data
gf=. (SQL_SUPPORTED_TYPES i. ty){GGETV

NB. columns numbers and stmt handles
cc=. <"1 sh,.>:i.#ty

dat=. (0,#ty)$<''
if. r=0 do. dat return. end.

z=. sqlfetch sh
while.do.

  if. sqlbad rc=. >{.z do.
    errret SQL_HANDLE_STMT,sh return.
  end.
  if. SQL_NO_DATA=src rc do.
    ddend sh break.
  end.

NB. apply gerund to fetch & convert all columns
  row=. , 1 gf\cc
  if. badrow row do.
    errret ISI13 return.
  end.
  dat=. dat , 1 {&> row

  if. 0=r=. <:r do. break. end.  NB. _1 case ends on SQL_NO_DATA
  z=. sqlfetch sh
end.
dat
)
