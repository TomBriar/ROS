import hashlib
import struct
from datetime import datetime
import math
import json
from basesage import *

def lequal2():
	hashtable = {}
	p = [1, 1, 1]
	while True:
		(p, carry) = increaseP(p)
		print(p)
		if carry:
			print('failed')
			print(hashtable)
			break
		evalp = unevaluate2(p)
		for i in range(0, len(evalp)):
			if str(evalp[i]) in hashtable:
				hashtable[str(evalp[i])].append(p[:])
				# print('adding a new entry to c: '+str(evalp[i])+' with value: '+str(p)+' new entry: '+str(hashtable[str(evalp[i])]))
				if len(hashtable[str(evalp[i])]) >= 3:
					print(str(hashtable[str(evalp[i])])+' all have the same c: '+str(evalp[i]))
					# return ''
			else:
				hashtable[str(evalp[i])] = [p[:]]
				# print('create a new entry to c: '+str(evalp[i])+' with value: '+str(p)+' new entry: '+str(hashtable[str(evalp[i])]))


lequal2()