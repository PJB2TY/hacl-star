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


#ifndef __Hacl_Streaming_Poly1305_128_H
#define __Hacl_Streaming_Poly1305_128_H

#if defined(__cplusplus)
extern "C" {
#endif

#include <string.h>
#include "krml/internal/types.h"
#include "krml/lowstar_endianness.h"
#include "krml/internal/target.h"


#include "Hacl_Poly1305_128.h"
#include "evercrypt_targetconfig.h"
#include "libintvector.h"
/* SNIPPET_START: Hacl_Streaming_Poly1305_128_poly1305_128_state */

typedef struct Hacl_Streaming_Poly1305_128_poly1305_128_state_s
{
  Lib_IntVector_Intrinsics_vec128 *block_state;
  uint8_t *buf;
  uint64_t total_len;
  uint8_t *p_key;
}
Hacl_Streaming_Poly1305_128_poly1305_128_state;

/* SNIPPET_END: Hacl_Streaming_Poly1305_128_poly1305_128_state */

/* SNIPPET_START: Hacl_Streaming_Poly1305_128_create_in */

Hacl_Streaming_Poly1305_128_poly1305_128_state
*Hacl_Streaming_Poly1305_128_create_in(uint8_t *k);

/* SNIPPET_END: Hacl_Streaming_Poly1305_128_create_in */

/* SNIPPET_START: Hacl_Streaming_Poly1305_128_init */

void
Hacl_Streaming_Poly1305_128_init(uint8_t *k, Hacl_Streaming_Poly1305_128_poly1305_128_state *s);

/* SNIPPET_END: Hacl_Streaming_Poly1305_128_init */

/* SNIPPET_START: Hacl_Streaming_Poly1305_128_update */

void
Hacl_Streaming_Poly1305_128_update(
  Hacl_Streaming_Poly1305_128_poly1305_128_state *p,
  uint8_t *data,
  uint32_t len
);

/* SNIPPET_END: Hacl_Streaming_Poly1305_128_update */

/* SNIPPET_START: Hacl_Streaming_Poly1305_128_finish */

void
Hacl_Streaming_Poly1305_128_finish(
  Hacl_Streaming_Poly1305_128_poly1305_128_state *p,
  uint8_t *dst
);

/* SNIPPET_END: Hacl_Streaming_Poly1305_128_finish */

/* SNIPPET_START: Hacl_Streaming_Poly1305_128_free */

void Hacl_Streaming_Poly1305_128_free(Hacl_Streaming_Poly1305_128_poly1305_128_state *s);

/* SNIPPET_END: Hacl_Streaming_Poly1305_128_free */

#if defined(__cplusplus)
}
#endif

#define __Hacl_Streaming_Poly1305_128_H_DEFINED
#endif
