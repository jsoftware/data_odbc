NB. api

3 : 0''
if. 0~: 4!:0<'PREFER_IODBC' do.
  PREFER_IODBC=. 0
end.
select. UNAME
case. 'Linux' do. libodbc=: (0-:PREFER_IODBC){::'libiodbc.so.2';'libodbc.so.2'
case. 'Darwin' do. libodbc=: (0-:PREFER_IODBC){::'libiodbc.dylib';'libodbc.dylib'
case. 'Win' do. libodbc=: 'odbc32.dll'
case. do. libodbc=: 'libodbc.so'
end.
i.0 0
)

NB. ODCB 3.x cd prototypes ------------------------------------------------
NB. This is only a small subset of the version 3.x ODBC API
sqlallochandle=: (libodbc, ' SQLAllocHandle s s x *x') &cd
sqlbindcol=: (libodbc, ' SQLBindCol s x s s * x *') &cd
sqlbindparameter=: (libodbc, ' SQLBindParameter s x s s s s x s * i *') &cd
sqlbulkoperations=: (libodbc, ' SQLBulkOperations s x s') &cd
sqlcancel=: (libodbc, ' SQLCancel s x') &cd
sqlcolumns=: (libodbc, ' SQLColumns s x * s * s *c s * s') &cd
sqlconnect=: (libodbc, ' SQLConnect s x *c s *c s *c s') &cd
sqldatasources=: (libodbc, ' SQLDataSources s x s *c s *s *c s *s') &cd
sqldescribecol=: (libodbc, ' SQLDescribeCol s x s *c s *s *s *x *s *s') &cd
sqldisconnect=: (libodbc, ' SQLDisconnect s x') &cd
sqldriverconnect=: (libodbc, ' SQLDriverConnect s x x *c s *c s *s s') &cd
sqldrivers=: (libodbc, ' SQLDrivers s x s *c s *s *c s *s') &cd
sqlendtran=: (libodbc, ' SQLEndTran s s x s') &cd
sqlexecdirect=: (libodbc, ' SQLExecDirect s x *c i') &cd
sqlexecdirectW=: (libodbc, ' SQLExecDirectW s x *w i') &cd
sqlexecute=: (libodbc, ' SQLExecute s x') &cd
sqlfetch=: (libodbc, ' SQLFetch s x') &cd
sqlfetchscroll=: (libodbc, ' SQLFetchScroll s x s x') &cd
sqlfreehandle=: (libodbc, ' SQLFreeHandle s s x') &cd
sqlgetfunctions=: (libodbc, ' SQLGetFunctions s x s *s') &cd
sqlgetdata=: (libodbc, ' SQLGetData s x s s * x *x') &cd
sqlgetdiagrec=: (libodbc, ' SQLGetDiagRec s s x s *c *i *c s *s') &cd
sqlgetinfo=: (libodbc, ' SQLGetInfo s x s * s *s') &cd
sqlgetstmtattr=: (libodbc, ' SQLGetStmtAttr s x i *x i *i') &cd
sqlgettypeinfo=: (libodbc, ' SQLGetTypeInfo s x s') &cd
sqlnumresultcols=: (libodbc, ' SQLNumResultCols s x *s') &cd
sqlprepare=: (libodbc, ' SQLPrepare s x *c i') &cd
sqlprepareW=: (libodbc, ' SQLPrepareW s x *w i') &cd
sqlrowcount=: (libodbc, ' SQLRowCount s x *x') &cd
sqlsetconnectattr=: (libodbc, ' SQLSetConnectAttr s x i x i') &cd
sqlsetenvattr=: (libodbc, ' SQLSetEnvAttr s x i x i') &cd
sqlsetstmtattr=: (libodbc, ' SQLSetStmtAttr s x i x i') &cd
sqltables=: (libodbc, ' SQLTables s x *c s *c s *c s *c s') &cd
sqlcolattribute=: (libodbc, ' SQLColAttribute s x s s *c s *s *') &cd
sqlgetconnectattra=: (libodbc, ' SQLGetConnectAttr s x i * i *i') &cd
sqlsetconnectattra=: (libodbc, ' SQLSetConnectAttr s x i x i') &cd
