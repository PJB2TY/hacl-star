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


#include "Hacl_Frodo976.h"

#include "internal/Hacl_Frodo_KEM.h"

u32 Hacl_Frodo976_crypto_bytes = (u32)24U;

u32 Hacl_Frodo976_crypto_publickeybytes = (u32)15632U;

u32 Hacl_Frodo976_crypto_secretkeybytes = (u32)31296U;

u32 Hacl_Frodo976_crypto_ciphertextbytes = (u32)15744U;

u32 Hacl_Frodo976_crypto_kem_keypair(u8 *pk, u8 *sk)
{
  u8 coins[64U] = { 0U };
  u8 *s;
  u8 *seed_se;
  u8 *z;
  u8 *seed_a;
  u8 *b_bytes;
  u8 *s_bytes;
  randombytes_((u32)64U, coins);
  s = coins;
  seed_se = coins + (u32)24U;
  z = coins + (u32)48U;
  seed_a = pk;
  Hacl_SHA3_shake256_hacl((u32)16U, z, (u32)16U, seed_a);
  b_bytes = pk + (u32)16U;
  s_bytes = sk + (u32)15656U;
  {
    u16 s_matrix[7808U] = { 0U };
    u16 e_matrix[7808U] = { 0U };
    u8 r[31232U] = { 0U };
    u8 shake_input_seed_se[25U] = { 0U };
    shake_input_seed_se[0U] = (u8)0x5fU;
    memcpy(shake_input_seed_se + (u32)1U, seed_se, (u32)24U * sizeof (u8));
    Hacl_SHA3_shake256_hacl((u32)25U, shake_input_seed_se, (u32)31232U, r);
    Lib_Memzero0_memzero(shake_input_seed_se, (u32)25U * sizeof (shake_input_seed_se[0U]));
    Hacl_Impl_Frodo_Sample_frodo_sample_matrix976((u32)976U, (u32)8U, r, s_matrix);
    Hacl_Impl_Frodo_Sample_frodo_sample_matrix976((u32)976U, (u32)8U, r + (u32)15616U, e_matrix);
    {
      u16 b_matrix[7808U] = { 0U };
      u16 a_matrix[952576U] = { 0U };
      u32 slen1;
      u8 *sk_p;
      Hacl_Impl_Frodo_Params_frodo_gen_matrix(Spec_Frodo_Params_SHAKE128,
        (u32)976U,
        seed_a,
        a_matrix);
      Hacl_Impl_Matrix_matrix_mul_s((u32)976U, (u32)976U, (u32)8U, a_matrix, s_matrix, b_matrix);
      Hacl_Impl_Matrix_matrix_add((u32)976U, (u32)8U, b_matrix, e_matrix);
      Hacl_Impl_Frodo_Pack_frodo_pack((u32)976U, (u32)8U, (u32)16U, b_matrix, b_bytes);
      Hacl_Impl_Matrix_matrix_to_lbytes((u32)976U, (u32)8U, s_matrix, s_bytes);
      Lib_Memzero0_memzero(s_matrix, (u32)7808U * sizeof (s_matrix[0U]));
      Lib_Memzero0_memzero(e_matrix, (u32)7808U * sizeof (e_matrix[0U]));
      slen1 = (u32)31272U;
      sk_p = sk;
      memcpy(sk_p, s, (u32)24U * sizeof (u8));
      memcpy(sk_p + (u32)24U, pk, (u32)15632U * sizeof (u8));
      Hacl_SHA3_shake256_hacl((u32)15632U, pk, (u32)24U, sk + slen1);
      Lib_Memzero0_memzero(coins, (u32)64U * sizeof (coins[0U]));
      return (u32)0U;
    }
  }
}

