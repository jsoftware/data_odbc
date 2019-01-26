cocurrent 'base'

ODBCSETZLOCALE__=: 0
wrds=. 'ddsrc ddtbl ddtblx ddcol ddcon dddis ddfch ddend ddsel ddcnm dderr'
wrds=. wrds, ' dddrv ddsql ddcnt ddtrn ddcom ddrbk ddbind ddfetch'
wrds=. wrds ,' dddata ddfet ddbtype ddcheck ddrow ddins ddparm ddsparm dddbms ddcolinfo ddttrn'
wrds=. wrds ,' dddriver ddconfig ddcoltype'
wrds=. wrds ,' userfn sqlbad sqlok sqlres sqlresok'
wrds=. wrds , ' ', ;:^:_1 ('get'&,)&.> ;: ' DateTimeNull IntegerNull NumericNull UseErrRet UseDayNo UseUnicode CHALL'
wrds=. > ;: wrds
4!:55 wrds ,&.> <'_z_'
18!:55 <'jdd'

load 'data/odbc'

integerdate=: 0

tdata_ddl=: 0 : 0
create table tdata (
NAME varchar(15),
SEX varchar(1),
DEPT varchar(4),
DOB date,
DOH date,
SALARY integer,
PHOTO longbinary );
)

tdata_ddl2=: 0 : 0
create table tdata (
NAME varchar(15),
SEX varchar(1),
DEPT varchar(4),
DOB integer,
DOH integer,
SALARY integer,
PHOTO longbinary );
)

tdata_data=: 0 : 0
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Macdonald B', 'F', 'D101', #1959-06-01#, #1978-05-01#, 32591);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Genereaux S', 'F', 'D103', #1945-03-01#, #1966-02-01#, 95415);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Koebel R', 'M', 'D101', #1937-11-01#, #1980-09-01#, 63374);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Keller J', 'F', 'D101', #1951-05-01#, #1974-04-01#, 48898);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Twa L', 'F', 'D108', #1955-07-01#, #1980-04-01#, 49075);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Blamire J', 'F', 'D101', #1960-08-01#, #1979-12-01#, 46469);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Gordon E', 'F', 'D103', #1952-02-01#, #1979-08-01#, 29960);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Denny D', 'F', 'D101', #1949-08-01#, #1980-04-01#, 46939);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Newton R', 'M', 'D108', #1956-01-01#, #1979-02-01#, 73368);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Miller S', 'F', 'D103', #1965-01-01#, #1983-03-01#, 43418);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Dingee S', 'M', 'D103', #1964-10-01#, #1983-09-01#, 46877);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Bugg P', 'F', 'D101', #1920-11-01#, #1958-04-01#, 47165);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Lafrance R', 'F', 'D101', #1952-02-01#, #1983-02-01#, 47017);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Rogerson G', 'M', 'D101', #1957-12-01#, #1983-02-01#, 108777);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Brando D', 'F', 'D108', #1959-04-01#, #1977-08-01#, 44931);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Anctil J', 'M', 'D108', #1946-06-01#, #1979-06-01#, 60974);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Bauerlein J', 'F', 'D103', #1962-04-01#, #1984-09-01#, 33668);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('O''Keefe D', 'M', 'D101', #1939-03-01#, #1967-10-01#, 66377);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Beale D', 'F', 'D103', #1957-03-01#, #1974-04-01#, 48023);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Chesher D', 'F', 'D103', #1956-10-01#, #1984-08-01#, 35184);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Cahill G', 'M', 'D108', #1932-05-01#, #1967-10-01#, 81358);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Abbott K', 'M', 'D103', #1963-10-01#, #1983-09-01#, 50817);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('McKee M', 'F', 'D103', #1960-04-01#, #1981-04-01#, 43115);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Livingston P', 'F', 'D101', #1958-09-01#, #1980-08-01#, 50010);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Holliss D', 'F', 'D101', #1960-05-01#, #1977-07-01#, 46313);
)

