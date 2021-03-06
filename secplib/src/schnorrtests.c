#include <string.h>
#include <math.h>
#include <errno.h>
#include <stdlib.h>

int lambdaParameter, wvar, L, k1, k2, l, memoryLimit, powerW, powerL, sqrtMemLimit;

typedef struct {
    secp256k1_gej R;
    secp256k1_scalar hash;
    unsigned int aux;
    int iteration;
} hash_value;

typedef struct {
  hash_value *hashes;
  int hasheslen;
  secp256k1_scalar currenthash;
} klistleaf;

secp256k1_scalar Prime = SECP256K1_SCALAR_CONST(
    0xFFFFFFFFUL, 0xFFFFFFFFUL, 0xFFFFFFFFUL, 0xFFFFFFFEUL,
    0xBAAEDCE6UL, 0xAF48A03BUL, 0xBFD25E8CUL, 0xD0364141UL);

int s_get_int(secp256k1_scalar *a) {
    return secp256k1_scalar_get_bits_var(a, 0, 31);;
}

int encode(unsigned char out[33], secp256k1_gej *R) {
    secp256k1_ge Rge;
    size_t size = sizeof(&out);
    secp256k1_ge_set_gej(&Rge, R);
    CHECK(secp256k1_eckey_pubkey_serialize(&Rge, out, &size, 1) == 1);
    return 1;
}

int s_add(secp256k1_scalar *r, secp256k1_scalar *a, secp256k1_scalar *b) {
    secp256k1_scalar_add(r, a, b);
    return 1;
}

int s_add_eq(secp256k1_scalar *a, secp256k1_scalar *b) {
    secp256k1_scalar_add(a, a, b);
    return 1;
}

int s_set_int(secp256k1_scalar *r, unsigned int a) {
    secp256k1_scalar_set_int(r, a);
    return 1;
}

int s_add_int(secp256k1_scalar *r, secp256k1_scalar *a, int b) {
    secp256k1_scalar one;
    int iter;
    s_set_int(&one, 1);
    secp256k1_scalar_add(r, a, &one);
    for (iter = 1; iter < b; iter++) {
        s_add_eq(r, &one);
    }
    return 1;
}

int s_add_int_eq(secp256k1_scalar *a, int b) {
    secp256k1_scalar one;
    int iter;
    s_set_int(&one, 1);
    secp256k1_scalar_add(a, a, &one);
    for (iter = 1; iter < b; iter++) {
        s_add_eq(a, &one);
    }
    return 1;
}

int s_pow(secp256k1_scalar *r, unsigned int bits) {
    s_set_int(r, 0);
    secp256k1_scalar_cadd_bit(r, bits, 1);
    return 1;
}

int s_to_gej(secp256k1_context ctx, secp256k1_gej *r, secp256k1_scalar *a) {
    secp256k1_ecmult_gen(&ctx.ecmult_gen_ctx, r, a);
    return 1;
}

int s_subtract(secp256k1_scalar *r, secp256k1_scalar *a, secp256k1_scalar *b) {
    secp256k1_scalar negB;
    int overflow;
    secp256k1_scalar_negate(&negB, b);
    overflow = secp256k1_scalar_add(r, a, &negB);
    return overflow;
}

int s_subtract_eq(secp256k1_scalar *a, secp256k1_scalar *b) {
    secp256k1_scalar negB;
    secp256k1_scalar_negate(&negB, b);
    secp256k1_scalar_add(a, a, &negB);
    return 1;
}

int s_subtract_int(secp256k1_scalar *r, secp256k1_scalar *a, int b) {
    secp256k1_scalar one;
    int iter;
    s_set_int(&one, 1);
    s_subtract(r, a, &one);
    for (iter = 1; iter < b; iter++) {
        s_subtract_eq(r, &one);
    }
    return 1;
}

int s_multiply(secp256k1_scalar *r, secp256k1_scalar *a, secp256k1_scalar *b) {
    secp256k1_scalar_mul(r, a, b);
    return 1;
}

