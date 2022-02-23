NB. types
NB.
NB. The following table describes the supported ODBC datatypes --------
NB. Conversion of SQL data to J is a two part process.
NB.
NB.   1) The SQL type is first converted to a C type by the ODBC driver.
NB.      The trick in this phase is getting the C type right, the
NB.      receiving buffer properly sized and a valid pointer to the
NB.      start of the buffer.
NB.
NB.      Most SQL types have a default conversion SQL_C_DEFAULT
NB.      that can be used if you correctly size the incoming buffer.
NB.
NB.      note - bad buffer sizes and pointers will crash J
NB.
NB.   2) The second phase involves converting the C type to
NB.      a J type.  J has only three basic native C datatypes:
NB.
NB.         Long Signed/Unsigned Integers  SQL_C_SLONG, SQL_C_ULONG
NB.         Characters                     SQL_C_CHAR
NB.         Double Precision Floats        SQL_C_DOUBLE
NB.
NB.      C types other than these three are handled as character
NB.      data and converted with J verbs.  Some non-char types
NB.      are left as char in J and not all SQL datatypes are supported.
NB.      Attempts to fetch an unsupported type should result in an error.
NB.      Executing:
NB.
NB.           dderr~ 2
NB.
NB.      after getting an unsupported type error should display a table
NB.      listing the offending columns and types.
NB.
NB.   3) All the supported datatypes can be fetched with (ddfet) only
NB.      fixed length and short datatypes (*'ed) can be returned by (ddfch).
NB.      This table is critical to the operation of this system. ALTER WITH CARE!

SQL_SUPPORTED_NAMES=: (];._2) 0 : 0
0 NB. SQL types            C default type           Into J as     Bytes Conversions
SQL_CHAR=: 1['*'           NB. SQL_C_CHAR           SQL_C_CHAR    1     ]
SQL_NUMERIC=: 2['*'        NB. SQL_C_CHAR           SQL_C_CHAR    1     ]
SQL_DECIMAL=: 3['*'        NB. SQL_C_CHAR           SQL_C_CHAR    1     ]
SQL_INTEGER=: 4['*'        NB. SQL_C_SLONG          SQL_C_SLONG   4     ]
SQL_SMALLINT=: 5['*'       NB. SQL_C_SSHORT         SQL_C_CHAR    2     ifs
SQL_FLOAT=: 6['*'          NB. SQL_C_DOUBLE         SQL_C_DOUBLE  8     ]
SQL_REAL=: 7['*'           NB. SQL_C_FLOAT          SQL_C_CHAR    4     ffs
SQL_DOUBLE=: 8['*'         NB. SQL_C_DOUBLE         SQL_C_DOUBLE  8     ]
SQL_TYPE_DATE=:91['*'      NB. SQL_C_TYPE_DATE      SQL_C_CHAR    16    fmtddts
SQL_TYPE_TIME=:92['*'      NB. SQL_C_TYPE_TIME      SQL_C_CHAR    6     fmttdts
SQL_TYPE_TIMESTAMP=:93['*' NB. SQL_C_TYPE_TIMESTAMP SQL_C_CHAR    6     fmtdts
SQL_SS_TIME2=: _154['*'    NB. SQL_C_BINARY         SQL_C_CHAR    12    fmttdts
SQL_SS_TIMESTAMPOFFSET=: _155['*'    NB. SQL_C_BINARY         SQL_C_CHAR    24    fmtdts
SQL_SS_XML=: _152          NB. SQL_C_BINARY         SQL_C_CHAR    1     ]
SQL_VARCHAR=: 12['*'       NB. SQL_C_CHAR           SQL_C_CHAR    1     trctnb trbuclnb
SQL_DEFAULT=: 99['*'       NB. SQL_C_DEFAULT        SQL_C_CHAR    1     ]
SQL_LONGVARCHAR=: _1['*'   NB. SQL_C_CHAR           SQL_C_CHAR    1     trbuclnb
SQL_BINARY=: _2['*'        NB. SQL_C_BINARY         SQL_C_CHAR    1     ]
SQL_VARBINARY=: _3['*'     NB. SQL_C_BINARY         SQL_C_CHAR    1     ]
SQL_LONGVARBINARY=:_4['*'  NB. SQL_C_BINARY         SQL_C_CHAR    1     ]
SQL_BIGINT=: _5['*'        NB. SQL_C_SBIGINT        SQL_C_CHAR    1     ]
SQL_TINYINT=: _6['*'       NB. SQL_C_STINYINT       SQL_C_CHAR    1     ]
SQL_BIT=: _7['*'           NB. SQL_C_BIT            SQL_C_CHAR    1     ]
SQL_WCHAR=: _8['*'         NB. SQL_C_WCHAR          +:SQL_C_CHAR  2     ]
SQL_WVARCHAR=: _9['*'      NB. SQL_C_WCHAR          +:SQL_C_CHAR  2     trctnb trbuclnb
SQL_WLONGVARCHAR=: _10['*' NB. SQL_C_WCHAR          +:SQL_C_CHAR  2     ]
SQL_UNIQUEID=:_11['*'      NB. SQL_C_CHAR           SQL_C_CHAR    36    trctguid
)

NB. =========================================================
NB. (settypeinfo) defines a series of locale globals that are
NB. datatype related.  (SQL_SUPPORTED_TYPES) lists all the types
NB. the jdd/ODBC interface can handle.  (SQL_COLBIND_TYPES) is a subset
NB. that can be bound to columns.
NB.
NB. monad:  settypeinfo uuIgnore
settypeinfo=: 3 : 0

NB. drop header
sqlnames=. }. SQL_SUPPORTED_NAMES
SQL_SUPPORTED_TYPES=: , ". sqlnames

NB. NB. (ddfch) type conversion gerund and type index - pass unlisted types
NB. GDX=: SQL_SMALLINT, SQL_VARCHAR, SQL_CHAR, SQL_TYPE_TIMESTAMP
NB. GCNM=: ;:'ifs           trctnb       trctnb     fmtdts'
NB.
NB. GDX=: GDX, SQL_REAL, SQL_WCHAR, SQL_WVARCHAR, SQL_UNIQUEID
NB. GCNM=: GCNM,;:'ffs       trctnb     trctnb        trctguid      ]'

NB. (ddfch) type conversion gerund and type index - char_trctnb on unlisted types
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

NB. handle 4 byte integers in J64
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

NB. sglgetdata datatypes gerund matches codes in SQL_SUPPORTED_TYPES
GGETV=: (sqlnames i."1'=') {."0 1 sqlnames
GGETV=: dltb&.> <"1 'get',"1 tolower 4 }."1 GGETV

NB. data types and subset that can be bound to columns
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
