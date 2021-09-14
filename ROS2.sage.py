

# This file was *autogenerated* from the file ROS2.sage
from sage.all_cmdline import *   # import sage library

_sage_const_571 = Integer(571); _sage_const_2 = Integer(2); _sage_const_0 = Integer(0); _sage_const_1 = Integer(1); _sage_const_16 = Integer(16)
import hashlib
import struct
from datetime import datetime
import math
import json


Prime = _sage_const_571 
IntPrime = Integers(Prime)
lambdaParameter = math.ceil((math.log(Prime) / math.log(_sage_const_2 )));

w = _sage_const_0  #2^w = 7

L = _sage_const_0 

k1 = _sage_const_2 **w-_sage_const_1  # 7
k2 = max(_sage_const_0 , math.ceil(lambdaParameter - (w + _sage_const_1 ) * L)) # 0

l = k1+k2
R = PolynomialRing(GF(Prime),l,"x")
Y = R.gens()
X = []
P = []
for x in Y:
	X.append(x)
	P.append(x)

def coeffs(p):
	result = []
	zero = []
	for x in X:
		result.append(p.coefficient(x))
		zero.append(_sage_const_0 )
	result.append(p(zero))
	return result

def encode(p):
	p = coeffs(p)
	result = b""
	for i in range(_sage_const_0 , len(p)):
		result = result + struct.pack('q', int(p[i]))
	return result

def hash(x, aux = 'aux321'):
	return IntPrime(R(int(hashlib.sha224(bytes(str(aux), "ascii")+bytes(str(x), "ascii")).hexdigest(),_sage_const_16 )))

def convertBinary(binairyInt):
	b = f'{int(binairyInt):0{l}b}'
	B = []
	for i in range(_sage_const_1 , k2-_sage_const_1 +_sage_const_2 ):
		B.append(b[i-_sage_const_1 :i])
	B.reverse()
	return B

def genCaux():
	caux = {}
	for i in range(_sage_const_0 , l):
		caux["p"+str(i)] = [hash(encode(X[i]), _sage_const_0 ), hash(encode(X[i]), _sage_const_1 )]
	return caux

def Ii(i):
	return range(-math.floor((Prime-_sage_const_1 )/_sage_const_2 **(((w-i)*L)+_sage_const_1 )),math.floor((Prime-_sage_const_1 )/_sage_const_2 **(((w-i)*L)+_sage_const_1 )))

def join(a, b, rangep):
	result = []
	for i in range(_sage_const_0 , len(a)):
		for j in range(_sage_const_0 , len(b)):
			ab = a[i][_sage_const_1 ]+b[j][_sage_const_1 ]
			if ((ab) in rangep):
				result.append((a[i][_sage_const_0 ]+b[j][_sage_const_0 ],ab,a[i][_sage_const_2 ]+b[j][_sage_const_2 ]))
	return result

caux = genCaux()

## Generate xi' 
xP = []
for i in range(_sage_const_0 ,l):
	a = X[i]-caux["p"+str(i)][_sage_const_0 ]
	b = caux["p"+str(i)][_sage_const_1 ] - caux["p"+str(i)][_sage_const_0 ]
	xP.append((a / b)) 

## Calculate First Term of RhoL
ft = _sage_const_0 
for i in range(_sage_const_0 , (k2-_sage_const_1 )+_sage_const_1 ): 
	ft += _sage_const_2 **i * xP[i]

## Calculate Mid Term of RhoL
a = Prime - _sage_const_1 
b = _sage_const_2 **((w+_sage_const_1 )*L+_sage_const_1 )
mt = IntPrime(math.floor((a / b)))

## Calculate End Term of RhoL
et = _sage_const_0 
for i in range(k2, (k1+k2-_sage_const_1 )+_sage_const_1 ):
	et += X[i]

Pl = ft - mt - et
hashp7 = int(hash(encode(Pl)))
P.append(Pl)


## Need a better definiton of this function
def kListHROS(w, L, P):
	##Setup ----
	aux = []
	for i in range(_sage_const_1 , _sage_const_2 **L+_sage_const_1 ):
		aux.append(i)
	Liw = []
	for i in range(_sage_const_0 , len(P)):
		Li = []
		for j in range(_sage_const_0 , len(aux)):
			Li.append(([IntPrime(hash(encode(P[i]), aux[j]))],IntPrime(hash(encode(P[i]), aux[j])),[aux[j]]))
		Liw.append(Li)
	Tree = [Liw]
	##Collison ----
	for x in range(_sage_const_0 , w): #add one because SUM is inclusive and end range is exclusive minus one because the range should be 1 - w
		FLi = []
		level = w-x
		TreeLevel = Tree[x]
		for j in range(_sage_const_0 , _sage_const_2 **(level-_sage_const_1 )): #add one because SUM is inclusive and end range is exclusive minus one because we are indexing from 0
			FLi.append(join(TreeLevel[j*_sage_const_2 ],TreeLevel[_sage_const_2 *j+_sage_const_1 ],Ii(level))) #minus one because lists are 1 indexed in the paper
		Tree.append(FLi)
	finalTree = Tree[w][_sage_const_0 ]
	result = []
	for i in range(_sage_const_0 , len(finalTree)):
		if finalTree[i][_sage_const_1 ] == _sage_const_0 :
			result = (finalTree[i][_sage_const_0 ], finalTree[i][_sage_const_1 ], finalTree[i][_sage_const_2 ])
			break
		result = ([],_sage_const_0 ,[])
	return result
(y, s, auxk2l) = kListHROS(w, math.ceil(L), P)


spl = hashp7 - s + mt

B = convertBinary(spl)

Cib = []
auxi = []
for i in range(_sage_const_0 ,k2-_sage_const_1 +_sage_const_1 ):
	Cib.append(caux['p'+str(i)][int(B[i])])
	auxi.append(B[i])

C = []
for i in range(_sage_const_0 , k2-_sage_const_1 +_sage_const_1 ):
	C.append(Cib[i])

for i in range(k2, l-_sage_const_1 +_sage_const_1 ):
	C.append(y[i])
	auxi.append(auxk2l[i])
if (k2 < l):
	auxi.append(auxk2l[l])
else:
	auxi.append('aux321')

print(Pl(C))

for i in range(_sage_const_0 ,l-_sage_const_1 +_sage_const_1 ):
	print('p'+str(i)+" with varibal list above evaluates to: "+str(int(X[i](C)))+' and hashes to: '+str(int(hash(encode(X[i]), auxi[i])))+' with the aux value '+str(auxi[i]))
print("pL with varibal list above evaluates to: "+str(int(Pl(C)))+' and hashes to: '+str(int(hash(encode(Pl), auxi[l]))) +' with the aux value '+str(auxi[l]))



