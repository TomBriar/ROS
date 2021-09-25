import hashlib
import struct
from datetime import datetime
import math
import json


Prime = 115792089237316195423570985008687907852837564279074904382605163141518161494337
IntPrime = Integers(Prime)
lambdaParameter = math.ceil((math.log(Prime) / math.log(2)));
print(lambdaParameter)

w = 3 #2^w = 7

L = 5

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
		hexval = str(int(p[i]))
		result = result + hexval.encode()
	return result

def hash(x, aux = 'aux321'):
	return IntPrime(R(int(hashlib.sha256(bytes(str(aux), "ascii")+bytes(str(x), "ascii")).hexdigest(),16)))

def padzero(binary, length):
	if (len(binary) >= length):
		return binary
	binary.insert(0,'0')
	return padzero(binary, length)

def convertBinary(binaryInt):
	print("start convert Binary")
	print(binaryInt)
	b = list(str(bin(binaryInt))[2:])
	print(b)
	B = padzero(b, k2)
	B.reverse()
	print(B)
	return B

def genCaux():
	caux = {}
	for i in range(0, l):
		caux["p"+str(i)] = [hash(encode(X[i]), 0), hash(encode(X[i]), 1)]
	return caux

def Ii(i):
	return (IntPrime(0)-int((Prime-1)/2^(((w-i)*L)+1)),IntPrime(int((Prime-1)/2^(((w-i)*L)+1))))

def inRange(rangetup, hashval):
	if (rangetup[0] > rangetup[1]):
		if (hashval > rangetup[0] or hashval < rangetup[1]):
			return True
	if (rangetup[0] < rangetup[1]):
		if (hashval > rangetup[0] and hashval < rangetup[1]):
			return True
	return False

def join(a, b, level):
	print("RUn join")
	print(len(a))
	print(len(b))
	result = []
	for i in range(0, len(a)):
		for j in range(0, len(b)):
			ab = a[i][1]+b[j][1]  #todo modlus
			if (inRange(Ii(level), ab)):
				result.append((a[i][0]+b[j][0],ab,a[i][2]+b[j][2]))
				currentY = a[i][0]+b[j][0]
				sumY = 0
				for x in range(0, len(currentY)):
					sumY += currentY[x]
				assert(sumY == ab)
				if (len(result) >= 1024): 
					return result
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
mt = IntPrime(int((a / b)))
print("mt")
print(mt)

## Calculate End Term of RhoL
et = 0
for i in range(k2, (k1+k2-1)+1):
	et += X[i]

Pl = ft - mt - et
Cl = int(hash(encode(Pl)))
P.append(Pl)


# print(Ii(1))
# print(inRange(Ii(1), 10))
# print(inRange(Ii(1), 115792089237316195423570985008687907852837564279074904382605163141518161494337))



## Need a better definiton of this function
def kListHROS(w, L, P):
	#Setup ----
	print("start setup")
	aux = []
	for i in range(0, 2^L):
		aux.append(i)
	print(aux)
	Liw = []
	for i in range(0, len(P)):
		print("p"+str(i))
		Li = []
		for j in range(0, len(aux)):
			Li.append(([IntPrime(hash(encode(P[i]), aux[j]))],IntPrime(hash(encode(P[i]), aux[j])),[aux[j]]))
		Liw.append(Li)
	Tree = [Liw]

	##Collison ----
	for x in range(0, w): #add one because SUM is inclusive and end range is exclusive minus one because the range should be 1 - w
		print("level: "+str(x))
		FLi = []
		level = w-x
		TreeLevel = Tree[x]
		for j in range(0, 2^(level-1)): #add one because SUM is inclusive and end range is exclusive minus one because we are indexing from 0
			print("j"+(str(j)))
			FLi.append(join(TreeLevel[j*2],TreeLevel[2*j+1],level)) #minus one because lists are 1 indexed in the paper
		Tree.append(FLi)
		
	finalTree = Tree[w][0]
	print(len(finalTree))
	result = []
	for i in range(0, len(finalTree)):
		if inRange(Ii(-1), finalTree[i][1]):
			result = (finalTree[i][0], finalTree[i][1], finalTree[i][2])
			break
		result = ([],0,[])
	return result

