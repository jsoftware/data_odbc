NB. uncomment the following 3 lines when building for J602
NB. script_z_ '~system/main/dates.ijs'
NB. script_z_ '~system/main/dll.ijs'
NB. script_z_ '~system/main/strings.ijs'

coclass 'jdd'

IMAX=: IF64{::2147483647;9223372036854775807
IMIN=: _1+-IMAX
AutoAsync=: 0            NB. automatically use async
AutoDend=: 1             NB. automatically ddend after ddfch ddfet
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
EH=: _1                  NB. environment handle

dayns=: 86400000000000   NB. nano seconds in one day
EpochOffset=: 73048

NB. immutable
UseErrRet=: 0
UseUnicode=: 0

SZI=: IF64{4 8     NB. sizeof integer - 4 for 32 bit and 8 for 64 bit
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
