NB.
NB. bulk insert from bill lam

NB. emulate sqlbulkoperation
NB. sql eg.  'select docnum,linenum,pcode,pqty from arinvl'
NB. (sql;data1;data2) ddinsemu ch
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
NB. MSSQL, table name can not be determined, try parsing the sql statement to get table name
if. (,a:)-:tbl do.
NB. discard "select"
  if. 'select'-.@-: tolower 6{.sql0=. deb sql do. errret ISI08 return. end.
  sql0=. dlb 6}.sql0
NB. discard " where ..." clause
  if. 1 e. r=. ' where ' E. s=. tolower sql0 do. sql0=. sql0{.~ r i: 1
  elseif. 1 e. r=. ' where(' E. s do. sql0=. sql0{.~ r i: 1
  elseif. 1 e. r=. ')where ' E. s do. sql0=. sql0{.~ r i: 1
  elseif. 1 e. r=. ')where(' E. s do. sql0=. sql0{.~ r i: 1
  end.
NB. parse fields and table name
  if. 1 e. r=. ' from ' E. s=. tolower sql0 do.
    tbl=. dltb sql0}.~ a + #' from ' [[ a=. r i: 1
  elseif. 1 e. r=. ' from(' E. s do.
    tbl=. dltb sql0}.~ a + #' from(' [[ a=. r i: 1
  elseif. 1 e. r=. ')from ' E. s do.
    tbl=. dltb sql0}.~ a + #')from ' [[ a=. r i: 1
  elseif. 1 e. r=. ')from(' E. s do.
    tbl=. dltb sql0}.~ a + #')from(' [[ a=. r i: 1
  elseif. do. errret ISI08 return. end.
NB. filter extra invalid characters
  tbl=. < tbl -. '+/()*,-.:;=?@\^_`{|}'''
