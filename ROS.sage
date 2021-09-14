import hashlib
import struct
from datetime import datetime
import math
import json

l = 7

lambdaParameter = 103

R.<x0,x1,x2,x3,x4,x5,x6> = GF(lambdaParameter)[]

def coeffs(p):
	return [p.coefficient(x0),p.coefficient(x1),p.coefficient(x2),p.coefficient(x3),p.coefficient(x4),p.coefficient(x5),p.coefficient(x6),]

def encode(p):
	p = coeffs(p)
	result = b""
	for i in range(0, len(p)):
		result = result + struct.pack('q', int(p[i]))
	return result

def hash(x, aux = 'aux11'):
	return R(int(hashlib.sha224(bytes(str(aux), "ascii")+bytes(str(x), "ascii")).hexdigest(),16))


X = [x0, x1, x2, x3, x4, x5, x6]
p0 = x0
p1 = x1
p2 = x2
p3 = x3
p4 = x4
p5 = x5
p6 = x6

# C = [hash(encode(roh0)), hash(encode(roh1)), hash(encode(p2)), hash(encode(p3)), hash(encode(p4)),hash(encode(p5)),hash(encode(p6))]


caux = {
	"p0": [hash(encode(p0), 0), hash(encode(p0), 1)],
	"p1": [hash(encode(p1), 0), hash(encode(p1), 1)],
	"p2": [hash(encode(p2), 0), hash(encode(p2), 1)],
	"p3": [hash(encode(p3), 0), hash(encode(p3), 1)],
	"p4": [hash(encode(p4), 0), hash(encode(p4), 1)],
	"p5": [hash(encode(p5), 0), hash(encode(p5), 1)],
	"p6": [hash(encode(p6), 0), hash(encode(p6), 1)],
}


p7 = 0
print(caux)


for i in range(0,l):
	a = X[i]-caux["p"+str(i)][0]
	b = caux["p"+str(i)][1] - caux["p"+str(i)][0]
	p7 += 2^i * (a / b) 

print(p7)

hashp7 = int(hash(encode(p7)))
print(hashp7)
b = f'{hashp7:07b}'
print(b)
B = []
for i in range(1, l+1):
	B.append(b[i-1:i])
B.reverse()
C = []
for i in range(0,l):
	C.append(caux['p'+str(i)][int(B[i])])
print(B)
print(caux)
print(C)

for i in range(0,l):
	print('p'+str(i)+" with varibal list above evaluates to: "+str(int(X[i](C)))+' and hashes to: '+str(int(hash(encode(X[i]), B[i]))))
print("p7 with varibal list above evaluates to: "+str(int(p7(C)))+' and hashes to: '+str(int(hash(encode(p7)))))



# for i in range(0, l):



# hashp7 = hash(encode(p7), '')
# print(hashp7)
# b = []
# a = 0
# for i in range(0,l):
# 	power = 2^i
# 	intager = int(str(C[i])[:],10)
# 	a += (power*intager)
# 	b.append((power*intager) % lambdaParameter)
# print(b)
# print(a  % lambdaParameter)
# # newC = C[:]
# print(evaluate(p7, b))


