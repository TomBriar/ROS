

# This file was *autogenerated* from the file base.sage
from sage.all_cmdline import *   # import sage library

_sage_const_103 = Integer(103); _sage_const_16 = Integer(16); _sage_const_0 = Integer(0); _sage_const_1 = Integer(1)
import hashlib
import struct
from datetime import datetime
import math
import json


lambdaParameter = _sage_const_103 


def hash(x, aux = 'aux11'):
	if aux == '':
		return int(hashlib.sha224(bytes(str(x), "ascii")).hexdigest(),_sage_const_16 ) % lambdaParameter
	else:
		return int(hashlib.sha224(bytes(str(aux), "ascii")+bytes(str(x), "ascii")).hexdigest(),_sage_const_16 ) % lambdaParameter

def encode(p):
	result = b""
	for i in range(_sage_const_0 , len(p)):
		result = result + struct.pack('q', p[i])
	return result

def evaluate(p, c):
	result = _sage_const_0 
	for i in range(_sage_const_0 , len(p)):
		if i == (len(p) - _sage_const_1 ):
			result += p[i]
		else:
			result += p[i] * c[i]
	return result % lambdaParameter


def unevaluate2(p):
	hashp = hash(encode(p))
	result = []
	for i in range(_sage_const_0 , lambdaParameter+_sage_const_1 ):
		for x in range(_sage_const_0 , lambdaParameter+_sage_const_1 ):
			for y in range(_sage_const_0 , lambdaParameter+_sage_const_1 ):
				evalp = evaluate(p, [i, x, y])
				if hashp == evalp:
					result.append([i, x, y])
	return result

def increaseP(P):
	p = P
	carry = True 
	for i in range(_sage_const_0 ,len(p)):
		if carry:
			p[i] += _sage_const_1 
			if p[i] >= lambdaParameter:
				p[i] = _sage_const_0 
				carry = True
			else:
				carry = False
		else:
			break
	return (p, carry)

