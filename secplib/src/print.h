/**********************************************************************
 * ** THIS SHOULD NOT BE COMMITTED **                              ** *
 **********************************************************************/

#ifndef _SECP256K1_PRINT_
#define _SECP256K1_PRINT_

#include <stdio.h>

#include "field.h"

void print_fe(const secp256k1_fe *fe) {
    int i;
    unsigned char data[32];
    secp256k1_fe copy = *fe;
    secp256k1_fe_normalize(&copy);
    secp256k1_fe_get_b32(data, &copy);
    printf("0x");
    for (i = 0; i < 32; ++i) {
        printf("%02x", data[i]);
    }
}

void println_fe(const secp256k1_fe *fe) {
    print_fe(fe);
    puts("");
}

void println_ge(const secp256k1_ge *ge) {
    if (secp256k1_ge_is_infinity(ge)) {
        puts ("(ge @ infinity)");
    } else {
        printf ("("); print_fe(&ge->x); printf (", "); print_fe(&ge->y); puts (")");
    }
}

void println_gej(secp256k1_gej *gej) {
    if (secp256k1_gej_is_infinity(gej)) {
        puts ("(gej @ infinity)");
    } else {
        printf ("("); print_fe(&gej->x); printf (", "); print_fe(&gej->y); printf(", "); print_fe(&gej->z); puts (")");
    }
}



void println_gej_ge(secp256k1_gej *gej) {
    secp256k1_ge ge;
    if (secp256k1_gej_is_infinity(gej)) {
        puts ("(gej @ infinity)");
    } else {
        secp256k1_ge_set_gej(&ge, gej);
        printf ("("); print_fe(&ge.x); printf (", "); print_fe(&ge.y); puts (")");
    }
}

#if 0
void println_scalar_ge(const secp256k1_context *ctx, const secp256k1_scalar *s) {
    secp256k1_gej pkeyj;
    secp256k1_ecmult_gen(&ctx->ecmult_gen_ctx, &pkeyj, s);
    println_gej_ge(&pkeyj);
}

void println_pubkey_ge(const secp256k1_context *ctx, const secp256k1_pubkey *p) {
    secp256k1_ge pkey;
    secp256k1_pubkey_load(ctx, &pkey, p);
    println_ge(&pkey);
}
#endif


#ifndef EXHAUSTIVE_TEST_ORDER
void println_scalar(const secp256k1_scalar *s) {
    int n = (int) (sizeof (s->d) / sizeof (s->d[0]));
    int i;
    printf("scalar: ");
    for (i = n - 1; i >= 0; --i) {
        switch (sizeof(s->d[0])) {
            case 1:  printf("%02llx", (long long) s->d[i]); break;
            case 2:  printf("%04llx", (long long) s->d[i]); break;
            case 4:  printf("%08llx", (long long) s->d[i]); break;
            case 8:  printf("%016llx", (long long) s->d[i]); break;
        }
    }
    printf("\n");
}
#else
void println_scalar(const secp256k1_scalar *s) {
    (void) s;
}
#endif


void printlnb(const unsigned char *msg) {
    int i;
    printf("Print 34: ");
    for (i = 0; i < 34; ++i) {
        printf("%02x", msg[i]);
    }
    printf("\n");
}




#endif
