

# This file was *autogenerated* from the file lequal3.sage
from sage.all_cmdline import *   # import sage library

_sage_const_103 = Integer(103); _sage_const_1 = Integer(1); _sage_const_0 = Integer(0); _sage_const_4 = Integer(4)
import hashlib
import struct
from datetime import datetime
import math
import json
from basesage import *


lambdaParameter = _sage_const_103 

def lequal3():
	hashtable = {}
	p = [_sage_const_1 , _sage_const_1 , _sage_const_1 , _sage_const_1 ]
	while True:
		(p, carry) = increaseP(p)
		print(p)
		if carry:
			print('failed')
			print(hashtable)
			break
		evalp = unevaluate2(p)
		for i in range(_sage_const_0 , len(evalp)):
			if str(evalp[i]) in hashtable:
				hashtable[str(evalp[i])].append(p[:])
				# print('adding a new entry to c: '+str(evalp[i])+' with value: '+str(p)+' new entry: '+str(hashtable[str(evalp[i])]))
				if len(hashtable[str(evalp[i])]) >= _sage_const_4 :
					print(str(hashtable[str(evalp[i])])+' all have the same c: '+str(evalp[i]))
					# return ''
			else:
				hashtable[str(evalp[i])] = [p[:]]
				# print('create a new entry to c: '+str(evalp[i])+' with value: '+str(p)+' new entry: '+str(hashtable[str(evalp[i])]))



lequal3()



