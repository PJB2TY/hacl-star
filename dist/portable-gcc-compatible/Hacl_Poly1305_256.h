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


#ifndef __Hacl_Poly1305_256_H
#define __Hacl_Poly1305_256_H

#if defined(__cplusplus)
extern "C" {
#endif

#include <string.h>
#include "krml/internal/types.h"
#include "krml/lowstar_endianness.h"
#include "krml/internal/target.h"


#include "Hacl_Krmllib.h"
#include "evercrypt_targetconfig.h"
#include "libintvector.h"
/* SNIPPET_START: Hacl_Poly1305_256_blocklen */

extern uint32_t Hacl_Poly1305_256_blocklen;

/* SNIPPET_END: Hacl_Poly1305_256_blocklen */

/* SNIPPET_START: Hacl_Poly1305_256_poly1305_ctx */

typedef Lib_IntVector_Intrinsics_vec256 *Hacl_Poly1305_256_poly1305_ctx;

/* SNIPPET_END: Hacl_Poly1305_256_poly1305_ctx */

/* SNIPPET_START: Hacl_Poly1305_256_poly1305_init */

void Hacl_Poly1305_256_poly1305_init(Lib_IntVector_Intrinsics_vec256 *ctx, uint8_t *key);

/* SNIPPET_END: Hacl_Poly1305_256_poly1305_init */

/* SNIPPET_START: Hacl_Poly1305_256_poly1305_update1 */

void Hacl_Poly1305_256_poly1305_update1(Lib_IntVector_Intrinsics_vec256 *ctx, uint8_t *text);

/* SNIPPET_END: Hacl_Poly1305_256_poly1305_update1 */

/* SNIPPET_START: Hacl_Poly1305_256_poly1305_update */

void
Hacl_Poly1305_256_poly1305_update(
  Lib_IntVector_Intrinsics_vec256 *ctx,
  uint32_t len,
  uint8_t *text
);

/* SNIPPET_END: Hacl_Poly1305_256_poly1305_update */

/* SNIPPET_START: Hacl_Poly1305_256_poly1305_finish */

void
Hacl_Poly1305_256_poly1305_finish(
  uint8_t *tag,
  uint8_t *key,
  Lib_IntVector_Intrinsics_vec256 *ctx
);

/* SNIPPET_END: Hacl_Poly1305_256_poly1305_finish */

/* SNIPPET_START: Hacl_Poly1305_256_poly1305_mac */

void Hacl_Poly1305_256_poly1305_mac(uint8_t *tag, uint32_t len, uint8_t *text, uint8_t *key);

/* SNIPPET_END: Hacl_Poly1305_256_poly1305_mac */

#if defined(__cplusplus)
}
#endif

#define __Hacl_Poly1305_256_H_DEFINED
#endif
