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


#ifndef __internal_Hacl_Ed25519_H
#define __internal_Hacl_Ed25519_H

#if defined(__cplusplus)
extern "C" {
#endif

#include <string.h>
#include "krml/internal/types.h"
#include "krml/lowstar_endianness.h"
#include "krml/internal/target.h"


#include "internal/Hacl_Streaming.h"
#include "internal/Hacl_Hash_SHA2.h"
#include "internal/Hacl_Curve25519_51.h"
#include "../Hacl_Ed25519.h"
#include "libintvector.h"
void Hacl_Bignum25519_reduce_513(u64 *a);

void Hacl_Bignum25519_inverse(u64 *out, u64 *a);

void Hacl_Bignum25519_load_51(u64 *output, u8 *input);

void Hacl_Bignum25519_store_51(u8 *output, u64 *input);

void Hacl_Impl_Ed25519_PointAdd_point_add(u64 *out, u64 *p, u64 *q);

void Hacl_Impl_Ed25519_Ladder_point_mul(u64 *result, u8 *scalar, u64 *q);

void Hacl_Impl_Ed25519_PointCompress_point_compress(u8 *z, u64 *p);

bool Hacl_Impl_Ed25519_PointDecompress_point_decompress(u64 *out, u8 *s);

bool Hacl_Impl_Ed25519_PointEqual_point_equal(u64 *p, u64 *q);

void Hacl_Impl_Ed25519_PointNegate_point_negate(u64 *p, u64 *out);

#if defined(__cplusplus)
}
#endif

#define __internal_Hacl_Ed25519_H_DEFINED
#endif
