import hashlib
import struct
from datetime import datetime
import math
import json


lambdaParameter = 103


def hash(x, aux = 'aux11'):
	if aux == '':
		return int(hashlib.sha224(bytes(str(x), "ascii")).hexdigest(),16) % lambdaParameter
	else:
		return int(hashlib.sha224(bytes(str(aux), "ascii")+bytes(str(x), "ascii")).hexdigest(),16) % lambdaParameter

def encode(p):
	result = b""
	for i in range(0, len(p)):
		result = result + struct.pack('q', p[i])
	return result

def evaluate(p, c):
	result = 0
	for i in range(0, len(p)):
		if i == (len(p) - 1):
			result += p[i]
		else:
			result += p[i] * c[i]
	return result % lambdaParameter


def unevaluate2(p):
	hashp = hash(encode(p))
	result = []
	for i in range(0, lambdaParameter+1):
		for x in range(0, lambdaParameter+1):
			for y in range(0, lambdaParameter+1):
				evalp = evaluate(p, [i, x, y])
				if hashp == evalp:
					result.append([i, x, y])
	return result

def increaseP(P):
	p = P
	carry = True 
	for i in range(0,len(p)):
		if carry:
			p[i] += 1
			if p[i] >= lambdaParameter:
				p[i] = 0
				carry = True
			else:
				carry = False
		else:
			break
	return (p, carry)