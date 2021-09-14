#if defined HAVE_CONFIG_H
#include "libsecp256k1-config.h"
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <time.h>

#include "secp256k1.c"
#include "../include/secp256k1.h"
#include "../include/secp256k1_preallocated.h"
#include "testrand_impl.h"
#include "util.h"
#include "print.h"
#include <math.h>


#include "schnorrtests.c"

#ifdef ENABLE_OPENSSL_TESTS
#include <openssl/bn.h>
#include <openssl/ec.h>
#include <openssl/ecdsa.h>
#include <openssl/obj_mac.h>
# if OPENSSL_VERSION_NUMBER < 0x10100000L
void ECDSA_SIG_get0(const ECDSA_SIG *sig, const BIGNUM **pr, const BIGNUM **ps) {*pr = sig->r; *ps = sig->s;}
# endif
#endif

#include "../contrib/lax_der_parsing.c"
#include "../contrib/lax_der_privatekey_parsing.c"

#include "modinv32_impl.h"
#ifdef SECP256K1_WIDEMUL_INT128
#include "modinv64_impl.h"
#endif

int main() {
    unsigned char rand32[32];
    secp256k1_context *ctx;
    ctx = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY);
    secp256k1_testrand256(rand32);
    CHECK(secp256k1_context_randomize(ctx, rand32));
    schnorr(*ctx);
    printf("\n no problems found\n");
}
