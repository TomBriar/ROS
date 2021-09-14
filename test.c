/***********************************************************************
 * Copyright (c) 2016 Andrew Poelstra                                  *
 * Distributed under the MIT software license, see the accompanying    *
 * file COPYING or https://www.opensource.org/licenses/mit-license.php.*
 ***********************************************************************/

#include "./secplib/src/libsecp256k1-config.h"
// #include <secp256k1_schnorrsig.h>
// #include <secp256k1_ecdh.h>
// #include <secp256k1_ecdsa_adaptor.h>
// #include <secp256k1_ecdsa_s2c.h>
// #include <secp256k1_extrakeys.h>
// #include <secp256k1_generator.h>
// #include <secp256k1_musig.h>
// #include <secp256k1_preallocated.h>
// #include <secp256k1_rangeproof.h>
// #include <secp256k1_recovery.h>
// #include <secp256k1_surjectionproof.h>
// #include <secp256k1_whitelist.h>


#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <secp256k1.h>

#ifndef SECP256K1_MODULE_SCHNORRSIG_TESTS_H
#define SECP256K1_MODULE_SCHNORRSIG_TESTS_H
#endif
#undef USE_ECMULT_STATIC_PRECOMPUTATION

// #include "secplib/src/secp256k1.c"
// #include "secplib/include/secp256k1.h"
// // #include "secplib/src/modules/schnorrsig/main_impl.h"
// // #include "secplib/src/modules/extrakeys/main_impl.h"
// // #include "secplib/include/secp256k1_extrakeys.h"
// // #include "secplib/include/secp256k1_schnorrsig.h"
// #include "secplib/src/assumptions.h"
#include "secplib/src/hash.h"
// #include "secplib/src/group.h"
// #include "secplib/src/testrand_impl.h"

static void hash(char* data, unsigned char *out) {
    size_t len = sizeof(data)-1;
    printf("len = %zu\n", len);
    secp256k1_sha256 hash;
    int iter;
    secp256k1_sha256_initialize(&hash);
    for (iter = 0; iter < len; iter++) {
        unsigned char bit = data[iter];
        secp256k1_sha256_write(&hash, &bit, len);
    }

    secp256k1_sha256_finalize(&hash, out);
}



// int encode(Point R) {
//     xy = R.xy()
//     x = int(xy[0])
//     y = int(xy[1])
//     result = b''
//     if y % 2:
//         result += b'3'
//     else:
//         result += b'2'
//     result += padbytes(bytes(hex(x), "utf8")[2:])
//     return result
// }
   

int klisthros(int w, int L, secp256k1_ge *R) {
    int iter;
    int power = pow(2, L);
    int aux[power];
    for(iter = 0; iter < power; iter++){
        aux[iter] = iter;
    }
    int x;
    for (x = 0; x < 32; x++) {
        if (x > 0) printf(":");
        printf("%02X", aux[x]);
    }
    // Liw = []
    // for i in range(0, len(R)):
    //     Li = []
    //     for j in range(0, len(aux)):
    //         Li.append(([IntPrime(hash(encode(R[i]), aux[j]))],IntPrime(hash(encode(R[i]), aux[j])),[aux[j]]))
    //     Liw.append(Li)
    // Tree = [Liw]
    // ##Collison ----
    // for x in range(0, w): #add one because SUM is inclusive and end range is exclusive minus one because the range should be 1 - w
    //     FLi = []
    //     level = w-x
    //     TreeLevel = Tree[x]
    //     for j in range(0, 2^(level-1)): #add one because SUM is inclusive and end range is exclusive minus one because we are indexing from 0
    //         FLi.append(join(TreeLevel[j*2-1],TreeLevel[2*j],Ii(level))) #minus one because lists are 1 indexed in the paper
    //     Tree.append(FLi)
    // finalTree = Tree[w][0]
    // result = []
    // for i in range(0, len(finalTree)):
    //     if finalTree[i][1] == 0:
    //         result = (finalTree[i][0], finalTree[i][1], finalTree[i][2])
    //         break
    //     result = ([],0,[])
    // return result
    return 1;
}

 // void random (secp256k1_scalar *r, const secp256k1_ge *group, int k, int* overflow) {
 //        secp256k1_fe x;
 //        unsigned char x_bin[32];
 //        k %= EXHAUSTIVE_TEST_ORDER;
 //        x = group[k].x;
 //        secp256k1_fe_normalize(&x);
 //        secp256k1_fe_get_b32(x_bin, &x);
 //        secp256k1_scalar_set_b32(r, x_bin, overflow);
 //    }
  
