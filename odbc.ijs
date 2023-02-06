coclass 'jdd'

IMAX=: IF64{::2147483647;9223372036854775807
IMIN=: _1+-IMAX
AutoAsync=: 0
AutoDend=: 1
DateTimeNull=: _
InitDone=: 0
IntegerNull=: IMIN
NumericNull=: __
EpochNull=: IF64{:: __ ; IMIN
FraSecond=: 0
OffsetMinute=: 0
OffsetMinute_bin=: 1&ic 0 0
UseBigInt=: 0
UseDayNo=: 0
UseNumeric=: 0
UseTrimBulkText=: 1
EH=: _1

dayns=: 86400000000000
EpochOffset=: 73048
UseErrRet=: 0
UseUnicode=: 0

SZI=: IF64{4 8
SFX=: >IF64{'32';'64'

create=: 3 : 0
InitDone=: 1
settypeinfo 0
initodbcenv 0
''
)

destroy=: 3 : 0
endodbcenv 0
codestroy''
)
3 : 0''
if. 0~: 4!:0<'PREFER_IODBC' do.
  PREFER_IODBC=. 0
end.
select. UNAME
case. 'Linux' do. libodbc=: (0-:PREFER_IODBC){::'libiodbc.so.2';'libodbc.so.2'
case. 'Darwin' do. libodbc=: (0-:PREFER_IODBC){::'libiodbc.dylib';'libodbc.dylib'
case. 'Win' do. libodbc=: 'odbc32.dll'
case. do. libodbc=: 'libodbc.so'
end.
i.0 0
)
sqlallochandle=: (libodbc, ' SQLAllocHandle s s x *x') &cd
sqlbindcol=: (libodbc, ' SQLBindCol s x s s * x *') &cd
sqlbindparameter=: (libodbc, ' SQLBindParameter s x s s s s x s * i *') &cd
sqlbulkoperations=: (libodbc, ' SQLBulkOperations s x s') &cd
sqlcancel=: (libodbc, ' SQLCancel s x') &cd
sqlcolumns=: (libodbc, ' SQLColumns s x * s * s *c s * s') &cd
sqlconnect=: (libodbc, ' SQLConnect s x *c s *c s *c s') &cd
sqldatasources=: (libodbc, ' SQLDataSources s x s *c s *s *c s *s') &cd
sqldescribecol=: (libodbc, ' SQLDescribeCol s x s *c s *s *s *x *s *s') &cd
sqldisconnect=: (libodbc, ' SQLDisconnect s x') &cd
sqldriverconnect=: (libodbc, ' SQLDriverConnect s x x *c s *c s *s s') &cd
sqldrivers=: (libodbc, ' SQLDrivers s x s *c s *s *c s *s') &cd
sqlendtran=: (libodbc, ' SQLEndTran s s x s') &cd
sqlexecdirect=: (libodbc, ' SQLExecDirect s x *c i') &cd
sqlexecdirectW=: (libodbc, ' SQLExecDirectW s x *w i') &cd
sqlexecute=: (libodbc, ' SQLExecute s x') &cd
sqlfetch=: (libodbc, ' SQLFetch s x') &cd
sqlfetchscroll=: (libodbc, ' SQLFetchScroll s x s x') &cd
sqlfreehandle=: (libodbc, ' SQLFreeHandle s s x') &cd
sqlgetfunctions=: (libodbc, ' SQLGetFunctions s x s *s') &cd
sqlgetdata=: (libodbc, ' SQLGetData s x s s * x *x') &cd
sqlgetdiagrec=: (libodbc, ' SQLGetDiagRec s s x s *c *i *c s *s') &cd
sqlgetinfo=: (libodbc, ' SQLGetInfo s x s * s *s') &cd
sqlgetstmtattr=: (libodbc, ' SQLGetStmtAttr s x i *x i *i') &cd
sqlgettypeinfo=: (libodbc, ' SQLGetTypeInfo s x s') &cd
sqlnumresultcols=: (libodbc, ' SQLNumResultCols s x *s') &cd
sqlprepare=: (libodbc, ' SQLPrepare s x *c i') &cd
sqlprepareW=: (libodbc, ' SQLPrepareW s x *w i') &cd
sqlrowcount=: (libodbc, ' SQLRowCount s x *x') &cd
sqlsetconnectattr=: (libodbc, ' SQLSetConnectAttr s x i x i') &cd
sqlsetenvattr=: (libodbc, ' SQLSetEnvAttr s x i x i') &cd
sqlsetstmtattr=: (libodbc, ' SQLSetStmtAttr s x i x i') &cd
sqltables=: (libodbc, ' SQLTables s x *c s *c s *c s *c s') &cd
sqlcolattribute=: (libodbc, ' SQLColAttribute s x s s *c s *s *') &cd
sqlgetconnectattra=: (libodbc, ' SQLGetConnectAttr s x i * i *i') &cd
sqlsetconnectattra=: (libodbc, ' SQLSetConnectAttr s x i x i') &cd
bindcol=: 4 : 0"1 1
'sh col rows longb'=. 4{.y,0
'type precision'=. x
type=. fat src type

name=. (":sh),'_',":col
bname=. 'BIND_',name
blname=. 'BINDLN_',name
(blname)=: (rows,1)$2-2
if. 0=col do.
  len=. precision [ tartype=. SQL_C_VARBOOKMARK
  (bname)=: (rows,len)$' '
elseif. type e. SQL_CHAR,SQL_VARCHAR do.
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
elseif. type e. SQL_INTEGER,SQL_SMALLINT,SQL_TINYINT do.
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
      len=. 1+ fat >:precision [ tartype=. SQL_C_CHAR
      (bname)=: (rows,len)$' '
    end.
  end.
elseif. type e. SQL_TYPE_TIMESTAMP do.
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
elseif. type e. SQL_BIT do.
  len=. 1 [ tartype=. SQL_C_BIT
  (bname)=: (rows,len)$0
elseif. type e. SQL_UNIQUEID do.
  len=. 37 [ tartype=. SQL_C_CHAR
  (bname)=: (rows,len)$' '
elseif. type e. SQL_LONGVARCHAR,SQL_LONGVARBINARY,SQL_WLONGVARCHAR do.
  if. (0<longb) *. (1=rows) do.
    len=. >: longb [ tartype=. SQL_C_BINARY
    (bname)=: (rows,len)$' '
  else.
    len=. 0 [ tartype=. SQL_C_BINARY
    (bname)=: (rows,len)$''
  end.
elseif.do. SQL_ERROR return.
end.

sqlbindcol sh;col;tartype;(vad bname);len;<vad blname
)
date7to6=: 3 : 0
d0=. 5{."1 d=. y
'd1 d2'=. |: 5 6{"1 d
d=. d0,.d1+d2%1e9
)
time4to3=: 3 : 0
d0=. 2{."1 d=. y
'd1 d2'=. |: 2 3{"1 d
d=. d0,.d1+d2%1e9
)
emptyrk1=: ''"1
fmtdts=: 3 : 0
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
if. 0=x do.
  d=. y
elseif. 1=x do.
  d1=. 3{."1 todate d0=. <. y
  d2=. 24 60 60&#:@(86400&*) y-d0
  d=. d1,.d2
elseif. 2=x do.
  d1=. 3{."1 todate <.@:(%&86400) d0=. (%&1e9)@:(+&(EpochOffset*dayns)) y
  d2=. 24 60 60&#:@(86400&|) d0
  d=. d1,.d2
end.

b=. ({:"1 d ) <: 60
s=. $d=. (4,(4#3),(3+(+*)FraSecond) j. FraSecond) ": b *"0 1 d
d=. , d
d=. s$'0'(I. ' '=d)}d
d=. ((#d)#,:'-- ::') (<a:;4 7 10 13 16)} d
(b * {:$d) {."0 1 d
)
fmtddts=: 3 : 0
d=. ddts y
0&fmtddtsn d
)

fmtddtsn=: 3 : 0
0 fmtddtsn y
:
if. 0=x do.
  d=. <.y
elseif. 1=x do.
  d=. todate <. y
elseif. 2=x do.
  d=. todate <.@:(%&86400) d0=. (%&1e9)@:(+&(EpochOffset*dayns)) y
end.

s=. $d=. (4,2#3) ": d
d=. , d
d=. s$'0'(I. ' '=d)}d
d=. ((#d)#,:'--') (<a:;4 7)} d
({:$d) {."0 1 d
)
fmttdts=: 3 : 0
d=. time4to3@:tdts y
0&fmttdtsn d
)

fmttdtsn=: 3 : 0
0 fmttdtsn y
:
if. 0=x do.
  d=. y
elseif. 1=x do.
  d=. 24 60 60&#:@(86400&*) y
elseif. 2=x do.
  d=. 24 60 60&#:@(86400&|) (%&1e9)@:(+&(EpochOffset*dayns)) y
end.

s=. $d=. (2 3,(3+(+*)FraSecond)) ": d
d=. , d
d=. s$'0'(I. ' '=d)}d
d=. ((#d)#,:'::') (<a:;2 5)} d
({:$d) {."0 1 d
)
fmttdts2=: 3 : 0
d=. time4to3@:tdts2 y
0&fmttdtsn d
)
fmtdts_num=: 3 : 0
d=. date7to6@:dts y
a=. todayno@(3&{.)"1 d
b=. ((% 1 60 60 24) #. |.@(0&,))@(3&}.)"1 d
,. a+b
)
fmtdtsx_num=: 3 : 0
d=. date7to6@:dtsx y
a=. todayno@(3&{.)"1 d
b=. ((% 1 60 60 24) #. |.@(0&,))@(3&}.)"1 d
,. a+b
)
fmtddts_num=: 3 : 0
d=. ddts y
,.todayno"1 d
)
fmttdts_num=: 3 : 0
d=. time4to3@:tdts y
,.((% 1 60 60 24) #. |.@(0&,))"1 d
)
fmttdts2_num=: 3 : 0
d=. time4to3@:tdts2 y
,.((% 1 60 60 24) #. |.@(0&,))"1 d
)
fmtdts_e=: 3 : 0
d=. dts y
a=. (-&EpochOffset)@todayno@(3&{.)"1 d
b=. (24 60 60 & #.)@(3 4 5&{)"1 d
f=. (2200<yy) +. 1800> yy=. {."1 d
,. <. EpochNull (I.f)} (dayns*a)+(b*1e9)+(6&{)"1 d
)
fmtdtsx_e=: 3 : 0
d=. dtsx y
a=. (-&EpochOffset)@todayno@(3&{.)"1 d
b=. (24 60 60 & #.)@(3 4 5&{)"1 d
f=. (2200<yy) +. 1800> yy=. {."1 d
,. <. EpochNull (I.f)} (dayns*a)+(b*1e9)+(6&{)"1 d
)
fmtddts_e=: 3 : 0
d=. ddts y
f=. (2200<yy) +. 1800> yy=. {."1 d
,. <. EpochNull (I.f)} dayns&*@(-&EpochOffset)@todayno"1 d
)
fmttdts_e=: 3 : 0
d=. tdts y
b=. (24 60 60 & #.)@(3&{.)"1 d
,. <. (b*1e9)+(3&{)"1 d
)
fmttdts2_e=: 3 : 0
d=. tdts2 y
b=. (24 60 60 & #.)@(3&{.)"1 d
,. <. (b*1e9)+(3&{)"1 d
)
errret=: 3 : 0
r=. SQL_ERROR
LERR=: ''
ALLDM=: i. 0 0
if. iscl y do.
  LERR=: y
else.
  't h'=. y
  if. SQL_ERROR-:em=. t getlasterror h do. r return.
  elseif. c=. #em do.
    LERR=: fmterr {. em
    ALLDM=: em
    if. 1<c do. LERR=: LERR , ' - more error info available (1)' end.
  end.
end.
r
)

clr=: 3 : 0
LERR=: ''
ALLDM=: i. 0 0
)
ddconfig=: 3 : 0
clr 0
rc=. 0
key=. {.keynvalue=. |: _2]\ y
value=. {:keynvalue
for_i. i.#key do.
  select. tolower i{::key
  case. 'autoasync' do. AutoAsync=: -. 0-: {.i{::value
  case. 'autodend' do. AutoDend=: -. 0-: {.i{::value
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
  case. 'numeric' do. UseNumeric=: -. 0-: {.i{::value
  case. 'integernull' do. IntegerNull=: (IntegerNull=__){::IntegerNull;IMIN [ IntegerNull=: <. {.i{::value
  case. 'numericnull' do. NumericNull=: <. {.i{::value
  case. 'trimbulktext' do. UseTrimBulkText=: -. 0-: {.i{::value
  case. do. rc=. SQL_ERROR
  end.
end.
settypeinfo 0
if. sqlbad rc do. errret ISI08 return. end.
rc
)
dddriver=: 3 : 0
clr 0
'ODBC'
)
dddrv=: 3 : 0
clr 0
d=. EH;SQL_FETCH_FIRST
n=. EH;SQL_FETCH_NEXT
r=. i.0 0
while.do.
  z=. sqldrivers d , 6$(256#' ');256;,0
  if. sqlbad z do. errret SQL_HANDLE_ENV,EH return. end.
  if. SQL_NO_DATA=rc=. src >0{z do. break. end.
  if. -. sqlok rc do. errret SQL_HANDLE_ENV,EH return. end.
  d=. n
  r=. r , 3 6{z
end.
(trbuclnb {."1 r),.nullvec2mat &.> {:"1 r
)
ddsrc=: 3 : 0
clr 0
d=. EH;SQL_FETCH_FIRST
n=. EH;SQL_FETCH_NEXT
l=. >:SQL_MAX_DSN_LENGTH
r=. i.0 0

while.do.
  z=. sqldatasources d ,(l#' ');256;(,0);(256#' ');256;,0
  if. sqlbad z do. errret SQL_HANDLE_ENV,EH return. end.
  if. SQL_NO_DATA=rc=. src >0{z do. break. end.
  if. -. sqlok rc do. errret SQL_HANDLE_ENV,EH return. end.
  d=. n
  r=. r , 3 6{z

end.
trbuclnb r
)

ddtbl=: 3 : 0
clr 0
if. -. isia y do. errret ISI08 return. end.
if. -. y e. CHALL do. errret ISI03 return. end.
if. SQL_ERROR=sh=. getstmt y do. errret SQL_HANDLE_DBC,y return. end.
if. AutoAsync do.
  rc1=. sqlsetstmtattr sh;SQL_ATTR_ASYNC_ENABLE;SQL_ASYNC_ENABLE_ON;SQL_IS_INTEGER
  if. sqlbad rc1 do. echo 'ddtbl fallback to sync' end.
end.
z=. sqltables pa=. sh;(<0);256;(<0);256;(<0);256;(<0);256
while. sqlstillexec z do. z=. sqltables pa [ usleep ASYNCDELAY end.
if. sqlok z do.
  CSPALL=: CSPALL,y,sh
  sh
else.
  r=. errret SQL_HANDLE_STMT,sh
  r [ freestmt sh return.
end.
)

ddtblx=: 3 : 0
if. SQL_ERROR-:sh=. ddtbl y do. SQL_ERROR
elseif. SQL_ERROR-:dat=. ddfch sh,_1 do. SQL_ERROR [ freestmt sh
elseif. 0<>./ #&> dat do. trctnob@:":&.> dat [ freestmt sh
elseif.do. dat [ freestmt sh
end.
)
ddtypeinfo=: 3 : 0
clr 0
if. -. isia y do. errret ISI08 return. end.
if. -. y e. CHALL do. errret ISI03 return. end.
if. SQL_ERROR=sh=. getstmt y do. errret SQL_HANDLE_DBC,y return. end.
if. sqlbad sqlsetstmtattr sh;SQL_ATTR_CURSOR_TYPE;SQL_CURSOR_FORWARD_ONLY;0 do. errret SQL_HANDLE_STMT,sh return. end.
if. sqlbad sqlsetstmtattr sh;SQL_ATTR_CONCURRENCY;SQL_CONCUR_READ_ONLY;0 do. errret SQL_HANDLE_STMT,sh return. end.
if. AutoAsync do.
  rc1=. sqlsetstmtattr sh;SQL_ATTR_ASYNC_ENABLE;SQL_ASYNC_ENABLE_ON;SQL_IS_INTEGER
  if. sqlbad rc1 do. echo 'ddtypeinfo fallback to sync' end.
end.

z=. sqlgettypeinfo pa=. sh;SQL_ALL_TYPES
while. sqlstillexec z do. z=. sqlgettypeinfo pa [ usleep ASYNCDELAY end.
if. sqlok z do.
  CSPALL=: CSPALL,y,sh
  sh
else.
  r=. errret SQL_HANDLE_STMT,sh
  r [ freestmt sh return.
end.
)
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
ddcheck=: 3 : 0
if. _1=y do. (sminfo]]) dderr $0 else. y end.
)
ddcol=: 4 : 0
clr 0
w=. y
if. -. (iscl x) *. isia w=. fat w do. errret ISI08 return. end.
if. -. w e. CHALL do. errret ISI03 return. end.
x=. ,x
if. SQL_ERROR=sh=. getstmt w do. errret SQL_HANDLE_DBC,w return. end.
if. AutoAsync do.
  rc1=. sqlsetstmtattr sh;SQL_ATTR_ASYNC_ENABLE;SQL_ASYNC_ENABLE_ON;SQL_IS_INTEGER
  if. sqlbad rc1 do. echo 'ddcol fallback to sync' end.
end.
z=. sqlcolumns pa=. sh;(<0);256;(<0);256;x;SQL_NTS;(<0);256
while. sqlstillexec z do. z=. sqlcolumns pa [ usleep ASYNCDELAY end.
if. sqlbad z do.
  r=. errret SQL_HANDLE_STMT,sh
  r [ freestmt sh return.
end.
r=. getcoldefs sh
r [ freestmt sh
)

getlasterror=: 3 : 0
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

getstmt=: 3 : 0
z=. sqlallochandle SQL_HANDLE_STMT;({.y);,0
if. sqlbad z do. SQL_ERROR else. fat >3{z end.
)

freestmt=: 3 : 0
sqlcancel y
sqlfreehandle SQL_HANDLE_STMT;y
)

freeenv=: 3 : 0
sqlfreehandle SQL_HANDLE_ENV;y
)

gc=: 0 4 6&{
tdatchar=: 3 : 0"1
z=. sqlgetdata pa=. (b0 y),SQL_C_CHAR;(SHORTBUF$' ');(>:SHORTBUF);,0
while. sqlstillexec z do. z=. sqlgetdata pa [ usleep ASYNCDELAY end.
z
)

trimdat=: 13 : '(<(0>.>2{y){.>1{y) 1} y'
datchar=: 3 : 0"1
z=. gc sqlgetdata pa=. (b0 y),SQL_C_CHAR;(SHORTBUF$' ');(>:SHORTBUF);,0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
if. sqlok z do. trimdat z else. z end.
)
datwchar=: 3 : 0"1
bufln=. >:buf=. wchar2char * SHORTBUF
z=. gc sqlgetdata pa=. (b0 y),SQL_C_CHAR;(buf$' ');bufln;,0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
z=. (<8&u: 6&u: 1:{z) 1} z
if. sqlok z do. trimdat z else. z end.
)
datdouble=: 3 : 0"1
z=. gc sqlgetdata pa=. (b0 y),SQL_C_DOUBLE;(,1.5-1.5);8;,0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
if. sqlok z do.
  if. SQL_NULL_DATA= _1{::z do.
    (<NumericNull) 1} z
  end.
else.
  z
end.
)
datinteger32=: 3 : 0"1
z=. gc sqlgetdata pa=. (b0 y),SQL_C_SLONG;(,2-2);4;,0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
if. sqlok z do.
  if. SQL_NULL_DATA= _1{::z do.
    (<IntegerNull) 1} z
  end.
else.
  z
end.
)
datinteger64=: 3 : 0"1
z=. gc sqlgetdata pa=. (b0 y),SQL_C_SLONG;(4${.a.);4;,0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
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
datbigint32=: 3 : 0"1
z=. gc sqlgetdata pa=. (b0 y),SQL_C_DOUBLE;(,1.5-1.5);8;,0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
if. sqlok z do.
  if. SQL_NULL_DATA= _1{::z do.
    (<IntegerNull) 1} z
  end.
else.
  z
end.
)
datbigint64=: 3 : 0"1
z=. gc sqlgetdata pa=. (b0 y),SQL_C_SBIGINT;(,2-2);8;,0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
if. sqlok z do.
  if. SQL_NULL_DATA= _1{::z do.
    (<IntegerNull) 1} z
  end.
else.
  z
end.
)

datbigint=: ('datbigint',(IF64*.UseBigInt){::'32';SFX)~ f.
datsmallint=: 3 : 0"1
z=. gc sqlgetdata pa=. (b0 y),SQL_C_SSHORT;(2${.a.);2;,0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
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
dattinyint=: 3 : 0"1
z=. gc sqlgetdata pa=. (b0 y),SQL_TINYINT;(1${.a.);1;,0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
if. sqlok z do.
  if. SQL_NULL_DATA= _1{::z do.
    (<IntegerNull) 1} z
  else.
    (< a. i. fat >1{z) 1} z
  end.
else.
  z
end.
)
datbit=: 3 : 0"1
z=. gc sqlgetdata pa=. (b0 y),SQL_C_BIT;(1${.a.);1;,0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
if. sqlok z do.
  if. SQL_NULL_DATA= _1{::z do.
    (<0) 1} z
  else.
    (< ({.a.) ~: fat >1{z) 1} z
  end.
else.
  z
end.
)
datreal=: 3 : 0"1
z=. gc sqlgetdata pa=. (b0 y),SQL_C_BINARY;(4${.a.);4;,0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
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
dattimestamp=: 3 : 0"1
z=. gc sqlgetdata pa=. (b0 y),SQL_C_TYPE_TIMESTAMP;(16$CNB);17;,0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
if. sqlok z do.
  if. 1=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do.
      (<DateTimeNull) 1}z
    else.
      (<fmtdts_num ,: 1{::z) 1}z
    end.
  elseif. 2=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do.
      (<EpochNull) 1}z
    else.
      (<fmtdts_e ,: 1{::z) 1}z
    end.
  elseif. 0=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do.
      (<(SQL_TIMESTAMP_LEN+(+*)FraSecond){.' ') 1}z
    else.
      (<,fmtdts ,:>1{z) 1}z
    end.
  end.
else.
  z
end.
)
datsstimestampoffset=: 3 : 0"1
z=. gc sqlgetdata pa=. (b0 y),SQL_C_SS_TIMESTAMPOFFSET;(20$CNB);21;,0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
if. sqlok z do.
  if. 1=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do.
      (<DateTimeNull) 1}z
    else.
      (<fmtdtsx_num ,: 1{::z) 1}z
    end.
  elseif. 2=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do.
      (<EpochNull) 1}z
    else.
      (<fmtdtsx_e ,: 1{::z) 1}z
    end.
  elseif. 0=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do.
      (<(SQL_TIMESTAMP_LEN+(+*)FraSecond){.' ') 1}z
    else.
      (<,fmtdtsx ,:>1{z) 1}z
    end.
  end.
else.
  z
end.
)
datdate=: 3 : 0"1
z=. gc sqlgetdata pa=. (b0 y),SQL_C_TYPE_DATE;(6$CNB);7;,-0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
if. sqlok z do.
  if. 1=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do.
      (<DateTimeNull) 1}z
    else.
      (<fmtddts_num ,: 1{::z) 1}z
    end.
  elseif. 2=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do.
      (<EpochNull) 1}z
    else.
      (<fmtddts_e ,: 1{::z) 1}z
    end.
  elseif. 0=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do.
      (<SQL_DATE_LEN{.' ') 1}z
    else.
      (<,fmtddts ,:>1{z) 1}z
    end.
  end.
else.
  z
end.
)
dattime=: 3 : 0"1
z=. gc sqlgetdata pa=. (b0 y),SQL_C_TYPE_TIME;(6$CNB);7;,-0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
if. sqlok z do.
  if. 1=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do.
      (<DateTimeNull) 1}z
    else.
      (<,fmttdts_num ,:>1{z) 1}z
    end.
  elseif. 2=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do.
      (<EpochNull) 1}z
    else.
      (<,fmttdts_e ,:>1{z) 1}z
    end.
  elseif. 0=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do.
      (<SQL_TIME_LEN{.' ') 1}z
    else.
      (<,fmttdts ,:>1{z) 1}z
    end.
  end.
else.
  z
end.
)
datsstime2=: 3 : 0"1
z=. gc sqlgetdata pa=. (b0 y),SQL_C_SS_TIME2;(12$CNB);13;,-0
while. sqlstillexec z do. z=. gc sqlgetdata pa [ usleep ASYNCDELAY end.
if. sqlok z do.
  if. 1=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do.
      (<DateTimeNull) 1}z
    else.
      (<,fmttdts2_num ,:>1{z) 1}z
    end.
  elseif. 2=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do.
      (<EpochNull) 1}z
    else.
      (<,fmttdts2_e ,:>1{z) 1}z
    end.
  elseif. 0=UseDayNo do.
    if. SQL_NULL_DATA= _1{::z do.
      (<(SQL_TIME_LEN+(+*)FraSecond){.' ') 1}z
    else.
      (<,fmttdts2 ,:>1{z) 1}z
    end.
  end.
else.
  z
end.
)
datlong=: 0&$: : (4 : 0)"1
sc=. b0 y
get=. sc,SQL_C_BINARY;(LONGBUF$' ');LONGBUF;,0

z=. sqlgetdata get
while. sqlstillexec z do. z=. sqlgetdata get [ usleep ASYNCDELAY end.
lim=. a:{ >{:z
dat=. ''
while. lim>:#dat do.
  if. sqlbad rc=. >{. z do. SQL_ERROR;'';0 return.
  elseif. sqlstillexec z do. z=. sqlgetdata get [ usleep ASYNCDELAY continue.
  elseif. SQL_NULL_DATA=src rc do. break.
  elseif. SQL_NO_DATA=src rc do. break.
  elseif. sqlok rc do.
    dat=. dat , (LONGBUF<.>{:z) {. , >4{z
    z=. sqlgetdata get
  elseif.do.
    z return.
  end.
end.
if. x do. dat=. 8&u: 6&u: dat end.
DD_OK ; dat ; #dat
)
getchar=: datchar&.>
getwchar=: datwchar&.>
getbinary=: datchar&.>
getvarbinary=: datchar&.>
getbit=: datbit&.>
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
gettinyint=: dattinyint&.>
getlongvarchar=: datlong&.>
getlongvarbinary=: datlong&.>
getwlongvarchar=: 1&datlong&.>
gettype_timestamp=: dattimestamp&.>
gettype_date=: datdate&.>
gettype_time=: dattime&.>
getss_timestampoffset=: datsstimestampoffset&.>
getss_time2=: datsstime2&.>
getss_xml=: 1&datlong&.>
getuniqueid=: datchar&.>

getempty=: 3 : 0
<DD_OK ; '' ; 0
)
iad=: 15!:14@boxopen
vad=: <@:iad
getcolinfo=: 3 : 0"1
z=. sqldescribecol pa=. (b0 y),(bs 128$' '),5#<,0
while. sqlstillexec z do. z=. sqldescribecol pa [ usleep ASYNCDELAY end.
z=. (<(fat 5{::z){.3{::z) 3}z
)
getallcolinfo=: 3 : 0
z=. sqlnumresultcols pa=. y;,0
while. sqlstillexec z do. z=. sqlnumresultcols pa [ usleep ASYNCDELAY end.
if. sqlbad z do.
  SQL_ERROR
else.
  z=. getcolinfo y,.1+i.>2{z
  z=. (<"0 src;6{"1 z)(<a:;6)}z
end.
)

SQL_DRIVER_NOPROMPT=: 0

ddcon=: 3 : 0
f=. (i.&';')({. ; }.@}.) ]
clr 0
if. -.iscl y do. errret ISI08 return. end.
usedsn=. 'dsn=' -: tolower 4{.y

if. usedsn do.
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
  z=. sqlallochandle SQL_HANDLE_DBC;EH;,0
  if. sqlbad z do. errret SQL_HANDLE_ENV,EH return. end.

  HDBC=: fat >3{z
  if. 1 e. a=. 'connection timeout=' E. tolower y do.
    ct=. ((#'connection timeout=')+{.I.a)}.y
    ct=. '{}' -.~ ct {.~ <./ ct i. ';}'
    if. (4=3!:0 ct) *. _1~:ct=. {.!._1 <. _1&". ct do.
      if. sqlbad sqlsetconnectattr HDBC;SQL_ATTR_CONNECTION_TIMEOUT;ct;SQL_IS_UINTEGER do.
        SQL_ERROR [ sqlfreehandle SQL_HANDLE_DBC;HDBC [ errret SQL_HANDLE_DBC,HDBC return.
      end.
    end.
    y=. ({.I.a){.y
  end.

  outstr=. 1024$' '
  z=. sqldriverconnect LASTCONNECT=: HDBC;0;(bs y),(bs outstr),(,0);SQL_DRIVER_NOPROMPT
  if. sqlbad z do. SQL_ERROR [ sqlfreehandle SQL_HANDLE_DBC;HDBC [ errret SQL_HANDLE_DBC,HDBC return. end.
  odsn=. ({.7{::z) {. 5{::z
end.
if. SQL_ERROR-:em=. SQL_HANDLE_DBC getlasterror HDBC do. SQL_ERROR [ sqlfreehandle SQL_HANDLE_DBC;HDBC [ errret '' return.
elseif. #em do.
  if. 0&e. ({."1 em) e. <SQLST_WARNING do.
    SQL_ERROR [ sqlfreehandle SQL_HANDLE_DBC;HDBC [ errret fmterr {.em return.
  end.
end.

CHALL=: CHALL,HDBC
dddbms HDBC
HDBC
)

dddis=: 3 : 0"0
clr 0
w=. y
if. -.isia w=. fat w do. errret ISI08 return. end.
if. -. w e. CHALL do. errret ISI03 return. end.
if. #shs=. 1{"1 CSPALL#~w=0{"1 CSPALL do. ddend shs end.
ch=. w
if. sqlbad sqldisconnect w do. errret SQL_HANDLE_DBC,ch return. end.
if. sqlbad sqlfreehandle SQL_HANDLE_DBC;y do. errret SQL_HANDLE_DBC,y return. end.
CHALL=: CHALL-.ch
CSPALL=: CSPALL#~ch~:0{"1 CSPALL
DBMSALL=: DBMSALL#~ch~:>0{("1) DBMSALL
DD_OK
)

ddsel=: 4 : 0
clr 0
if. 32=3!:0 x do.
  if. -. (0 4 e.~ 3!:0 w0=. ,y) *. *./ iscl&> x do. errret ISI08 return. end.
  if. 1=#w0 do. w0=. ({.w0)#~#x end.
  if. w0 ~:&# x do. errret ISI08 return. end.
  x0=. x
  sync=. 0
else.
  if. -.(isia w=. fat y) *. iscl x do. errret ISI08 return. end.
  if. -.w e. CHALL do. errret ISI03 return. end.
  w0=. ,w
  x0=. <x
  sync=. 1
end.
erase 'x';'y'

if. 0 e. w0 e. CHALL do. errret ISI03 return. end.
CSPALL0=. 0 0$0
sh0=. _1#~#x0
pending=. 0 5$0
for_x1. x0 do.
  x=. ,>x1
  w=. x1_index{w0
  if. SQL_ERROR=sh=. getstmt w do. errret SQL_HANDLE_DBC,w [ freestmt"0^:(*@#) sh0-._1 return. end.
  if. AutoAsync +. -.sync do.
    rc1=. sqlsetstmtattr sh;SQL_ATTR_ASYNC_ENABLE;SQL_ASYNC_ENABLE_ON;SQL_IS_INTEGER
    if. 0 [ sqlbad rc1 do. errret SQL_HANDLE_STMT,sh [ freestmt"0^:(*@#) sh0-._1 [ sqlcancel"0^:(*@#) sh0-._1 return. end.
    if. sqlbad rc1 do. echo 'ddsel fallback to sync' end.
  end.
  p=. sh;bs 7&u:^:unipa x [ unipa=. -. *./128>a.i. x
  rc=. sqlexecdirect`sqlexecdirectW@.unipa p
  if. sqlok1 rc do.
    sh0=. sh x1_index}sh0 [ CSPALL0=. CSPALL0,w,sh
  elseif. sqlstillexec rc do. pending=. pending, x1_index;unipa;p
  elseif.do.
    r=. errret SQL_HANDLE_STMT,sh
    r [ freestmt"0^:(*@#) sh,sh0-._1 [ sqlcancel"0^:(*@#) sh,sh0-._1 return.
  end.
end.
while. *@#pending do.

  fini=. 0 5$0
  for_p1. pending do.
    p=. 2}.p1 [ 'x1_index unipa'=. 2{.p1
    rc=. sqlexecdirect`sqlexecdirectW@.unipa p
    sh=. >{.p [ w=. x1_index{w0
    if. sqlok1 rc do.
      fini=. fini, p1
      sh0=. sh x1_index}sh0 [ CSPALL0=. CSPALL0,w,sh
    elseif. sqlbad rc do.
      r=. errret SQL_HANDLE_STMT,sh
      r [ freestmt"0^:(*@#) sh0-._1 [ sqlcancel"0^:(*@#) sh0-._1 return.
    elseif. sqlstillexec rc do.
    elseif.do.
      echo 'unhandled error code: ',":>{.rc
      r=. errret ISI14
      r [ freestmt"0^:(*@#) sh0-._1 [ sqlcancel"0^:(*@#) sh0-._1 return.
    end.
  end.
  pending=. pending -. fini
  if. (*@#pending) do. usleep ASYNCDELAYLONG end.

end.
CSPALL=: CSPALL, CSPALL0
{.^:sync sh0
)

transact=: 4 : 0
if. sqlok sqlendtran SQL_HANDLE_DBC;y;x do.
  DD_OK [ CHTR=: CHTR-.y
else.
  SQL_ERROR
end.
)

ddsql=: 4 : 0
clr DDROWCNT=: 0
if. 32=3!:0 x do.
  if. -. (0 4 e.~ 3!:0 w0=. ,y) *. *./ iscl&> x do. errret ISI08 return. end.
  if. 1=#w0 do. w0=. ({.w0)#~#x end.
  if. w0 ~:&# x do. errret ISI08 return. end.
  x0=. x
  sync=. 0
else.
  if. -.(isia w=. fat y) *. iscl x do. errret ISI08 return. end.
  if. -.w e. CHALL do. errret ISI03 return. end.
  w0=. ,w
  x0=. <x
  sync=. 1
end.
erase 'x';'y'

if. 0 e. w0 e. CHALL do. errret ISI03 return. end.
sh0=. 0$0
DDROWCNT=: _1#~#x0
pending=. 0 5$0
for_x1. x0 do.
  x=. ,>x1
  w=. x1_index{w0
  if. SQL_ERROR=sh=. getstmt w do. errret SQL_HANDLE_DBC,w [ freestmt"0^:(*@#) sh0 [ sqlcancel"0^:(*@#) sh0 return. end.
  if. AutoAsync +. -.sync do.
    rc1=. sqlsetstmtattr sh;SQL_ATTR_ASYNC_ENABLE;SQL_ASYNC_ENABLE_ON;SQL_IS_INTEGER
    if. 0 [ sqlbad rc1 do. errret SQL_HANDLE_STMT,sh [ freestmt"0^:(*@#) sh0 return. end.
    if. sqlbad rc1 do. echo 'ddsql fallback to sync' end.
  end.
  p=. sh;bs 7&u:^:unipa x [ unipa=. -. *./128>a.i. x
  rc=. sqlexecdirect`sqlexecdirectW@.unipa p
  if. sqlok1 rc do.
    sh0=. sh0,sh
    if. (SQL_NO_DATA=src>@{.rc) do. DDROWCNT=: 0
    elseif. sqlok z=. sqlrowcount sh;,256 do. DDROWCNT=: (fat >{:z) x1_index} DDROWCNT end.
  elseif. sqlstillexec rc do. pending=. pending, x1_index;unipa;p
  elseif.do.
    r=. errret SQL_HANDLE_STMT,sh
    r [ freestmt"0^:(*@#) sh,sh0 [ sqlcancel"0^:(*@#) sh,sh0 return.
  end.
end.
while. #pending do.

  fini=. 0 5$0
  for_p1. pending do.
    p=. 2}.p1 [ 'x1_index unipa'=. 2{.p1
    rc=. sqlexecdirect`sqlexecdirectW@.unipa p
    sh=. >@{.p [ w=. x1_index{w0
    if. sqlok1 rc do.
      if. (SQL_NO_DATA=src>@{.rc) do. DDROWCNT=: 0
      elseif. sqlok z=. sqlrowcount sh;,256 do. DDROWCNT=: (fat >{:z) x1_index} DDROWCNT end.
      fini=. fini, p1
    elseif. sqlbad rc do.
      r=. errret SQL_HANDLE_STMT,sh
      r [ freestmt"0^:(*@#) sh0 [ sqlcancel"0^:(*@#) sh0 return.
    elseif. sqlstillexec rc do.
    elseif.do.
      echo 'unhandled error code: ',":>{.rc
      r=. errret ISI14
      r [ freestmt"0^:(*@#) sh0 [ sqlcancel"0^:(*@#) sh0 return.
    end.
  end.
  pending=. pending -. fini
  if. (*@#pending) do. usleep ASYNCDELAYLONG end.

end.
for_w. ~.w0 do.
  if. -. w e. CHTR do. SQL_COMMIT transact w end.
end.
DDROWCNT=: {.^:sync DDROWCNT
DD_OK [ freestmt"0^:(*@#) sh0
)

ddcnt=: 3 : 0
DDROWCNT
)

ddend=: 3 : 0"0
clr 0
w=. y
if. -.isia w=. fat w do. errret ISI08 return. end.
if. -.w e.1{"1 CSPALL do. errret ISI04 return. end.
sh=. w
sqlcancel w
z=. sqlfreehandle SQL_HANDLE_STMT;w
CSPALL=: CSPALL#~sh~:1{"1 CSPALL
erasebind sh
if. sqlbad z do. errret SQL_HANDLE_STMT,sh else. DD_OK end.
)

ddfch=: 3 : 0
COLUMNBUF ddfch y
:
clr 0
if. 1<#@$ y do.
  if. 2~:#@$y do. errret ISI08 return. end.
  if. -.(isia x) *. isiu y do. errret ISI08 return. end.
  'sh0 r0'=. |: 2{.!.1 "1 y
  if. 0 e. sh0 e.1{"1 CSPALL do. errret ISI04 return. end.
  r0=. (r0<0)}r0,:_1
  sync=. 0
else.
  if. -.(isia x) *. isiu y do. errret ISI08 return. end.
  'sh r'=. 2{.,y,1
  if. -.sh e.1{"1 CSPALL do. errret ISI04 return. end.
  r=. (r<0){r,_1
  sh0=. ,sh [ r0=. ,r
  sync=. 1
end.

cv0=. 0$0
ty0=. 0$0
done=. 0$0
dat0=. 0$0
buf0=. 0$0
for_i. i.#sh0 do.
  sh=. i{sh0 [ r=. i{r0
  if. SQL_ERROR-:ci=. getallcolinfo sh do. errret SQL_HANDLE_STMT,sh return. end.
  assert. 10={:@$ ci
  longb=. (x<0){0,-x
  buf0=. buf0, buf=. (_1=r){r,(x<0){x,COLUMNBUF
  if. sqlbad z=. ci dbind sh,buf,longb do. SQL_ERROR return. end.

  ty0=. ty0, < ty=. >6 {"1 ci
  cv=. GCNM {~ GDX i. ; 6 {"1 ci
  if. (0<longb) *. (1=buf) do.
    cv=. (<,']') (I. ty e. SQL_LONGVARCHAR, SQL_LONGVARBINARY, SQL_WLONGVARCHAR)} cv
  end.
  cv0=. cv0, < cv

  dat=. (#ci)#<0 0$0
  done=. done, r=0
  dat0=. dat0, <dat
end.
while. 0 e. done do.
  stillexec=. 0
  for_j. I.0=done do.
    sh=. j{sh0
    fetch=. sh;SQL_FETCH_NEXT;0

    rc=. >{.sqlfetchscroll fetch
    if. sqlstillexec rc do. stillexec=. 1 continue. end.
    if. SQL_NO_DATA=src rc do. done=. 1 j}done [ ddend^:AutoDend sh [ sqlcancel sh continue. end.
    if. sqlbad rc do.
      r=. errret SQL_HANDLE_STMT,sh
      SQL_ERROR [ ddend^:AutoDend sh0 [ sqlcancel"0^:(*@#) sh0 return.
    end.
    c=. {. dddcnt sh
    cv=. j{::cv0
    ty=. j{::ty0
    z=. ''
    for_i. i.#ci do.
      n=. (i_index{cv) `:0 dddata sh,i+1
      len=. dddataln sh,i+1
      if. (1=#len) *. (SQL_NULL_DATA -.@e. len) *. (0<longb) *. (i{ty) e. SQL_LONGVARCHAR, SQL_LONGVARBINARY, SQL_WLONGVARCHAR do.
        n=. ,:({.len){.{.n
      end.
      if. SQL_NULL_DATA e. len do.
        if. # ndx=. I. len = SQL_NULL_DATA do.
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
    if. c<j{buf0 do. z=. (fat c) {.&.> z end.
    dat=. >j{dat0
    dat=. dat ,&.> z
    dat0=. (<dat) j}dat0
    if. 1 [ 0<j{r0 do. if. (0=c) +. c<j{buf0 do. done=. 1 j} done [ ddend^:AutoDend sh [ sqlcancel sh end. end.
  end.
  if. stillexec do. usleep ASYNCDELAYLONG end.
end.
assert. (1=#)@:~.@:#&> &> dat0
>@{.^:sync dat0
)

ddbind=: 3 : 0
COLUMNBUF ddbind y
:
clr 0
if. -.(isia x) *. isiu y do. errret ISI08 return. end.
'sh r'=. 2{.,y,x
if. -.sh e.1{"1 CSPALL do. errret ISI04 return. end.
if. SQL_ERROR-:ci=. getallcolinfo sh do. errret SQL_HANDLE_STMT,sh
elseif. sqlbad ci dbind sh,x,0 do. SQL_ERROR
elseif.do. DD_OK [ ('BINDTI_',":sh)=: ci
end.
)

dbind=: 4 : 0
y=. 3{.y,0
if. 0&e. b=. (;6{"1 x) e. SQL_COLBIND_TYPES do. errret ISI10 typeerr (-.b)#x return. end.
if. DD_OK-.@-:r=. dcolbind 2{.y do. r return. end.
z=. (6 7{"1 x) bindcol (2{y),.~(0{y),.(>: i.#x),.(1{y)
if. *./(src ; 0{"1 z) e. DD_SUCCESS do. DD_OK else. errret ISI10 end.
)

ddfetch=: 3 : 0
w=. y
if. -.isia w=. fat w do. errret ISI08 return. end.
if. -.w e.1{"1 CSPALL do. errret ISI04 return. end.
z=. sqlfetchscroll pa=. w;SQL_FETCH_NEXT;0
while. sqlstillexec z do. z=. sqlfetchscroll pa [ usleep ASYNCDELAYLONG end.
if. sqlok1 z do. DD_OK else. errret SQL_HANDLE_STMT,y end.
)

typeerr=: 4 : 0
hd=. ;:'ColNumber ColName TypeCode SqlType'
dat=. 2 3 6 {"1 y
sqltypes=. (}.SQL_SUPPORTED_NAMES) , '**JDD UNKNOWN TYPE**'
tnames=. <"1 sqltypes {~ SQL_SUPPORTED_TYPES i. ; {:"1 dat
BADTYPES=: hd , (trbuclnb ":&.> dat) ,. dltb&.> tnames
x ,' - more error info available (2)'
)

dddata=: 3 : 0
".'BIND_',(":0{y),'_',":1{y
)
dddataln=: 3 : 0
,".'BINDLN_',(":0{y),'_',":1{y
)

dddcnt=: 3 : 0
".'BINDRR_',":y
)
ddrow=: dddcnt
initodbcenv=: 3 : 0
CHTR=: CHALL=: i.0
CSPALL=: 0 2$0
DBMSALL=: 0 12$<''
LERR=: ''
ALLDM=: i. 0 3
BADTYPES=: i. 0 0
DDROWCNT=: 0
HDBC=: _1

if. 0=#libodbc do. dderr (sminfo]]) errret ISI11 return. end.
if. 2 0-.@-:(libodbc ,' dummy > n')&cd ::cder'' do. (sminfo]]) dderr errret ISI11 return. end.
if. _1=EH do.
  z=. sqlallochandle SQL_HANDLE_ENV;0;,0
  if. sqlbad z do.

    (sminfo]]) dderr errret ISI11
    return.
  end.
  EH_jdd_=: fat >3{z
  if. sqlbad sqlsetenvattr EH;SQL_ATTR_ODBC_VERSION;SQL_OV_ODBC3;0 do.
    (sminfo]]) dderr errret ISI12
    return.
  end.
end.
6!:3[0

DD_OK
)

getcoldefs=: 3 : 0
if. SQL_ERROR-:ci=. getallcolinfo y do. SQL_ERROR return. end.
assert. 10={:@$ ci

if. #dc=. ci getdata y,_1 do.
  (trbuclnb 3 {"1 ci) , ,&.> dc
else.
  trbuclnb 3 {"1 ci
end.

)

endodbcenv=: 3 : 0
if. *#libodbc do.
  set=. 0&= @: (4!:0)
  if. set <'CHTR' do. if. #CHTR do. ddrbk CHTR end. end.
  if. set <'CSPALL' do. if. #CSPALL do. ddend {:"1 CSPALL end. end.
  if. set <'CHALL' do. if. #CHALL do. dddis CHALL end. end.
end.
CHTR=: CHALL=: i.0
CSPALL=: 0 2$0
DBMSALL=: 0 12$<''
LERR=: ''
ALLDM=: i. 0 3
BADTYPES=: i. 0 0
DDROWCNT=: 0
HDBC=: _1
)

ddcnm=: 3 : 0
clr 0
w=. y
if. -. isia w=. fat w do. errret ISI08 return. end.
if. -.w e.1{"1 CSPALL do. errret ISI04 return. end.
if. SQL_ERROR-:ci=. getallcolinfo w do. errret SQL_HANDLE_STMT,w return. end.
assert. 10={:@$ ci
trbuclnb 3{"1 ci
)

dderr=: 3 : 0
0 dderr y
:
select. x
case. 1 do. ALLDM
case. 2 do. BADTYPES
case.do. LERR
end.
)

ddtrn=: 3 : 0
clr 0
w=. fat y
if. -. isia w=. fat w do. errret ISI08 return. end.
if. -. w e. CHALL do. errret ISI03 return. end.
if. w e. CHTR do. errret ISI07 return. end.

if. sqlok sqlsetconnectattr w;SQL_ATTR_AUTOCOMMIT;SQL_AUTOCOMMIT_OFF;SQL_IS_UINTEGER do.
  DD_OK [ CHTR=: CHTR,w
else.
  errret SQL_HANDLE_DBC,w
end.
)

comrbk=: 4 : 0
w=. y
if. -. isia w=. fat w do. errret ISI08 return. end.
if. -. w e. CHALL do. errret ISI03 return. end.
if. -. w e. CHTR do. errret ISI07 return. end.
if. sqlok x transact w do.
  if. sqlok sqlsetconnectattr w;SQL_ATTR_AUTOCOMMIT;SQL_AUTOCOMMIT_ON;SQL_IS_UINTEGER do.
    DD_OK; ''
  else.
    errret SQL_HANDLE_DBC,w
  end.
  DD_OK
else. errret SQL_HANDLE_DBC,w end.
)

ddcom=: 3 : 0
clr 0
SQL_COMMIT comrbk y
)

ddrbk=: 3 : 0
clr 0
SQL_ROLLBACK comrbk y
)

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
erasebind=: 3 : 0"0
if. b=. #n=. 'B' (4!:1) 0 do. *./(4!:55) n #~ +./"1 (,:'_',":,y) E. > n else. b end.
)

dcolbind=: 3 : 0
'sh r'=. y
bstname=. 'BINDST_',":sh
if. IF64 do.
  (bstname)=: r$2-2
else.
  (bstname)=: (r,2)$' '
end.
brfname=. 'BINDRR_',":sh
(brfname)=: ,256
et=. SQL_HANDLE_STMT,sh
if. sqlbad sqlsetstmtattr sh;SQL_ATTR_ROW_BIND_TYPE;SQL_BIND_BY_COLUMN;0 do. errret et
elseif. sqlbad sqlsetstmtattr sh;SQL_ATTR_ROW_ARRAY_SIZE;r;0 do. errret et
elseif. sqlbad sqlsetstmtattr sh;SQL_ATTR_ROW_STATUS_PTR;(iad bstname);0 do. errret et
elseif. sqlbad sqlsetstmtattr sh;SQL_ATTR_ROWS_FETCHED_PTR;(iad brfname);0 do. errret et
end.
if. sqlbad rc=. sqlgetstmtattr sh;SQL_ATTR_USE_BOOKMARKS;(,_1);SZI;(,_1) do. errret et
elseif. SQL_UB_VARIABLE = (0< {.>@{:rc){0,3{::rc do.
  if. sqlbad (SQL_C_VARBOOKMARK;10) bindcol sh,0,r do. errret et
  elseif.do. DD_OK
  end.
elseif.do. DD_OK
end.
)

ddfet=: 3 : 0
clr 0
if. -. isiu y do. errret ISI08 return. end.
'sh r'=. 2{.,y,1
if. -. sh e.1{"1 CSPALL do. errret ISI04 return. end.
mod=. _2=r
r=. (r<0){r,_1
if. SQL_ERROR-:ci=. getallcolinfo sh do.
  errret SQL_HANDLE_STMT,sh
else.
  z=. ,&.> ci getdata sh,mod{r,_2
  assert. 1= #@$&> ,z
  z
end.
)

ddbtype=: 3 : 0
".'BINDTI_',":y
)

SQL_DATA_SOURCE_NAME=: 2
SQL_DBMS_NAME=: 17
SQL_DBMS_VER=: 18
SQL_DRIVER_NAME=: 6
SQL_DRIVER_VER=: 7
SQL_SERVER_NAME=: 13
SQL_USER_NAME=: 47

strsqlgetinfo=: SQL_DATA_SOURCE_NAME,SQL_DBMS_NAME,SQL_DBMS_VER,SQL_DRIVER_NAME,SQL_DRIVER_VER,SQL_SERVER_NAME,SQL_USER_NAME
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
dddbms=: 3 : 0
if. -. isia y=. fat y do. errret ISI08 return. end.
if. -.y e. CHALL do. errret ISI03 return. end.
ch=. y
clr 0
if. ch e. >0{("1) DBMSALL do.
  }.DBMSALL{~(>0{("1) DBMSALL)i.ch
  return.
end.
bugflag=. 0
chardiv=. 1
charset=. IFUNIX{OEMCP,UTF8
dsn=. ch getinfo2~ SQL_DATA_SOURCE_NAME, charset
uid=. ch getinfo2~ SQL_USER_NAME, charset
server=. ch getinfo2~ SQL_SERVER_NAME, charset
ver=. ch getinfo2~ SQL_DBMS_VER, charset
drvname=. ch getinfo2~ SQL_DRIVER_NAME, charset
drvver=. ch getinfo2~ SQL_DRIVER_VER, charset
name=. ch getinfo2~ SQL_DBMS_NAME, charset
name=. ('Microsoft SQL Server'-:name){:: name ; 'MSSQL'
name=. ('ACCESS'-:name){:: name ; 'MSACCESS'
name=. (((<3{.ver)e.'12.';'14.')*.'MSACCESS'-:name){:: name ; 'MSACEDB'
name=. ('firebird'-:tolower name){:: name ; 'Firebird'
name=. ('interbase'-:tolower name){:: name ; 'InterBase'
name=. ('oracle'-:tolower name){:: name ; 'Oracle'
name=. ('mysql'-:tolower name){:: name ; 'MYSQL'

if. drvname -: 'libtdsodbc.so' do.
  charset=. UTF8
  chardiv=. 4
  bugflag=. bugflag (23 b.) BUGFLAG_WCHAR_SUTF8
elseif. name -: 'SQLite' do.
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
DBMSALL=: DBMSALL, y; r=. 'ODBC';dsn;uid;server;name;ver;drvname;drvver;charset;chardiv;bugflag
r
)
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
ddsetconnectattr=: 4 : 0
clr 0
if. 'ODBC' -.@-: dddriver'' do. errret ISI14 return. end.
if. -. isia y=. fat y do. errret ISI08 return. end.
if. -. isiu x=. ,x do. errret ISI08 return. end.
if. 2~:#x do. errret ISI08 return. end.
ch=. y
'attr val'=. x
if. sqlok z=. sqlsetconnectattra ch;attr;val;SQL_IS_UINTEGER do.
  z=. ''
else.
  errret SQL_HANDLE_DBC,ch return.
end.
z
)
getdata=: 4 : 0
'sh r'=. y
assert. 10={:@$ x
ty=. ; 6 {"1 x

mod=. _2=r
r=. (r<0){r,_1
if. -.*./b=. ty e. SQL_SUPPORTED_TYPES do. errret ISI09 typeerr (-.b)#x return. end.
gf=. (SQL_SUPPORTED_TYPES i. ty){GGETV
if. mod do.
  lb=. ty e. SQL_LONGVARCHAR,SQL_LONGVARBINARY,SQL_WLONGVARCHAR
  gf=. (<'getempty') (I.-.lb) } gf
end.
cc=. <"1 sh,.>:i.#ty

dat=. (0,#ty)$<''
if. r=0 do. dat return. end.

z=. sqlfetchscroll pa=. sh;SQL_FETCH_NEXT;0
while.do.

  if. sqlbad rc=. >{.z do.
    ddend^:AutoDend sh [ sqlcancel sh
    errret SQL_HANDLE_STMT,sh return.
  elseif. SQL_NO_DATA=src rc do.
    sqlcancel sh
    ddend^:AutoDend sh [ sqlcancel sh break.
  elseif. sqlstillexec rc do.
    usleep ASYNCDELAYLONG
  elseif. sqlok rc do.
    row=. , 1 gf\cc
    if. badrow row do.
      errret ISI13 return.
    end.
    dat=. dat , 1 {&> row

    if. 0=r=. <:r do. break. end.
  elseif.do.
    echo 'unhandled error code: ',":rc
    r=. errret ISI14
    r [ ddend^:AutoDend sh [ sqlcancel sh return.
  end.
  z=. sqlfetchscroll pa
end.
dat
)
ddinsemu=: 4 : 0
clr 0
if. -.(isia y) *. isbx x do. errret ISI08 return. end.
if. -.y e.CHALL do. errret ISI03 return. end.
if. 2>#x do. errret ISI08 return. end.
if. -. *./ 2>: #@$&> }.x do. errret ISI08 return. end.
if. 1<#rows=. ~. > {.@$&>}.x do. errret ISI08 return. end.
if. 0=rows=. fat rows do. SQL_NO_DATA return. end.
sql=. ,0{::x
if. SQL_ERROR-: z=. y ddcoltype~ sql do. z return. end.
'oty ty lns'=. |: _3]\;8 13 9{("1) z
flds=. 4{("1) z
tbl=. ~. 2{("1) z
if. (,a:)-:tbl do.
  if. 'select'-.@-: tolower 6{.sql0=. deb sql do. errret ISI08 return. end.
  sql0=. dlb 6}.sql0
  if. 1 e. r=. ' where ' E. s=. tolower sql0 do. sql0=. sql0{.~ r i: 1
  elseif. 1 e. r=. ' where(' E. s do. sql0=. sql0{.~ r i: 1
  elseif. 1 e. r=. ')where ' E. s do. sql0=. sql0{.~ r i: 1
  elseif. 1 e. r=. ')where(' E. s do. sql0=. sql0{.~ r i: 1
  end.
  if. 1 e. r=. ' from ' E. s=. tolower sql0 do.
    tbl=. dltb sql0}.~ a + #' from ' [[ a=. r i: 1
  elseif. 1 e. r=. ' from(' E. s do.
    tbl=. dltb sql0}.~ a + #' from(' [[ a=. r i: 1
  elseif. 1 e. r=. ')from ' E. s do.
    tbl=. dltb sql0}.~ a + #')from ' [[ a=. r i: 1
  elseif. 1 e. r=. ')from(' E. s do.
    tbl=. dltb sql0}.~ a + #')from(' [[ a=. r i: 1
  elseif. do. errret ISI08 return. end.
  tbl=. < tbl -. '+/()*,-.:;=?@\^_`{|}'''
end.
if. (1~:#tbl) +. a: e. tbl do.
  errret ISI52 return.
end.
if. (<:#x)~:#ty do.
  errret ISI50 return.
end.
inssql=. 'insert into ', (>@{.tbl), '(', (}. ; (<',') ,("0) flds), ') values (', (}. ; (#flds)#<',?'), ')'
z=. (inssql ; (|: oty,.lns,.ty) ; (}.x)) ddparm y
)

ddins=: 4 : 0
clr 0
if. -.(isia y) *. isbx x do. errret ISI08 return. end.
if. -.y e.CHALL do. errret ISI03 return. end.
'datadriver dsn uid server name ver drvname drvver charset chardiv bugflag'=. }.DBMSALL{~(>0{("1) DBMSALL)i. y
dbmsname=. name
if. bugflag (17 b.) BUGFLAG_BULKOPERATIONS do. x ddinsemu y return. end.

if. 2>#x do. errret ISI08 return. end.
if. -. *./ 2=> #@$&.>}.x do. errret ISI08 return. end.
if. 1<#rows=. ~. > {.@$&.>}.x do. errret ISI08 return. end.
if. 0=rows=. fat rows do. DD_OK return. end.

sql=. ,>0{x
of=. 1

loctran=. 0
if. y -.@e. CHTR do.
  if. sqlok sqlsetconnectattr y;SQL_ATTR_AUTOCOMMIT;SQL_AUTOCOMMIT_OFF;SQL_IS_UINTEGER do.
    loctran=. 1 [ CHTR=: CHTR, y
  end.
end.

if. SQL_ERROR=sh=. getstmt y do.
  r=. errret SQL_HANDLE_DBC,y
  if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
  r return.
end.
if. AutoAsync do.
  rc1=. sqlsetstmtattr sh;SQL_ATTR_ASYNC_ENABLE;SQL_ASYNC_ENABLE_ON;SQL_IS_INTEGER
  if. sqlbad rc1 do. echo 'ddins fallback to sync' end.
end.

arraysize=. MAXARRAYSIZE<.rows
bstname=. 'BINDST_', (cvt2str sh)
(bstname)=: (arraysize,2)${.a.

et=. SQL_HANDLE_STMT,sh
if. sqlbad sqlsetstmtattr sh;SQL_ATTR_ROW_BIND_TYPE;SQL_BIND_BY_COLUMN;0 do. rc=. errret et
elseif. sqlbad sqlsetstmtattr sh;SQL_ATTR_CURSOR_TYPE;SQL_CURSOR_DYNAMIC;0 do. rc=. errret et
elseif. sqlbad sqlsetstmtattr sh;SQL_ATTR_CONCURRENCY;SQL_CONCUR_LOCK;0 do. rc=. errret et
elseif. sqlbad sqlsetstmtattr sh;SQL_ATTR_ROW_ARRAY_SIZE;arraysize;0 do. rc=. errret et
elseif. sqlbad sqlsetstmtattr sh;SQL_ATTR_ROW_STATUS_PTR;(iad bstname);0 do. rc=. errret et
elseif.do. rc=. DD_OK
end.

if. -. DD_OK= >@{.rc do.
  erasebind sh [ freestmt sh [ r=. errret SQL_HANDLE_STMT,sh
  if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
  r return.
end.

p=. sh;bs 7&u:^:unipa sql [ unipa=. -. *./128>a.i. sql
rc=. sqlexecdirect`sqlexecdirectW@.unipa p
while. sqlstillexec z do. z=. sqlexecdirect`sqlexecdirectW@.unipa pa [ usleep ASYNCDELAYLONG end.
if. sqlbad z do.
  erasebind sh [ freestmt sh [ r=. errret SQL_HANDLE_STMT,sh
  if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
  r return.
end.

ty=. ; src&.> 6{"1 a=. getallcolinfo sh
lns=. ; src&.> 7{"1 a
if. (#x)~:of+#ty do.
  erasebind sh [ freestmt sh [ r=. errret ISI50
  if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
  r return.
end.
if. #ty do.
  ncol=. #ty
  for_brows. (-arraysize)<\i.rows do.
    nrows=. #brow=. >brows
    if. arraysize~:nrows do.
      if. sqlbad sqlsetstmtattr sh;SQL_ATTR_ROW_ARRAY_SIZE;nrows;0 do.
        erasebind sh [ freestmt sh [ r=. errret SQL_HANDLE_STMT,sh
        if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
        r return.
      end.
    end.
    for_i. i.ncol do.
      name=. (cvt2str sh),'_',":i
      bname=. 'BIND_',name
      blname=. 'BINDLN_',name
      ln=. i{lns
      select. i{ty
      case. SQL_BIGINT do.
        if. (1 4 8 2) -.@e.~ 3!:0 >(of+i){x do.
          erasebind sh [ freestmt sh [ r=. errret ISI51
          if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
          r return.
        end.
        if. (1 4 8) e.~ 3!:0 >(of+i){x do.
          if. IF64 do.
            if. UseBigInt do.
              a=. , brow&{ >(of+i){x
              if. (8=3!:0 a) *. *#b=. I. a e. NumericNull do.
                (bname)=: (2-2)&+ <. (1.1-1.1) b}a
                (blname)=: SQL_NULL_DATA b}nrows$SZI
              elseif. (1 4 e.~ 3!:0 a) *. *#b=. I. a e. IntegerNull do.
                (bname)=: (2-2)&+ <. (2-2) b}a
                (blname)=: SQL_NULL_DATA b}nrows$SZI
              elseif. do.
                (bname)=: (2-2)&+ <. brow&{ >(of+i){x
                (blname)=: nrows$SZI
              end.
              q=. sh;(>:i);SQL_C_SBIGINT;(vad bname);SZI;(<vad blname)
            else.
              a=. , brow&{ >(of+i){x
              if. (8=3!:0 a) *. *#b=. I. a e. NumericNull do.
                (bname)=: (_&<.) <. (1.1-1.1) b}a
                (blname)=: SQL_NULL_DATA b}nrows$8
              elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
                (bname)=: (_&<.) <. (2-2) b}a
                (blname)=: SQL_NULL_DATA b}nrows$8
              elseif. do.
                (bname)=: (_&<.) <. brow&{ >(of+i){x
                (blname)=: nrows$8
              end.
              q=. sh;(>:i);SQL_C_DOUBLE;(vad bname);8;(<vad blname)
            end.
          else.
            a=. , brow&{ >(of+i){x
            if. (8=3!:0 a) *. *#b=. I. a e. NumericNull do.
              (bname)=: (_&<.) <. (1.1-1.1) b}a
              (blname)=: SQL_NULL_DATA b}nrows$8
            elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
              (bname)=: (_&<.) <. (2-2) b}a
              (blname)=: SQL_NULL_DATA b}nrows$8
            elseif. do.
              (bname)=: (_&<.) <. brow&{ >(of+i){x
              (blname)=: nrows$8
            end.
            q=. sh;(>:i);SQL_C_DOUBLE;(vad bname);8;(<vad blname)
          end.
        else.
          (bname)=: ,a=. 22&{."1 brow&{ >(of+i){x
          (blname)=: nrows$#{.a
          assert. nrows = #blname~
          q=. sh;(>:i);SQL_C_CHAR;(vad bname);(#{.a);(<vad blname)
        end.
      case. SQL_INTEGER;SQL_SMALLINT;SQL_TINYINT do.
        if. (1 4 8) -.@e.~ 3!:0 >(of+i){x do.
          erasebind sh [ freestmt sh [ r=. errret ISI51
          if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
          r return.
        end.
        if. IF64 do.
          a=. , brow&{ >(of+i){x
          if. (8=3!:0 a) *. *#b=. I. a e. NumericNull do.
            (bname)=: 2 ic , (2-2)&+ <. (1.1-.1.1) b}a
            (blname)=: SQL_NULL_DATA b}nrows$4
          elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
            (bname)=: 2 ic , (2-2)&+ <. (2-2) b}a
            (blname)=: SQL_NULL_DATA b}nrows$4
          elseif. do.
            (bname)=: 2 ic , (2-2)&+ <. brow&{ >(of+i){x
            (blname)=: nrows$4
          end.
          q=. sh;(>:i);SQL_C_SLONG;(vad bname);4;(<vad blname)
        else.
          a=. , brow&{ >(of+i){x
          if. (8=3!:0 a) *. *#b=. I. a e. NumericNull do.
            (bname)=: (2-2)&+ <. (1.1-1.1) b}a
            (blname)=: SQL_NULL_DATA b}nrows$SZI
          elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
            (bname)=: (2-2)&+ <. (2-2) b}a
            (blname)=: SQL_NULL_DATA b}nrows$SZI
          elseif. do.
            (bname)=: (2-2)&+ <. brow&{ >(of+i){x
            (blname)=: nrows$SZI
          end.
          q=. sh;(>:i);SQL_C_SLONG;(vad bname);SZI;(<vad blname)
        end.
      case. SQL_DOUBLE;SQL_FLOAT;SQL_REAL;SQL_DECIMAL;SQL_NUMERIC do.
        if. (1 4 8) -.@e.~ 3!:0 >(of+i){x do.
          erasebind sh [ freestmt sh [ r=. errret ISI51
          if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
          r return.
        end.
        a=. , brow&{ >(of+i){x
        if. (8=3!:0 a) *. *#b=. I. a e. NumericNull do.
          (bname)=: (_&<.) (1.1-1.1) b}a
          (blname)=: SQL_NULL_DATA b}nrows$8
        elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
          (bname)=: (_&<.) (2-2) b}a
          (blname)=: SQL_NULL_DATA b}nrows$8
        elseif. do.
          (bname)=: , (_&<.) brow&{ >(of+i){x
          (blname)=: nrows$8
        end.
        q=. sh;(>:i);SQL_C_DOUBLE;(vad bname);8;(<vad blname)
      case. SQL_BIT do.
        if. (1 4 8) -.@e.~ 3!:0 >(of+i){x do.
          erasebind sh [ freestmt sh [ r=. errret ISI51
          if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
          r return.
        end.
        (bname)=: 0~: brow&{ >(of+i){x
        (blname)=: nrows$1
        q=. sh;(>:i);SQL_C_BIT;(vad bname);1;(<vad blname)
      case. SQL_CHAR;SQL_VARCHAR;SQL_WCHAR;SQL_WVARCHAR;SQL_BINARY;SQL_VARBINARY do.
        if. 2 -.@e.~ 3!:0 >(of+i){x do.
          erasebind sh [ freestmt sh [ r=. errret ISI51
          if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
          r return.
        end.
        (bname)=: ,a=. ln&{."1 brow&{ >(of+i){x
        if. UseTrimBulkText > (i{ty) e. SQL_BINARY,SQL_VARBINARY do.
          (blname)=: 1 >. #@dtb"1 a
        else.
          (blname)=: nrows$#{.a
        end.
        assert. nrows = #blname~
        q=. sh;(>:i);SQL_C_CHAR;(vad bname);(#{.a);(<vad blname)
      case. SQL_LONGVARCHAR do.
        if. 2 -.@e.~ 3!:0 >(of+i){x do.
          erasebind sh [ freestmt sh [ r=. errret ISI51
          if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
          r return.
        end.
        ln=. 1
        (bname)=: ,a=. ln&{."1 brow&{ >(of+i){x
        (blname)=: nrows$SQL_NULL_DATA
        q=. sh;(>:i);SQL_C_CHAR;(vad bname);(#{.a);(<vad blname)
      case. SQL_LONGVARBINARY do.
        if. 2 -.@e.~ 3!:0 >(of+i){x do.
          erasebind sh [ freestmt sh [ r=. errret ISI51
          if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
          r return.
        end.
        ln=. 1
        (bname)=: ,a=. ln&{."1 brow&{ >(of+i){x
        (blname)=: nrows$SQL_NULL_DATA
        q=. sh;(>:i);SQL_C_CHAR;(vad bname);(#{.a);(<vad blname)
      case. SQL_TYPE_DATE;SQL_TYPE_TIME;SQL_TYPE_TIMESTAMP;SQL_SS_TIME2;SQL_SS_TIMESTAMPOFFSET do.
        fm=. i{ty
        scale=. 0
        if. 1 4 8 e.~ 3!:0 data=. >(of+i){x do.
          nnul=. +/ nul=. ((2=UseDayNo){::DateTimeNull;EpochNull) = ,data
          select. i{ty
          case. SQL_TYPE_DATE do.
            prec=. 10
            if. IFTIMESTRUC do.
              a=. >(1>.UseDayNo)&date2odbc data
            else.
              a=. (_2&}.)@(4&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) >(1>.UseDayNo)&date2db("1) 0 (I. nul)} data
            end.
          case. SQL_TYPE_TIME;SQL_SS_TIME2 do.
            prec=. 8+(+*)FraSecond
            scale=. FraSecond
            if. IFTIMESTRUC do.
              a=. >(1>.UseDayNo)&(time2odbc`timex2odbc@.(SQL_SS_TIME2=i{ty)) data
            else.
              a=. (_2&}.)@(4&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) >(1>.UseDayNo)&time2db("1) 0 (I. nul)} data
            end.
          case. SQL_TYPE_TIMESTAMP;SQL_SS_TIMESTAMPOFFSET do.
            prec=. 19+(+*)FraSecond
            scale=. FraSecond
            if. IFTIMESTRUC do.
              a=. >(1>.UseDayNo)&(datetime2odbc`datetimex2odbc@.(SQL_SS_TIMESTAMPOFFSET=i{ty)) data
            else.
              a=. (_2&}.)@(5&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) >(1>.UseDayNo)&datetime2db("1) 0 (I. nul)} data
            end.
          end.
          (bname)=: ,a
          (blname)=: nrows$#{.a
          (blname)=: SQL_NULL_DATA (I. nul)} (blname)~
        elseif. 2 e.~ 3!:0 data do.
          data=. (1&u: ::])("1) data
          nnul=. +/ nul=. (*./"1 e.&'{}tsd '"1 data) +. (+./"1 '1800-01-01'&E."1 data) +. (+./"1 'NULL'&E."1 data)
          select. 3{.{.data
          case. '{d ' do. fm=. SQL_TYPE_DATE [ prec=. 10
          case. '{t ' do. fm=. SQL_TYPE_TIME [ prec=. 8+(+*)FraSecond [ scale=. FraSecond
          case. '{ts' do. fm=. SQL_TYPE_TIMESTAMP [ prec=. 19+(+*)FraSecond [ scale=. FraSecond
          case. do.
            select. i{ty
            case. SQL_TYPE_DATE do.
              prec=. 10
              if. IFTIMESTRUC do.
                a=. >0&date2odbc data
              else.
                if. -. '{' e. tolower {.("1) a=. data do.
                  a=. (_2&}.)@(4&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) ('{d '''),("1) (prec{.("1) data),("1) '''}'
                end.
              end.
            case. SQL_TYPE_TIME;SQL_SS_TIME2 do.
              prec=. 8+(+*)FraSecond
              scale=. FraSecond
              if. IFTIMESTRUC do.
                a=. >0&(time2odbc`timex2odbc@.(SQL_SS_TIME2=i{ty)) data
              else.
                if. -. '{' e. tolower {.("1) a=. data do.
                  a=. (_2&}.)@(4&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) ('{t '''),("1) (prec{.("1) data),("1) '''}'
                end.
              end.
            case. SQL_TYPE_TIMESTAMP;SQL_SS_TIMESTAMPOFFSET do.
              prec=. 19+(+*)FraSecond
              scale=. FraSecond
              if. IFTIMESTRUC do.
                a=. >0&(datetime2odbc`datetimex2odbc@.(SQL_SS_TIMESTAMPOFFSET=i{ty)) data
              else.
                if. -. '{' e. tolower {.("1) a=. data do.
                  a=. (_2&}.)@(5&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) ('{ts '''),("1) (prec{.("1) data) ,("1) '''}'
                end.
              end.
            end.
          end.
          (bname)=: ,a
          (blname)=: nrows$#{.a
          (blname)=: SQL_NULL_DATA (I. nul)} (blname)~
        elseif. do.
          erasebind sh [ freestmt sh [ r=. errret ISI51
          if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
          r return.
        end.
        if. IFTIMESTRUC do.
          q=. sh;(>:i);fm;(vad bname);(#{.a);(<vad blname)
        else.
          q=. sh;(>:i);SQL_C_CHAR;(vad bname);(#{.a);(<vad blname)
        end.
      case. do.
        erasebind sh [ freestmt sh [ r=. errret ISI51
        if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
        r return.
      end.
      if. sqlbad sqlbindcol q do.
        erasebind sh [ freestmt sh [ r=. errret SQL_HANDLE_STMT,sh
        if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
        r return.
      end.
    end.
    z=. sqlbulkoperations pa=. sh;SQL_ADD
    while. sqlstillexec z do. z=. sqlbulkoperations pa [ usleep ASYNCDELAYLONG end.
    if. SQL_SUCCESS~: src >@{. z do.
      erasebind sh [ freestmt sh [ r=. errret SQL_HANDLE_STMT,sh
      if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
      r return.
    end.
  end.
end.
erasebind sh [ freestmt sh
if. loctran do. CHTR=: CHTR-. y [ SQL_COMMIT comrbk y end.
DDROWCNT=: rows
DD_OK
)
getcolinfo1=: 3 : 0"1
z=. sqlcolattribute pa=. (b0 y),SQL_DESC_CATALOG_NAME;(bs 128#' '), (,2-2) (;<) <0
while. sqlstillexec z do. z=. sqlcolattribute pa [ usleep ASYNCDELAY end.
if. sqlbad z do.
  catalog=. ''
else.
  catalog=. dtb (fat 6{::z){.4{::z
end.
z=. sqlcolattribute pa=. (b0 y),SQL_DESC_SCHEMA_NAME;(bs 128#' '), (,2-2) (;<) <0
while. sqlstillexec z do. z=. sqlcolattribute pa [ usleep ASYNCDELAY end.
if. sqlbad z do.
  schema=. ''
else.
  schema=. dtb (fat 6{::z){.4{::z
end.
z=. sqlcolattribute pa=. (b0 y),SQL_DESC_TABLE_NAME;(bs 128#' '), (,2-2) (;<) <0
while. sqlstillexec z do. z=. sqlcolattribute pa [ usleep ASYNCDELAY end.
if. sqlbad z do.
  table=. ''
else.
  table=. dtb (fat 6{::z){.4{::z
end.
z=. sqlcolattribute pa=. (b0 y),SQL_DESC_BASE_TABLE_NAME;(bs 128#' '), (,2-2) (;<) <0
while. sqlstillexec z do. z=. sqlcolattribute pa [ usleep ASYNCDELAY end.
if. sqlbad z do.
  org_table=. ''
else.
  org_table=. dtb (fat 6{::z){.4{::z
end.
z=. sqlcolattribute pa=. (b0 y),SQL_DESC_BASE_COLUMN_NAME;(bs 128#' '), (,2-2) (;<) <0
while. sqlstillexec z do. z=. sqlcolattribute pa [ usleep ASYNCDELAY end.
if. sqlbad z do.
  org_column=. ''
else.
  org_column=. dtb (fat 6{::z){.4{::z
end.
z=. sqlcolattribute pa=. (b0 y),SQL_DESC_TYPE_NAME;(bs 128#' '), (,2-2) (;<) <0
while. sqlstillexec z do. z=. sqlcolattribute pa [ usleep ASYNCDELAY end.
if. sqlbad z do.
  typename=. ''
else.
  typename=. dtb (fat 6{::z){.4{::z
end.
'colnum colname coltype colsize decimal nullable'=. 2 3 6 7 8 9{getcolinfo y
z=. ,&.> catalog;schema;table;org_table;colname;org_column;colnum;typename;coltype;colsize;decimal;nullable;'';coltype;0
)
getallcolinfo1=: 4 : 0
ch=. y [ sh=. x
z=. sqlnumresultcols pa=. sh;,0
while. sqlstillexec z do. sqlnumresultcols pa [ usleep ASYNCDELAY end.
if. sqlbad z do.
  SQL_ERROR
else.
  z=. getcolinfo1 sh,.1+i. 2{::z
end.
z
)
ddcolinfo=: 3 : 0
clr 0
if. -. isia y=. fat y do. errret ISI08 return. end.
if. -.y e. 1{("1) CSPALL do. errret ISI04 return. end.
sh=. y
ch=. (0{("1) CSPALL){~(1{("1) CSPALL)i.{.sh
if. SQL_ERROR-:ci=. sh getallcolinfo1 ch do.
  z=. errret SQL_HANDLE_STMT,sh
else.
  assert. 15={:@$ci
  assert. 1= #@$&> ,ci
  z=. ci
end.
z
)
ddcoltype=: 4 : 0
clr 0
if. 32=3!:0 x do.
  if. -. (0 4 e.~ 3!:0 w0=. ,y) *. *./ iscl&> x do. errret ISI08 return. end.
  if. 1=#w0 do. w0=. ({.w0)#~#x end.
  if. w0 ~:&# x do. errret ISI08 return. end.
  x0=. x
  sync=. 0
else.
  if. -.(isia w=. fat y) *. iscl x do. errret ISI08 return. end.
  if. -.w e. CHALL do. errret ISI03 return. end.
  w0=. ,w
  x0=. <x
  sync=. 1
end.
erase 'x';'y'

if. 0 e. w0 e. CHALL do. errret ISI03 return. end.
sh0=. 0$0
pending=. 0 5$0
for_x1. x0 do.
  x=. ,>x1
  w=. x1_index{w0
  if. SQL_ERROR=sh=. getstmt w do. errret SQL_HANDLE_DBC,w [ freestmt"0^:(*@#sh0) sh0 return. end.
  if. AutoAsync +. -.sync do.
    rc1=. sqlsetstmtattr sh;SQL_ATTR_ASYNC_ENABLE;SQL_ASYNC_ENABLE_ON;SQL_IS_INTEGER
    if. 0 [ sqlbad rc1 do. errret SQL_HANDLE_STMT,sh [ freestmt"0^:(*@#sh0) sh0 return. end.
    if. sqlbad rc1 do. echo 'ddcoltype fallback to sync' end.
  end.
  p=. sh;bs 7&u:^:unipa x [ unipa=. -. *./128>a.i. x
  rc=. sqlexecdirect`sqlexecdirectW@.unipa p
  if. -. sqlbad rc do.
    sh0=. sh0, sh
    if. sqlok rc do.
    elseif. sqlstillexec rc do. pending=. pending, x1_index;unipa;p
    elseif.do.
      r=. errret SQL_HANDLE_STMT,sh
      r [ freestmt"0^:(*@#) sh,sh0 [ sqlcancel"0^:(*@#) sh,sh0 return.
    end.
  else.
    r=. errret SQL_HANDLE_STMT,sh
    r [ freestmt"0^:(*@#) sh,sh0 [ sqlcancel"0^:(*@#) sh,sh0 return.
  end.
end.
z=. (#sh0)#<''
while. #pending do.

  fini=. 0 5$0
  for_p1. pending do.
    p=. 2}.p1 [ 'x1_index unipa'=. 2{.p1
    rc=. sqlexecdirect`sqlexecdirectW@.unipa p
    if. sqlok rc do.
      fini=. fini, p1
      w=. x1_index{w0
      if. SQL_ERROR-:ci=. sh getallcolinfo1 w do.
        r=. errret SQL_HANDLE_STMT,sh
        r [ freestmt"0^:(*@#) sh0 [ sqlcancel"0^:(*@#) sh0 return.
      else.
        assert. 15={:@$ci
        assert. 1= #@$&> ,ci
        z=. (<ci) x1_index} z
        freestmt sh [ sqlcancel sh
      end.
    elseif. sqlbad rc do.
      r=. errret SQL_HANDLE_STMT,>{.p
      r [ freestmt"0^:(*@#) sh0 [ sqlcancel"0^:(*@#) sh0 return.
    elseif. sqlstillexec rc do.
    elseif.do.
      echo 'unhandled error code: ',":>{.rc
      r=. errret ISI14
      r [ freestmt"0^:(*@#) sh0 [ sqlcancel"0^:(*@#) sh0 return.
    end.
  end.
  pending=. pending -. fini
  if. (*@#pending) do. usleep ASYNCDELAYLONG end.

end.
>@{.^:sync z
)
ddsparm=: 4 : 0
clr 0
if. -.(isiu y) *. (isbx x) do. errret ISI08 return. end.
if. -.y e.CHALL do. errret ISI03 return. end.
if. 2>#x do. errret ISI08 return. end.
sql=. 0{::x
if. -.(iscl sql) do. errret ISI08 return. end.
if. ''-:table=. 0{:: tp=. parsesqlparm sql do. errret ISI08 return. end.
if. tp ~:&# x do. errret ISI08 return. end.
sql2=. 'select ', (}. ; (<',') ,&.> (}.tp)), ' from ', table, ' where 1=0'
if. SQL_ERROR-: z=. y ddcoltype~ sql2 do. z return. end.
'oty ty lns'=. |: _3]\;8 13 9{("1) z
a=. (2 131072 262144 e.~ 3!:0)&> x1=. }.x
b=. (2>(#@$))&> x1
if. 1 e. r=. a *. b do.
  x=. (,:@:,&.> (1+I.r){x) (1+I.r)}x
end.
y ddparm~ (<|:oty,.lns,.ty) ,&.(1&|.) x
)
ddparm=: 4 : 0
clr 0
if. -.(isiu y) *. (isbx x) do. errret ISI08 return. end.
if. -.y e.CHALL do. errret ISI03 return. end.
if. 3>#x do. errret ISI08 return. end.
sql=. ,>0{x
tyln=. >1{x
if. -.(iscl sql) *. (isiu tyln) do. errret ISI08 return. end.
if. 1 e. 2< #@$&> 2}.x do. errret ISI08 return. end.
if. 1 < #@:~. #&> 2}.x do. errret ISI08 return. end.
f=. >x{~ of=. 2
arraysize=. nrows=. #f
ty=. ''
if. 2=$$tyln do.
  if. 2=#tyln do.
    'sqlty lns'=. tyln
  elseif. 3=#tyln do.
    'sqlty lns ty'=. tyln
  elseif. do.
    assert. 0
  end.
else.
  sqlty=. tyln [ lns=. (#tyln)#_2
end.
if. ''-:ty do.
  ty=. sqlty
end.

if. (#x) ~: of+#ty do. errret ISI50 return. end.
if. 0=nrows do. SQL_NO_DATA return. end.

loctran=. 0
if. y -.@e. CHTR do.
  if. sqlok sqlsetconnectattr y;SQL_ATTR_AUTOCOMMIT;SQL_AUTOCOMMIT_OFF;SQL_IS_UINTEGER do.
    loctran=. 1 [ CHTR=: CHTR, y
  end.
end.

if. SQL_ERROR=sh=. getstmt y do.
  r= errret SQL_HANDLE_DBC,y
  if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
  r return.
end.
if. AutoAsync do.
  rc1=. sqlsetstmtattr sh;SQL_ATTR_ASYNC_ENABLE;SQL_ASYNC_ENABLE_ON;SQL_IS_INTEGER
  if. sqlbad rc1 do. echo 'ddparm fallback to sync' end.
end.


'datadriver dsn uid server name ver drvname drvver charset chardiv bugflag'=. }.DBMSALL{~(>0{("1) DBMSALL)i. y
dbmsname=. name
ncol=. #ty
bytelen=. ''
for_i. i.ncol do.
  name=. (cvt2str sh),'_',":i
  bname=. 'BIND_',name
  blname=. 'BINDLN_',name
  (blname)=: 2-2
  select. i{ty
  case. SQL_BIGINT do.
    if. (1 4 8) e.~ 3!:0 >(of+i){x do.
      try.
        if. (-. IF64 *. UseBigInt) do.
          a=. , >(of+i){x
        else.
          a=. , >(of+i){x
        end.
      catch.
        erasebind sh [ freestmt sh [ r=. errret ISI51
        if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
        r return.
      end.
      if. IF64 do.
        if. UseBigInt do.
          if. (IF64*.(SQL_BIGINT~:i{ty)+.(0~:bugflag (17 b.) BUGFLAG_BINDPARMBIGINT)) do.
            if. (8=3!:0 a) *. *#b=. I. a e. NumericNull do.
              (bname)=: 2&ic (2-2) + <. (1.1-1.1) b}a
              (blname)=: SQL_NULL_DATA b}nrows$bl=. 4
            elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
              (bname)=: 2&ic (2-2) + <. (2-2) b}a
              (blname)=: SQL_NULL_DATA b}nrows$bl=. 4
            elseif. do.
              (bname)=: 2&ic (2-2) + <. a
              (blname)=: nrows$bl=. 4
            end.
          else.
            if. (8=3!:0 a) *. *#b=. I. a e. NumericNull do.
              (bname)=: (2-2) + <. (1.1-1.1) b}a
              (blname)=: SQL_NULL_DATA b}nrows$bl=. SZI
            elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
              (bname)=: (2-2) + <. (2-2) b}a
              (blname)=: SQL_NULL_DATA b}nrows$bl=. SZI
            elseif. do.
              (bname)=: (2-2) + <. a
              (blname)=: nrows$bl=. SZI
            end.
          end.
          bytelen=. bytelen, bl
          q=. sh;(>:i);SQL_PARAM_INPUT;((IF64*.(SQL_BIGINT=i{ty)*.(0=bugflag (17 b.) BUGFLAG_BINDPARMBIGINT)){SQL_C_SLONG, SQL_C_SBIGINT);((IF64*.(SQL_BIGINT=i{ty)*.(0=bugflag (17 b.) BUGFLAG_BINDPARMBIGINT)){SQL_INTEGER, SQL_BIGINT);0;0;(vad bname);bl;(<vad blname)
        else.
          if. (8=3!:0 a) *. *#b=. I. a e. NumericNull do.
            (bname)=: (_&<.) <. (1.1-1.1) b}a
            (blname)=: SQL_NULL_DATA b}nrows$bl=. 8
          elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
            (bname)=: (_&<.) <. (2-2) b}a
            (blname)=: SQL_NULL_DATA b}nrows$bl=. 8
          elseif. do.
            (bname)=: (_&<.) <. a
            (blname)=: nrows$bl=. 8
          end.
          bytelen=. bytelen, bl
          q=. sh;(>:i);SQL_PARAM_INPUT;SQL_C_DOUBLE;SQL_BIGINT;0;0;(vad bname);0;(<vad blname)
        end.
      else.
        if. (8=3!:0 a) *. *#b=. I. a e. NumericNull do.
          (bname)=: (2-2) + <. (1.1-1.1) b}a
          (blname)=: SQL_NULL_DATA b}nrows$bl=. SZI
        elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
          (bname)=: (2-2) + <. (2-2) b}a
          (blname)=: SQL_NULL_DATA b}nrows$bl=. SZI
        elseif. do.
          (bname)=: (2-2) + <. a
          (blname)=: nrows$bl=. SZI
        end.
        bytelen=. bytelen, bl
        q=. sh;(>:i);SQL_PARAM_INPUT;SQL_C_SLONG;SQL_INTEGER;0;0;(vad bname);0;(<vad blname)
      end.
    else.
      if. 2~:$$a=. (1&u: ::]) >(of+i){x do. a=. ,:@, a end.
      if. -. isca a do.
        erasebind sh [ freestmt sh [ r=. errret ISI51
        if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
        r return.
      end.
      (bname)=: 22&{.("1) a
      (blname)=: nrows$22
      assert. nrows = #blname~
      bl=. 22
      bytelen=. bytelen, bl
      q=. sh;(>:i);SQL_PARAM_INPUT;SQL_C_CHAR;SQL_BIGINT;(22);0;(vad bname);bl;(<vad blname)
    end.
  case. SQL_TINYINT;SQL_SMALLINT;SQL_INTEGER do.
    try.
      a=. , >(of+i){x
    catch.
      erasebind sh [ freestmt sh [ r=. errret ISI51
      if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
      r return.
    end.
    if. IF64 do.
      if. (8=3!:0 a) *. *#b=. I. a e. NumericNull do.
        (bname)=: 2&ic (2-2) + <. (1.1-1.1) b}a
        (blname)=: SQL_NULL_DATA b}nrows$bl=. 4
      elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
        (bname)=: 2&ic (2-2) + <. (2-2) b}a
        (blname)=: SQL_NULL_DATA b}nrows$bl=. 4
      elseif. do.
        (bname)=: 2&ic (2-2) + <. a
        (blname)=: nrows$bl=. 4
      end.
      bytelen=. bytelen, bl
      q=. sh;(>:i);SQL_PARAM_INPUT;SQL_C_SLONG;SQL_INTEGER;0;0;(vad bname);0;(<vad blname)
    else.
      if. (8=3!:0 a) *. *#b=. I. a e. NumericNull do.
        (bname)=: (2-2) + <. (1.1-1.1) b}a
        (blname)=: SQL_NULL_DATA b}nrows$bl=. SZI
      elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
        (bname)=: (2-2) + <. (2-2) b}a
        (blname)=: SQL_NULL_DATA b}nrows$bl=. SZI
      elseif. do.
        (bname)=: (2-2) + <. a
        (blname)=: nrows$bl=. SZI
      end.
      bytelen=. bytelen, bl
      q=. sh;(>:i);SQL_PARAM_INPUT;SQL_C_SLONG;SQL_INTEGER;0;0;(vad bname);0;(<vad blname)
    end.
  case. SQL_DOUBLE;SQL_FLOAT;SQL_REAL;SQL_DECIMAL;SQL_NUMERIC do.
    try.
      a=. , >(of+i){x
      if. (8=3!:0 a) *. *#b=. I. a e. NumericNull do.
        (bname)=: (_&<.) (1.1-1.1) b}a
        (blname)=: SQL_NULL_DATA b}nrows$bl=. 8
      elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
        (bname)=: (_&<.) (2-2) b}a
        (blname)=: SQL_NULL_DATA b}nrows$bl=. 8
      elseif. do.
        (bname)=: (_&<.) a
        (blname)=: nrows$bl=. 8
      end.
    catch.
      erasebind sh [ freestmt sh [ r=. errret ISI51
      if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
      r return.
    end.
    bytelen=. bytelen, bl
    q=. sh;(>:i);SQL_PARAM_INPUT;SQL_C_DOUBLE;SQL_DOUBLE;0;0;(vad bname);0;(<vad blname)
  case. SQL_BIT do.
    if. 2~:$$a=. >(of+i){x do. a=. ,:@, a end.
    if. 1 4 8 -.@e.~ 3!:0 a do.
      erasebind sh [ freestmt sh [ r=. errret ISI51
      if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
      r return.
    end.
    (bname)=: 0~:a
    (blname)=: nrows$bl=. 1
    bytelen=. bytelen, bl
    q=. sh;(>:i);SQL_PARAM_INPUT;SQL_C_BIT;SQL_BIT;(1);0;(vad bname);(1);(<vad blname)
  case. SQL_BINARY;SQL_VARBINARY do.
    if. 2~:$$a=. (1&u: ::]) >(of+i){x do. a=. ,:@, a end.
    if. -. isca a do.
      erasebind sh [ freestmt sh [ r=. errret ISI51
      if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
      r return.
    end.
    if. _2 ~: i{lns do. colsize=. i{lns [ a=. (({:@$a)<.i{lns){."1 a else. colsize=. {:@$a end.
    (bname)=: a
    if. {:@$a do. (blname)=: nrows$bl=. {:@$a else. (blname)=: nrows$SQL_NULL_DATA end.
    bytelen=. bytelen, bl
    q=. sh;(>:i);SQL_PARAM_INPUT;SQL_C_BINARY;SQL_VARBINARY;(1>.colsize);0;(vad bname);(1>.colsize);(<vad blname)
  case. SQL_CHAR;SQL_VARCHAR;SQL_WCHAR;SQL_WVARCHAR do.
    if. 2~:$$a=. (1&u: ::]) >(of+i){x do. a=. ,:@, a end.
    if. -. isca a do.
      erasebind sh [ freestmt sh [ r=. errret ISI51
      if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
      r return.
    end.
    if. _2 ~: i{lns do. colsize=. i{lns [ a=. (({:@$a)<.i{lns){.("1) a else. colsize=. {.@{:@$a end.
    if. 0=colsize do. colsize=. 1 [ a=. (1,~ {.@$a)$u:' ' end.
    (bname)=: (1+colsize)&{.("1) a
    if. colsize do.
      if. UseTrimBulkText do.
        (blname)=: 1 >. #@dtb@(colsize&{.)("1) a
      else.
        (blname)=: nrows$colsize
      end.
      assert. nrows = #blname~
      bl=. 1+colsize
    else.
      (blname)=: nrows$SQL_NULL_DATA [ bl=. SZI
    end.
    bytelen=. bytelen, bl
    q=. sh;(>:i);SQL_PARAM_INPUT;SQL_C_CHAR;SQL_VARCHAR;(colsize);0;(vad bname);bl;(<vad blname)
  case. SQL_TYPE_DATE;SQL_TYPE_TIME;SQL_TYPE_TIMESTAMP;SQL_SS_TIME2;SQL_SS_TIMESTAMPOFFSET do.
    fm=. i{ty
    scale=. 0
    if. 1 4 8 e.~ 3!:0 data=. >(of+i){x do.
      nnul=. +/ nul=. ((2=UseDayNo){::DateTimeNull;EpochNull) = ,data
      select. i{ty
      case. SQL_TYPE_DATE do.
        prec=. 10
        if. IFTIMESTRUC do.
          a=. >(1>.UseDayNo)&date2odbc data
        else.
          a=. (_2&}.)@(4&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) >(1>.UseDayNo)&date2db("1) 0 (I. nul)} data
        end.
      case. SQL_TYPE_TIME;SQL_SS_TIME2 do.
        prec=. 8+(+*)FraSecond
        scale=. FraSecond
        if. IFTIMESTRUC do.
          a=. >(1>.UseDayNo)&(time2odbc`timex2odbc@.(SQL_SS_TIME2=i{ty)) data
        else.
          a=. (_2&}.)@(4&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) >(1>.UseDayNo)&time2db("1) 0 (I. nul)} data
        end.
      case. SQL_TYPE_TIMESTAMP;SQL_SS_TIMESTAMPOFFSET do.
        prec=. 19+(+*)FraSecond
        scale=. FraSecond
        if. IFTIMESTRUC do.
          a=. >(1>.UseDayNo)&(datetime2odbc`datetimex2odbc@.(SQL_SS_TIMESTAMPOFFSET=i{ty)) data
        else.
          a=. (_2&}.)@(5&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) >(1>.UseDayNo)&datetime2db("1) 0 (I. nul)} data
        end.
      end.
      (blname)=: nrows$bl=. {:@$a [ nrows=. {.@$ a
      (blname)=: SQL_NULL_DATA (I. nul)} (blname)~
    elseif. 2 e.~ 3!:0 data do.
      data=. (1&u: ::])("1) data
      nnul=. +/ nul=. (*./"1 e.&'{}tsd '"1 data) +. (+./"1 '1800-01-01'&E."1 data) +. (+./"1 '1900-01-01'&E."1 data) +. (+./"1 'NULL'&E."1 data)
      select.<3{.{.data
      case. <'{d ' do. fm=. SQL_TYPE_DATE [ prec=. 10
      case. <'{t ' do. fm=. SQL_TYPE_TIME [ prec=. 8+(+*)FraSecond [ scale=. FraSecond
      case. <'{ts' do. fm=. SQL_TYPE_TIMESTAMP [ prec=. 19+(+*)FraSecond [ scale=. FraSecond
      case. do.
        select. i{ty
        case. SQL_TYPE_DATE do.
          prec=. 10
          if. IFTIMESTRUC do.
            a=. >0&date2odbc("1) data
          else.
            if. -. '{' e. tolower {.("1) a=. data do.
              a=. (_2&}.)@(4&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) ('{d '''),("1) (prec{.("1) data),("1) '''}'
            end.
          end.
        case. SQL_TYPE_TIME;SQL_SS_TIME2 do.
          prec=. 8+(+*)FraSecond
          scale=. FraSecond
          if. IFTIMESTRUC do.
            a=. >0&(time2odbc`timex2odbc@.(SQL_SS_TIME2=i{ty)) data
          else.
            if. -. '{' e. tolower {.("1) a=. data do.
              a=. (_2&}.)@(4&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) ('{t '''),("1) (prec{.("1) data),("1) '''}'
            end.
          end.
        case. SQL_TYPE_TIMESTAMP;SQL_SS_TIMESTAMPOFFSET do.
          prec=. 19+(+*)FraSecond
          scale=. FraSecond
          if. IFTIMESTRUC do.
            a=. >0&(datetime2odbc`datetimex2odbc@.(SQL_SS_TIMESTAMPOFFSET=i{ty)) data
          else.
            if. -. '{' e. tolower {.("1) a=. data do.
              a=. (_2&}.)@(5&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) ('{ts '''),("1) (prec{.("1) data) ,("1) '''}'
            end.
          end.
        end.
      end.
      (blname)=: nrows$bl=. {:@$a [ nrows=. {.@$ a
      (blname)=: SQL_NULL_DATA (I. nul)} (blname)~
    elseif. do.
      erasebind sh [ freestmt sh [ r=. errret ISI51
      if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
      r return.
    end.
    (bname)=: a
    bytelen=. bytelen, bl
    if. IFTIMESTRUC do.
      q=. sh;(>:i);SQL_PARAM_INPUT;fm;fm;prec;scale;(vad bname);({:@$a);(<vad blname)
    else.
      q=. sh;(>:i);SQL_PARAM_INPUT;SQL_C_CHAR;fm;prec;scale;(vad bname);({:@$a);(<vad blname)
    end.
  case. SQL_LONGVARBINARY do.
    if. 2~:$$a=. >(of+i){x do. a=. ,:@, a end.
    if. 0=#,a do. a=. ($a)$'' end.
    if. -. isca a do.
      erasebind sh [ freestmt sh [ r=. errret ISI51
      if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
      r return.
    end.
    (bname)=: a
    (blname)=: nrows$bl=. {:@$a
    bytelen=. bytelen, bl
    q=. sh;(>:i);SQL_PARAM_INPUT;SQL_C_BINARY;SQL_LONGVARBINARY;(1>.{:@$a);0;(vad bname);(1>.{:@$a);(<vad blname)
  case. SQL_LONGVARCHAR do.
    if. 2~:$$a=. 1&u: >(of+i){x do. a=. ,:@, a end.
    if. -. isca a do.
      erasebind sh [ freestmt sh [ r=. errret ISI51
      if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
      r return.
    end.
    (bname)=: a
    (blname)=: nrows$bl=. {:@$a
    bytelen=. bytelen, bl
    q=. sh;(>:i);SQL_PARAM_INPUT;SQL_C_CHAR;SQL_LONGVARCHAR;(1>.{:@$a);0;(vad bname);(1>.{:@$a);(<vad blname)
  case. do.
    erasebind sh [ freestmt sh [ r=. errret ISI51
    if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
    r return.
  end.
  z=. sqlbindparameter q
  if. sqlbad z do.
    erasebind sh [ freestmt sh [ r=. errret SQL_HANDLE_STMT,sh
    if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
    r return.
  end.
end.
p=. sh;bs 7&u:^:unipa sql [ unipa=. -. *./128>a.i. sql
rc=. sqlprepare`sqlprepareW@.unipa p
while. sqlstillexec z do. z=. sqlprepare`sqlprepareW@.unipa pa [ usleep ASYNCDELAYLONG end.
if. sqlbad z do.
  erasebind sh [ freestmt sh [ r=. errret SQL_HANDLE_STMT,sh
  if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
  r return.
end.
rowcnt=. 0
k=. 0
while. k<nrows do.
  if. 0<k do.
    for_i. i.ncol do.
      if. 0<i{bytelen do.
        name=. (cvt2str sh),'_',":i
        bname=. 'BIND_',name
        blname=. 'BINDLN_',name
        v=. iad bname
        (memr v, (k*i{bytelen), i{bytelen) memw v, 0, i{bytelen
        v=. iad blname
        (memr v, (SZI*k), SZI) memw v, 0, SZI
      end.
    end.
  end.
  z=. sqlexecute pa=. <sh
  while. sqlstillexec z do. z=. sqlexecute pa [ usleep ASYNCDELAYLONG end.
  if. sqlbad z do.
    erasebind sh [ freestmt sh [ r=. errret SQL_HANDLE_STMT,sh
    if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
    r return.
  end.
  if. sqlok z=. sqlrowcount sh;,256 do. rowcnt=. rowcnt + fat >{:z end.
  k=. >:k
end.
erasebind sh [ freestmt sh
if. loctran do. CHTR=: CHTR-. y [ SQL_COMMIT comrbk y end.
DDROWCNT=: rowcnt
DD_OK
)
ISI01=: 'ISI01 Too many connections'
ISI02=: 'ISI02 Too many statements'
ISI03=: 'ISI03 Bad connection handle'
ISI04=: 'ISI04 Bad statement handle'
ISI05=: 'ISI05 Not a select command'
ISI06=: 'ISI06 Transactions not supported'
ISI07=: 'ISI07 Bad transaction state'
ISI08=: 'ISI08 Bad arguments'
ISI09=: 'ISI09 Unsupported data type'
ISI10=: 'ISI10 Unable to bind all columns'
ISI11=: 'ISI11 Unable to initialize ODBC environment'
ISI12=: 'ISI12 Unable to set 3.x ODBC version'
ISI13=: 'ISI13 SQL errors fetching row'
ISI14=: 'ISI14 Not implemented'
ISI15=: 'ISI15 Driver limitation'
ISI16=: 'ISI16 Shared library error'
ISI17=: 'ISI17 Out of memory'
ISI18=: 'ISI18 Database file not found'
ISI19=: 'ISI19 Unable to open database'
ISI50=: 'ISI50 Incorrect number of columns'
ISI51=: 'ISI51 Incorrect data type'
ISI52=: 'ISI52 Incorrect base table'
ISI53=: 'ISI53 No column in query result'
ISI54=: 'ISI54 Column ordinal number error'
ISI55=: 'ISI55 Unable to map data type to ODBC data type'
ISI56=: 'ISI56 Unable to handle parameterized query'
SQLST_WARNING=: '01000'
SQL_SUCCESS=: 0
SQL_SUCCESS_WITH_INFO=: 1
SQL_NO_DATA=: 100
SQL_ERROR=: _1
SQL_INVALID_HANDLE=: _2
SQL_STILL_EXECUTING=: 2
SQL_NEED_DATA=: 99
SQL_MAX_DSN_LENGTH=: 32
SQL_COMMIT=: 0
SQL_ROLLBACK=: 1
SQL_NULL_DATA=: _1
SQL_NTS=: _3
SQL_HANDLE_ENV=: 1
SQL_HANDLE_DBC=: 2
SQL_HANDLE_STMT=: 3
SQL_HANDLE_DESC=: 4
SQL_FETCH_NEXT=: 1
SQL_FETCH_FIRST=: 2
SQL_ATTR_ODBC_VERSION=: 200
SQL_OV_ODBC3=: 3
SQL_ATTR_ROW_BIND_TYPE=: 5
SQL_BIND_BY_COLUMN=: 0
SQL_ATTR_ROWS_FETCHED_PTR=: 26
SQL_ATTR_ROW_ARRAY_SIZE=: 27
SQL_ATTR_ROW_STATUS_PTR=: 25
SQL_ATTR_AUTOCOMMIT=: 102
SQL_AUTOCOMMIT_OFF=: 0
SQL_AUTOCOMMIT_ON=: 1
SQL_ROWSET_SIZE=: 9
SQL_IS_POINTER=: _4
SQL_IS_UINTEGER=: _5
SQL_IS_INTEGER=: _6
SQL_IS_USMALLINT=: _7
SQL_IS_SMALLINT=: _8
SQL_TRUE=: 1
SQL_API_SQLBULKOPERATIONS=: 24
SQL_ATTR_CONNECTION_TIMEOUT=: 113
SQL_ATTR_USE_BOOKMARKS=: 12
SQL_USE_BOOKMARKS=: 12
SQL_UB_OFF=: 0
SQL_UB_ON=: 1
SQL_UB_FIXED=: 1
SQL_UB_VARIABLE=: 2

SQL_DESC_BASE_COLUMN_NAME=: 22
SQL_DESC_BASE_TABLE_NAME=: 23
SQL_DESC_CATALOG_NAME=: 17
SQL_DESC_NAME=: 1011
SQL_DESC_SCHEMA_NAME=: 16
SQL_DESC_TABLE_NAME=: 15
SQL_DESC_TYPE_NAME=: 14

SQL_SIGNED_OFFSET=: _20
SQL_C_BIT=: _7
SQL_C_CHAR=: 1
SQL_C_DOUBLE=: 8
SQL_C_LONG=: 4
SQL_C_SLONG=: (SQL_C_LONG+SQL_SIGNED_OFFSET)
SQL_C_SHORT=: 5
SQL_C_SSHORT=: (SQL_C_SHORT+SQL_SIGNED_OFFSET)
SQL_C_BINARY=: _2
SQL_LONGVARBINARY=: _4
SQL_TYPE_DATE=: 91
SQL_TYPE_TIME=: 92
SQL_TYPE_TIMESTAMP=: 93
SQL_C_BIGINT=: _5
SQL_C_SBIGINT=: (SQL_C_BIGINT+SQL_SIGNED_OFFSET)
SQL_C_VARBOOKMARK=: SQL_C_BINARY

SQL_DATE_LEN=: 10
SQL_TIME_LEN=: 8
SQL_TIMESTAMP_LEN=: 19

SQL_C_TYPE_DATE=: SQL_TYPE_DATE
SQL_C_TYPE_TIME=: SQL_TYPE_TIME
SQL_C_TYPE_TIMESTAMP=: SQL_TYPE_TIMESTAMP

SQL_SS_TIME2=: _154
SQL_SS_TIMESTAMPOFFSET=: _155

SQL_C_TYPES_EXTENDED=. 16b4000
SQL_C_SS_TIME2=: SQL_C_TYPES_EXTENDED
SQL_C_SS_TIMESTAMPOFFSET=: SQL_C_TYPES_EXTENDED+1

SQL_ADD=: 4
SQL_UPDATE_BY_BOOKMARK=: 5
SQL_DELETE_BY_BOOKMARK=: 6
SQL_FETCH_BY_BOOKMARK=: 7
SQL_ATTR_CURSOR_TYPE=: 6
SQL_CURSOR_FORWARD_ONLY=: 0
SQL_CURSOR_KEYSET_DRIVEN=: 1
SQL_CURSOR_DYNAMIC=: 2
SQL_ATTR_CONCURRENCY=: 7
SQL_CONCUR_LOCK=: 2
SQL_CONCUR_READ_ONLY=: 1
SQL_PARAM_INPUT=: 1
SQL_ALL_TYPES=: 0
SQL_ASYNC_ENABLE=: 4
SQL_ATTR_ASYNC_ENABLE=: 4
SQL_ASYNC_ENABLE_OFF=: 0
SQL_ASYNC_ENABLE_ON=: 1
SQL_ASYNC_MODE=: 10021
SQL_AM_CONNECTION=: 1
SQL_AM_STATEMENT=: 2
SQL_MAX_ASYNC_CONCURRENT_STATEMENTS=: 10022
COLUMNBUF=: 20000
LONGBUF=: 1000000
SHORTBUF=: 8000
MAXARRAYSIZE=: 65535
ASYNCDELAY=: 10000
ASYNCDELAYLONG=: 1e6
CNB=: 0{a.

char_trctnb=: ]`trctnb @. (2:=3!:0)
trctnb=: <:@{:@$ {."1 (i.&({.a.) {. ])"1
trctnbw=: trctnb
trbuclnb=: (] i.&> ({.a.)"_) {.&.> ]
rebtbcol=: ] #"1~ [: -. [: *./ [: *./\."1 ' '&=
trctnob=: [: rebtbcol ] -."1 (0{a.)"_
trctguid=: 36&{."1

nullvec2mat=: 3 : '> a: -.~ deb each <;._2 y,{.a.'
'UCS2 UCS4 UTF8 OEMCP'=: i.4
BUGFLAG_BINDPARMBIGINT=: 8
BUGFLAG_WCHAR_SUTF8=: 16
BUGFLAG_LONGVARBINARY_BINARY=: 128
BUGFLAG_BULKOPERATIONS=: 256
IFTIMESTRUC=: 1
DD_SUCCESS1=: SQL_SUCCESS,SQL_SUCCESS_WITH_INFO,SQL_NO_DATA
DD_SUCCESS=: SQL_SUCCESS,SQL_SUCCESS_WITH_INFO
DD_ERROR=: SQL_ERROR,SQL_INVALID_HANDLE
DD_OK=: 0
parsesqlparm=: 3 : 0
fmt=. 0
if. ('insert into' ; 'select into') e.~ <tolower 11{.y=. dlb y do. ix=. 11 [ fmt=. 1
elseif. 'insert ' -: tolower 7{.y do. ix=. 6 [ fmt=. 1
elseif. 'delete from' -: tolower 11{.y do. ix=. 11
elseif. 'update' -: tolower 6{.y do. ix=. 6
elseif. do. ix=. _1
end.
if. _1~:ix do.
  table=. ({.~ i.&' ') dlb ix}. ' ' (I.y e.'()')}y
else.
  table=. ''
end.
if. 1=fmt do.
  if. 1 e. ivb=. ' values ' E. tolower ' ' (I.y e.'()')}y do. iv=. {.I.ivb else. fmt=. 0 end.
end.
if. 0=fmt do.
  y1=. ' ' (I. y e. '[]')}y
  f1=. (0=(2&|)) +/\ ''''=y1
  f2=. (> 0:,}:) f1
  f2=. 0,}.f2
  y1=. ' ' (I.-.f1)}y1
  y1=. ' ' (I.f2)}y1
  f1=. 0< (([: +/\ '('&=) - ([: +/\ ')'&=)) y1
  y1=. ' ' (I.f1 *. ','=y1)}y1
  y1=. ' ' (I.y1 e.'()')}y1
  y1=. (' where ';', where ';' WHERE ';', WHERE ';' and ';', and ';' AND ';', AND ';' or ';', or ';' OR ';', OR ') stringreplace (deb y1) , ','
  a=. (',' = y1) <;._2 y1
  b=. (#~ ('='&e. *. '?'&e.)&>) a
  c=. ({.~ i:&'=')&.> b
  parm=. dtb&.> ({.~ i.&' ')&.|.&.> c
else.
  fld=. <@dltb;._1 ',', ' ' (I.a e.'()')} a=. (}.~ i.&'(') y{.~ iv

  y1=. y}.~ iv + #' values '
  f1=. (0=(2&|)) +/\ ''''=y1
  f2=. (> 0:,}:) f1
  f2=. 0,}.f2
  y1=. ' ' (I.-.f1)}y1
  y1=. ' ' (I.f2)}y1
  y1=. }.}:dltb y1
  f1=. 0< (([: +/\ '('&=) - ([: +/\ ')'&=)) y1
  y1=. ' ' (I.f1 *. ','=y1)}y1
  y1=. ' ' (I.y1 e.'()')}y1
  y1=. (deb y1),','
  a=. <;._2 y1
  msk=. ('?'&e.)&> a
  parm=. ((#fld){.msk)#fld
end.
table;parm
)
SQL_SUPPORTED_NAMES=: (];._2) 0 : 0
0
SQL_CHAR=: 1['*'
SQL_NUMERIC=: 2['*'
SQL_DECIMAL=: 3['*'
SQL_INTEGER=: 4['*'
SQL_SMALLINT=: 5['*'
SQL_FLOAT=: 6['*'
SQL_REAL=: 7['*'
SQL_DOUBLE=: 8['*'
SQL_TYPE_DATE=:91['*'
SQL_TYPE_TIME=:92['*'
SQL_TYPE_TIMESTAMP=:93['*'
SQL_SS_TIME2=: _154['*'
SQL_SS_TIMESTAMPOFFSET=: _155['*'
SQL_SS_XML=: _152
SQL_VARCHAR=: 12['*'
SQL_DEFAULT=: 99['*'
SQL_LONGVARCHAR=: _1['*'
SQL_BINARY=: _2['*'
SQL_VARBINARY=: _3['*'
SQL_LONGVARBINARY=:_4['*'
SQL_BIGINT=: _5['*'
SQL_TINYINT=: _6['*'
SQL_BIT=: _7['*'
SQL_WCHAR=: _8['*'
SQL_WVARCHAR=: _9['*'
SQL_WLONGVARCHAR=: _10['*'
SQL_UNIQUEID=:_11['*'
)
settypeinfo=: 3 : 0
sqlnames=. }. SQL_SUPPORTED_NAMES
SQL_SUPPORTED_TYPES=: , ". sqlnames
GDX=: SQL_VARCHAR, SQL_CHAR, SQL_VARBINARY, SQL_BINARY
GCNM=: ;:'trctnb       trctnb trctnb       trctnb '
if. 1=UseDayNo do.
  GDX=: GDX, SQL_TYPE_TIMESTAMP, SQL_TYPE_DATE, SQL_TYPE_TIME, SQL_SS_TIME2, SQL_SS_TIMESTAMPOFFSET
  GCNM=: GCNM,;:'fmtdts_num       fmtddts_num    fmttdts_num    fmttdts2_num  fmtdtsx_num'
elseif. 2=UseDayNo do.
  GDX=: GDX, SQL_TYPE_TIMESTAMP, SQL_TYPE_DATE, SQL_TYPE_TIME, SQL_SS_TIME2, SQL_SS_TIMESTAMPOFFSET
  GCNM=: GCNM,;:'fmtdts_e         fmtddts_e      fmttdts_e      fmttdts2_e    fmtdtsx_e'
elseif. 0=UseDayNo do.
  GDX=: GDX, SQL_TYPE_TIMESTAMP, SQL_TYPE_DATE, SQL_TYPE_TIME, SQL_SS_TIME2, SQL_SS_TIMESTAMPOFFSET
  GCNM=: GCNM,;:'fmtdts           fmtddts        fmttdts        fmttdts2      fmtdtsx'
end.
GDX=: GDX, SQL_WCHAR, SQL_WVARCHAR, SQL_UNIQUEID
GCNM=: GCNM,;:'trctnbw     trctnbw   trctguid'

GDX=: GDX , SQL_DECIMAL, SQL_NUMERIC, SQL_DOUBLE, SQL_FLOAT, SQL_REAL
if. UseNumeric do.
  GCNM=: GCNM , ;:']        ]            ]           ]          ]'
else.
  GCNM=: GCNM , ;:'rnnum    rnnum        ]           ]          ]'
end.
if. IF64 do.
  GDX=: GDX , SQL_BIT, SQL_TINYINT, SQL_SMALLINT, SQL_INTEGER, SQL_BIGINT
  GCNM=: GCNM , ;:' ]        ifi       ifi           ifi         ]'
else.
  GDX=: GDX , SQL_BIT, SQL_TINYINT, SQL_SMALLINT, SQL_INTEGER, SQL_BIGINT
  GCNM=: GCNM , ;:' ]         ]      ]             ]            ]'
end.
GDX=: GDX , SQL_LONGVARCHAR, SQL_LONGVARBINARY, SQL_WLONGVARCHAR
GCNM=: GCNM , ;:' emptyrk1   emptyrk1            emptyrk1'

assert. (#GDX) = #GCNM
GGETV=: (sqlnames i."1'=') {."0 1 sqlnames
GGETV=: dltb&.> <"1 'get',"1 tolower 4 }."1 GGETV
SQL_COLBIND_TYPES=: ('*' +./"1 . = sqlnames) # SQL_SUPPORTED_TYPES

datbigint=: ('datbigint',(IF64*.UseBigInt){::'32';SFX)~ f.

if. IF64*.UseBigInt do.
  getbigint=: datbigint&.>
else.
  if. UseNumeric do.
    getbigint=: datbigint&.>
  else.
    getbigint=: datchar&.>
  end.
end.
if. UseNumeric do.
  getdecimal=: datdouble&.>
  getnumeric=: datdouble&.>
else.
  getdecimal=: datchar&.>
  getnumeric=: datchar&.>
end.
''
)
b0=: <"0
bs=: ];#

bitor=: 23 b.
fat=: ''&$@:,
src=: _1: ic 1: ic ]
sqlbad=: 13 : '(src >{. y) e. DD_ERROR'
sqlok=: 13 : '(src >{. y) e. DD_SUCCESS'
sqlok1=: 13 : '(src >{. y) e. DD_SUCCESS1'
sqlsuccess=: 13 : '(src >{. y) e. SQL_SUCCESS'
sqlstillexec=: 13 : '(src >{. y) e. SQL_STILL_EXECUTING'
iscl=: e.&(2 131072 262144)@(3!:0) *. 1: >: [: # $
isua=: 0: = [: # $
isiu=: 3!:0 e. 1 4"_
isia=: isua *. isiu

isnu=: 3!:0 e. 1 4 8"_
isna=: isua *. isnu
iscu=: (e.&2 131072 262144)@(3!:0)
ifs=: [: ,. [: _1&ic ,
ifi=: [: ,. [: _2&ic ,
ffs=: [: ,. [: _1&fc ,
rnnum=: (-."1 0)&({.a.)
dts=: ((6 ,~ #) $ [: _1&ic [: , 12{."1 ]) ,. ([: _2&ic [: , 12 13 14 15{"1 ])
dtsx=: ((6 ,~ #) $ [: _1&ic [: , 12{."1 ]) ,. ([: _2&ic [: , 12 13 14 15{"1 ])
ddts=: 13 : '((#y),3) $ _1&ic , 6{.("1) y'
tdts=: ((3 ,~ #) $ [: _1&ic [: , 6{."1 ]) ,. 0:"1
tdts2=: ((3 ,~ #) $ [: _1&ic [: , 6{."1 ]) ,. ([: _2&ic [: , 8 9 10 11{"1 ])
date2odbc=: 4 : 0
if. (0~:x) *. (0=y) *. 1=#y do.
  if. 0&= #@$ y do.
    <6#{.a.
  else.
    <,: 6#{.a.
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
datetime2odbc=: 4 : 0
if. (0~:x) *. (0=y) *. 1=#y do.
  if. 0&= #@$ y do.
    <16#{.a.
  else.
    <,: 16#{.a.
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
datetimex2odbc=: 4 : 0
if. (0~:x) *. (0=y) *. 1=#y do.
  if. 0&= #@$ y do.
    <20#{.a.
  else.
    <,: 20#{.a.
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
time2odbc=: 4 : 0
if. (0~:x) *. (0=y) *. 1=#y do.
  if. 0&= #@$ y do.
    <6#{.a.
  else.
    <,: 6#{.a.
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
timex2odbc=: 4 : 0
if. (0~:x) *. (0=y) *. 1=#y do.
  if. 0&= #@$ y do.
    <12#{.a.
  else.
    <,: 12#{.a.
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
fmterr=: [: ; ([: ":&.> ]) ,&.> ' '"_
badrow=: 13 : '0 e. (src ;{.&> y) e. DD_SUCCESS'
isbx=: 3!:0 e. 32"_
isca=: 3!:0 e. 2"_
cvt2str=: 'a'&,@":
date2db=: 4 : 0
y=. >y
y=. <.y
if. (((2=x){::DateTimeNull;EpochNull)=y) *. 1=#y do.
  if. 0&= #@$ y do.
    <16{.'NULL'
  else.
    <,: 16{.'NULL'
  end.
else.
  < (16{.'NULL' ) g} '{d ''' ,("1) (x&fmtddtsn 0 (g=. I. ((2=x){::DateTimeNull;EpochNull)=y)}y) ,("1) '''}'
end.
)
datetime2db=: 4 : 0
y=. >y
if. (((2=x){::DateTimeNull;EpochNull)=y) *. 1=#y do.
  if. 0&= #@$ y do.
    <(26+(+*)FraSecond){.'NULL'
  else.
    <,: (26+(+*)FraSecond){.'NULL'
  end.
else.
  < ((26+(+*)FraSecond){.'NULL' ) g} '{ts ''' ,("1) (x&fmtdtsn 0 (g=. I. ((2=x){::DateTimeNull;EpochNull)=y)}y) ,("1) '''}'
end.
)
time2db=: 4 : 0
y=. >y
if. (((2=x){::DateTimeNull;EpochNull)=y) *. 1=#y do.
  if. 0&= #@$ y do.
    <(14+(+*)FraSecond){.'NULL'
  else.
    <,: (14+(+*)FraSecond){.'NULL'
  end.
else.
  < ((14+(+*)FraSecond){.'NULL' ) g} '{t ''' ,("1) (x&fmttdtsn 0 (g=. I. ((2=x){::DateTimeNull;EpochNull)=y)}y) ,("1) '''}'
end.
)
getDateTimeNull=: 3 : 'DateTimeNull'
getIntegerNull=: 3 : '(IntegerNull=IMIN){::IntegerNull;__'
getNumericNull=: 3 : 'NumericNull'
getFraSecond=: 3 : 'FraSecond'
getOffsetMinute=: 3 : 'OffsetMinute'
getUseErrRet=: 3 : 'UseErrRet'
getUseDayNo=: 3 : 'UseDayNo'
getUseUnicode=: 3 : 'UseUnicode'
getCHALL=: 3 : 'CHALL'
getAutoAsync=: 3 : 'AutoAsync'
getAutoDend=: 3 : 'AutoDend'
setzface=: 3 : 0
r=. i. 0 0
setz=. 1
if. 0=4!:0<'ODBCSETZLOCALE' do.
  if. 0=ODBCSETZLOCALE do. setz=. 0 end.
end.
if. (<'base') -: cl=. 18!:5 '' do. r
else.
  cl=. '_' , (,>cl) , '_'
  wrds=. 'ddsrc ddtbl ddtblx ddcol ddcon dddis ddfch ddend ddsel ddcnm dderr'
  wrds=. wrds, ' dddrv ddsql ddcnt ddtrn ddcom ddrbk ddbind ddfetch'
  wrds=. wrds ,' dddata ddfet ddbtype ddcheck ddrow ddins ddparm ddsparm dddbms ddcolinfo ddttrn'
  wrds=. wrds ,' ddttrn ddprep ddparm ddsparm ddput ddgetinfo ddcolinfo'
  wrds=. wrds ,' ddsetconnectattr ddgetconnectattr dddriver ddconfig ddcoltype ddtypeinfo ddtypeinfox'
  if. -.setz do. wrds=. '' end.
  wrds=. wrds ,' userfn sqlbad sqlok sqlres sqlresok'
  wrds=. >;: wrds , ' ', ;:^:_1 ('get'&,)&.> ;: ' AutoAsync DateTimeNull IntegerNull NumericNull FraSecond OffsetMinute UseErrRet UseDayNo UseUnicode CHALL'
  ". (wrds ,("1) '_z_ =: ',("1) wrds ,("1) cl) -.("1) ' '
  r
end.
)
setzlocale=: 3 : 0
setz=. 1
if. 0=4!:0<'ODBCSETZLOCALE' do.
  if. 0=ODBCSETZLOCALE do. setz=. 0 end.
end.
cl=. '_jdd_'
wrds=. 'ddsrc ddtbl ddtblx ddcol ddcon dddis ddfch ddend ddsel ddcnm dderr'
wrds=. wrds, ' dddrv ddsql ddcnt ddtrn ddcom ddrbk ddbind ddfetch'
wrds=. wrds ,' dddata ddfet ddbtype ddcheck ddrow ddins ddparm ddsparm dddbms ddcolinfo ddttrn'
wrds=. wrds ,' ddttrn ddprep ddparm ddsparm ddput ddgetinfo ddcolinfo'
wrds=. wrds ,' ddsetconnectattr ddgetconnectattr dddriver ddconfig ddcoltype ddtypeinfo ddtypeinfox'
if. -.setz do. wrds=. '' end.
wrds=. wrds ,' userfn sqlbad sqlok sqlres sqlresok'
wrds=. >;: wrds , ' ', ;:^:_1 ('get'&,)&.> ;: ' AutoAsync DateTimeNull IntegerNull NumericNull FraSecond OffsetMinute UseErrRet UseDayNo UseUnicode CHALL'
". (wrds ,("1) '_z_ =: ',("1) wrds ,("1) cl) -.("1) ' '
EMPTY
)
SQL_CHAR_z_=: 1
SQL_NUMERIC_z_=: 2
SQL_DECIMAL_z_=: 3
SQL_INTEGER_z_=: 4
SQL_SMALLINT_z_=: 5
SQL_FLOAT_z_=: 6
SQL_REAL_z_=: 7
SQL_DOUBLE_z_=: 8
SQL_DATE_z_=: 9
SQL_DATETIME_z_=: 9
SQL_TIME_z_=: 10
SQL_TYPE_DATE_z_=: 91
SQL_TYPE_TIME_z_=: 92
SQL_TYPE_TIMESTAMP_z_=: 93
SQL_SS_TIME2_z_=: _154
SQL_SS_TIMESTAMPOFFSET=: _155
SQL_VARCHAR_z_=: 12
SQL_DEFAULT_z_=: 99
SQL_LONGVARCHAR_z_=: _1
SQL_BINARY_z_=: _2
SQL_VARBINARY_z_=: _3
SQL_LONGVARBINARY_z_=: _4
SQL_BIGINT_z_=: _5
SQL_TINYINT_z_=: _6
SQL_BIT_z_=: _7
SQL_WCHAR_z_=: _8
SQL_WVARCHAR_z_=: _9
SQL_WLONGVARCHAR_z_=: _10
SQL_UNIQUEID_z_=: _11


3 : 0''
wchar2char=: 1 + IFWIN > 1252= (('kernel32 GetACP > i'&cd) :: 0:) ''
endodbcenv 0
InitDone=: 1
settypeinfo 0
initodbcenv 0
setzlocale 0

EMPTY
)
