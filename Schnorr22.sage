from sage.cpython.string import str_to_bytes
import hashlib
import math


def hashN(x0, x1):
	return N(int(hashlib.sha256(x0+x1).hexdigest(),16))

def countBits(number):
    return int((math.log(number) /
                math.log(2)));

F = FiniteField (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
C = EllipticCurve ([F (0), F (7)])
#y^2 = x^3 + ax + b standard curve
#y^2 = x^3 + 0*x + 7 this curve
G = C.lift_x(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798) 
lambdaParameter = countBits(C.order())
N = FiniteField (C.order())

K = []
PX = N.random_element()
X = int(PX) * G

def padbytes(byteslist):
	if len(byteslist) >= 64:
		return byteslist
	else:
		return padbytes(b'0' + byteslist)

def encode(R):
	xy = R.xy()
	x = int(xy[0])
	y = int(xy[1])
	result = b''
	if y % 2:
		result += b'3'
	else:
		result += b'2'
	result += padbytes(bytes(hex(x), "utf8")[2:])
	return result


def sign1(i, c):
	return 

R = []
M = []
C = []
S = []
CB = []
zero = []


#Generate zero array
for i in range(0, lambdaParameter):
	zero.append(N(0))


for i in range(0, lambdaParameter):
	#Generate nonse
	k = N.random_element()
	K.append(k)
	#Generate public version of nonse
	r = int(k) * G
	R.append(r)
	#Generate two messages in which we will ask the server to sign
	m0 = bytes(str(int(N.random_element())), "utf8")
	m1 = bytes(str(int(N.random_element())), "utf8")
	#Hash our public nonse with the message as the aux string
	c0 = hashN(encode(r), m0)
	c1 = hashN(encode(r), m1)
	M.append([m0[:], m1[:]])
	C.append([c0, c1])

	
#Run the P256 function with the zero vector to get the 256th term of the hashes
p256256 = 0
for i in range(0, len(zero)):
	a = zero[i] - C[i][0]
	b = C[i][1] - C[i][0]
	p256256 += (N(2^i) / b) * a


#Run the P256 function with the public nonses to get a public nonse with the 256 term added on after multiplyied by the public key
r256 = 0 
for i in range(0, len(R)):
	a = R[i] - int(C[i][0]) * G
	b = C[i][1] - C[i][0]
	r256 += int(N(2^i) / b) * a
r256 += (int(p256256) * X)
#Generate the message we wish to forge a signature for
m256 = N.random_element()
#Hash the new public nonse and messagee
c256 = hashN(encode(r256), bytes(str(int(m256)), "utf8"))


#Turn the hash into a binary string
b = f'{int(c256):0256b}'
B = []
for i in range(1, lambdaParameter+1):
	B.append(b[i-1:i])
B.reverse()


#Choose the correct message hashes by the binary string generated
for i in range(0, lambdaParameter):
	CB.append(C[i][int(B[i], 2)])


#Ask the server for the signatures for the correct hashes
for i in range(0, lambdaParameter):
	si = K[i] - N(PX) * N(CB[i])
	S.append(si)


#Run the P256 function with the signatures to get the final signature
s256 = 0
for i in range(0, len(S)):
	a = S[i] - C[i][0]
	b = C[i][1] - C[i][0]
	s256 += (N(2^i) / b) * a
S.append(s256)

#Verify the final signature
print(((int(s256) * G) + (int(c256) * X)) == r256)