end.
if. (1~:#tbl) +. a: e. tbl do.  NB. more than one base table or column with base table
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
NB. fallback to sync
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
        if. UseTrimBulkText > (i{ty) e. SQL_BINARY,SQL_VARBINARY do.  NB. test feature: trim literal data
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
          case. do.  NB. in the form '2001-03-09 00:00:00'
            select. i{ty
            case. SQL_TYPE_DATE do.
              prec=. 10
              if. IFTIMESTRUC do.
                a=. >0&date2odbc data
              else.
                if. -. '{' e. tolower {.("1) a=. data do.  NB. null
                  a=. (_2&}.)@(4&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) ('{d '''),("1) (prec{.("1) data),("1) '''}'
                end.
              end.
            case. SQL_TYPE_TIME;SQL_SS_TIME2 do.
              prec=. 8+(+*)FraSecond
              scale=. FraSecond
              if. IFTIMESTRUC do.
                a=. >0&(time2odbc`timex2odbc@.(SQL_SS_TIME2=i{ty)) data
              else.
                if. -. '{' e. tolower {.("1) a=. data do.  NB. null
                  a=. (_2&}.)@(4&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) ('{t '''),("1) (prec{.("1) data),("1) '''}'
                end.
              end.
            case. SQL_TYPE_TIMESTAMP;SQL_SS_TIMESTAMPOFFSET do.
              prec=. 19+(+*)FraSecond
              scale=. FraSecond
              if. IFTIMESTRUC do.
                a=. >0&(datetime2odbc`datetimex2odbc@.(SQL_SS_TIMESTAMPOFFSET=i{ty)) data
              else.
                if. -. '{' e. tolower {.("1) a=. data do.  NB. null
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
NB. SQLSVR need specific precision for date time fields
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

NB. assume always success
NB. also get base table name
NB. y sh, icol
NB. return  catalog schema basetable column column_id(1-base) datatype columnsize decimaldigit nullable
NB. return  catalog database table org_table name org_name column-id(1-base) typename coltype length decimals nullable def nativetype nativeflags
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
NB. z=. sqlcolattribute pa=. (b0 y),SQL_DESC_NAME;(bs 128#' '), (,2-2) (;<) <0
NB. while. sqlstillexec z do. z=. sqlcolattribute pa [ usleep ASYNCDELAY end.
NB. if. sqlbad z do.
NB.   column=. ''
NB. else.
NB.   column=. dtb (fat 6{::z){.4{::z
NB. end.
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

NB. also get base table name
NB. y ch  x sh
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

NB.*ddcolinfo v get column type of result of a statement handle
NB. y sh
NB. return  catalog database table org_table name org_name column-id(1-base) typename coltype length decimals nullable def nativetype nativeflags
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

NB.*ddcoltype v get column type of result of a select statement
NB. base table name appended
NB. x select statement
NB. return  catalog database table org_table name org_name column-id(1-base) typename coltype length decimals nullable def nativetype nativeflags
ddcoltype=: 4 : 0
NB. test arguments
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
NB. attempt to execute and return statement handle
  w=. x1_index{w0
  if. SQL_ERROR=sh=. getstmt w do. errret SQL_HANDLE_DBC,w [ freestmt"0^:(*@#sh0) sh0 return. end.
  if. AutoAsync +. -.sync do.
    rc1=. sqlsetstmtattr sh;SQL_ATTR_ASYNC_ENABLE;SQL_ASYNC_ENABLE_ON;SQL_IS_INTEGER
NB. fallback to sync
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
      r=. errret SQL_HANDLE_STMT,sh   NB. unknown error
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

NB.* ddsparm v
NB. parameterised query (no rows returned),  useful for insert/update blob
NB. will add column type and call ddparm, single base table only
NB.    ch ddsparm~ 'insert into blobs (jjname,jjbinary) values (?,?)';'abc';2345678$a.
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

NB.* ddparm v
NB. parameterised query (no rows returned),  useful for insert/update blob
NB. (sql;((sqltype1, sqltype2, sqltype3) ., len1 , len2, len3);param1;param2;parm3) ddparm ch
NB. (sql;(sqltype1, sqltype2, sqltype3);param1;param2;parm3) ddparm ch
NB. create a longbinary field for testing because access memo field has max length about 64k
NB.    ch=: ddcon 'dsn=jblob'
NB.    ch ddsql~ 'alter table blobs add column jjbinary longbinary'
NB.    ch ddsql~ 'delete from blobs'
NB.    ch ddparm~ 'insert into blobs (jjname,jjbinary) values (?,?)';(SQL_VARCHAR_jdd_, SQL_LONGVARBINARY_jdd_);'abc';2345678$a.
NB.    sh=: ch ddsel~ 'select jjbinary from blobs where jjname=''abc'''
NB.    (2345678$a.) -: >{.{.ddfet sh, 1
NB.    dddis ch
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
  sqlty=. tyln [ lns=. (#tyln)#_2 NB. _2 mean undefined, _1 may be reserved for null in the future
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
NB. fallback to sync
  if. sqlbad rc1 do. echo 'ddparm fallback to sync' end.
end.


'datadriver dsn uid server name ver drvname drvver charset chardiv bugflag'=. }.DBMSALL{~(>0{("1) DBMSALL)i. y
dbmsname=. name

NB. bind column, need erasebind in freestmt/ddend
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
          a=. , >(of+i){x  NB. promoting to double
        else.
          a=. , >(of+i){x  NB. ensure double also map to long
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
              (bname)=: 2&ic (2-2) + <. (1.1-1.1) b}a  NB. ensure double also map to long
              (blname)=: SQL_NULL_DATA b}nrows$bl=. 4
            elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
              (bname)=: 2&ic (2-2) + <. (2-2) b}a  NB. ensure double also map to long
              (blname)=: SQL_NULL_DATA b}nrows$bl=. 4
            elseif. do.
              (bname)=: 2&ic (2-2) + <. a  NB. ensure double also map to long
              (blname)=: nrows$bl=. 4
            end.
          else.
            if. (8=3!:0 a) *. *#b=. I. a e. NumericNull do.
              (bname)=: (2-2) + <. (1.1-1.1) b}a  NB. ensure double also map to long
              (blname)=: SQL_NULL_DATA b}nrows$bl=. SZI
            elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
              (bname)=: (2-2) + <. (2-2) b}a  NB. ensure double also map to long
              (blname)=: SQL_NULL_DATA b}nrows$bl=. SZI
            elseif. do.
              (bname)=: (2-2) + <. a  NB. ensure double also map to long
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
      a=. , >(of+i){x  NB. ensure double also map to long
    catch.
      erasebind sh [ freestmt sh [ r=. errret ISI51
      if. loctran do. CHTR=: CHTR-. y [ SQL_ROLLBACK comrbk y end.
      r return.
    end.
    if. IF64 do.
      if. (8=3!:0 a) *. *#b=. I. a e. NumericNull do.
        (bname)=: 2&ic (2-2) + <. (1.1-1.1) b}a  NB. ensure double also map to long
        (blname)=: SQL_NULL_DATA b}nrows$bl=. 4
      elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
        (bname)=: 2&ic (2-2) + <. (2-2) b}a  NB. ensure double also map to long
        (blname)=: SQL_NULL_DATA b}nrows$bl=. 4
      elseif. do.
        (bname)=: 2&ic (2-2) + <. a  NB. ensure double also map to long
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
        (bname)=: (_&<.) (1.1-1.1) b}a  NB. promoting to double
        (blname)=: SQL_NULL_DATA b}nrows$bl=. 8
      elseif. (1 4 e.~ a) *. *#b=. I. a e. IntegerNull do.
        (bname)=: (_&<.) (2-2) b}a  NB. promoting to double
        (blname)=: SQL_NULL_DATA b}nrows$bl=. 8
      elseif. do.
        (bname)=: (_&<.) a  NB. promoting to double
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
    if. 0=colsize do. colsize=. 1 [ a=. (1,~ {.@$a)$u:' ' end.  NB. avoid insert null
    (bname)=: (1+colsize)&{.("1) a
    if. colsize do.
      if. UseTrimBulkText do.  NB. test feature: trim literal data
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
      case. do.  NB. in the form '2001-03-09 00:00:00'
        select. i{ty
        case. SQL_TYPE_DATE do.
          prec=. 10
          if. IFTIMESTRUC do.
            a=. >0&date2odbc("1) data
          else.
            if. -. '{' e. tolower {.("1) a=. data do.  NB. null
              a=. (_2&}.)@(4&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) ('{d '''),("1) (prec{.("1) data),("1) '''}'
            end.
          end.
        case. SQL_TYPE_TIME;SQL_SS_TIME2 do.
          prec=. 8+(+*)FraSecond
          scale=. FraSecond
          if. IFTIMESTRUC do.
            a=. >0&(time2odbc`timex2odbc@.(SQL_SS_TIME2=i{ty)) data
          else.
            if. -. '{' e. tolower {.("1) a=. data do.  NB. null
              a=. (_2&}.)@(4&}.)^:('{'={.)("1)^:('MSSQL'-:dbmsname) ('{t '''),("1) (prec{.("1) data),("1) '''}'
            end.
          end.
        case. SQL_TYPE_TIMESTAMP;SQL_SS_TIMESTAMPOFFSET do.
          prec=. 19+(+*)FraSecond
          scale=. FraSecond
          if. IFTIMESTRUC do.
            a=. >0&(datetime2odbc`datetimex2odbc@.(SQL_SS_TIMESTAMPOFFSET=i{ty)) data
          else.
            if. -. '{' e. tolower {.("1) a=. data do.  NB. null
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
NB. SQLSVR need specific precision for date time fields
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
