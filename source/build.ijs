NB. build

writesourcex_jp_ '~Addons/data/odbc/source';'~Addons/data/odbc/odbc.ijs'

(jpath '~addons/data/odbc/odbc.ijs') (fcopynew ::0:) jpath '~Addons/data/odbc/odbc.ijs'

f=. 3 : 0
(jpath '~Addons/data/odbc/',y) fcopynew jpath '~Addons/data/odbc/source/',y
(jpath '~addons/data/odbc/',y) (fcopynew ::0:) jpath '~Addons/data/odbc/source/',y
)

mkdir_j_ jpath '~addons/data/odbc'
f 'manifest.ijs'
f 'history.txt'
f 'test/test.ijs'
f 'test/test0.ijs'
f 'test/test1.ijs'
f 'test/test2.ijs'
f 'test/test3.ijs'
