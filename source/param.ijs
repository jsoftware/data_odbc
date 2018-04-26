NB. param

NB. find base table and parameter in parameterised sql query like
NB. only applicable to single base table and one ? for each field
NB. return box array: table ; parm0 ; parm1 ; ...
NB. test
NB. 'update t set pa1=?,pa2=? where key=?'
NB. 'update t set a=12,b=b+?,c=(?),k=''abc'',p=right(t,3),q=trim(?,4),d=? where e1=foo(?) and e2=? or and e3<>4 and e4=?'
NB. 'insert into t (a,b,c,d,e,f) values (?,''?'',1,?,?,''aa'')'
parsesqlparm=: 3 : 0
fmt=. 0  NB. 1 (...) values (?,?,?)
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
  f1=. (0=(2&|)) +/\ ''''=y1  NB. outside quote but including trailing quote
  f2=. (> 0:,}:) f1           NB. firstones of f1
  f2=. 0,}.f2                 NB. no leading quote
  y1=. ' ' (I.-.f1)}y1        NB. replace string with blanks
  y1=. ' ' (I.f2)}y1          NB. replace trailing quote
  f1=. 0< (([: +/\ '('&=) - ([: +/\ ')'&=)) y1    NB. inside ()
  y1=. ' ' (I.f1 *. ','=y1)}y1    NB. replace , within () with blanks
  y1=. ' ' (I.y1 e.'()')}y1    NB. replace () with blanks
  y1=. (' where ';', where ';' WHERE ';', WHERE ';' and ';', and ';' AND ';', AND ';' or ';', or ';' OR ';', OR ') stringreplace (deb y1) , ','  NB. add delimiter for the last field
  a=. (',' = y1) <;._2 y1
  b=. (#~ ('='&e. *. '?'&e.)&>) a
  c=. ({.~ i:&'=')&.> b
  parm=. dtb&.> ({.~ i.&' ')&.|.&.> c
else.
  fld=. <@dltb;._1 ',', ' ' (I.a e.'()')} a=. (}.~ i.&'(') y{.~ iv

  y1=. y}.~ iv + #' values '
  f1=. (0=(2&|)) +/\ ''''=y1  NB. outside quote but including trailing quote
  f2=. (> 0:,}:) f1           NB. firstones of f1
  f2=. 0,}.f2                 NB. no leading quote
  y1=. ' ' (I.-.f1)}y1        NB. replace string with blanks
  y1=. ' ' (I.f2)}y1          NB. replace trailing quote
  y1=. }.}:dltb y1            NB. remove outermost ()
  f1=. 0< (([: +/\ '('&=) - ([: +/\ ')'&=)) y1    NB. inside ()
  y1=. ' ' (I.f1 *. ','=y1)}y1    NB. replace , within () with blanks
  y1=. ' ' (I.y1 e.'()')}y1    NB. replace () with blanks
  y1=. (deb y1),','   NB. add delimiter for the last field
  a=. <;._2 y1
  msk=. ('?'&e.)&> a
  parm=. ((#fld){.msk)#fld
end.
table;parm
)