P2 = []
for i in range(0, 2^w):
	P2.append(P[k2+i])



(y, s, auxk2l) = kListHROS(w, math.ceil(L), P2)

sumY = 0
for i in range(0, len(y)):
	sumY += y[i]
assert(sumY == s)

smt = s + mt

B = convertBinary(smt)

Cib = []
auxi = []
for i in range(0,k2-1+1):
	Cib.append(caux['p'+str(i)][int(B[i])])
	auxi.append(B[i])


C = []
for i in range(0, k2-1+1):
	C.append(Cib[i])

for i in range(0, k1):
	C.append(y[i])
	# print("y["+str(i)+"] = "+str(y[i]))
	auxi.append(auxk2l[i])
if (k2 < l):
	auxi.append(auxk2l[k1])
else:
	auxi.append('aux321')

assert(y[k1] == int(hash(encode(Pl), auxi[l])))

for i in range(0,l-1+1):
	assert(int(X[i](C)) == int(hash(encode(X[i]), auxi[i])))
	# print('p'+str(i)+" with varibal list above evaluates to: "+str(int(X[i](C)))+' and hashes to: '+str(int(hash(encode(X[i]), auxi[i])))+' with the aux value '+str(auxi[i]))
print("pL with varibal list above evaluates to: "+str(int(Pl(C)))+' and hashes to: '+str(int(hash(encode(Pl), auxi[l]))) +' with the aux value '+str(auxi[l]))

Cl = hash(encode(Pl), auxi[l])

sumXp = 0
for i in range(0, k2):
	sumXp += 2^i * xP[i](C)

sumC = 0
for i in range(k2, l):
	sumC += X[i](C)

sumB = 0
for i in range(0, k2):
	sumB += 2^i * int(B[i])
sumY = 0
for i in range(k2, l):
	sumY += y[i-k2]

assert(sumB == sumXp)
assert(sumB == s+mt)

print("1 = "+str(int(Pl(C))))
print("2 = "+str((sumXp - mt - sumC) % Prime))
print("3 = "+str((sumB - mt - sumY) % Prime))
print("4 = "+str((s - sumY) % Prime))
print("5 = "+str(int(hash(encode(Pl), auxi[l]))))
print("d = "+str(hash(encode(Pl), auxi[l]) - int(Pl(C))))
print("m = "+str(mt))
print("s = "+str(s))


Yval = 0
for i in range(0, len(y)):
	Yval += y[i]
print("s - y  = "+str(s-Yval))

print(Ii(-1))


#              = 67335027711028348519148087300636081720158523555595798438729264680836696171822
#Cl            = 67335061525574109029746721603323635537974763533130538253132863068605048486494
#s + mt        = 67334976114994509657372820354118364484484835663119674732280079909222781096892
#Cl - (s + mt) = 67335061525524515770105222142291029771529647428223222804102787203170005642779
#s - mt        = 67335086136612356291202776805440409937262388740335668083631675309067603233376
#Cl - (s - mt) = 67335061525629828061773779328988947799213317860541724615452816245450413129850
#s             = 67335086136665012437037055398789368951104223956494918989306689830207806976911
#Cl - s        = 67335061525577171915939500735639988785371482644382473709777801724310209386314
#Cl + s        = 67335061525571046143553942471007282290578044421878602796487924412899887586673
#newCl         = 67335039924413049185070173788443570812405769538083078545009833255144324801299
#newCl - s     = 67335039924416112071262952920759924059802488649335014001654771910849485701120
#s - newCl     = 67335068133230453178142998795703522043490613099215197166492303415478769738865
#newCl - (s-mt)= 67335039924468768217097231514108883073644323865494264907329786431989689444655
#newCl - (s+mt)= 67335039924363455925428674327410965045960653433175763095979757389709281957584
		



