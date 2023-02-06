NB.
NB. Interface words:
NB.
NB. ddsrc
NB. ddtbl & ddtblx
NB. ddcol
NB. ddcon
NB. dddis
NB. ddfch - only fixed length and short datatypes
NB. ddend
NB. ddsel
NB. ddcnm
NB. dderr - dyad extension (2 dderr '') and (1 dderr '') returns more info
NB. ddsql
NB. ddcnt
NB. ddcom
NB. ddrbk
NB. ddtrn
NB. ddfet - fetches all supported datatypes - required for long datatypes
NB. ddrow - returns number of rows actually read
NB. dddbms - database dsn;uid;server;name;ver;drvname;drvver;charset;chardiv;bugflag
NB.
NB. ----------- extensions no corresponding 14!:x verbs ---------------
NB. ddbind    - binds columns in result set to J nouns
NB. ddfetch   - fetches data into J nouns (applies J conversions)
NB. dddata    - returns raw column data (no J conversions applied)
NB. ddbtype   - column types of corresponding bound columns
NB. utility:
NB.*ddcheck v check response, display any error message
NB. example: ch=: ddcheck ddcon 'dsn=Access97'

NB. ddparm - parameter query, send long data
NB. ddins - bulk insert
NB. ddinsemu - bulk insert emulated
NB. dddbms - database info
NB. ddttrn - test transaction
NB. ddprep - prepare
NB. ddparm - execute
NB. ddsparm - execute update, insert, delete, select into on single base table
NB. ddgetinfo - get info
NB. ddcolinfo - get statement handle type info
NB. ddtypeinfo - get database type info
NB. ddtypeinfox - get database type info

NB. =========================================================
setzface=: 3 : 0

NB. (setzface) defines the (z) interface for the user words
NB. of the jdd/ODBC locale.  If the current locale is (base)
NB. the (z) interface is not set.
NB.
NB. monad:  setzface uuIgnore

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

NB. =========================================================
NB. replace z locale names defined by jdd/ODBC locale.

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
