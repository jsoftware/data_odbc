NB. test1
NB.
NB. includes bigint

9!:11[12

NMS=: ;: 'Anne Brenda Carol Denise Esther Fanny'
NB. require 'stats'
toss=: ?. @ (# #) { ]

NB. =========================================================
testdb=: 3 : 0

ddconfig 'frasecond';3;'dayno';0
NB. 1099511627776 _35184372088832 1125899906842624
abc=. 1 _1 1 * <. 2^40 45 50
'a b c'=. deb each '0.0' (8!:0) abc

NB. ---------------------------------------------------------
cls=. 'bon,name,sal,rate,dob'
def=. 'bon bigint,name char(6),sal numeric,rate float,dob datetime'

CH=: ddcheck ddcon 'dsn=testdata'
'drop table mytab' ddsql CH
('create table mytab (',def,')') ddsql CH

for_i. 1 do.
  t=. 'insert into mytab (',cls,') values (',a,',''George'',40000,1.234,''1970-11-23 11:12:13.345'')'
  assert. 0 = t ddsql CH
  t=. 'insert into mytab (',cls,') values (',b,',''John'',42000,0.7,''1982-05-28'')'
  assert. 0 = t ddsql CH
end.

if. 1 do.
  len=. 4
NB. ?format for datetime ddins
  s=. (,.len$abc);(>len toss NMS);(,.20000+?.len$50000);(,.0.001*?.len$100000);(len,23)$;'1999-12-31 23:59:59.888';'2000-01-01 00:00:00.000';'2000-01-01 00:00:01.000';'2010-02-03 11:22:33.444'
  echo s
  sel=. 'select bon,name,sal,rate,dob from mytab'
  echo (sel;s) ddins CH
end.

ddconfig 'dayno';1
if. 1 do.
  len=. 4
NB. ?format for datetime ddins
  s=. (,.len$abc);(>len toss NMS);(,.20000+?.len$50000);(,.0.001*?.len$100000);len$,.(%&86400000)@:tsrep"(1) (len,6)$ 1999 12 31 23 59 59.888 2000 01 01 00 00 00.000 2000 01 01 00 00 01.000 2010 02 03 11 22 33.444
  echo s
  sel=. 'select bon,name,sal,rate,dob from mytab'
  echo (sel;s) ddins CH
echo dderr''
end.

ddconfig 'dayno';2
if. 1 do.
  len=. 4
NB. ?format for datetime ddins
  s=. (,.len$abc);(>len toss NMS);(,.20000+?.len$50000);(,.0.001*?.len$100000);len$,.<.(86400000000000*73048)-~(*&1e6)@:<.@:tsrep"(1) (len,6)$ 1999 12 31 23 59 59.888 2000 01 01 00 00 00.000 2000 01 01 00 00 01.000 2010 02 03 11 22 33.444
  echo s
  sel=. 'select bon,name,sal,rate,dob from mytab'
  echo (sel;s) ddins CH
echo dderr''
end.

ddconfig 'dayno';0
sh=. 'select * from mytab' ddsel CH
echo 'ddfet'
echo ddfet sh,_1

sh=. 'select * from mytab' ddsel CH
echo 'ddfch'
echo ddfch sh,_1

ddconfig 'dayno';1
sh=. 'select * from mytab' ddsel CH
echo 'ddfet'
echo ddfet sh,_1

sh=. 'select * from mytab' ddsel CH
echo 'ddfch'
echo ddfch sh,_1

ddconfig 'dayno';2
sh=. 'select * from mytab' ddsel CH
echo 'ddfet'
echo ddfet sh,_1

sh=. 'select * from mytab' ddsel CH
echo 'ddfch'
echo ddfch sh,_1

empty dddis sh,CH
)

dbg 1
dbstops''
NB. dbstops 'ddins'
testdb ''