u32 Hacl_Frodo976_crypto_kem_enc(u8 *ct, u8 *ss, u8 *pk)
{
  u8 coins[24U] = { 0U };
  randombytes_((u32)24U, coins);
  {
    u8 seed_se_k[48U] = { 0U };
    u8 pkh_mu[48U] = { 0U };
    u8 *seed_se;
    u8 *k;
    Hacl_SHA3_shake256_hacl((u32)15632U, pk, (u32)24U, pkh_mu);
    memcpy(pkh_mu + (u32)24U, coins, (u32)24U * sizeof (u8));
    Hacl_SHA3_shake256_hacl((u32)48U, pkh_mu, (u32)48U, seed_se_k);
    seed_se = seed_se_k;
    k = seed_se_k + (u32)24U;
    {
      u8 *seed_a = pk;
      u8 *b = pk + (u32)16U;
      u16 sp_matrix[7808U] = { 0U };
      u16 ep_matrix[7808U] = { 0U };
      u16 epp_matrix[64U] = { 0U };
      u8 r[31360U] = { 0U };
      u8 shake_input_seed_se[25U] = { 0U };
      u8 *c1;
      u8 *c2;
      shake_input_seed_se[0U] = (u8)0x96U;
      memcpy(shake_input_seed_se + (u32)1U, seed_se, (u32)24U * sizeof (u8));
      Hacl_SHA3_shake256_hacl((u32)25U, shake_input_seed_se, (u32)31360U, r);
      Lib_Memzero0_memzero(shake_input_seed_se, (u32)25U * sizeof (shake_input_seed_se[0U]));
      Hacl_Impl_Frodo_Sample_frodo_sample_matrix976((u32)8U, (u32)976U, r, sp_matrix);
      Hacl_Impl_Frodo_Sample_frodo_sample_matrix976((u32)8U, (u32)976U, r + (u32)15616U, ep_matrix);
      Hacl_Impl_Frodo_Sample_frodo_sample_matrix976((u32)8U, (u32)8U, r + (u32)31232U, epp_matrix);
      c1 = ct;
      c2 = ct + (u32)15616U;
      {
        u16 bp_matrix[7808U] = { 0U };
        u16 a_matrix[952576U] = { 0U };
        Hacl_Impl_Frodo_Params_frodo_gen_matrix(Spec_Frodo_Params_SHAKE128,
          (u32)976U,
          seed_a,
          a_matrix);
        Hacl_Impl_Matrix_matrix_mul((u32)8U, (u32)976U, (u32)976U, sp_matrix, a_matrix, bp_matrix);
        Hacl_Impl_Matrix_matrix_add((u32)8U, (u32)976U, bp_matrix, ep_matrix);
        Hacl_Impl_Frodo_Pack_frodo_pack((u32)8U, (u32)976U, (u32)16U, bp_matrix, c1);
        {
          u16 v_matrix[64U] = { 0U };
          u16 b_matrix[7808U] = { 0U };
          Hacl_Impl_Frodo_Pack_frodo_unpack((u32)976U, (u32)8U, (u32)16U, b, b_matrix);
          Hacl_Impl_Matrix_matrix_mul((u32)8U, (u32)976U, (u32)8U, sp_matrix, b_matrix, v_matrix);
          Hacl_Impl_Matrix_matrix_add((u32)8U, (u32)8U, v_matrix, epp_matrix);
          {
            u16 mu_encode[64U] = { 0U };
            Hacl_Impl_Frodo_Encode_frodo_key_encode((u32)16U, (u32)3U, (u32)8U, coins, mu_encode);
            Hacl_Impl_Matrix_matrix_add((u32)8U, (u32)8U, v_matrix, mu_encode);
            Lib_Memzero0_memzero(mu_encode, (u32)64U * sizeof (mu_encode[0U]));
            Hacl_Impl_Frodo_Pack_frodo_pack((u32)8U, (u32)8U, (u32)16U, v_matrix, c2);
            Lib_Memzero0_memzero(v_matrix, (u32)64U * sizeof (v_matrix[0U]));
            Lib_Memzero0_memzero(sp_matrix, (u32)7808U * sizeof (sp_matrix[0U]));
            Lib_Memzero0_memzero(ep_matrix, (u32)7808U * sizeof (ep_matrix[0U]));
            Lib_Memzero0_memzero(epp_matrix, (u32)64U * sizeof (epp_matrix[0U]));
            {
              u32 ss_init_len = (u32)15768U;
              KRML_CHECK_SIZE(sizeof (u8), ss_init_len);
              {
                u8 shake_input_ss[ss_init_len];
                memset(shake_input_ss, 0U, ss_init_len * sizeof (u8));
                memcpy(shake_input_ss, ct, (u32)15744U * sizeof (u8));
                memcpy(shake_input_ss + (u32)15744U, k, (u32)24U * sizeof (u8));
                Hacl_SHA3_shake256_hacl(ss_init_len, shake_input_ss, (u32)24U, ss);
                Lib_Memzero0_memzero(shake_input_ss, ss_init_len * sizeof (shake_input_ss[0U]));
                Lib_Memzero0_memzero(seed_se_k, (u32)48U * sizeof (seed_se_k[0U]));
                Lib_Memzero0_memzero(coins, (u32)24U * sizeof (coins[0U]));
                return (u32)0U;
              }
            }
          }
        }
      }
    }
  }
}

