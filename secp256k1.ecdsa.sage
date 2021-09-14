from sage.cpython.string import str_to_bytes

def padbytes(byteslist):
	print(len(byteslist))
	if len(byteslist) >= 64:
		return byteslist
	else:
		return padbytes(b'0' + byteslist)

def encode(R):
	xy = R.xy()
	x = int(xy[0])
	y = int(xy[1])
	result = b''
	print(y)
	if y % 2:
		result += b'3'
	else:
		result += b'2'
	print(x)
	result += padbytes(bytes(hex(x), "utf8")[2:])
	print(result)
	return result


F = FiniteField (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
C = EllipticCurve ([F (0), F (7)])
#y^2 = x^3 + ax + b standard curve
#y^2 = x^3 + 0*x + 7 this curve
G = C.lift_x(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798) 
#group of p order means every element is a generator
#lift_x solves for y given X
#Generator
N = FiniteField (C.order()) # how many points are in our curve

d = int(N(3952319235)) # our secret
pd = G*d # our pubkey
print(N(pd.xy()[1]))
m = int(N.random_element()) # our message

#sign
k = N.random_element() # our private nonce
R = int(k) * G # public nonce
# r = (int(k)*G).xy()[0]
# m = e
# X = pubkey pd
#econde R
#y = even = 2 else 3 concat x
# len(x) = 32 padd left with 0
c = hash(encode(R)+bytes(str(m), "utf8"))
print("c")
s = k - N(d) * N(c)
print("s")
#s = sig

#Given public to prove you have d
# s
# R
# m
# pd

c = hash(encode(R)+bytes(str(m), "utf8"))
print(int(s)*G == R - pd * c)






