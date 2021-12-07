NB. uncomment the following 3 lines when building for J602
NB. script_z_ '~system/main/dates.ijs'
NB. script_z_ '~system/main/dll.ijs'
NB. script_z_ '~system/main/strings.ijs'

coclass 'jdd'

IMAX=: IF64{::2147483647;9223372036854775807
IMIN=: _1+-IMAX
DateTimeNull=: _
InitDone=: 0
IntegerNull=: IMIN       NB. for backward compatible
NumericNull=: __
EpochNull=: IF64{:: __ ; IMIN
FraSecond=: 0            NB. fractional second 0 to 9
OffsetMinute=: 0         NB. timezone offset ahead of utc in minutes for ddins
OffsetMinute_bin=: 1&ic 0 0
UseBigInt=: 0
UseDayNo=: 0
UseNumeric=: 0
UseTrimBulkText=: 1

dayns=: 86400000000000   NB. nano seconds in one day
EpochOffset=: 73048

NB. immutable
UseErrRet=: 0
UseUnicode=: 0

SZI=: IF64{4 8     NB. sizeof integer - 4 for 32 bit and 8 for 64 bit
SFX=: >IF64{'32';'64'

create=: 3 : 0
if. 0=InitDone do.
  InitDone_jdd_=: 1
end.
settypeinfo 0
initodbcenv 0
''
)

destroy=: 3 : 0
endodbcenv 0
codestroy''
)

NB. =========================================================
NB. replace z locale names defined by jdd/ODBC locale.

setzlocale=: 3 : 0
wrds=. 'ddsrc ddtbl ddtblx ddcol ddcon dddis ddfch ddend ddsel ddcnm dderr'
wrds=. wrds, ' dddrv ddsql ddcnt ddtrn ddcom ddrbk ddbind ddfetch'
wrds=. wrds ,' dddata ddfet ddbtype ddcheck ddrow ddins ddparm ddsparm dddbms ddcolinfo ddttrn'
wrds=. wrds ,' dddriver ddconfig ddcoltype ddtypeinfo ddtypeinfox'
wrds=. wrds ,' userfn sqlbad sqlok sqlres sqlresok'
wrds=. wrds , ' ', ;:^:_1 ('get'&,)&.> ;: ' DateTimeNull IntegerNull NumericNull FraSecond OffsetMinute UseErrRet UseDayNo UseUnicode CHALL'
wrds=. > ;: wrds

cl=. '_jdd_'
". (wrds ,"1 '_z_ =: ',"1 wrds ,"1 cl) -."1 ' '

if. 0=InitDone_jdd_ do.
  InitDone_jdd_=: 1
end.
settypeinfo 0
endodbcenv 0
initodbcenv 0

EMPTY
)
