import hashlib
import struct
from datetime import datetime
import math
import json


Prime = 571
IntPrime = Integers(Prime)
lambdaParameter = math.ceil((math.log(Prime) / math.log(2)));
print(lambdaParameter)

w = 0 #2^w = 7

L = 0

k1 = 2^w-1 # 7
k2 = max(0, math.ceil(lambdaParameter - (w + 1) * L)) # 0
print(k1)
print(k2)
print(k1+k2)

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
		zero.append(0)
	result.append(p(zero))
	return result

def encode(p):
	p = coeffs(p)
	result = b""
	for i in range(0, len(p)):
		result = result + struct.pack('q', int(p[i]))
	return result

def hash(x, aux = 'aux321'):
	return IntPrime(R(int(hashlib.sha224(bytes(str(aux), "ascii")+bytes(str(x), "ascii")).hexdigest(),16)))

def convertBinary(binairyInt):
	b = f'{int(binairyInt):0{l}b}'
	B = []
	for i in range(1, k2-1+2):
		B.append(b[i-1:i])
	B.reverse()
	return B

def genCaux():
	caux = {}
	for i in range(0, l):
		caux["p"+str(i)] = [hash(encode(X[i]), 0), hash(encode(X[i]), 1)]
	return caux

def Ii(i):
	return range(-math.floor((Prime-1)/2^(((w-i)*L)+1)),math.floor((Prime-1)/2^(((w-i)*L)+1)))

def join(a, b, rangep):
	result = []
	for i in range(0, len(a)):
		for j in range(0, len(b)):
			ab = a[i][1]+b[j][1]
			if ((ab) in rangep):
				result.append((a[i][0]+b[j][0],ab,a[i][2]+b[j][2]))
	return result

caux = genCaux()

## Generate xi' 
xP = []
for i in range(0,l):
	a = X[i]-caux["p"+str(i)][0]
	b = caux["p"+str(i)][1] - caux["p"+str(i)][0]
	xP.append((a / b)) 

## Calculate First Term of RhoL
ft = 0
for i in range(0, (k2-1)+1): 
	ft += 2^i * xP[i]

## Calculate Mid Term of RhoL
a = Prime - 1
b = 2^((w+1)*L+1)
mt = IntPrime(math.floor((a / b)))
print("mt")
print(mt)

## Calculate End Term of RhoL
et = 0
for i in range(k2, (k1+k2-1)+1):
	et += X[i]

Pl = ft - mt - et
hashp7 = int(hash(encode(Pl)))
P.append(Pl)


## Need a better definiton of this function
def kListHROS(w, L, P):
	##Setup ----
	aux = []
	for i in range(1, 2^L+1):
		aux.append(i)
	Liw = []
	for i in range(0, len(P)):
		Li = []
		for j in range(0, len(aux)):
			Li.append(([IntPrime(hash(encode(P[i]), aux[j]))],IntPrime(hash(encode(P[i]), aux[j])),[aux[j]]))
		Liw.append(Li)
	Tree = [Liw]
	##Collison ----
	for x in range(0, w): #add one because SUM is inclusive and end range is exclusive minus one because the range should be 1 - w
		FLi = []
		level = w-x
		TreeLevel = Tree[x]
		for j in range(0, 2^(level-1)): #add one because SUM is inclusive and end range is exclusive minus one because we are indexing from 0
			FLi.append(join(TreeLevel[j*2],TreeLevel[2*j+1],Ii(level))) #minus one because lists are 1 indexed in the paper
		Tree.append(FLi)
	finalTree = Tree[w][0]
	result = []
	for i in range(0, len(finalTree)):
		if finalTree[i][1] == 0:
			result = (finalTree[i][0], finalTree[i][1], finalTree[i][2])
			break
		result = ([],0,[])
	return result
(y, s, auxk2l) = kListHROS(w, math.ceil(L), P)


spl = hashp7 - s + mt

B = convertBinary(spl)

Cib = []
auxi = []
for i in range(0,k2-1+1):
	Cib.append(caux['p'+str(i)][int(B[i])])
	auxi.append(B[i])

C = []
for i in range(0, k2-1+1):
	C.append(Cib[i])

for i in range(k2, l-1+1):
	C.append(y[i])
	auxi.append(auxk2l[i])
if (k2 < l):
	auxi.append(auxk2l[l])
else:
	auxi.append('aux321')

print(Pl(C))

for i in range(0,l-1+1):
	print('p'+str(i)+" with varibal list above evaluates to: "+str(int(X[i](C)))+' and hashes to: '+str(int(hash(encode(X[i]), auxi[i])))+' with the aux value '+str(auxi[i]))
print("pL with varibal list above evaluates to: "+str(int(Pl(C)))+' and hashes to: '+str(int(hash(encode(Pl), auxi[l]))) +' with the aux value '+str(auxi[l]))


