NB. ddpost
NB.
NB. Post-processor script for (jdd.ijs).  Statements in this script
NB. are executed after (jdd.ijs) is loaded.

NB. put these into z locale for ddparm
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
NB. initialize ODBC environment - any extant environment is ended
endodbcenv 0
InitDone=: 1
settypeinfo 0
initodbcenv 0
setzlocale 0

EMPTY
)
