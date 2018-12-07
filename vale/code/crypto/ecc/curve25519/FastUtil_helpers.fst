module FastUtil_helpers

open Words_s
open Types_s
open FStar.Mul
open FStar.Tactics
open CanonCommSemiring
open Fast_defs
open Fast_lemmas_internal

#reset-options "--using_facts_from '* -FStar.Tactics -FStar.Reflection -CanonCommMonoid -CanonCommSwaps -CanonCommSemiring'"

#push-options "--z3rlimit 5000 --max_fuel 0 --max_ifuel 0"
// Passes
(*
let lemma_sub2
      (a:nat) (a0 a1:nat64)      
      (b:nat) (b0 b1:nat64)
      (s1 s2:nat64) (c:bit) : Lemma
  (requires a = pow2_two a0 a1 /\
            b = pow2_two b0 b1 /\            
           (let s1', c1 = sub_carry a0 b0 0 in
            let s2', c2 = sub_carry a1 b1 c1 in
            s1 == s1' /\
            s2 == s2' /\
            c  == c2))
  (ensures a - b == pow2_two s1 s2 - c * pow2_128)
  =
  ()
*)
// Passes
let lemma_sub3
      (a:nat) (a0 a1 a2:nat64)      
      (b:nat) (b0 b1 b2:nat64)
      (s1 s2 s3:nat64) (c:bit) : Lemma
  (requires a = pow2_three a0 a1 a2 /\
            b = pow2_three b0 b1 b2 /\            
           (let s1', c1 = sub_carry a0 b0 0 in
            let s2', c2 = sub_carry a1 b1 c1 in
            let s3', c3 = sub_carry a2 b2 c2 in
            s1 == s1' /\
            s2 == s2' /\
            s3 == s3' /\
            c  == c3))
  (ensures a - b == pow2_three s1 s2 s3 - c * pow2_192)
  =
  ()
#pop-options

// Unclear why lemma_sub2 and lemma_sub3 pass, but lemma_sub4 fails without explicit help

let pow2int_three (c0 c1 c2:int) : int = c0 + c1 * pow2_64 + c2 * pow2_128
let pow2int_four (c0 c1 c2 c3:int) : int = c0 + c1 * pow2_64 + c2 * pow2_128 + c3 * pow2_192

let lemma_pow2_int_34 (c0 c1 c2 c3:int) : 
  Lemma (pow2int_four c0 c1 c2 c3 == pow2int_three c0 c1 c2 + c3 * pow2_192)
  =
  ()

#push-options "--z3rlimit 300 --max_fuel 0 --max_ifuel 0"
let lemma_sub
      (a:nat) (a0 a1 a2 a3:nat64)      
      (b:nat) (b0 b1 b2 b3:nat64)
      (s1 s2 s3 s4:nat64) (c:bit) : Lemma
  (requires a = pow2_four a0 a1 a2 a3 /\
            b = pow2_four b0 b1 b2 b3 /\            
           (let s1', c1 = sub_carry a0 b0 0 in
            let s2', c2 = sub_carry a1 b1 c1 in
            let s3', c3 = sub_carry a2 b2 c2 in
            let s4', c4 = sub_carry a3 b3 c3 in
            s1 == s1' /\
            s2 == s2' /\
            s3 == s3' /\
            s4 == s4' /\
            c  == c4))
  (ensures a - b == pow2_four s1 s2 s3 s4 - c * pow2_256)
  =
  let a_minus_b = a - b in
  assert_by_tactic (a_minus_b == pow2int_four (a0 - b0) (a1 - b1) (a2 - b2) (a3 - b3)) int_canon;
  let a_three = pow2_three a0 a1 a2 in
  let b_three = pow2_three b0 b1 b2 in
  let a3_minus_b3 = a_three - b_three in
  assert_by_tactic (a3_minus_b3 == pow2int_three (a0 - b0) (a1 - b1) (a2 - b2)) int_canon;
  lemma_pow2_int_34 (a0 - b0) (a1 - b1) (a2 - b2) (a3 - b3);
  assert (pow2int_four (a0 - b0) (a1 - b1) (a2 - b2) (a3 - b3) == pow2int_three (a0 - b0) (a1 - b1) (a2 - b2) + (a3 - b3) * pow2_192); 
  assert (a_minus_b == a3_minus_b3 + (a3 - b3) * pow2_192);
  let s1', c1 = sub_carry a0 b0 0 in
  let s2', c2 = sub_carry a1 b1 c1 in
  let s3', c3 = sub_carry a2 b2 c2 in
  let s4', c4 = sub_carry a3 b3 c3 in
  lemma_sub3 a_three a0 a1 a2
             b_three b0 b1 b2
             s1 s2 s3 c3;
  assert (a3_minus_b3 = pow2_three s1 s2 s3 - c3 * pow2_192);     
  assert (a_minus_b == pow2_three s1 s2 s3 + (a3 - b3 - c3) * pow2_192);
  assert_by_tactic ((a3 - b3 - c3) * pow2_192 == s4 * pow2_192 - c * pow2_256) int_canon;
  assert (a_minus_b == pow2_three s1 s2 s3 + s4 * pow2_192 - c * pow2_256);
  assert_by_tactic (pow2_three s1 s2 s3 + s4 * pow2_192 == pow2_four s1 s2 s3 s4) int_canon;
  () 
#pop-options