int schnorr(secp256k1_context ctx, secp256k1_ge group, secp256k1_gej groupj) {
    // int lambdaParameter = ceil((log(Prime) / log(2)));
    // int w = 3;
    // int L = lambdaParameter/(w+1);
    // int k1 = pow(2, (w-1));
    // int k2 = fmax(0, ceil(lambdaParameter - (w + 1) * L));
    // int l = k1+k2;
    // printf("l = %d \n", l);

    // int a = Prime - 1;
    // int b = pow(2,((w+1)*L+1));
    // printf("a = %d \n", a);
    // printf("b = %d \n", b);
    // secp256k1_scalar mt = floor((a / b));
    // printf("mt = %d \n", mt);
    // char msg[30] = "haaohna";
    // unsigned char out32;
    // hash(&msg, &out32);
    // printf("out32 = %d\n", out32);

    // printf("gx: %llu", group.x.n[1]);


    secp256k1_scalar k;
    secp256k1_scalar_set_int(&k, 3);
    secp256k1_gej r;
    secp256k1_ecmult_gen(&ctx.ecmult_gen_ctx, &r, &k);
    printf("\n r: %llu", r.x.n[0]);



    // secp256k1_ge R[l];
    // int iter;
    // for (iter = 0; x < l; x++) {
    //     secp256k1_ge 
    //     R[iter] = 
    // }


    // res = klisthros(w, L, R);

   
    

 
    return 1;
}




// int secp256k1_nonce_function_smallint(unsigned char *nonce32, const unsigned char *msg32,
//                                       const unsigned char *key32, const unsigned char *algo16,
//                                       void *data, unsigned int attempt) {
//     secp256k1_scalar s;
//     int *idata = data;
//     (void)msg32;
//     (void)key32;
//     (void)algo16;
//     /* Some nonces cannot be used because they'd cause s and/or r to be zero.
//      * The signing function has retry logic here that just re-calls the nonce
//      * function with an increased `attempt`. So if attempt > 0 this means we
//      * need to change the nonce to avoid an infinite loop. */
//     if (attempt > 0) {
//         *idata = (*idata + 1) % EXHAUSTIVE_TEST_ORDER;
//     }
//     secp256k1_scalar_set_int(&s, *idata);
//     secp256k1_scalar_get_b32(nonce32, &s);
//     return 1;
// }

// typedef struct {
//     secp256k1_scalar sc[2];
//     secp256k1_ge pt[2];
// } ecmult_multi_data;

// void r_from_k(secp256k1_scalar *r, const secp256k1_ge *group, int k, int* overflow) {
//     secp256k1_fe x;
//     unsigned char x_bin[32];
//     k %= EXHAUSTIVE_TEST_ORDER;
//     x = group[k].x;
//     secp256k1_fe_normalize(&x);
//     secp256k1_fe_get_b32(x_bin, &x);
//     secp256k1_scalar_set_b32(r, x_bin, overflow);
// }