int s_divide(secp256k1_scalar *r, secp256k1_scalar *a, secp256k1_scalar *b) {
    secp256k1_scalar binverse;
    secp256k1_scalar_inverse(&binverse, b);
    secp256k1_scalar_mul(r, a, &binverse);
    return 1;
}

int s_copy(secp256k1_scalar *r, secp256k1_scalar *a) {
    secp256k1_scalar_cmov(r, a, 1);
    return 1;
}

int gej_add(secp256k1_gej *r, secp256k1_gej *a, secp256k1_gej *b) {
    secp256k1_gej_add_var(r, a, b, NULL);
    return 1;
}
int gej_add_eq(secp256k1_gej *a, secp256k1_gej *b) {
    secp256k1_gej_add_var(a, a, b, NULL);
    return 1;
}

int gej_subtract(secp256k1_gej *r, secp256k1_gej *a, secp256k1_gej *b) {
    secp256k1_gej negB;
    secp256k1_gej_neg(&negB, b);
    secp256k1_gej_add_var(r, a, &negB, NULL);
    return 1;
}

int gej_subtract_eq(secp256k1_gej *a, secp256k1_gej *b) {
    secp256k1_gej negB;
    secp256k1_gej_neg(&negB, b);
    secp256k1_gej_add_var(a, a, &negB, NULL);
    return 1;
}

int gej_multiply_s(secp256k1_context ctx, secp256k1_gej *r, secp256k1_gej *a, secp256k1_scalar *b) {
    secp256k1_scalar zero;
    s_set_int(&zero, 0);
    secp256k1_ecmult(&ctx.ecmult_ctx, r, a, b, &zero);
    return 1;
}

int s_comp(secp256k1_scalar *a, secp256k1_scalar *b, int less_than, int or_equal) {
    secp256k1_scalar a1, b2, ab;
    int overflow;
    secp256k1_scalar_cmov(&a1, a, 1);
    secp256k1_scalar_cmov(&b2, b, 1);
    overflow = s_subtract(&ab, &a1, &b2);
    if (or_equal && secp256k1_scalar_is_zero(&ab)) {
        return 1;
    } else if (!or_equal && secp256k1_scalar_is_zero(&ab)) {
        return 0;
    }
    if (less_than) {
        if (overflow) {
            return 0;
        }
        return 1;
    } else {
        if (overflow) {
            return 1;
        }
        return 0;
    }
}

static void scalar_hash(secp256k1_scalar *out, unsigned char *data, int len) {
    secp256k1_sha256 hash;
    int iter, overflow;
    unsigned char out32[32];
    secp256k1_sha256_initialize(&hash);
    for (iter = 0; iter < len; iter++) {
        unsigned char bit;
        bit = data[iter];
        secp256k1_sha256_write(&hash, &bit, len);
    }
    secp256k1_sha256_finalize(&hash, out32);
    overflow = 0;
    secp256k1_scalar_set_b32(out, out32, &overflow);
}

static void hash_point(secp256k1_scalar *out, unsigned char *data, unsigned int msg) {
    uint32_t d;
    secp256k1_sha256 hash;
    int iter, overflow;
    unsigned char out32[32];
    d = msg;
    secp256k1_sha256_initialize(&hash);
    for (iter = 0; iter < 33; iter++) {
        unsigned char bit;
        bit = data[iter];
        secp256k1_sha256_write(&hash, &bit, sizeof(char));
    }
    for (iter = 3; iter > -1; iter--) {
        unsigned char bit;
        bit = d >> (iter * 8);
        secp256k1_sha256_write(&hash, &bit, sizeof(char));
    }
    secp256k1_sha256_finalize(&hash, out32);
    overflow = 0;
    secp256k1_scalar_set_b32(out, out32, &overflow);
}

int Ii(secp256k1_scalar *min, secp256k1_scalar *max, int i) {
    secp256k1_scalar powersc, Primem1, iter;
    int power = ((wvar-i)*L)+1;
    s_subtract_int(&Primem1, &Prime, 1);
    s_set_int(&powersc, power);
    for (s_set_int(&iter, 0); s_comp(&iter, &powersc, 1, 0); s_add_int_eq(&iter, 1)) {
        secp256k1_scalar_shr_int(&Primem1, 1);
    }
    *max = Primem1;
    secp256k1_scalar_negate(min, max);
    return 1;
}