tdata_data2=: 0 : 0
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Macdonald B', 'F', 'D101', 19590601, 19780501, 32591);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Genereaux S', 'F', 'D103', 19450301, 19660201, 95415);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Koebel R', 'M', 'D101', 19371101, 19800901, 63374);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Keller J', 'F', 'D101', 19510501, 19740401, 48898);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Twa L', 'F', 'D108', 19550701, 19800401, 49075);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Blamire J', 'F', 'D101', 19600801, 19791201, 46469);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Gordon E', 'F', 'D103', 19520201, 19790801, 29960);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Denny D', 'F', 'D101', 19490801, 19800401, 46939);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Newton R', 'M', 'D108', 19560101, 19790201, 73368);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Miller S', 'F', 'D103', 19650101, 19830301, 43418);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Dingee S', 'M', 'D103', 19641001, 19830901, 46877);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Bugg P', 'F', 'D101', 19201101, 19580401, 47165);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Lafrance R', 'F', 'D101', 19520201, 19830201, 47017);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Rogerson G', 'M', 'D101', 19571201, 19830201, 108777);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Brando D', 'F', 'D108', 19590401, 19770801, 44931);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Anctil J', 'M', 'D108', 19460601, 19790601, 60974);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Bauerlein J', 'F', 'D103', 19620401, 19840901, 33668);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('O''Keefe D', 'M', 'D101', 19390301, 19671001, 66377);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Beale D', 'F', 'D103', 19570301, 19740401, 48023);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Chesher D', 'F', 'D103', 19561001, 19840801, 35184);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Cahill G', 'M', 'D108', 19320501, 19671001, 81358);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Abbott K', 'M', 'D103', 19631001, 19830901, 50817);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('McKee M', 'F', 'D103', 19600401, 19810401, 43115);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Livingston P', 'F', 'D101', 19580901, 19800801, 50010);
insert into tdata (NAME, SEX, DEPT, DOB, DOH, SALARY) values ('Holliss D', 'F', 'D101', 19600501, 19770701, 46313);
)

NB. =========================================================
testdb=: 3 : 0
if. -.IFWIN do. echo '>> msaccess only works under windows' return. end.
NB. setzlocale_jdd_ 0
db=. '' conew 'jdd'

ddconfig__db 'errret';0;'dayno';0;'unicode';0

echo '>> dddriver'
echo dddriver__db ''

echo '>> dddrv'
echo dddrv__db ''

echo '>> ddsrc'
echo ddsrc__db ''

echo '>> delete old database'
f=. jpath '~temp/jdata.mdb'
1!:55 ::0: <f

echo '>> create empty database'

