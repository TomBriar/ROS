import hashlib
import struct
from datetime import datetime
import math
import json
from basesage import *

def test():
	cof = 0
	result = []
	while True:
		hashval = hash(cof)
		print(cof, hashval)
		if hashval == cof:
			result.append(str(cof)+"'s hash is equal to "+str(hashval))
		if cof >= 103:
			print(result)
			break
		cof = cof + 1