int s_in_range(secp256k1_scalar *min, secp256k1_scalar *max, secp256k1_scalar *hash) {
    if (s_comp(min, max, 1, 0)) {
        if (s_comp(hash, min, 0, 0) && s_comp(hash, max, 1, 0)) {
            return 1;
        }
    } else {
        if (s_comp(hash, min, 0, 0) || s_comp(hash, max, 1, 0)) {
            return 1;
        }
    }
    return 0;
}

int join(klistleaf *branchres, int *treelen, klistleaf *branch1, klistleaf *branch2, int len1, int len2, int level) {
    secp256k1_scalar min, max;
    int iter, iter2, lenres;
    Ii(&min, &max, level);
    lenres = 0;
    for (iter = 0; iter < len1; iter++) {
        for (iter2 = 0; iter2 < len2; iter2++) {
            secp256k1_scalar ab;
            s_add(&ab, &branch1[iter].currenthash, &branch2[iter2].currenthash);
            if (s_in_range(&min, &max, &ab)) {
                klistleaf newleaf;
                int newleafhasheslen, iter3, iter4;
                newleaf.currenthash = ab;
                newleaf.hashes = malloc((branch1[iter].hasheslen+branch2[iter].hasheslen) * sizeof(hash_value));
                newleafhasheslen = 0;
                for (iter3 = 0; iter3 < branch1[iter].hasheslen; iter3++) {
                    newleaf.hashes[newleafhasheslen] = branch1[iter].hashes[iter3];
                    newleafhasheslen++;
                }
                for (iter4 = 0; iter4 < branch2[iter].hasheslen; iter4++) {
                    newleaf.hashes[newleafhasheslen] = branch2[iter2].hashes[iter4];
                    newleafhasheslen++;
                }
                newleaf.hasheslen = newleafhasheslen;
                branchres[lenres] = newleaf;
                lenres++;
                if (lenres >= memoryLimit) {
                    *treelen = lenres;
                    return 1;
                }
            } 
        }
    }
    *treelen = lenres;
    return 1;
}



int klisthros(klistleaf *klistresult, secp256k1_gej *R) {
    int iter, iter2, powerwL;
    klistleaf ***Tree; 
    int **Treelen, x, level, j, newlistlen;
    powerwL = pow(wvar, powerL);
    Tree = malloc(wvar * sizeof(klistleaf *));
    Tree[0] = malloc(powerW * sizeof(klistleaf *));
    Treelen = malloc(wvar * sizeof(int *));
    Treelen[0] = malloc(powerW * sizeof(int));
    for (iter = 0; iter < powerW; iter++) {
        klistleaf sizeleaf;
        sizeleaf.hashes =  malloc(powerW * sizeof(hash_value));
        Tree[0][iter] = malloc(powerL * sizeof(klistleaf));
        Treelen[0][iter] = powerL;
        for (iter2 = 0; iter2 < powerL; iter2++) {
            unsigned char encodeR[33];
            secp256k1_scalar hashres;
            hash_value hashvalue;
            klistleaf leaf;
            encode(encodeR, &R[iter]);
            hash_point(&hashres, encodeR, iter2);
            hashvalue.R = R[iter];
            hashvalue.hash = hashres;
            hashvalue.aux = iter2;
            hashvalue.iteration = iter;
            leaf.hashes = malloc(powerW * sizeof(hash_value));
            leaf.hashes[0] = hashvalue;
            leaf.hasheslen = 1;
            leaf.currenthash = hashres;
            Tree[0][iter][iter2] = leaf; 
        }
    }

    newlistlen = powerW;
    for (x = 0; x < wvar; x++) { //wvar
        int levelpow;
        printf("Level %d\n\n\n\n", x);
        level = wvar-x;
        newlistlen = newlistlen / 2;
        Tree[x+1] = malloc(newlistlen * sizeof(klistleaf *));
        Treelen[x+1] = malloc(newlistlen * sizeof(int));
        levelpow = pow(2, level-1);
        for (j = 0; j < newlistlen; j++) { //newlistlen
            int treeLenMax;
            printf("j = %d\n\n", j);
            if (Treelen[x][j*2] >= sqrtMemLimit || Treelen[x][j*2+1] >= sqrtMemLimit) {
                treeLenMax = memoryLimit;
            } else {
                treeLenMax = Treelen[x][j*2]*Treelen[x][j*2+1];
            }
            Tree[x+1][j] = malloc((treeLenMax)*sizeof(klistleaf));
            join(Tree[x+1][j], &Treelen[x+1][j], Tree[x][j*2], Tree[x][j*2+1], Treelen[x][j*2], Treelen[x][j*2+1], level);
        }
    }
    for (iter = 0; iter < Treelen[wvar][0]; iter++) {
        secp256k1_scalar min, max;
        Ii(&min, &max, -1);
        if (s_in_range(&min, &max, &Tree[wvar][0][iter].currenthash)) {
            printf("VALUEE: %d\n", iter);
            *klistresult = Tree[wvar][0][iter];
            return 1;
        }
    }
    printf("ERROR with klist algo");
    return 0;
}