ODBC_ADD_DSN=. 1   NB. Add data source
sqlconfigdatasource=. 'odbccp32 SQLConfigDataSourceW i i i *w *w'&cd
drv=. IF64{::'Microsoft Access Driver (*.mdb)';'Microsoft Access Driver (*.mdb, *.accdb)'

attrib=. 'CREATE_DBV4=' , (dquote f), ' General', {.a.
sqlconfigdatasource 0 ; ODBC_ADD_DSN ; (uucp drv) ; (uucp attrib)

echo '>> open database'

drv=. IF64{::'Driver={Microsoft Access Driver (*.mdb)}';'Driver={Microsoft Access Driver (*.mdb, *.accdb)}'
if. _1~: ch=. ddcon__db drv,';Dbq=',f do.
  echo '>> create metadata and fill sample data'
  if. _1= ch ddsql__db~ integerdate{::tdata_ddl;tdata_ddl2 do.
    echo dderr__db''
    return.
  end.
  ddtrn__db ch
  ddsql__db&ch &.> <;._2 (integerdate{::tdata_data;tdata_data2) -. LF
  ddcom__db ch

  echo '>> dddbm'
  echo dddbms__db ch
  echo '>> ddtblx'
  echo ddtblx__db ch

  echo '>> ddtbl'
  if. _1~: sh=. ddtbl__db ch do.
    echo '>> ddcnm'
    echo ddcnm__db sh
    echo '>> ddfet'
    echo ddfet__db sh,_1
  end.
  echo '>> ddcol'
  echo 'tdata' ddcol__db ch
  echo '>> ddsel 5 rows'
  if. _1~: sh=. ch ddsel__db~ 'select * from tdata' do.
    echo '>> ddcolinfo'
    echo ddcolinfo__db sh
    echo '>> ddcnm'
    ddcnm__db sh
    echo '>> ddfet'
    echo ddfet__db sh,5
    echo '>> ddend'
    ddend__db sh
  end.
  echo '>> ddfch'
  if. _1~: sh=. ch ddsel__db~ 'select * from tdata' do.
    echo ddfch__db sh,_1
    ddend__db sh
  end.
  echo '>> ddfch__db raw format'
  if. _1~: sh=. ch ddsel__db~ 'select * from tdata' do.
    echo r=. _2&ddfch__db sh,_1
    ddend__db sh
  end.
  echo '>> ddttrn'
  echo ddttrn__db ch
  echo '>> ddtrn'
  ddtrn__db ch
  echo '>> ddttrn'
  echo ddttrn__db ch
  echo '>> update inside transaction'
  if. _1= ch ddsql__db~ 'update tdata set SALARY=SALARY + 100' do.
    echo dderr__db''
  else.
    echo '>> ddcnt'
    echo ddcnt__db ch
  end.
  echo '>> value changed in transaction'
  if. _1~: sh=. ch ddsel__db~ 'select * from tdata' do.
    echo ddfet__db sh,3
    ddend__db sh
  else.
    echo dderr__db''
  end.
  echo '>> abort transaction'
  ddrbk__db ch
  echo '>> ddttrn'
  echo ddttrn__db ch

  echo '>> value restored'
  if. _1~: sh=. ch ddsel__db~ 'select * from tdata' do.
    echo ddfet__db sh,3
    ddend__db sh
  else.
    echo dderr__db''
  end.

  echo '>> ddtrn'
  ddtrn__db ch
  echo '>> ddttrn'
  echo ddttrn__db ch
  echo '>> update inside transaction'
  ch ddsql__db~ 'update tdata set SALARY=SALARY + 1'
  echo '>> commit transaction'
  ddcom__db ch
  echo '>> ddttrn'
  echo ddttrn__db ch
  if. _1~: sh=. ch ddsel__db~ 'select * from tdata' do.
    echo ddfet__db sh,3
    ddend__db sh
  end.
  echo '>> dderr'
  ch ddsql__db~ 'update NOTABLE set status=status + 1'
  echo dderr__db''

  echo '>> ddins'
  len=. 1e5
  if. integerdate do.
    data=. ((len, 5)$'A''BCDEF');((len, 1)$'MF');((len, 4)$'E101E201');((len, 1)$19910213);((len, 1)$20081203);(,. 1+i.len)
  else.
    if. UseDayNo__db do.
      data=. ((len,5)$'A''BCDEF');((len,1)$'MF');((len,4)$'E101E201');(len$todayno 1991 2 13);(len$todayno 2008 12 3);(,. 1+i.len)
    else.
      data=. ((len,5)$'A''BCDEF');((len,1)$'MF');((len,4)$'E101E201');((len,16)$'{d ''1991-02-13''}');((len,16)$'{d ''2008-12-03''}');(,. 1+i.len)
    end.
  end.
  echo '>> begin insert ', (":len), ' rows'
  if. _1~: rc=. ch ddins__db~ 'select NAME, SEX, DEPT, DOB, DOH, SALARY from tdata';data do.
    echo '>> finish insert ', (":len), ' rows'
    echo '>> ddcnt'
    echo ddcnt__db ch
    if. _1~: sh=. ch ddsel__db~ 'select count(*) from tdata where DOH=', integerdate{::'{d ''2008-12-03''}';'20081203' do.
      echo ddfet__db sh,_1
      ddend__db sh
    else.
      echo dderr__db''
    end.
    if. _1~: sh=. ch ddsel__db~ 'select * from tdata where DOH=', integerdate{::'{d ''2008-12-03''}';'20081203' do.
      echo ddfet__db sh,5
      ddend__db sh
    else.
      echo dderr__db''
    end.
  else.
    echo dderr__db''
  end.

  echo '>> ddsparm'
  if. 0= rc=. ch ddsparm__db~ 'update tdata set PHOTO=? where NAME=?';(>'photo1';'photo2';'photo3');< (>'Abbott K';'Nobody';'Denny D') do.
    echo '>> ddcnt'
    echo ddcnt__db ch
    if. _1~: sh=. ch ddsel__db~ 'select * from tdata where photo is not null' do.
      echo ddfet__db sh,_1
    else.
      echo dderr__db''
    end.
  else.
    echo dderr__db''
  end.

  echo '>> ddsparm box'
  if. 0= rc=. ch ddsparm__db~ 'update tdata set PHOTO=? where NAME=?';('photo4';'photo5';'photo6');< ('Blamire J';'somebody';'Gordon E') do.
    echo '>> ddcnt'
    echo ddcnt__db ch
    if. _1~: sh=. ch ddsel__db~ 'select * from tdata where photo is not null' do.
      echo ddfet__db sh,_1
      ddend__db sh
    else.
      echo dderr__db''
    end.
  else.
    echo dderr__db''
  end.

  echo '>> dddis'
  dddis__db ch

  echo '>> finish'
else.
  echo '>> cannot open ',f
end.
destroy__db''
EMPTY
)

testdb''
