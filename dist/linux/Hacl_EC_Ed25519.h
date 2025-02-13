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


#ifndef __Hacl_EC_Ed25519_H
#define __Hacl_EC_Ed25519_H

#if defined(__cplusplus)
extern "C" {
#endif

#include <string.h>
#include "krml/internal/types.h"
#include "krml/lowstar_endianness.h"
#include "krml/internal/target.h"


#include "Hacl_Krmllib.h"
#include "Hacl_Bignum25519_51.h"
#include "libintvector.h"
void Hacl_EC_Ed25519_mk_felem_zero(u64 *b);

void Hacl_EC_Ed25519_mk_felem_one(u64 *b);

void Hacl_EC_Ed25519_felem_add(u64 *a, u64 *b, u64 *out);

void Hacl_EC_Ed25519_felem_sub(u64 *a, u64 *b, u64 *out);

void Hacl_EC_Ed25519_felem_mul(u64 *a, u64 *b, u64 *out);

void Hacl_EC_Ed25519_felem_inv(u64 *a, u64 *out);

void Hacl_EC_Ed25519_felem_load(u8 *b, u64 *out);

void Hacl_EC_Ed25519_felem_store(u64 *a, u8 *out);

void Hacl_EC_Ed25519_mk_point_at_inf(u64 *p);

void Hacl_EC_Ed25519_mk_base_point(u64 *p);

void Hacl_EC_Ed25519_point_negate(u64 *p, u64 *out);

void Hacl_EC_Ed25519_point_add(u64 *p, u64 *q, u64 *out);

void Hacl_EC_Ed25519_point_mul(u8 *scalar, u64 *p, u64 *out);

bool Hacl_EC_Ed25519_point_eq(u64 *p, u64 *q);

void Hacl_EC_Ed25519_point_compress(u64 *p, u8 *out);

bool Hacl_EC_Ed25519_point_decompress(u8 *s, u64 *out);

#if defined(__cplusplus)
}
#endif

#define __Hacl_EC_Ed25519_H_DEFINED
#endif