u32 Hacl_Frodo976_crypto_kem_dec(u8 *ss, u8 *ct, u8 *sk)
{
  u16 bp_matrix[7808U] = { 0U };
  u16 c_matrix[64U] = { 0U };
  u8 *c1 = ct;
  u8 *c2 = ct + (u32)15616U;
  Hacl_Impl_Frodo_Pack_frodo_unpack((u32)8U, (u32)976U, (u32)16U, c1, bp_matrix);
  Hacl_Impl_Frodo_Pack_frodo_unpack((u32)8U, (u32)8U, (u32)16U, c2, c_matrix);
  {
    u8 mu_decode[24U] = { 0U };
    u8 *s_bytes = sk + (u32)15656U;
    u16 s_matrix[7808U] = { 0U };
    u16 m_matrix[64U] = { 0U };
    Hacl_Impl_Matrix_matrix_from_lbytes((u32)976U, (u32)8U, s_bytes, s_matrix);
    Hacl_Impl_Matrix_matrix_mul_s((u32)8U, (u32)976U, (u32)8U, bp_matrix, s_matrix, m_matrix);
    Hacl_Impl_Matrix_matrix_sub((u32)8U, (u32)8U, c_matrix, m_matrix);
    Hacl_Impl_Frodo_Encode_frodo_key_decode((u32)16U, (u32)3U, (u32)8U, m_matrix, mu_decode);
    Lib_Memzero0_memzero(s_matrix, (u32)7808U * sizeof (s_matrix[0U]));
    Lib_Memzero0_memzero(m_matrix, (u32)64U * sizeof (m_matrix[0U]));
    {
      u8 seed_se_k[48U] = { 0U };
      u32 pkh_mu_decode_len = (u32)48U;
      KRML_CHECK_SIZE(sizeof (u8), pkh_mu_decode_len);
      {
        u8 pkh_mu_decode[pkh_mu_decode_len];
        memset(pkh_mu_decode, 0U, pkh_mu_decode_len * sizeof (u8));
        {
          u8 *pkh = sk + (u32)31272U;
          u8 *seed_se;
          u8 *kp;
          u8 *s;
          memcpy(pkh_mu_decode, pkh, (u32)24U * sizeof (u8));
          memcpy(pkh_mu_decode + (u32)24U, mu_decode, (u32)24U * sizeof (u8));
          Hacl_SHA3_shake256_hacl(pkh_mu_decode_len, pkh_mu_decode, (u32)48U, seed_se_k);
          seed_se = seed_se_k;
          kp = seed_se_k + (u32)24U;
          s = sk;
          {
            u16 bpp_matrix[7808U] = { 0U };
            u16 cp_matrix[64U] = { 0U };
            u16 sp_matrix[7808U] = { 0U };
            u16 ep_matrix[7808U] = { 0U };
            u16 epp_matrix[64U] = { 0U };
            u8 r[31360U] = { 0U };
            u8 shake_input_seed_se[25U] = { 0U };
            u8 *pk;
            u8 *seed_a;
            u8 *b;
            shake_input_seed_se[0U] = (u8)0x96U;
            memcpy(shake_input_seed_se + (u32)1U, seed_se, (u32)24U * sizeof (u8));
            Hacl_SHA3_shake256_hacl((u32)25U, shake_input_seed_se, (u32)31360U, r);
            Lib_Memzero0_memzero(shake_input_seed_se, (u32)25U * sizeof (shake_input_seed_se[0U]));
            Hacl_Impl_Frodo_Sample_frodo_sample_matrix976((u32)8U, (u32)976U, r, sp_matrix);
            Hacl_Impl_Frodo_Sample_frodo_sample_matrix976((u32)8U,
              (u32)976U,
              r + (u32)15616U,
              ep_matrix);
            Hacl_Impl_Frodo_Sample_frodo_sample_matrix976((u32)8U,
              (u32)8U,
              r + (u32)31232U,
              epp_matrix);
            pk = sk + (u32)24U;
            seed_a = pk;
            b = pk + (u32)16U;
            {
              u16 a_matrix[952576U] = { 0U };
              Hacl_Impl_Frodo_Params_frodo_gen_matrix(Spec_Frodo_Params_SHAKE128,
                (u32)976U,
                seed_a,
                a_matrix);
              Hacl_Impl_Matrix_matrix_mul((u32)8U,
                (u32)976U,
                (u32)976U,
                sp_matrix,
                a_matrix,
                bpp_matrix);
              Hacl_Impl_Matrix_matrix_add((u32)8U, (u32)976U, bpp_matrix, ep_matrix);
              {
                u16 b_matrix[7808U] = { 0U };
                Hacl_Impl_Frodo_Pack_frodo_unpack((u32)976U, (u32)8U, (u32)16U, b, b_matrix);
                Hacl_Impl_Matrix_matrix_mul((u32)8U,
                  (u32)976U,
                  (u32)8U,
                  sp_matrix,
                  b_matrix,
                  cp_matrix);
                Hacl_Impl_Matrix_matrix_add((u32)8U, (u32)8U, cp_matrix, epp_matrix);
                {
                  u16 mu_encode[64U] = { 0U };
                  u16 b1;
                  u16 b2;
                  u16 mask0;
                  u16 mask;
                  Hacl_Impl_Frodo_Encode_frodo_key_encode((u32)16U,
                    (u32)3U,
                    (u32)8U,
                    mu_decode,
                    mu_encode);
                  Hacl_Impl_Matrix_matrix_add((u32)8U, (u32)8U, cp_matrix, mu_encode);
                  Lib_Memzero0_memzero(mu_encode, (u32)64U * sizeof (mu_encode[0U]));
                  Hacl_Impl_Matrix_mod_pow2((u32)8U, (u32)976U, (u32)16U, bpp_matrix);
                  Hacl_Impl_Matrix_mod_pow2((u32)8U, (u32)8U, (u32)16U, cp_matrix);
                  Lib_Memzero0_memzero(sp_matrix, (u32)7808U * sizeof (sp_matrix[0U]));
                  Lib_Memzero0_memzero(ep_matrix, (u32)7808U * sizeof (ep_matrix[0U]));
                  Lib_Memzero0_memzero(epp_matrix, (u32)64U * sizeof (epp_matrix[0U]));
                  b1 = Hacl_Impl_Matrix_matrix_eq((u32)8U, (u32)976U, bp_matrix, bpp_matrix);
                  b2 = Hacl_Impl_Matrix_matrix_eq((u32)8U, (u32)8U, c_matrix, cp_matrix);
                  mask0 = b1 & b2;
                  mask = mask0;
                  {
                    u8 kp_s[24U] = { 0U };
                    u32 ss_init_len;
                    {
                      u32 i;
                      for (i = (u32)0U; i < (u32)24U; i++)
                      {
                        u8 *os = kp_s;
                        u8 uu____0 = s[i];
                        u8 x = uu____0 ^ ((u8)mask & (kp[i] ^ uu____0));
                        os[i] = x;
                      }
                    }
                    ss_init_len = (u32)15768U;
                    KRML_CHECK_SIZE(sizeof (u8), ss_init_len);
                    {
                      u8 ss_init[ss_init_len];
                      memset(ss_init, 0U, ss_init_len * sizeof (u8));
                      memcpy(ss_init, ct, (u32)15744U * sizeof (u8));
                      memcpy(ss_init + (u32)15744U, kp_s, (u32)24U * sizeof (u8));
                      Hacl_SHA3_shake256_hacl(ss_init_len, ss_init, (u32)24U, ss);
                      Lib_Memzero0_memzero(ss_init, ss_init_len * sizeof (ss_init[0U]));
                      Lib_Memzero0_memzero(kp_s, (u32)24U * sizeof (kp_s[0U]));
                      Lib_Memzero0_memzero(seed_se_k, (u32)48U * sizeof (seed_se_k[0U]));
                      Lib_Memzero0_memzero(mu_decode, (u32)24U * sizeof (mu_decode[0U]));
                      return (u32)0U;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