int schnorr(secp256k1_context ctx) {

    /* varible initilization */
    secp256k1_scalar privKey, k, s, *K, pll, *S, powersc, Primem1, itersc, firstTermsc, endTermsc, Sl, mt;
    hash_value c0, c1, **CB, Cl, *C;
    int iter, iter2, power, bit;
    unsigned int **MB, randomint, m1, m0, Ml, *bits, *aux;
    unsigned char encodeR[33];
    secp256k1_gej pubKey, rgej, *R, *P, Rl, firstTerm, endTerm, pllG, mtgej;
    secp256k1_ge rge;
    klistleaf klistresult;

    /* varible decleration */
    iter = 0;
    iter2 = 0;
    power = 0;
    memoryLimit = 1024;
    sqrtMemLimit = sqrt(memoryLimit);
    lambdaParameter = 256;
    wvar = 3;
    L = 5;
    k1 = pow(2, wvar);
    k1--;
    powerW = pow(2, wvar);
    powerL = pow(2, L);
    k2 = fmax(0, ceil(lambdaParameter - (wvar + 1) * L));
    l = k1+k2;
    printf("l = %d\n", l);
    printf("k1 = %d\n", k1);
    printf("k2 = %d\n", k2);


    /* Generate mt */
    power = ((wvar+1)*L)+1;
    s_subtract_int(&Primem1, &Prime, 1);
    s_set_int(&powersc, power);
    for (s_set_int(&itersc, 0); s_comp(&itersc, &powersc, 1, 0); s_add_int_eq(&itersc, 1)) {
        secp256k1_scalar_shr_int(&Primem1, 1);
    }
    mt = Primem1;

    /* Generate Private and Public Keys */
    randomint = secp256k1_testrand32();
    secp256k1_scalar_set_int(&privKey, randomint);
    secp256k1_ecmult_gen(&ctx.ecmult_gen_ctx, &pubKey, &privKey);

    /* secondary varible initilization */
    secp256k1_testrand_init("0x6babad1ad8c5e1266586e7e26b2ca6f8");
    K = malloc(l*sizeof(secp256k1_scalar));
    R = malloc((l+1)*sizeof(secp256k1_gej));
    P = malloc(powerW*sizeof(secp256k1_gej));
    MB = malloc(l*sizeof(unsigned int *));
    CB = malloc(l*sizeof(secp256k1_scalar *));

    /* get random k's and r's */
    for (iter = 0; iter < l; iter++) {
        MB[iter] = malloc(2*sizeof(unsigned int));
        CB[iter] = malloc(2*sizeof(hash_value));
        randomint = secp256k1_testrand32();
        secp256k1_scalar_set_int(&k, randomint);
        K[iter] = k;
        secp256k1_ecmult_gen(&ctx.ecmult_gen_ctx, &rgej, &k);
        R[iter] = rgej;
        m0 = secp256k1_testrand32();
        m1 = secp256k1_testrand32();
        encode(encodeR, &rgej);
        c0.R = rgej;
        c1.R = rgej;
        c0.aux = m0;
        c0.iteration = iter;
        hash_point(&c0.hash, encodeR, m0);
        c1.aux = m1;
        c1.iteration = iter;
        hash_point(&c1.hash, encodeR, m1);
        MB[iter][0] = m0;
        MB[iter][1] = m1;
        CB[iter][0] = c0;
        CB[iter][1] = c1;
    }

    /* Get pll */
    s_set_int(&pll, 0);
    for (iter = 0; iter < k2; iter++) {
        secp256k1_scalar C1, C0, a, ab, b, p, res, binv;
        s_copy(&C0, &CB[iter][0].hash);
        s_copy(&C1, &CB[iter][1].hash);
        // s_copy(&a, &CB[iter][0].hash);
        s_subtract(&b, &C1, &C0);
        secp256k1_scalar_inverse(&binv, &b);
        s_multiply(&ab, &a, &binv);
        s_pow(&p, iter);
        s_multiply(&res, &ab, &p);
        s_add_eq(&pll, &res);
    }
    s_subtract_eq(&pll, &mt);
    /* no end term because we use zero*/
    printf("GENERATE RHO L\n\n\n\n\n");
    /* Get Rho L */
    /* Generate the First Term of Rho L*/
    secp256k1_gej_set_infinity(&firstTerm);
    for (iter = 0; iter < k2; iter++) {
        secp256k1_scalar C1, C0, b, binv, p;
        secp256k1_gej C0ge, a, res, ab;
        s_copy(&C0, &CB[iter][0].hash);
        s_copy(&C1, &CB[iter][1].hash);
        s_to_gej(ctx, &C0ge, &C0);
        gej_subtract(&a, &R[iter], &C0ge);
        s_subtract(&b, &C1, &C0);
        secp256k1_scalar_inverse(&binv, &b);
        gej_multiply_s(ctx, &ab, &a, &binv);
        s_pow(&p, iter);
        gej_multiply_s(ctx, &res, &ab, &p);
        gej_add_eq(&firstTerm, &res);
    }

    /* Generate the Second Term of Rho L*/
    s_to_gej(ctx, &mtgej, &mt);
    
    /* Generate the Third Term of Rho L */
    endTerm = R[k2];
    for (iter = k2+1; iter < k1+k2; iter++) {
        gej_add_eq(&endTerm, &R[iter]);
    }

    /* Asemble Rho L*/
    if (k2 > 0 && k1 > 0) {
        gej_subtract_eq(&firstTerm, &mtgej);
        gej_subtract(&Rl, &firstTerm, &endTerm);
    } else if (k1 > 0) {
        gej_subtract_eq(&endTerm, &mtgej);
        secp256k1_gej_neg(&Rl, &endTerm);
    } else {
        gej_subtract_eq(&firstTerm, &mtgej);
        Rl = firstTerm;
    }
    gej_multiply_s(ctx, &pllG, &pubKey, &pll);
    gej_subtract_eq(&Rl, &pllG);
    R[l] = Rl;


    /* Assign Cl*/
    Ml = secp256k1_testrand32();
    encode(encodeR, &Rl);
    Cl.R = Rl;
    Cl.aux = Ml;
    Cl.iteration = l+1;
    hash_point(&Cl.hash, encodeR, Ml);

    // /* Call Klist */


    /* Grab correct R's and assign to P's to run in klist*/
    for (iter = 0; iter < powerW; iter++) {
        P[iter] = R[k2+iter];
    }



    s_set_int(&s, 0);
    if (k1 > 0) {
        for (iter = 0; iter < powerW; iter++) {
            printf("iter%d = ", iter);
            println_gej_ge(&P[iter]);
        }

        klisthros(&klistresult, P);
        printf("klistresult\n");
        println_scalar(&Cl.hash);
        println_scalar(&klistresult.currenthash);
        for (iter = 0; iter < powerW; iter++) {
            printf("aux%d = %u\n", iter, klistresult.hashes[iter].aux);
            printf("hash%d: ", iter);
            println_scalar(&klistresult.hashes[iter].hash);
        }

        /* Offset s */ 
        s_add(&s, &klistresult.currenthash, &mt);
    }
    printf("s: ");
    println_scalar(&s);






    

    /* Convert s to binary */
    bits = malloc(k2*sizeof(unsigned int));
    printf("binary: ");
    for (iter = 0; iter < k2; iter++) {
        bit = secp256k1_scalar_get_bits(&s, iter, 1); 
        printf("%d", bit);
        bits[iter] = bit;
    }

    /* Assign correct aux and Cs */
    aux = malloc(l+1*sizeof(unsigned int));
    C = malloc(l+1*sizeof(hash_value));
    for (iter = 0; iter < k2; iter++) {
        aux[iter] = MB[iter][bits[iter]];
        C[iter] = CB[iter][bits[iter]];
    }
    if (k1 > 0) {
        for (iter = 0; iter < powerW; iter++) {
            aux[k2+iter] = klistresult.hashes[iter].aux;
            C[k2+iter] = klistresult.hashes[iter];
        }
    }

    /* Get l signatures */
    S = malloc(l*sizeof(secp256k1_scalar));
    for (iter = 0; iter < l; iter++) {
        secp256k1_scalar result;
        s_multiply(&result, &privKey, &C[iter].hash);
        s_add_eq(&result, &K[iter]);
        S[iter] = result;
    }

    /* Test the l signatures */
    for (iter = 0; iter < l; iter++) {
        secp256k1_gej smG, cimP, smc;
        secp256k1_ecmult_gen(&ctx.ecmult_gen_ctx, &smG, &S[iter]);
        gej_multiply_s(ctx, &cimP, &pubKey, &C[iter].hash);
        gej_subtract(&smc, &smG, &cimP);
        println_gej_ge(&smc);
        println_gej_ge(&R[iter]);
    }



    /* Generate the First Term of Sl*/
    s_set_int(&firstTermsc, 0);
    for (iter = 0; iter < k2; iter++) {
        secp256k1_scalar C1, C0, a, ab, b, p, res, binv;
        s_copy(&C0, &CB[iter][0].hash);
        s_copy(&C1, &CB[iter][1].hash);
        s_subtract(&b, &C1, &C0);
        s_subtract(&a, &S[iter], &C0);
        secp256k1_scalar_inverse(&binv, &b);
        s_multiply(&ab, &a, &binv);
        s_pow(&p, iter);
        s_multiply(&res, &p, &ab);
        s_add_eq(&firstTermsc, &res);
    }
    printf("ft");
    println_scalar(&firstTermsc);


    /* Generate the End Term of Sl*/
    s_set_int(&endTermsc, 0);
    for (iter = k2; iter < l; iter++) {
        s_add_eq(&endTermsc, &S[iter]);
    }
    /* Asemble Sl */
    if (k2 > 0 && k1 > 0) {
        s_subtract_eq(&firstTermsc, &mt);
        s_subtract(&Sl, &firstTermsc, &endTermsc);
    } else if (k1 > 0) {
        s_subtract_eq(&endTermsc, &mt);
        secp256k1_scalar_negate(&Sl, &endTermsc);
    } else {
        s_subtract_eq(&firstTermsc, &mt);
        Sl = firstTermsc;
    }
    printf("Sl: ");
    println_scalar(&Sl);
    println_scalar(&Cl.hash);

    println_scalar(&C[l].hash);
    {
        secp256k1_gej smG, cimP, smc;
        secp256k1_ecmult_gen(&ctx.ecmult_gen_ctx, &smG, &Sl);
        gej_multiply_s(ctx, &cimP, &pubKey, &C[l].hash);
        gej_subtract(&smc, &smG, &cimP);
        println_gej_ge(&smc);
        println_gej_ge(&Rl);
    }
    
    return 1;
}
