from sage.cpython.string import str_to_bytes
import hashlib
import math

# Define a hash function over N
def hashN(x0, x1):
	return N(int(hashlib.sha256(x0+x1).hexdigest(),16))

# Helper function for counting the bits of a number
def countBits(number):
    return int((math.log(number) /
                math.log(2)));

# Define our Fields and Curve
F = FiniteField (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
C = EllipticCurve ([F (0), F (7)])
#y^2 = x^3 + ax + b standard curve
#y^2 = x^3 + 0*x + 7 this curve
G = C.lift_x(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798) 
N = FiniteField (C.order())

#Define our Private Key
PX = N.random_element()
#Derive the Public Key from the Private Key
X = int(PX) * G

#A function to bad a byte number with 0's
def padbytes(byteslist):
	if len(byteslist) >= 64:
		return byteslist
	else:
		return padbytes(b'0' + byteslist)

#A function to encode a point
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


S = []
K256 = []
R256 = []
M256 = []
C256 = []



#Generate zero array
zero256 = []
for i in range(0, 256):
	zero256.append(N(0))


for i in range(0, 256):
	#Generate nonse
	k = N.random_element()
	K256.append(k)
	#Generate public version of nonse
	r = int(k) * G
	R256.append(r)
	#Generate two messages 
	m0 = bytes(str(int(N.random_element())), "utf8")
	m1 = bytes(str(int(N.random_element())), "utf8")
	#Hash our public nonse with the message as the aux string
	c0 = hashN(encode(r), m0)
	c1 = hashN(encode(r), m1)
	M256.append([m0[:], m1[:]])
	C256.append([c0, c1])

	
#Run the P256 function with the zero vector to get the 256th term of the hashes
p256256 = 0
for i in range(0, 256):
	a = zero256[i] - C256[i][0]
	b = C256[i][1] - C256[i][0]
	p256256 += (N(2^i) / b) * a


#Run the P256 function with the public nonses to get a public nonse with the 256 term added on after multiplyied by the public key
r257 = 0 
for i in range(0, 256):
	a = R256[i] - int(C256[i][0]) * G
	b = C256[i][1] - C256[i][0]
	r257 += int(N(2^i) / b) * a
r257 += (int(p256256) * X)
#Generate two messages that will be signed by our 257 siganture
m2570 = N.random_element()
m2571 = N.random_element()

#Hash the new public nonse and messages 
c257 = [hashN(encode(r257), bytes(str(int(m2570)), "utf8")), hashN(encode(r257), bytes(str(int(m2571)), "utf8"))]

# create the zero array for 257 0's
zero257 = []
for i in range(0, 257):
	zero257.append(N(0))

C257 = C256+[c257]

#get the 257th term of our P257 function using the 257 zero array
p257257 = 0
for i in range(0, 257):
	a = zero257[i] - C257[i][0]
	b = C257[i][1] - C257[i][0]
	p257257 += (N(2^i) / b) * a

#generate a 258th message to have a signature forged
m258 = N.random_element()

#Create the public nonse for the 258th signature using all 256 valid hashes and our 257th hash's
R257 = R256 + [r257]
r258 = 0 
for i in range(0, 257):
	a = R257[i] - int(C257[i][0]) * G
	b = C257[i][1] - C257[i][0]
	r258 += int(N(2^i) / b) * a
r258 += (int(p257257) * X)

#Create the 258th hash
c258 = hashN(encode(r258), bytes(str(int(m258)), "utf8"))

#Select all proper 256th hashes and our 257th hash for our 258th signature
b = f'{int(c258):0257b}'
B257 = []
for i in range(1, 257+1):
	B257.append(b[i-1:i])
B257.reverse()

# Choose the correct message hashes by the binary string generated
CB2562 = []
for i in range(0, 256):
	CB2562.append(C257[i][int(B257[i], 2)])

c257 = c257[int(B257[256], 2)]


#Select all proper 256th hashes using the correct 257th hash 
b = f'{int(c257):0256b}'
B256 = []
for i in range(1, 256+1):
	B256.append(b[i-1:i])
B256.reverse()

#Choose the correct message hashes by the binary string generated
CB256 = []
for i in range(0, 256):
	CB256.append(C256[i][int(B256[i], 2)])



#If CB256 == CB2562 then we only have to ask the server for 256 signatures and get 258 signatures
#The probabilty of this occuring is the same as fliping 256 coins and all of them landing on heads

#Ask the server for the 256 signatures for our 257th hash
S256 = []
for i in range(0, 256):
	si = K256[i] - N(PX) * N(CB256[i])
	S256.append(si)

#Ask the server for the 256 signatures for our 258th hash
S2562 = []
for i in range(0, 256):
	si = K256[i] - N(PX) * N(CB2562[i])
	S2562.append(si)

#Generate the 257th siganutre
s257 = 0
for i in range(0, 256):
	a = S256[i] - C256[i][0]
	b = C256[i][1] - C256[i][0]
	s257 += (N(2^i) / b) * a

#Generate the 258th sigantureu
S257 = S2562+[s257]
s258 = 0
for i in range(0, 257):
	a = S257[i] - C257[i][0]
	b = C257[i][1] - C257[i][0]
	s258 += (N(2^i) / b) * a

#Verify the final signature
print(((int(s257) * G) + (int(c257) * X)) == r257)
print(((int(s258) * G) + (int(c258) * X)) == r258)