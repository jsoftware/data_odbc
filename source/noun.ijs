NB.noun

'UCS2 UCS4 UTF8 OEMCP'=: i.4

NB. various bugs in bugflag
BUGFLAG_BINDPARMBIGINT=: 8          NB. 64 bit driver that cannot bind to BIGINT in sqlbindparameter
BUGFLAG_WCHAR_SUTF8=: 16            NB. sqldescribecol return wchar as 4-byte utf8 single byte char
BUGFLAG_LONGVARBINARY_BINARY=: 128  NB. sqldescribecol return BINARY for LONGVARBINARY
BUGFLAG_BULKOPERATIONS=: 256        NB. does not support sqlbulkoperations
IFTIMESTRUC=: 1                     NB. use sql_c_timestamp struc

NB. =========================================================
NB. common combinations of SQL codes
DD_SUCCESS1=: SQL_SUCCESS,SQL_SUCCESS_WITH_INFO,SQL_NO_DATA
DD_SUCCESS=: SQL_SUCCESS,SQL_SUCCESS_WITH_INFO
DD_ERROR=: SQL_ERROR,SQL_INVALID_HANDLE
DD_OK=: 0
