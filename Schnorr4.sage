from sage.cpython.string import str_to_bytes
import hashlib
import math


def hash(byteslist):
	return IntPrime(int(hashlib.sha256(byteslist).hexdigest(), 16))

def countBits(number):
    return math.ceil((math.log(number) /
                math.log(2)));

F = FiniteField (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
C = EllipticCurve ([F (0), F (7)])
#y^2 = x^3 + ax + b standard curve
#y^2 = x^3 + 0*x + 7 this curve
G = -C.lift_x(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798) 
Prime = G.order()
IntPrime = FiniteField(Prime)


lambdaParameter = countBits(Prime)

PrivKey = 3943403887
PubKey = int(PrivKey) * G

w = 4
L =	5
k1 = 2^w-1 
k2 = max(0, math.ceil(lambdaParameter - (w + 1) * L)) # 0
l = k1+k2
print(k1)
print(k2)
print("l = "+str(l))

a = Prime - 1
b = 2^((w+1)*L+1)

def padbytes(byteslist, length):
	if len(byteslist) >= length:
		return byteslist
	else:
		return padbytes('0' + byteslist, length)

def encode(R, m=0):
	xy = R.xy()
	x = xy[0]
	y = int(xy[1])
	result = ""
	if y % 2:
		result += "03"
	else:
		result += "02"
	result += padbytes(str(hex(x))[2:],64)
	if m > 0:
		result += padbytes(str(hex(m))[2:], 8)
	# print("hex res: "+str(result))
	result = bytes.fromhex(result)
	return result

def randomElement(Field):
	while True:
		element = Field.random_element()
		if element != 0:
			return element

def inRange(rangetup, hashval):
	if (rangetup[0] > rangetup[1]):
		if (hashval > rangetup[0] or hashval < rangetup[1]):
			return True
	if (rangetup[0] < rangetup[1]):
		if (hashval > rangetup[0] and hashval < rangetup[1]):
			return True
	return False

def join(a, b, rangetup):
	result = []
	for i in range(0, len(a)):
		for j in range(0, len(b)):
			ab = a[i][1]+b[j][1]
			print(a[i][1])
			print(b[j][1])
			print(ab)
			return result
			if (inRange(rangetup, ab)):
				result.append((a[i][0]+b[j][0],ab,a[i][2]+b[j][2]))
				# print("result "+str(i)+","+str(j)+" : "+str(ab));
				if len(result) >= 62500:
					return result
	return result

def Ii(i):
	return (IntPrime(0)-int((Prime-1)/2^(((w-i)*L)+1)),int((Prime-1)/2^(((w-i)*L)+1)))

def convertBinary(binairyInt):
	b = f'{int(binairyInt):{k2}b}'
	print("bbbb\n")
	print(b)
	B = []
	for i in range(1, k2-1+2):
		B.append(b[i-1:i])
	B.reverse()
	return B

def kListHROS(w, L, R):
	if (k1 <= 0):
		return ([],0,[])
	#Setup ----
	Liw = []
	for i in range(0, 2^w):#2^w
		Li = []
		for j in range(0, 2^L):
			Li.append(([IntPrime(hash(encode(R[i], j)))],IntPrime(hash(encode(R[i], j))),[j]))
		Liw.append(Li)
	Tree = [Liw]
	##Collison ----
	for x in range(0, 1): #w add one because SUM is inclusive and end range is exclusive minus one because the range should be 1 - w
		print("\n\nlevel "+str(x)+"\n")
		FLi = []
		level = w-x
		TreeLevel = Tree[x]
		for j in range(0, 1): #2^(level-1) add one because SUM is inclusive and end range is exclusive minus one because we are indexing from 0
			print("j "+str(j))
			FLi.append(join(TreeLevel[j*2],TreeLevel[2*j+1],Ii(level))) #minus one because lists are 1 indexed in the paper
		Tree.append(FLi)
	finalTree = Tree[w][0]
	result = ([],0,[])
	for i in range(0, len(finalTree)):
		if inRange(Ii(-1), finalTree[i][1]):
			print(finalTree[11])
			print(i)
			result = (finalTree[i][0], finalTree[i][1], finalTree[i][2])
			break
	print(result)
	return result

def main():			
	K = []
	R = []
	M = []
	C = []
	S = []
	CB = []
	zero = []

	

	# print(hashlib.sha256(bytes.fromhex("031e09c104cdb9a41285f802b9f7e80e74781c630f66db2f151dfa991dcc1214299a")).hexdigest())
	#Generate zero array
	for i in range(0, l):
		zero.append(IntPrime(0))

	# M = [[3952459683, 140620442],[2017216018, 2009046716],[1509335457, 4077915080],[1932088938, 2486682281],[3314941358, 499585529],[3362337200, 2211775199],[2330471963, 3606788670],[4134288763, 3260445262],[2586822768, 1128746907],[3723722377, 1544039621],[1516844343, 3838049092],[3234026267, 1742413807],[3209196705, 4042251632],[3975864098, 1096753163],[3633611705, 767066282],[3768454157, 539424771],[3606753106, 18313224],[1075685129, 737257314],[1301487686, 364160362],[4217215080, 1352247727],[1914230622, 142035844],[3445740864, 2469049293],[1797902554, 3319456240],[2229753882, 2191947181],[3976251297, 1619755698],[2552941005, 2301914585],[2503888055, 1844588746],[3047825066, 1928880188],[4155801463, 2583818105],[3106220087, 3279762563],[3212767151, 3807893560],[2229425900, 2739136220],[1632389433, 2902152512],[83693948, 2093956158],[1095902075, 2868146148],[766459304, 1914935438],[3406978115, 1395422425],[2520335904, 1504028136],[4023735222, 3046846676],[1201078568, 375908758],[119286203, 1853781173],[2369168331, 1804912580],[733969225, 3163390675],[328558366, 4154804709],[2922558557, 1022427754],[2077866832, 2841336229],[4112332032, 3683257847],[3115064832, 1424320860],[709678450, 1251382373],[3834362799, 3311489886],[1059044347, 1840764376],[2720090515, 3505032467],[593507574, 661286706],[1143943486, 496329025],[472939875, 2414880472],[2030246970, 324673756],[3697634721, 449647308],[2787228712, 4205775805],[2018848604, 3934436566],[3711878379, 586563327],[1900151571, 1782602950],[204982352, 1168800016],[1760581905, 3312121479],[389216358, 2538577611],[1600728930, 42948890],[2790096070, 2592628431],[603771702, 364764022],[3657953974, 345932725],[2389681322, 2511987192],[2554772220, 4000714081],[2512894656, 1282546849],[607700325, 3520902869],[3760734200, 1167290368],[366505776, 809138353],[1838612482, 3525364779],[1952591117, 3667128651],[577679124, 209929118],[952525595, 2805017976],[1908102323, 3107524892],[3998515704, 2818601629],[1632644731, 1673264357],[2478623148, 2387096063],[1271224779, 3545655642],[1338634086, 208565460],[1144254551, 566749384],[1213444573, 2270680829],[2667338802, 447393599],[2745909947, 1413657208],[2818038301, 2611315625],[558788, 2001781779],[1145522126, 3864133576],[2855615464, 1175579813],[445158637, 817566918],[1344934809, 1890208939],[595665807, 2083040701],[2546103415, 3799539368],[1653802914, 3120286505],[4017684220, 4108938953],[385794252, 3054087990],[2519574417, 2903452730],[1291639897, 826798828],[586206110, 3285585972],[2920486174, 3175925084],[459481797, 466529033],[848706037, 2934537306],[4289714493, 1245082734],[2589996752, 2389930559],[4163622221, 1032226453],[4047370927, 3998477336],[4203406315, 2577438133],[4190796340, 1445431932],[542197919, 1523076747],[3156657627, 1151167272],[899779775, 3888750110],[4178055519, 1059680825],[134098916, 3241953930],[1403191210, 2782617305],[1596932414, 3824062207],[1446860573, 2646807260],[3227579532, 3132938294],[2768482560, 461251643],[661133937, 3012269095],[2269874965, 3805639755],[2364681041, 226700072],[3071628030, 740031554],[1029331527, 4133052612],[206116831, 3546889884],[4110204268, 748254024],[2441189548, 4054227839],[1907595159, 4000683750],[3249068243, 1504667377],[3054475378, 3276497813],[1509430713, 2677043124],[3244208999, 446714967],[1180268955, 1106168058],[1413675763, 711113383],[377958134, 1247237878],[1756911021, 201052169],[1959269810, 3190208469],[3099357099, 3092865037],[195020592, 3379419715],[1392797718, 3609500251],[3967480620, 1470003086],[1611273651, 2678649306],[3793943163, 4263260479],[2272670323, 3552013912],[2327802720, 964409761],[2589215214, 2428882680],[648055316, 4123710212],[1673774034, 3887832523],[1441529431, 4290921581],[807526737, 1496000033],[3361527512, 2194767334],[1819445301, 2517018921],[3594711790, 2796122842],[872001322, 3229855629],[3114124587, 4169245642],[2616053411, 3909511573],[994489645, 3587611841],[2210050416, 437035565],[554583559, 1559347049],[1112273838, 4121356635],[3785139433, 4090626494],[1931371692, 3548553825],[4181304425, 1469510419],[2206424494, 3477963051],[3849342270, 3703460250],[1334252130, 288572380],[971216662, 1815390916],[3493969241, 2608286018],[651275292, 1215400968],[1898101947, 3439487858],[2006176490, 500620238],[730932289, 2279956838],[101866724, 3243125721],[4093792017, 2824718385],[296941721, 2486937000],[3435465698, 3023964098],[1248385944, 3209359661],[433832325, 2414181781],[1035892004, 1267320598],[781849687, 4175962999],[3250906632, 3334829192],[2799399854, 1317434321],[1417465101, 4117758796],[4092211979, 2879341984],[2160184051, 412025946],[3913954063, 2290482390],[2858885770, 1497709652],[2808944091, 1308877778],[3190731050, 1832988858],[978508767, 1900348650],[3251776573, 3896457431],[4094300135, 2656886649],[1616027087, 1809944247],[3790895900, 1974078952],[2826935185, 3261996568],[239419057, 2645414694],[1914423974, 4066359836],[2957408273, 1580192614],[3529152483, 498440598],[2074047399, 3878220458],[28566736, 3717809264],[3717577698, 2786808071],[2634436011, 3528688245],[57331723, 3941478473],[532788744, 3085440955],[631024091, 2092762845],[2900199454, 1681880163],[65030485, 1923886359],[3186692127, 2373847057],[2970320823, 2179393866],[4232235063, 2724142643],[434961598, 2212549068],[1852891838, 2174479740],[205195157, 137033942],[1131010727, 907169493],[594560834, 3286951263],[2279593073, 2628790437],[222639794, 1974918295],[3285634123, 2045561189],[1882398249, 283934601],[1265040621, 3601155789],[3231133674, 1070736492],[2604041139, 1286644694],[3471881410, 3998008737],[4166692921, 1984749305],[3717312094, 170493346],[4151638014, 3100096563],[1781970618, 1469465656],[1129563677, 3126950261],[2598959897, 3930980098],[3145416236, 2065799006],[503245321, 2349936549],[34718926, 466644579],[4081985580, 3273641486],[1620257026, 2982646358],[199380680, 87748991],[1537697907, 1353507210],[649640394, 923002607],[3954168617, 3588753946],[2395140467, 3528208126],[942612979, 535721316],[277984505, 2398191553],[3198280166, 3103354176],[1906004320, 703614489],[2733831898, 167894300],[3927722210, 462166401],[1949372081, 394481983],[142259367, 2142924833],[3723138218, 1513897917],[2229626255, 2108490120],[1230492766, 3008774167],[3812375492, 3074455388],[1848665308, 3120260622],[4141159246, 621593509]]
	M = [[3952459683,140620442],[2017216018,2009046716],[1509335457,4077915080],[1932088938,2486682281],[3314941358,499585529],[3362337200,2211775199],[2330471963,3606788670],[4134288763,3260445262],[2586822768,1128746907],[3723722377,1544039621],[1516844343,3838049092],[3234026267,1742413807],[3209196705,4042251632],[3975864098,1096753163],[3633611705,767066282],[3768454157,539424771],[3606753106,18313224],[1075685129,737257314],[1301487686,364160362],[4217215080,1352247727],[1914230622,142035844],[3445740864,2469049293],[1797902554,3319456240],[2229753882,2191947181],[3976251297,1619755698],[2552941005,2301914585],[2503888055,1844588746],[3047825066,1928880188],[4155801463,2583818105],[3106220087,3279762563],[3212767151,3807893560],[2229425900,2739136220],[1632389433,2902152512],[83693948,2093956158],[1095902075,2868146148],[766459304,1914935438],[3406978115,1395422425],[2520335904,1504028136],[4023735222,3046846676],[1201078568,375908758],[119286203,1853781173],[2369168331,1804912580],[733969225,3163390675],[328558366,4154804709],[2922558557,1022427754],[2077866832,2841336229],[4112332032,3683257847],[3115064832,1424320860],[709678450,1251382373],[3834362799,3311489886],[1059044347,1840764376],[2720090515,3505032467],[593507574,661286706],[1143943486,496329025],[472939875,2414880472],[2030246970,324673756],[3697634721,449647308],[2787228712,4205775805],[2018848604,3934436566],[3711878379,586563327],[1900151571,1782602950],[204982352,1168800016],[1760581905,3312121479],[389216358,2538577611],[1600728930,42948890],[2790096070,2592628431],[603771702,364764022],[3657953974,345932725],[2389681322,2511987192],[2554772220,4000714081],[2512894656,1282546849],[607700325,3520902869],[3760734200,1167290368],[366505776,809138353],[1838612482,3525364779],[1952591117,3667128651],[577679124,209929118],[952525595,2805017976],[1908102323,3107524892],[3998515704,2818601629],[1632644731,1673264357],[2478623148,2387096063],[1271224779,3545655642],[1338634086,208565460],[1144254551,566749384],[1213444573,2270680829],[2667338802,447393599],[2745909947,1413657208],[2818038301,2611315625],[558788,2001781779],[1145522126,3864133576],[2855615464,1175579813],[445158637,817566918],[1344934809,1890208939],[595665807,2083040701],[2546103415,3799539368],[1653802914,3120286505],[4017684220,4108938953],[385794252,3054087990],[2519574417,2903452730],[1291639897,826798828],[586206110,3285585972],[2920486174,3175925084],[459481797,466529033],[848706037,2934537306],[4289714493,1245082734],[2589996752,2389930559],[4163622221,1032226453],[4047370927,3998477336],[4203406315,2577438133],[4190796340,1445431932],[542197919,1523076747],[3156657627,1151167272],[899779775,3888750110],[4178055519,1059680825],[134098916,3241953930],[1403191210,2782617305],[1596932414,3824062207],[1446860573,2646807260],[3227579532,3132938294],[2768482560,461251643],[661133937,3012269095],[2269874965,3805639755],[2364681041,226700072],[3071628030,740031554],[1029331527,4133052612],[206116831,3546889884],[4110204268,748254024],[2441189548,4054227839],[1907595159,4000683750],[3249068243,1504667377],[3054475378,3276497813],[1509430713,2677043124],[3244208999,446714967],[1180268955,1106168058],[1413675763,711113383],[377958134,1247237878],[1756911021,201052169],[1959269810,3190208469],[3099357099,3092865037],[195020592,3379419715],[1392797718,3609500251],[3967480620,1470003086],[1611273651,2678649306],[3793943163,4263260479],[2272670323,3552013912],[2327802720,964409761],[2589215214,2428882680],[648055316,4123710212],[1673774034,3887832523],[1441529431,4290921581],[807526737,1496000033],[3361527512,2194767334],[1819445301,2517018921],[3594711790,2796122842],[872001322,3229855629],[3114124587,4169245642],[2616053411,3909511573],[994489645,3587611841],[2210050416,437035565],[554583559,1559347049],[1112273838,4121356635],[3785139433,4090626494],[1931371692,3548553825],[4181304425,1469510419],[2206424494,3477963051],[3849342270,3703460250],[1334252130,288572380],[971216662,1815390916],[3493969241,2608286018],[651275292,1215400968],[1898101947,3439487858],[2006176490,500620238],[730932289,2279956838],[101866724,3243125721],[4093792017,2824718385],[296941721,2486937000],[3435465698,3023964098],[1248385944,3209359661],[433832325,2414181781],[1035892004,1267320598],[781849687,4175962999],[3250906632,3334829192],[2799399854,1317434321],[1417465101,4117758796],[4092211979,2879341984],[2160184051,412025946],[3913954063,2290482390],[2858885770,1497709652],[2808944091,1308877778],[3190731050,1832988858],[978508767,1900348650],[3251776573,3896457431],[4094300135,2656886649],[1616027087,1809944247],[3790895900,1974078952],[2826935185,3261996568],[239419057,2645414694],[1914423974,4066359836],[2957408273,1580192614],[3529152483,498440598],[2074047399,3878220458],[28566736,3717809264],[3717577698,2786808071],[2634436011,3528688245],[57331723,3941478473],[532788744,3085440955],[631024091,2092762845],[2900199454,1681880163],[65030485,1923886359],[3186692127,2373847057],[2970320823,2179393866],[4232235063,2724142643],[434961598,2212549068],[1852891838,2174479740],[205195157,137033942],[1131010727,907169493],[594560834,3286951263],[2279593073,2628790437],[222639794,1974918295],[3285634123,2045561189],[1882398249,283934601],[1265040621,3601155789],[3231133674,1070736492],[2604041139,1286644694],[3471881410,3998008737],[4166692921,1984749305],[3717312094,170493346],[4151638014,3100096563],[1781970618,1469465656],[1129563677,3126950261],[2598959897,3930980098],[3145416236,2065799006],[503245321,2349936549],[34718926,466644579],[4081985580,3273641486],[1620257026,2982646358],[199380680,87748991],[1537697907,1353507210],[649640394,923002607],[3954168617,3588753946],[2395140467,3528208126],[942612979,535721316],[277984505,2398191553],[3198280166,3103354176],[1906004320,703614489],[2733831898,167894300],[3927722210,462166401],[1949372081,394481983],[142259367,2142924833],[3723138218,1513897917],[2229626255,2108490120],[1230492766,3008774167],[3812375492,3074455388],[1848665308,3120260622],[4141159246,621593509],[1520284440,419672987]]
	# K = [3952319235,1972040021,2682795333,4248958407,2430489776,1998982847,2447726525,4186472610,4072971075,193515222,1070797965,836171487,1787824246,664674363,734630056,4028847063,1371828711,4246510952,3343965217,2643351565,1217664939,2940984862,3942219648,505760561,540562365,3221206580,3713131495,3367407149,1345854475,2500012197,877056782,2010460269,1125841596,393541314,1093377296,2207060009,2193458018,3185777727,1734059597,2835440292,3795486676,236382810,196722783,273542651,1939662971,3839481177,3809197040,4127081423,2254237506,3859992183,2935782939,1709109184,1631021458,166788004,1243239501,3911919396,127742131,2799649543,2699707072,894878619,2134355819,874662292,4243725233,2965176282,3631572266,246165295,1326531614,434637048,4093779404,4275927089,330883731,2573083971,4041603319,1078826072,1205178391,2804818001,3648185928,2062983627,3964754414,3825757328,2268216703,3710959221,1198002389,4036779168,2492232218,1928923097,2348851751,1017299113,1270160978,4110788366,2153685733,3728171636,1876621909,485833390,1651722917,2682417343,3230797873,2820676544,2423016272,601987276,4225572480,2647148433,651290631,2147758899,188984776,2082976857,3175276849,3796197588,3554347013,3543187949,496630012,2208459623,3272907041,210407366,3991869385,2357925000,2070201873,977621473,1255307098,4222709020,691479729,3065895902,3055126435,3263974894,3723648766,1604036949,1105364752,4181140885,838845188,2273312903,1766468476,3353527955,1725600089,4137000307,2427062551,3490521428,1415370922,2679882528,3796729361,924907542,2302164408,1407497627,3167248507,1147976257,6118358,4260044114,1848231444,2720759468,3056979594,2970693772,1493032544,744644094,164286594,2711565098,2030457173,1657508875,1184221857,1268943103,2551904019,1925257953,3712826754,3488346100,1981020400,2161469554,1226220086,534564588,307498003,310722413,3173002092,41750711,3187637261,2713095315,433825015,3807644237,2508300676,2968131701,2767486568,294221686,1595137624,1299592670,1522586545,2703264289,798522702,855707870,310120694,3572230065,2333612681,2041702558,104358760,3423081585,2756612595,358222834,1756994402,3854650109,391562022,3945956139,2040176921,557049729,3427457227,4242258101,1633630566,448351314,635648450,779325024,907754110,1853532259,267542844,584127385,3650779727,2777540958,2510108176,3361672012,3942017305,3360905211,2030277480,1409676013,2392006602,3226960738,278983218,3860359492,416534282,2841754813,1278787368,2412452225,331925259,2851460015,1977865620,3364921170,2540431163,383779840,1054421842,4121059223,1972176582,3932834336,1181121744,837376906,2052847070,2711665445,544313009,2639086723,953043149,3861671823,3334016664,891565430,2754391506,1862912009,1494085880,1755571949,837655699,3956001935,2275404762,439626653,3809009290,3322116919,198773039,3239534950]
	K = [3952319235,1972040021,2682795333,4248958407,2430489776,1998982847,2447726525,4186472610,4072971075,193515222,1070797965,836171487,1787824246,664674363,734630056,4028847063,1371828711,4246510952,3343965217,2643351565,1217664939,2940984862,3942219648,505760561,540562365,3221206580,3713131495,3367407149,1345854475,2500012197,877056782,2010460269,1125841596,393541314,1093377296,2207060009,2193458018,3185777727,1734059597,2835440292,3795486676,236382810,196722783,273542651,1939662971,3839481177,3809197040,4127081423,2254237506,3859992183,2935782939,1709109184,1631021458,166788004,1243239501,3911919396,127742131,2799649543,2699707072,894878619,2134355819,874662292,4243725233,2965176282,3631572266,246165295,1326531614,434637048,4093779404,4275927089,330883731,2573083971,4041603319,1078826072,1205178391,2804818001,3648185928,2062983627,3964754414,3825757328,2268216703,3710959221,1198002389,4036779168,2492232218,1928923097,2348851751,1017299113,1270160978,4110788366,2153685733,3728171636,1876621909,485833390,1651722917,2682417343,3230797873,2820676544,2423016272,601987276,4225572480,2647148433,651290631,2147758899,188984776,2082976857,3175276849,3796197588,3554347013,3543187949,496630012,2208459623,3272907041,210407366,3991869385,2357925000,2070201873,977621473,1255307098,4222709020,691479729,3065895902,3055126435,3263974894,3723648766,1604036949,1105364752,4181140885,838845188,2273312903,1766468476,3353527955,1725600089,4137000307,2427062551,3490521428,1415370922,2679882528,3796729361,924907542,2302164408,1407497627,3167248507,1147976257,6118358,4260044114,1848231444,2720759468,3056979594,2970693772,1493032544,744644094,164286594,2711565098,2030457173,1657508875,1184221857,1268943103,2551904019,1925257953,3712826754,3488346100,1981020400,2161469554,1226220086,534564588,307498003,310722413,3173002092,41750711,3187637261,2713095315,433825015,3807644237,2508300676,2968131701,2767486568,294221686,1595137624,1299592670,1522586545,2703264289,798522702,855707870,310120694,3572230065,2333612681,2041702558,104358760,3423081585,2756612595,358222834,1756994402,3854650109,391562022,3945956139,2040176921,557049729,3427457227,4242258101,1633630566,448351314,635648450,779325024,907754110,1853532259,267542844,584127385,3650779727,2777540958,2510108176,3361672012,3942017305,3360905211,2030277480,1409676013,2392006602,3226960738,278983218,3860359492,416534282,2841754813,1278787368,2412452225,331925259,2851460015,1977865620,3364921170,2540431163,383779840,1054421842,4121059223,1972176582,3932834336,1181121744,837376906,2052847070,2711665445,544313009,2639086723,953043149,3861671823,3334016664,891565430,2754391506,1862912009,1494085880,1755571949,837655699,3956001935,2275404762,439626653,3809009290,3322116919,198773039,3239534950,335298040]
	for i in range(0, l):
		r = int(K[i]) * G
		R.append(r)
		c0 = hash(encode(r, M[i][0]))
		c1 = hash(encode(r, M[i][1]))
		CB.append([c0, c1])


	# #Run the Pl function with the zero vector to get the 256th term of the hashes
	def Pl(x, public=True):
		#FT
		result = 0
		for i in range(0, l):
			if public:
				a = x[i] - int(CB[i][0]) * G
			else:
				a = int(x[i]) - CB[i][0]
			b = CB[i][1] - CB[i][0]
			result += int(2^i / b) * a
		#ET
		endTerm = 0
		for i in range(k2, (k1+k2-1)+1):
			endTerm += x[i]
		result = result - endTerm
		return result

	Rl = Pl(R) 
	pll = Pl(zero, False)
	Rl -= (int(pll) * PubKey)
	R.append(Rl)
	print(Rl)

	Ml = 335298040
	#Hash the new public nonse and messagee
	Cl = hash(encode(Rl, Ml))


# # 	#Run the P256 function with the public nonses to get a public nonse with the 256 term added on after multiplyied by the public key
	P = []
	for i in range(0, k1+1):
		P.append(R[k2+i])
		# print("From R["+str(k2+i)+"]")
		# print("P["+str(i)+"] = "+str(P[i]))
	(Y, s, auxk2l) = kListHROS(w, math.ceil(L), P)
	print(Y)
	print(s)
	print(auxk2l)
	# (Y, s, auxk2l) = ([69941745913993024878289062469584981154044959652311900484001576924908388893180, 83263816839295088418241218676773091670190011778897851081819221196682969152456, 32939841957761733810998997784021385361934449283920869019343613626449362165161, 46761562533733746409712510129618034103303502588343595035178103434787994211768, 10193257443427220008748011819294820376898484033327430779454263530044543700026, 21474956574749022368677494299888098823998107144015035567528335758131665740635, 26991046229603210612695046697705722848817518835826643690629629065199134014188, 55862874617168658219824003306036920909108080441850539912675591803508586782991, 82876111567929014239712505628285623128176817764835529086901644374046012283267, 69514645328365053659855233211655025662138173401026322581272487226396966809180, 32411837506304328099005025547027268691964605095957770325949979611691974080887, 47696966563113844976803973548755519944549381862025749710372505356901682884245, 89975383737043117386470344097867728182066292883578421223913012761261602122017, 64506279562824399252260117559625953913772113201605148033961503876138194467519, 101213146615715631735055963358423324948172501438914481323099427593804597033451, 90713241558379558014904737266474654900732930258758487641567348340433458604378], 650877088702686365331534891797167415432596540436826939348241840990653, [0, 0, 0, 5, 0, 0, 9, 4, 0, 1, 22, 29, 29, 8, 30, 11])


	# spl = s + int((Prime-1)/2^(((w+1)*L)+1))
	# B = convertBinary(spl)

	# C = []
	# auxi = []
	# for i in range(0,k2):
	# 	C.append(CB[i][int(B[i])])
	# 	auxi.append(B[i])

	# for i in range(k2, l):
	# 	C.append(Y[k2-i])
	# if (k2 < l):
	# 	Cl = Y[k2-l]
	# else:

	# for i in range(0, l):
	# 	si = K[i] + IntPrime(PrivKey) * IntPrime(C[i])
	# 	S.append(si)


	# Sl = Pl(S, False)
	# print(Sl)


	# for i in range(0,l):
	# 	print(((int(S[i]) * G) - (int(C[i]) * PubKey)) == R[i])
	# print(((int(Sl) * G) - (int(Cl) * PubKey)) == Rl)


	# print("Rl "+str(Rl))
	# print("int(Sl) * G - int(Cl) * PubKey "+str(int(Sl) * G - int(Cl) * PubKey))


print(main())