// void test_exhaustive_sign(const secp256k1_context *ctx, const secp256k1_ge *group) {
//     int i, j, k;
//     uint64_t iter = 0;
//     i = 75;
//     j = 1;
//     k = 1;

 
    // const int starting_k = k;
    // int ret;
    // secp256k1_ecdsa_signature sig;
    // secp256k1_scalar sk, msg, r, s, expected_r;
    // unsigned char sk32[32], msg32[32];
    // secp256k1_scalar_set_int(&msg, i);

    // secp256k1_scalar_get_b32(msg32, &msg);
    // msg32[30] = 0x4C;
    // printf("%02X\n", msg32[30]);

    
    // printf("\n");
    // printf("%d", msg);
    //#IMPORTANT ----
    // unsigned char sk[32];
    // secp256k1_xonly_pubkey pk;
    // secp256k1_keypair keypair;
    // const unsigned char msg[32] = "this is a msg for a schnorrsig..";
    // unsigned char sig[64];
    // unsigned char sig2[64];
    // unsigned char zeros64[64] = { 0 };
    // secp256k1_schnorrsig_extraparams extraparams = SECP256K1_SCHNORRSIG_EXTRAPARAMS_INIT;
    // unsigned char aux_rand[32];

    // secp256k1_testrand256(sk);
    // secp256k1_testrand256(aux_rand);
    // CHECK(secp256k1_keypair_create(ctx, &keypair, sk));
    //#STOP----
    // CHECK(secp256k1_keypair_xonly_pub(ctx, &pk, NULL, &keypair));
    // CHECK(secp256k1_schnorrsig_sign(ctx, sig, msg, &keypair, NULL) == 1);
    // CHECK(secp256k1_schnorrsig_verify(ctx, sig, msg, sizeof(msg), &pk));

    /* Test different nonce functions */
    // CHECK(secp256k1_schnorrsig_sign_custom(ctx, sig, msg, sizeof(msg), &keypair, &extraparams) == 1);
    // CHECK(secp256k1_schnorrsig_verify(ctx, sig, msg, sizeof(msg), &pk));
    // ret = secp256k1_ecdsa_sign(ctx, &sig, msg32, sk32, secp256k1_nonce_function_smallint, &k);
    // CHECK(ret == 1);

    // secp256k1_ecdsa_signature_load(ctx, &r, &s, &sig);

    /* Note that we compute expected_r *after* signing -- this is important
     * because our nonce-computing function function might change k during
     * signing. */
    // r_from_k(&expected_r, group, k, NULL);
    // CHECK(r == expected_r);
    // CHECK((k * s) % EXHAUSTIVE_TEST_ORDER == (i + r * j) % EXHAUSTIVE_TEST_ORDER ||
    //       (k * (EXHAUSTIVE_TEST_ORDER - s)) % EXHAUSTIVE_TEST_ORDER == (i + r * j) % EXHAUSTIVE_TEST_ORDER);

    /* We would like to verify zero-knowledge here by counting how often every
     * possible (s, r) tuple appears, but because the group order is larger
     * than the field order, when coercing the x-values to scalar values, some
     * appear more often than others, so we are actually not zero-knowledge.
     * (This effect also appears in the real code, but the difference is on the
     * order of 1/2^128th the field order, so the deviation is not useful to a
     * computationally bounded attacker.)
     */
// }


int main(int argc, char** argv) {
    // int i;
    secp256k1_gej groupj, groupjinf;
    secp256k1_ge group, groupinf;
    secp256k1_gej_set_infinity(&groupjinf);
    secp256k1_ge_set_gej(&groupinf, &groupjinf);
    secp256k1_gej_add_ge(&groupj, &groupj, &secp256k1_ge_const_g);
    secp256k1_ge_set_gej(&group, &groupj);
    unsigned char rand32[32];
    secp256k1_context *ctx;
    ctx = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY);
    secp256k1_testrand256(rand32);
    CHECK(secp256k1_context_randomize(ctx, rand32));

    // /* Generate the entire group */
    // secp256k1_gej_set_infinity(&groupj[0]);
    // secp256k1_ge_set_gej(&group[0], &groupj[0]);
    // for (i = 1; i < EXHAUSTIVE_TEST_ORDER; i++) {
    //     secp256k1_gej_add_ge(&groupj[i], &groupj[i - 1], &secp256k1_ge_const_g);
    //     secp256k1_ge_set_gej(&group[i], &groupj[i]);
    // }
    // test_exhaustive_sign(ctx, group);
    schnorr(*ctx, group, groupj);
    printf("\n no problems found\n");
}



