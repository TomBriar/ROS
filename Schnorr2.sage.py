

# This file was *autogenerated* from the file Schnorr2.sage
from sage.all_cmdline import *   # import sage library

_sage_const_16 = Integer(16); _sage_const_2 = Integer(2); _sage_const_0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F = Integer(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F); _sage_const_0 = Integer(0); _sage_const_7 = Integer(7); _sage_const_0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798 = Integer(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798); _sage_const_256 = Integer(256); _sage_const_64 = Integer(64); _sage_const_1 = Integer(1); _sage_const_257 = Integer(257)
from sage.cpython.string import str_to_bytes
import hashlib
import math


def hashN(x0, x1):
	return N(int(hashlib.sha256(x0+x1).hexdigest(),_sage_const_16 ))

def countBits(number):
    return int((math.log(number) /
                math.log(_sage_const_2 )));

F = FiniteField (_sage_const_0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F )
C = EllipticCurve ([F (_sage_const_0 ), F (_sage_const_7 )])
#y^2 = x^3 + ax + b standard curve
#y^2 = x^3 + 0*x + 7 this curve
G = C.lift_x(_sage_const_0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798 ) 
lambdaParameter = _sage_const_256 
N = FiniteField (C.order())

K = []
PX = N.random_element()
X = int(PX) * G

def padbytes(byteslist):
	if len(byteslist) >= _sage_const_64 :
		return byteslist
	else:
		return padbytes(b'0' + byteslist)

def encode(R):
	xy = R.xy()
	x = int(xy[_sage_const_0 ])
	y = int(xy[_sage_const_1 ])
	result = b''
	if y % _sage_const_2 :
		result += b'3'
	else:
		result += b'2'
	result += padbytes(bytes(hex(x), "utf8")[_sage_const_2 :])
	return result


def sign1(i, c):
	return 

S = []
CB = []


#Generate zero array
zero256 = []
for i in range(_sage_const_0 , _sage_const_256 ):
	zero256.append(N(_sage_const_0 ))

K256 = []
R256 = []
M256 = []
C256 = []
for i in range(_sage_const_0 , _sage_const_256 ):
	#Generate nonse
	k = N.random_element()
	K256.append(k)
	#Generate public version of nonse
	r = int(k) * G
	R256.append(r)
	#Generate two messages in which we will ask the server to sign
	m0 = bytes(str(int(N.random_element())), "utf8")
	m1 = bytes(str(int(N.random_element())), "utf8")
	#Hash our public nonse with the message as the aux string
	c0 = hashN(encode(r), m0)
	c1 = hashN(encode(r), m1)
	M256.append([m0[:], m1[:]])
	C256.append([c0, c1])

	
#Run the P256 function with the zero vector to get the 256th term of the hashes
p256256 = _sage_const_0 
for i in range(_sage_const_0 , _sage_const_256 ):
	a = zero256[i] - C256[i][_sage_const_0 ]
	b = C256[i][_sage_const_1 ] - C256[i][_sage_const_0 ]
	p256256 += (N(_sage_const_2 **i) / b) * a


#Run the P256 function with the public nonses to get a public nonse with the 256 term added on after multiplyied by the public key
r257 = _sage_const_0  
for i in range(_sage_const_0 , _sage_const_256 ):
	a = R256[i] - int(C256[i][_sage_const_0 ]) * G
	b = C256[i][_sage_const_1 ] - C256[i][_sage_const_0 ]
	r257 += int(N(_sage_const_2 **i) / b) * a
r257 += (int(p256256) * X)
#Generate the message we wish to forge a signature for
m2570 = N.random_element()
m2571 = N.random_element()

#Hash the new public nonse and messagee
c257 = [hashN(encode(r257), bytes(str(int(m2570)), "utf8")), hashN(encode(r257), bytes(str(int(m2571)), "utf8"))]

#******

# create the zero array for 257 0
zero257 = []
for i in range(_sage_const_0 , _sage_const_257 ):
	zero257.append(N(_sage_const_0 ))

C257 = C256+[c257]

#get the p257 257th term
p257257 = _sage_const_0 
for i in range(_sage_const_0 , _sage_const_257 ):
	a = zero257[i] - C257[i][_sage_const_0 ]
	b = C257[i][_sage_const_1 ] - C257[i][_sage_const_0 ]
	p257257 += (N(_sage_const_2 **i) / b) * a

#generate a second meessage to be signed
m258 = N.random_element()

#Create the public nonse for the 258th signature using all 256 valid hashes and our 257th hash
R257 = R256 + [r257]
r258 = _sage_const_0  
for i in range(_sage_const_0 , _sage_const_257 ):
	a = R257[i] - int(C257[i][_sage_const_0 ]) * G
	b = C257[i][_sage_const_1 ] - C257[i][_sage_const_0 ]
	r258 += int(N(_sage_const_2 **i) / b) * a
r258 += (int(p257257) * X)

#Create the 258th hash
c258 = hashN(encode(r258), bytes(str(int(m258)), "utf8"))

#Select all proper 256th hashes and our 257th hash
b = f'{int(c258):0257b}'
B257 = []
for i in range(_sage_const_1 , _sage_const_257 +_sage_const_1 ):
	B257.append(b[i-_sage_const_1 :i])
B257.reverse()

# Choose the correct message hashes by the binary string generated
CB2562 = []
for i in range(_sage_const_0 , _sage_const_256 ):
	CB2562.append(C257[i][int(B257[i], _sage_const_2 )])

c257 = c257[int(B257[_sage_const_256 ], _sage_const_2 )]
#******


#Select all poper 256 hashes for our 257th hash
b = f'{int(c257):0256b}'
B256 = []
for i in range(_sage_const_1 , _sage_const_256 +_sage_const_1 ):
	B256.append(b[i-_sage_const_1 :i])
B256.reverse()


#Choose the correct message hashes by the binary string generated
CB256 = []
for i in range(_sage_const_0 , _sage_const_256 ):
	CB256.append(C256[i][int(B256[i], _sage_const_2 )])



#Ask the server for the signatures for the correct hashes
S256 = []
for i in range(_sage_const_0 , _sage_const_256 ):
	si = K256[i] - N(PX) * N(CB256[i])
	S256.append(si)

S2562 = []
for i in range(_sage_const_0 , _sage_const_256 ):
	si = K256[i] - N(PX) * N(CB2562[i])
	S2562.append(si)

#Generate the 257th siganutre
s257 = _sage_const_0 
for i in range(_sage_const_0 , _sage_const_256 ):
	a = S256[i] - C256[i][_sage_const_0 ]
	b = C256[i][_sage_const_1 ] - C256[i][_sage_const_0 ]
	s257 += (N(_sage_const_2 **i) / b) * a
S.append(s257)

#Generate the 258th sigantureu
S257 = S2562+[s257]
s258 = _sage_const_0 
for i in range(_sage_const_0 , _sage_const_257 ):
	a = S257[i] - C257[i][_sage_const_0 ]
	b = C257[i][_sage_const_1 ] - C257[i][_sage_const_0 ]
	s258 += (N(_sage_const_2 **i) / b) * a
S.append(s258)

#*******
# K257 = K256+[]
# S257 = []
# for i in range(0, 256):
# 	si = K256[i] - N(PX) * N(CB257[i])
# 	S257.append(si)

#*******


#Verify the final signature
print(((int(s257) * G) + (int(c257) * X)) == r257)
print(((int(s258) * G) + (int(c258) * X)) == r258)



#You must use two diffrent messages that you don't know which one will be used.
#Some how you must ask the server to geterate a signature multiple times for the same R but Different M's with probibility half





