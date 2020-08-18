/* MIT License
 *
 * Copyright (c) 2016-2020 INRIA, CMU and Microsoft Corporation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


#if defined(__cplusplus)
extern "C" {
#endif

#include "evercrypt_targetconfig.h"
#include "libintvector.h"
#include "kremlin/internal/types.h"
#include "kremlin/lowstar_endianness.h"
#include <string.h>
#include "kremlin/internal/target.h"


#ifndef __Hacl_Frodo_KEM_H
#define __Hacl_Frodo_KEM_H

#include "Hacl_Kremlib.h"
#include "Lib_RandomBuffer_System.h"
#include "Hacl_SHA3.h"
#include "Hacl_Lib.h"

/* SNIPPET_START: Hacl_Frodo_KEM_crypto_kem_keypair */

uint32_t Hacl_Frodo_KEM_crypto_kem_keypair(uint8_t *pk, uint8_t *sk);

/* SNIPPET_END: Hacl_Frodo_KEM_crypto_kem_keypair */

/* SNIPPET_START: Hacl_Frodo_KEM_crypto_kem_enc */

uint32_t Hacl_Frodo_KEM_crypto_kem_enc(uint8_t *ct, uint8_t *ss, uint8_t *pk);

/* SNIPPET_END: Hacl_Frodo_KEM_crypto_kem_enc */

/* SNIPPET_START: Hacl_Frodo_KEM_crypto_kem_dec */

uint32_t Hacl_Frodo_KEM_crypto_kem_dec(uint8_t *ss, uint8_t *ct, uint8_t *sk);

/* SNIPPET_END: Hacl_Frodo_KEM_crypto_kem_dec */

#define __Hacl_Frodo_KEM_H_DEFINED
#endif

#if defined(__cplusplus)
}
#endif

