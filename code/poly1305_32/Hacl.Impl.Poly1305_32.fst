module Hacl.Impl.Poly1305_32

open FStar.HyperStack.All

module ST = FStar.HyperStack.ST


open FStar.Mul
open FStar.HyperStack.ST
open FStar.Ghost
open FStar.Seq
open FStar.HyperStack
open FStar.Endianness
open FStar.Buffer

open Hacl.Spec.Endianness
open Hacl.Endianness

open Hacl.Cast
open Hacl.Bignum.Parameters
open Hacl.Spec.Bignum.Bigint
open Hacl.Spec.Bignum.AddAndMultiply
open Hacl.Spe.Poly1305_32
open Hacl.Bignum.AddAndMultiply

include Hacl.Impl.Poly1305_32.State

module H8   = Hacl.UInt8
module Limb = Hacl.Bignum.Limb
module Wide = Hacl.Bignum.Wide
module U8   = FStar.UInt8
module U32  = FStar.UInt32
module U64  = FStar.UInt64


let log_t = erased (Hacl.Spec.Poly1305_32.text)

inline_for_extraction let bigint = felem
inline_for_extraction let uint8_p = buffer Hacl.UInt8.t

let elemB : Type0  = b:felem

let wordB : Type0  = b:uint8_p{length b <= 16}
let wordB_16 : Type0 = b:uint8_p{length b = 16}


#reset-options "--max_fuel 0 --z3rlimit 5"

(** From the current memory state, returns the integer corresponding to a elemB, (before
   computing the modulo)  *)
private val sel_int: h:mem -> b:elemB{live h b} -> GTot nat
private let sel_int h b = eval h b


(* ############################################################################# *)
(*                              API FOR THE RECORD LAYER                         *)
(* ############################################################################# *)


#reset-options "--z3rlimit 200 --max_fuel 0"

[@ Substitute]
val upd_5: b:felem -> b0:limb -> b1:limb -> b2:limb -> b3:limb -> b4:limb -> Stack unit
    (requires (fun h -> live h b))
    (ensures (fun h0 _ h1 -> live h1 b /\ modifies_1 b h0 h1
      /\ as_seq h1 b == Hacl.Spec.Poly1305_32.create_5 b0 b1 b2 b3 b4))
[@ Substitute]
let upd_5 b b0 b1 b2 b3 b4 =
  b.(0ul) <- b0;
  b.(1ul) <- b1;
  b.(2ul) <- b2;
  b.(3ul) <- b3;
  b.(4ul) <- b4;
  let h = ST.get() in
  assert (get h b 0 == b0);
  assert (get h b 1 == b1);
  assert (get h b 2 == b2);
  assert (get h b 2 == b2);
  assert (get h b 2 == b2);
  Seq.lemma_eq_intro (as_seq h b) (Hacl.Spec.Poly1305_32.create_5 b0 b1 b2 b3 b4)


inline_for_extraction private
let clamp_mask : cm:Hacl.UInt128.t{Hacl.UInt128.v cm = 0x0ffffffc0ffffffc0ffffffc0fffffff} =
  Hacl.Spec.Poly1305_32.hload128 (0x0ffffffc0ffffffcuL) (0x0ffffffc0fffffffuL)


[@ Substitute]
val poly1305_encode_r:
  r:bigint ->
  key:uint8_p{length key = 16} ->
  Stack unit
    (requires (fun h -> live h r /\ live h key))
    (ensures  (fun h0 _ h1 -> modifies_1 r h0 h1 /\ live h1 r /\ live h0 key
      /\ red_26 (as_seq h1 r)
      /\ as_seq h1 r == Hacl.Spec.Poly1305_32.poly1305_encode_r_spec (as_seq h0 key)
    ))
[@ Substitute]
let poly1305_encode_r r key =
  let h0 = ST.get() in
  let k = hload128_le key in
  let k_clamped = Hacl.UInt128.(k &^ clamp_mask) in
  // let r0 = Limb.(sint128_to_sint64 k_clamped &^ Hacl.Spec.Poly1305_32.mask_26) in
  // let r1 = Limb.(sint128_to_sint64 (Wide.(k_clamped >>^ 44ul)) &^ Hacl.Spec.Poly1305_32.mask_26) in
  // let r2 = Limb.(sint128_to_sint64 (Wide.(k_clamped >>^ 88ul))) in
  // let r0 = Limb.(sint128_to_sint64 k_clamped &^ Hacl.Spec.Poly1305_32.mask_26) in
  // let r1 = Limb.(sint128_to_sint64 (Wide.(k_clamped >>^ 44ul)) &^ Hacl.Spec.Poly1305_32.mask_26) in
  // let r2 = Limb.(sint128_to_sint64 (Wide.(k_clamped >>^ 88ul))) in  
  // Hacl.Spec.Poly1305_32.lemma_encode_r k_clamped;
  let open Hacl.Spec.Poly1305_32 in
  let r0 = shift_mask' k_clamped in
  let r1 = shift_mask k_clamped 26ul in
  let r2 = shift_mask k_clamped 52ul in
  let r3 = shift_mask k_clamped 78ul in
  let r4 = shift_mask k_clamped 104ul in  
  // assert_norm(pow2 44 = 0x100000000000);
  // assert_norm(pow2 40 = 0x10000000000);
  upd_5 r r0 r1 r2 r3 r4


[@ Substitute]
val toField:
  b:bigint ->
  m:wordB_16 ->
  Stack unit
    (requires (fun h -> live h b /\ live h m /\ disjoint b m))
    (ensures  (fun h0 _ h1 -> modifies_1 b h0 h1 /\ live h1 b /\ live h0 m
      /\ red_26 (as_seq h1 b)
      /\ v (Seq.index (as_seq h1 b) 4) < pow2 24
      /\ as_seq h1 b == Hacl.Spec.Poly1305_32.fexpand_spec (as_seq h0 m)
    ))
[@ Substitute]
let toField b block =
  let h0 = ST.get() in
  let s0 = Buffer.sub block 0ul 4ul in
  let s1 = Buffer.sub block 3ul 4ul in
  let s2 = Buffer.sub block 6ul 4ul in
  let s3 = Buffer.sub block 9ul 4ul in
  let s4 = Buffer.sub block 12ul 4ul in
  Seq.lemma_eq_intro (as_seq h0 s0) (Seq.slice (as_seq h0 block) 0 4);
  Seq.lemma_eq_intro (as_seq h0 s1) (Seq.slice (as_seq h0 block) 3 7);
  Seq.lemma_eq_intro (as_seq h0 s2) (Seq.slice (as_seq h0 block) 6 10);
  Seq.lemma_eq_intro (as_seq h0 s3) (Seq.slice (as_seq h0 block) 9 13);
  Seq.lemma_eq_intro (as_seq h0 s4) (Seq.slice (as_seq h0 block) 12 16);
  let i0 = load32_le s0 in
  let i1 = load32_le s1 in
  let i2 = load32_le s2 in
  let i3 = load32_le s3 in
  let i4 = load32_le s4 in
  let open Hacl.UInt32 in
  let open Hacl.Spec.Poly1305_32 in
  let r0 = (i0         ) &^ mask_26 in
  let r1 = (i1 >>^ 2ul ) &^ mask_26 in
  let r2 = (i2 >>^ 4ul ) &^ mask_26 in
  let r3 = (i3 >>^ 6ul ) &^ mask_26 in
  let r4 = (i4 >>^ 8ul) in
  // let m  = hload128_le block in
  // let r0 = Limb.(sint128_to_sint64 m &^ Hacl.Spec.Poly1305_32.mask_26) in
  // let r1 = Limb.(sint128_to_sint64 (Wide.(m >>^ 44ul)) &^ Hacl.Spec.Poly1305_32.mask_26) in
  // let r2 = Limb.(sint128_to_sint64 (Wide.(m >>^ 88ul))) in
  upd_5 b r0 r1 r2 r3 r4;
  let h1 = ST.get() in
  (**) Seq.lemma_eq_intro (as_seq h1 b) (Hacl.Spec.Poly1305_32.fexpand_spec (as_seq h0 block));
  ()


[@ Substitute]
val toField_plus_2_128:
  b:bigint ->
  m:wordB_16 ->
  Stack unit
    (requires (fun h -> live h b /\ live h m /\ disjoint b m))
    (ensures  (fun h0 _ h1 -> modifies_1 b h0 h1 /\ live h1 b /\ live h0 m
      /\ red_26 (as_seq h1 b)
      /\ as_seq h1 b == Hacl.Spec.Poly1305_32.toField_plus_2_128_spec (as_seq h0 m)
    ))
[@ Substitute]
let toField_plus_2_128 b m =
  let h0 = ST.get() in
  toField b m;
  let b4 = b.(4ul) in
  let open Hacl.Bignum.Limb in
  assert_norm (pow2 24 = 0x1000000);
  assert_norm (0 = 0x1000000 % pow2 24);
  UInt.logor_disjoint (0x1000000) (v b4) 24;
  assert_norm (pow2 24 + pow2 24 < pow2 26);
  let b4' = uint32_to_limb 0x1000000ul |^ b4 in
  b.(4ul) <- b4'


[@ Substitute]
val poly1305_start:
  a:elemB ->
  Stack unit
    (requires (fun h -> live h a))
    (ensures  (fun h0 _ h1 -> live h1 a /\ modifies_1 a h0 h1
      /\ red_y (as_seq h1 a)
      /\ as_seq h1 a == Hacl.Spec.Poly1305_32.poly1305_start_spec ()
      ))
[@ Substitute]
let poly1305_start a =
  (* Zeroing the accumulator *)
  upd_5 a limb_zero limb_zero limb_zero limb_zero limb_zero;
  let h = ST.get() in
  Seq.lemma_eq_intro (as_seq h a) (Hacl.Spec.Poly1305_32.poly1305_start_spec ())


module Spec = Hacl.Spec.Poly1305_32

#reset-options "--max_fuel 0 --z3rlimit 100"

[@ Substitute]
val poly1305_init_:
  st:poly1305_state ->
  key:uint8_p{length key = 16} ->
  Stack log_t
    (requires (fun h -> live_st h st /\ live h key))
    (ensures  (fun h0 log h1 -> modifies_2 st.r st.h h0 h1 /\ live h0 key
      /\ live h1 st.r /\ live h1 st.h /\ red_26 (as_seq h1 st.r) /\ red_y (as_seq h1 st.h)
      /\ Spec.MkState (as_seq h1 st.r) (as_seq h1 st.h) (Ghost.reveal log) == poly1305_init_spec (as_seq h0 key)
      ))
[@ Substitute]
let poly1305_init_ st key =
  poly1305_encode_r st.r (sub key 0ul 16ul);
  poly1305_start st.h;
  let log = hide (Seq.createEmpty #Spec.Poly1305.word) in
  log


#reset-options "--z3rlimit 100 --max_fuel 0"

noextract
private val hide_log:
  h0:HyperStack.mem ->
  m:uint8_p{length m <= 16} ->
  log:log_t{live h0 m} ->
  Tot (log':log_t{Ghost.reveal log' == FStar.Seq.(create 1 (as_seq h0 m) @| Ghost.reveal log)})

#reset-options "--z3rlimit 100 --max_fuel 0"

let hide_log h0 m log =
  let (m':erased Spec.Poly1305.word) = elift1 #(b:wordB{live h0 b}) #Spec.word'
                    (fun m -> reveal_sbytes (as_seq h0 m)) (hide m) in
  elift2 (fun (l:Spec.Poly1305.text) (m:Spec.Poly1305.word) -> FStar.Seq.((Seq.create 1 (m)) @| l)) log m'

#reset-options "--z3rlimit 100 --max_fuel 0"

[@ CInline]
val poly1305_update:
  current_log:log_t ->
  st:poly1305_state ->
  m:uint8_p{length m = 16} ->
  Stack log_t
    (requires (fun h -> live_st h st /\ live h m
      /\ red_y (as_seq h st.h)
      /\ red_26 (as_seq h st.r)
      ))
    (ensures  (fun h0 updated_log h1 -> modifies_1 st.h h0 h1 /\ live_st h1 st /\ live_st h0 st
      /\ live h0 m
      /\ red_y (as_seq h0 st.h)
      /\ red_26 (as_seq h0 st.r)
      /\ red_y (as_seq h1 st.h)
      /\ Spec.MkState (as_seq h1 st.r) (as_seq h1 st.h) (Ghost.reveal updated_log)
        == poly1305_update_spec (Spec.MkState (as_seq h0 st.r) (as_seq h0 st.h) (Ghost.reveal current_log)) (as_seq h0 m)
      ))
#reset-options "--z3rlimit 200 --max_fuel 0"
[@ CInline]
let poly1305_update log st m =
  let acc = st.h in
  let r   = st.r in
  (**) let h0 = ST.get() in
  push_frame();
  (**) let h1 = ST.get() in
  let tmp = create limb_zero clen in
  (**) let h2 = ST.get() in
  (**) no_upd_lemma_0 h1 h2 r;
  (**) no_upd_lemma_0 h1 h2 acc;
  toField_plus_2_128 tmp m;
  (**) let h3 = ST.get() in
  (**) lemma_modifies_0_1' tmp h1 h2 h3;
  (**) no_upd_lemma_1 h2 h3 tmp r;
  (**) no_upd_lemma_1 h2 h3 tmp acc;
  add_and_multiply acc tmp r;
  let h4 = ST.get() in
  no_upd_lemma_1 h3 h4 acc r;
  (**) lemma_modifies_0_1 acc h1 h3 h4;
  pop_frame();
  let h5 = ST.get() in
  (**) modifies_popped_1 st.h h0 h1 h4 h5;
  hide_log h0 m log

  (* let (m':erased Spec.Poly1305.word) = elift2_p #wordB_16 #HyperStack.mem #(fun m h -> live h m) #Spec.word' *)
  (*                   (fun m h -> reveal_sbytes (as_seq h m)) (hide m) (hide h0) in *)
  (* elift2 (fun (l:Spec.Poly1305.text) (m:Spec.Poly1305.word) -> FStar.Seq.((Seq.create 1 (m)) @| l)) log m' *)


#reset-options "--max_fuel 0 --z3rlimit 100"

[@ Substitute]
val poly1305_concat:
  b:uint8_p{length b = 16} ->
  m:uint8_p{disjoint b m} ->
  len:U64.t{U64.v len < 16 /\ U64.v len = length m} ->
  Stack unit
    (requires (fun h -> live h m /\ live h b
      /\ as_seq h b == Seq.create 16 (uint8_to_sint8 0uy)))
    (ensures (fun h0 _ h1 -> live h0 m /\ live h0 b /\ live h1 b /\ modifies_1 b h0 h1
      /\ as_seq h1 b == Seq.append (as_seq h0 m) (Seq.create (16 - U64.v len) (uint8_to_sint8 0uy))
    ))
[@ Substitute]
let poly1305_concat b m len =
  assert_norm(pow2 32 = 0x100000000);
  let h0 = ST.get() in
  Hacl.Spec.Bignum.Fmul.lemma_whole_slice (as_seq h0 m);
  let i = FStar.Int.Cast.uint64_to_uint32 len in
  Math.Lemmas.modulo_lemma (U64.v len) (pow2 32);
  cut (Seq.slice (as_seq h0 m) 0 (U32.v i) == as_seq h0 m);
  blit m 0ul b 0ul i;
  let h1 = ST.get() in
  Seq.lemma_eq_intro (Seq.create (16 - U64.v len) (uint8_to_sint8 0uy)) (Seq.slice (as_seq h0 b) (U64.v len) 16);
  Seq.lemma_eq_intro (Seq.create (16 - U64.v len) (uint8_to_sint8 0uy)) (Seq.slice (as_seq h1 b) (U64.v len) 16);
  Seq.lemma_eq_intro (as_seq h0 m) (Seq.slice (as_seq h1 b) 0 (U64.v len));
  Hacl.Spec.Bignum.Fmul.lemma_whole_slice (as_seq h1 b);
  Seq.lemma_eq_intro (as_seq h1 b) (Seq.append (as_seq h0 m) (Seq.create (16 - U64.v len) (uint8_to_sint8 0uy)))

#reset-options "--max_fuel 0 --z3rlimit 100"

[@ CInline]
val poly1305_process_last_block_:
  current_log:log_t ->
  block:uint8_p{length block = 16} ->
  st:poly1305_state ->
  m:uint8_p ->
  len:U64.t{U64.v len < 16 /\ U64.v len = length m} ->
  Stack log_t
    (requires (fun h -> live_st h st /\ live h m /\ red_26 (as_seq h st.r) /\ red_y (as_seq h st.h)
      /\ live h block /\ as_seq h block == Seq.upd (Seq.append (as_seq h m) (Seq.create (16 - U64.v len) (uint8_to_sint8 0uy))) (U64.v len) (uint8_to_sint8 1uy)
      /\ disjoint block st.h /\ disjoint block st.r
    ))
    (ensures (fun h0 updated_log h1 -> live_st h0 st /\ live h0 m /\ red_26 (as_seq h0 st.r) /\ red_y (as_seq h0 st.h)
      /\ live_st h1 st /\ red_26 (as_seq h1 st.r) /\ red_y (as_seq h1 st.h)
      /\ live h0 block
      /\ modifies_1 st.h h0 h1
      /\ Spec.MkState (as_seq h1 st.r) (as_seq h1 st.h) (Ghost.reveal updated_log) == Hacl.Spec.Poly1305_32.poly1305_process_last_block_spec (Spec.MkState (as_seq h0 st.r) (as_seq h0 st.h) (Ghost.reveal current_log)) (as_seq h0 m) (len)
    ))

#reset-options "--max_fuel 0 --z3rlimit 100"

[@ CInline]
let poly1305_process_last_block_ log block st m rem' =
  (**) let hinit = ST.get() in
  push_frame();
  (**) let h = ST.get() in
  let tmp = create limb_zero clen in
  (**) let h' = ST.get() in
  assert_norm(pow2 32 = 0x100000000);
  Math.Lemmas.modulo_lemma (U64.v rem') (pow2 32);
  let i = FStar.Int.Cast.uint64_to_uint32 rem' in
  let h0 = ST.get() in
  toField tmp block;
  let h1 = ST.get() in
  (**) lemma_modifies_0_1' tmp h h' h1;
  add_and_multiply st.h tmp st.r;
  let h2 = ST.get() in
  (**) lemma_modifies_0_1 st.h h h1 h2;
  pop_frame();
  (**) let hfin = ST.get() in
  (**) modifies_popped_1 st.h hinit h h2 hfin;
  hide_log h0 m log
  

#reset-options "--max_fuel 0 --z3rlimit 100"

[@ CInline]
val poly1305_process_last_block:
  current_log:log_t ->
  st:poly1305_state ->
  m:uint8_p ->
  len:U64.t{U64.v len < 16 /\ U64.v len = length m} ->
  Stack log_t
    (requires (fun h -> live_st h st /\ live h m /\ red_26 (as_seq h st.r) /\ red_y (as_seq h st.h)))
    (ensures (fun h0 updated_log h1 -> live_st h0 st /\ live h0 m
      /\ red_26 (as_seq h0 st.r) /\ red_y (as_seq h0 st.h)
      /\ live_st h1 st /\ red_26 (as_seq h1 st.r) /\ red_y (as_seq h1 st.h)
      /\ modifies_1 st.h h0 h1
      /\ Spec.MkState (as_seq h1 st.r) (as_seq h1 st.h) (Ghost.reveal updated_log) == Hacl.Spec.Poly1305_32.poly1305_process_last_block_spec (Spec.MkState (as_seq h0 st.r) (as_seq h0 st.h) (Ghost.reveal current_log)) (as_seq h0 m) (len)
    ))
[@ CInline]
let poly1305_process_last_block log st m rem' =
  (**) let hinit = ST.get() in
  push_frame();
  (**) let h0 = ST.get() in
  let zero = uint8_to_sint8 0uy in
  let block = create zero 16ul in
  (**) let h1 = ST.get() in
  let i = FStar.Int.Cast.uint64_to_uint32 rem' in
  poly1305_concat block m rem';
  (**) let h2 = ST.get() in
  block.(i) <- uint8_to_sint8 1uy;
  (**) let h3 = ST.get() in
  (**) lemma_modifies_1_trans block h1 h2 h3;
  (**) lemma_modifies_0_1' block h0 h1 h3;
  let log' = poly1305_process_last_block_ log block st m rem' in
  (**) let h4 = ST.get() in
  (**) lemma_modifies_0_1 st.h h0 h3 h4;
  pop_frame();
  (**) let hfin = ST.get() in
  (**) modifies_popped_1 st.h hinit h0 h4 hfin;
  log'


[@ Substitute]
val poly1305_last_pass_:
  acc:felem ->
  Stack unit
    (requires (fun h -> live h acc /\ bounds (as_seq h acc) p26 p26 p26 p26 p26))
    (ensures (fun h0 _ h1 -> live h0 acc /\ bounds (as_seq h0 acc) p26 p26 p26 p26 p26
      /\ live h1 acc /\ bounds (as_seq h1 acc) p26 p26 p26 p26 p26
      /\ modifies_1 acc h0 h1
      /\ as_seq h1 acc == Hacl.Spec.Poly1305_32.poly1305_last_pass_spec_ (as_seq h0 acc)))
[@ Substitute]
let poly1305_last_pass_ acc =
  let a0 = acc.(0ul) in
  let a1 = acc.(1ul) in
  let a2 = acc.(2ul) in
  let a3 = acc.(3ul) in
  let a4 = acc.(4ul) in
  let open Hacl.Bignum.Limb in
  let mask0 = gte_mask a0 Hacl.Spec.Poly1305_32.p26m5 in
  let mask1 = eq_mask a1 Hacl.Spec.Poly1305_32.p26m1 in
  let mask2 = eq_mask a2 Hacl.Spec.Poly1305_32.p26m1 in
  let mask3 = eq_mask a3 Hacl.Spec.Poly1305_32.p26m1 in
  let mask4 = eq_mask a4 Hacl.Spec.Poly1305_32.p26m1 in
  let mask  = mask0 &^ mask1 &^ mask2 &^ mask3 &^ mask4 in
  let open Hacl.Spec.Poly1305_32 in
  UInt.logand_lemma_1 (v mask0); UInt.logand_lemma_1 (v mask1); UInt.logand_lemma_1 (v mask2);
  UInt.logand_lemma_1 (v mask3); UInt.logand_lemma_1 (v mask4);
  UInt.logand_lemma_2 (v mask0); UInt.logand_lemma_2 (v mask1); UInt.logand_lemma_2 (v mask2);
  UInt.logand_lemma_2 (v mask3); UInt.logand_lemma_2 (v mask4);
  UInt.logand_associative (v mask0) (v mask1) (v mask2);
  cut (v mask = UInt.ones 64 ==> (v a0 >= pow2 26 - 5 /\ v a1 = pow2 26 - 1 /\ v a2 = pow2 26 - 1 /\ v a3 = pow2 26 - 1 /\ v a4 = pow2 26 - 1));
  UInt.logand_lemma_1 (v p26m5); UInt.logand_lemma_1 (v p26m1); UInt.logand_lemma_1 (v p26m1);
  UInt.logand_lemma_2 (v p26m5); UInt.logand_lemma_2 (v p26m1); UInt.logand_lemma_2 (v p26m1);
  let a0' = a0 -^ (p26m5 &^ mask) in
  let a1' = a1 -^ (p26m1 &^ mask) in
  let a2' = a2 -^ (p26m1 &^ mask) in
  let a3' = a3 -^ (p26m1 &^ mask) in
  let a4' = a4 -^ (p26m1 &^ mask) in
  upd_5 acc a0' a1' a2' a3' a4'

#reset-options "--max_fuel 0 --z3rlimit 100"

private let lemma_div_26 (a:nat{a <= pow2 26}) : Lemma (a / pow2 26 = 1 ==> (a = pow2 26 /\ a % pow2 26 = 0)) = assert_norm((pow2 26 - 1) / pow2 26 = 0); assert_norm(pow2 26 % pow2 26 = 0)

#reset-options "--max_fuel 0 --z3rlimit 1000"

[@ Substitute]
val fcontract_first_carry_pass:
  acc:felem ->
  Stack unit
    (requires (fun h -> live h acc /\ red_y (as_seq h acc)))
    (ensures (fun h0 _ h1 -> live h0 acc /\ red_y (as_seq h0 acc)
      /\ live h1 acc /\ modifies_1 acc h0 h1
      /\ as_seq h1 acc == Hacl.Spec.Poly1305_32.fcontract_first_carry_pass (as_seq h0 acc)))
[@ Substitute]
let fcontract_first_carry_pass acc =
  let open Hacl.UInt32 in
  assert_norm(pow2 26 + pow2 13 = 0x4002000);
  assert_norm(pow2 26 = 0x4000000);
  assert_norm(pow2 0 = 1);
  let t0 = acc.(0ul) in
  let t1 = acc.(1ul) in
  let t2 = acc.(2ul) in
  let t3 = acc.(3ul) in
  let t4 = acc.(4ul) in
  // Hacl.Spec.Bignum.Modulo.lemma_seval_5 s;
  let t1' = t1 +^ (t0 >>^ 26ul) in
  let mask_26 = Hacl.Spec.Poly1305_32.mask_26 in
  let t0' = t0 &^ mask_26 in
  UInt.logand_mask (v t0) 26;
  // lemma_carry_local (v t0) (v t1) 0;
  // cut (v t0' + pow2 26 * v t1' + pow2 52 * v t2 + pow2 78 * v t3 + pow2 104 * v t4 = Hacl.Spec.Bignum.Bigint.seval s);
  let t2' = t2 +^ (t1' >>^ 26ul) in
  let t1'' = t1' &^ mask_26 in
  UInt.logand_mask (v t1') 26;
  // lemma_carry_local (v t1') (v t2) 26;
  // cut (v t0' + pow2 26 * v t1'' + pow2 52 * v t2' + pow2 78 * v t3 + pow2 104 * v t4
  //      = v t0' + pow2 26 * v t1' + pow2 52 * v t2 + pow2 78 * v t3 + pow2 104 * v t4);
  let t3' = t3 +^ (t2' >>^ 26ul) in
  let t2'' = t2' &^ mask_26 in
  UInt.logand_mask (v t2') 26;
  // lemma_carry_local (v t2') (v t3) 52;
  // cut (v t0' + pow2 26 * v t1'' + pow2 52 * v t2'' + pow2 78 * v t3' + pow2 104 * v t4
  //      = v t0' + pow2 26 * v t1'' + pow2 52 * v t2' + pow2 78 * v t3 + pow2 104 * v t4);
  let t4' = t4 +^ (t3' >>^ 26ul) in
  let t3'' = t3' &^ mask_26 in
  UInt.logand_mask (v t3') 26;
  // lemma_carry_local (v t3') (v t4) 78;
  // cut (v t0' + pow2 26 * v t1'' + pow2 52 * v t2'' + pow2 78 * v t3' + pow2 104 * v t4
  //      = v t0' + pow2 26 * v t1'' + pow2 52 * v t2'' + pow2 78 * v t3'' + pow2 104 * v t4');
  upd_5 acc t0' t1'' t2'' t3'' t4';
  // Hacl.Spec.Bignum.Modulo.lemma_seval_5 s';
  // s'
  ()


[@ Substitute]
val fcontract_first_carry_full:
  acc:felem ->
  Stack unit
    (requires (fun h -> live h acc /\ red_y (as_seq h acc)))
    (ensures (fun h0 _ h1 -> live h0 acc /\ red_y (as_seq h0 acc)
      /\ live h1 acc /\ modifies_1 acc h0 h1
      /\ as_seq h1 acc == Hacl.Spec.Poly1305_32.fcontract_first_carry_full (as_seq h0 acc)))
[@ Substitute]
let fcontract_first_carry_full acc =
  fcontract_first_carry_pass acc;
  let h = ST.get() in
  assert_norm(5 * (pow2 32 / pow2 26) + pow2 26 < pow2 27);
  Hacl.Spec.Bignum.Modulo.lemma_carry_top_spec_ (as_seq h acc);
  Hacl.Spec.Bignum.Modulo.lemma_carry_top_spec (as_seq h acc);
  Hacl.Bignum.Modulo.carry_top acc


#reset-options "--z3rlimit 100 --max_fuel 0"

[@ Substitute]
val fcontract_second_carry_pass_full:
  acc:felem ->
  Stack unit
    (requires (fun h -> live h acc /\ bounds (as_seq h acc) (pow2 27) p26 p26 p26 p26))
      // /\ (v (Seq.index (as_seq h acc) 2) = p42 ==> v (Seq.index (as_seq h acc) 1) = 0)))
    (ensures (fun h0 _ h1 -> live h0 acc /\ bounds (as_seq h0 acc) (pow2 27) p26 p26 p26 p26
      // /\ (v (Seq.index (as_seq h0 acc) 2) = p42 ==> v (Seq.index (as_seq h0 acc) 1) = 0)
      /\ live h1 acc /\ bounds (as_seq h1 acc) p26 p26 p26 p26 p26
      /\ modifies_1 acc h0 h1
      /\ as_seq h1 acc == Hacl.Spec.Poly1305_32.fcontract_second_carry_full (as_seq h0 acc)))

[@ Substitute]
let fcontract_second_carry_pass_full acc =
  let open Hacl.UInt32 in
  let open Hacl.Spec.Poly1305_32 in
  assert_norm(pow2 26 = 0x4000000);
  assert_norm(pow2 27 = 0x8000000);
  assert_norm(pow2 52 = 0x10000000000000);
  assert_norm(pow2 78 = 0x40000000000000000000);
  assert_norm(pow2 104 = 0x100000000000000000000000000);
  assert_norm(pow2 0 = 1);
  let t0 = acc.(0ul) in
  let t1 = acc.(1ul) in
  let t2 = acc.(2ul) in
  let t3 = acc.(3ul) in
  let t4 = acc.(4ul) in
  let t1' = t1 +^ (t0 >>^ 26ul) in
  assert_norm((pow2 27 - 1) / pow2 26 = 1);
  lemma_div_26 (v t1');
  let t0' = t0 &^ mask_26 in
  UInt.logand_mask (v t0) 26;
  // lemma_carry_local (v t0) (v t1) 0;
  // cut (v t0' + pow2 26 * v t1' + pow2 52 * v t2 + pow2 78 * v t3 + pow2 104 * v t4 = Hacl.Spec.Bignum.Bigint.seval s);
  let t2' = t2 +^ (t1' >>^ 26ul) in
  lemma_div_26 (v t2');
  let t1'' = t1' &^ mask_26 in
  UInt.logand_mask (v t1') 26;
  // lemma_carry_local (v t1') (v t2) 26;
  // cut (v t0' + pow2 26 * v t1'' + pow2 52 * v t2' + pow2 78 * v t3 + pow2 104 * v t4
  //      = v t0' + pow2 26 * v t1' + pow2 52 * v t2 + pow2 78 * v t3 + pow2 104 * v t4);
  let t3' = t3 +^ (t2' >>^ 26ul) in
  lemma_div_26 (v t3');
  let t2'' = t2' &^ mask_26 in
  UInt.logand_mask (v t2') 26;
  // lemma_carry_local (v t2') (v t3) 52;
  // cut (v t0' + pow2 26 * v t1'' + pow2 52 * v t2'' + pow2 78 * v t3' + pow2 104 * v t4
  //      = v t0' + pow2 26 * v t1'' + pow2 52 * v t2' + pow2 78 * v t3 + pow2 104 * v t4);
  let t4' = t4 +^ (t3' >>^ 26ul) in
  lemma_div_26 (v t4');
  let t3'' = t3' &^ mask_26 in
  UInt.logand_mask (v t3') 26;
  // lemma_carry_local (v t3') (v t4) 78;
  // cut (v t0' + pow2 26 * v t1'' + pow2 52 * v t2'' + pow2 78 * v t3' + pow2 104 * v t4
  //      = v t0' + pow2 26 * v t1'' + pow2 52 * v t2'' + pow2 78  * v t3'' + pow2 104 * v t4');
  let h0 = ST.get() in
  upd_5 acc t0' t1'' t2'' t3'' t4';
  let h1 = ST.get() in
  Hacl.Spec.Bignum.Modulo.lemma_carry_top_spec_ (as_seq h1 acc);
  Hacl.Spec.Bignum.Modulo.lemma_carry_top_spec (as_seq h1 acc);
  Hacl.Bignum.Modulo.carry_top acc;
  let h2 = ST.get() in
  Hacl.Bignum.Fproduct.carry_0_to_1 acc


#reset-options "--z3rlimit 100 --max_fuel 0"

[@ Substitute]
val poly1305_last_pass:
  acc:felem ->
  Stack unit
    (requires (fun h -> live h acc /\ red_y (as_seq h acc)))
    (ensures (fun h0 _ h1 -> live h0 acc /\ live h1 acc /\ red_y (as_seq h0 acc)
      /\ modifies_1 acc h0 h1
      /\ as_seq h1 acc == Hacl.Spec.Poly1305_32.poly1305_last_pass_spec (as_seq h0 acc)))
let poly1305_last_pass acc =
  let h = ST.get() in
  last_pass_is_fine (as_seq h acc);
  lemma_carried_is_fine_to_carry (as_seq h acc);
  Hacl.Bignum.Fproduct.carry_limb_ acc;
  let h1 = ST.get() in
  lemma_carried_is_fine_to_carry_top (as_seq h1 acc);
  Hacl.Spec.Bignum.Modulo.lemma_carry_top_spec (as_seq h1 acc);
  Hacl.Bignum.Modulo.carry_top acc;
  fcontract_first_carry_full acc;
  fcontract_second_carry_pass_full acc;
  poly1305_last_pass_ acc


[@ Substitute]
val bignum_to_128:
  a:felem ->
  Stack Hacl.UInt128.t
    (requires (fun h -> live h a /\ bounds (as_seq h a) p26 p26 p26 p26 p26))
    (ensures (fun h0 z h1 -> live h0 a /\ bounds (as_seq h0 a) p26 p26 p26 p26 p26
      /\ h0 == h1 /\ z == Hacl.Spec.Poly1305_32.bignum_to_128 (as_seq h0 a)))
[@ Substitute]
let bignum_to_128 acc =
  assert_norm(pow2 24 = 0x1000000);
  assert_norm(pow2 26 = 0x4000000);
  assert_norm(pow2 52 = 0x10000000000000);
  assert_norm(pow2 78 = 0x40000000000000000000);
  assert_norm(pow2 104 = 0x100000000000000000000000000);
  let h0 = acc.(0ul) in
  let h1 = acc.(1ul) in
  let h2 = acc.(2ul) in
  let h3 = acc.(3ul) in
  let h4 = acc.(4ul) in
  let x0 = sint32_to_sint128 h0 in
  let open Hacl.Spec.Poly1305_32 in
  let x1 = shift_left_128 h1 26ul in
  let x2 = shift_left_128 h2 52ul in
  let x3 = shift_left_128 h3 78ul in
  let x4 = shift_left_128' h4 in
  let h  = add_limbs x0 x1 x2 x3 x4 in
  h


[@ Substitute]
val poly1305_finish__:
  log:log_t ->
  st:poly1305_state ->
  m:uint8_p ->
  len:U64.t{U64.v len < 16 /\ U64.v len = length m} ->
  Stack log_t
    (requires (fun h -> live_st h st /\ live h m /\ red_26 (as_seq h st.r) /\ red_y (as_seq h st.h)))
    (ensures  (fun h0 updated_log h1 -> modifies_1 st.h h0 h1 /\ live_st h0 st /\ live h1 st.h
      /\ red_26 (as_seq h0 st.r) /\ red_y (as_seq h0 st.h) /\ red_y (as_seq h1 st.h) /\ live h0 m
      /\ (let r1   = as_seq h1 st.r in
         let r0   = as_seq h0 st.r in
         let acc1 = as_seq h1 st.h in
         let acc0 = as_seq h0 st.h in
         let log  = Ghost.reveal log in
         let log' = Ghost.reveal updated_log in
         let m    = as_seq h0 m in
         Spec.MkState r1 acc1 log' == (
           if U64.(len =^ 0uL) then Spec.MkState r0 acc0 log
           else Hacl.Spec.Poly1305_32.poly1305_process_last_block_spec (Spec.MkState r0 acc0 log) m len))
      ))
[@ Substitute]
let poly1305_finish__ log st m len =
  let h0 = ST.get() in
  if U64.(len =^ 0uL) then (log)
  else (
    let last_block = m in
    poly1305_process_last_block log st m len
    )


#reset-options "--max_fuel 0 --z3rlimit 1000"

[@ Substitute]
val poly1305_finish_:
  log:log_t ->
  st:poly1305_state ->
  mac:uint8_p{length mac = 16} ->
  m:uint8_p ->
  len:U64.t{U64.v len < 16 /\ U64.v len = length m} ->
  key_s:uint8_p{length key_s = 16} ->
  Stack unit
    (requires (fun h -> live_st h st /\ live h mac /\ live h m /\ live h key_s
      /\ disjoint st.h mac /\ disjoint st.h key_s /\ disjoint st.h m
      /\ red_26 (as_seq h st.r) /\ red_y (as_seq h st.h)))
    (ensures  (fun h0 updated_log h1 -> modifies_2 st.h mac h0 h1 /\ live_st h0 st /\ live h0 m
      /\ live h1 st.h /\ live h1 mac /\ live h0 key_s
      /\ red_26 (as_seq h0 st.r) /\ red_y (as_seq h0 st.h)
      /\ (let r0   = as_seq h0 st.r in
         let acc0 = as_seq h0 st.h in
         let log  = Ghost.reveal log in
         let m    = as_seq h0 m in
         let mac  = as_seq h1 mac in
         let k    = as_seq h0 key_s in
         mac == poly1305_finish_spec (Spec.MkState r0 acc0 log) m len k)
    ))

// Wintersteiger: admitting this query to unblock CI. It's likely solvable, but Z3 takes ages. 
#reset-options "--max_fuel 0 --z3rlimit 1000"

[@ Substitute]
let poly1305_finish_ log st mac m len key_s =
  let acc = st.h in
  let h0 = ST.get() in
  let log' = poly1305_finish__ log st m len in
  poly1305_last_pass acc;
  cut (disjoint acc mac);
  let h2 = ST.get() in
  no_upd_lemma_1 h0 h2 acc key_s;
  assert (equal h0 key_s h2 key_s);
  let k'  = hload128_le key_s in
  assert (FStar.UInt128.v k' == FStar.Endianness.little_endian (as_seq h0 key_s));
  FStar.UInt128.v_inj k' (FStar.UInt128.uint_to_t (FStar.Endianness.little_endian (as_seq h0 key_s))); //NS: 07/14 ... need to invoke injectivity explicitly; which is rather heavy
  assert (k' == Hacl.Spec.Poly1305_32.load128_le_spec (as_seq h0 key_s));
  let open Hacl.UInt128 in
  let acc' = bignum_to_128 acc in
  let mac' = acc' +%^ k' in
  hstore128_le mac mac';
  let h1 = ST.get() in
  lemma_little_endian_inj (Hacl.Spec.Endianness.reveal_sbytes (as_seq h1 mac)) (Hacl.Spec.Endianness.reveal_sbytes (poly1305_finish_spec (Spec.MkState (as_seq h0 st.r) (as_seq h0 st.h) (Ghost.reveal log)) (as_seq h0 m) len (as_seq h0 key_s)))


#reset-options "--max_fuel 0 --z3rlimit 1000"

[@ Substitute]
val poly1305_update_last:
  log:log_t ->
  st:poly1305_state ->
  m:uint8_p ->
  len:U64.t{U64.v len < 16 /\ U64.v len = length m} ->
  Stack unit
    (requires (fun h -> live_st h st /\ live h m
      /\ red_26 (as_seq h st.r) /\ red_y (as_seq h st.h)))
    (ensures  (fun h0 _ h1 -> modifies_1 st.h h0 h1 /\ live_st h0 st /\ live h0 m /\ live h1 st.h
      /\ red_26 (as_seq h0 st.r) /\ red_y (as_seq h0 st.h)
      /\ (let r0   = as_seq h0 st.r in
         let acc0 = as_seq h0 st.h in
         let log  = Ghost.reveal log in
         let r1   = as_seq h1 st.r in
         let acc1 = as_seq h1 st.h in
         let m    = as_seq h0 m in
         bounds acc1 p26 p26 p26 p26 p26 /\ 
         acc1 == Hacl.Spec.Poly1305_32.poly1305_update_last_spec (Spec.MkState r0 acc0 log) m len)
    ))
[@ Substitute]
let poly1305_update_last log st m len =
  let log' = poly1305_finish__ log st m len in
  let acc  = st.h in
  poly1305_last_pass acc


[@ Substitute]
val poly1305_finish:
  st:poly1305_state ->
  mac:uint8_p{length mac = 16} ->
  k:uint8_p{length k = 16} ->
  Stack unit
    (requires (fun h -> live_st h st /\ live h mac /\ live h k
      /\ bounds (as_seq h (st.h)) p26 p26 p26 p26 p26))
    (ensures (fun h0 _ h1 -> modifies_1 mac h0 h1 /\ live_st h0 st /\ live h0 mac /\ live h0 k /\ live h1 mac
      /\ bounds (as_seq h0 (st.h)) p26 p26 p26 p26 p26
      /\ as_seq h1 mac == Hacl.Spec.Poly1305_32.poly1305_finish_spec' (as_seq h0 (st.h)) (as_seq h0 k)
    ))
[@ Substitute]
let poly1305_finish st mac key_s =
  let h0 = ST.get() in
  let acc = st.h in
  let k'  = hload128_le key_s in
  let open Hacl.UInt128 in
  let acc' = bignum_to_128 acc in
  let mac' = acc' +%^ k' in
  hstore128_le mac mac';
  let h1 = ST.get() in
  lemma_little_endian_inj (Hacl.Spec.Endianness.reveal_sbytes (as_seq h1 mac)) (Hacl.Spec.Endianness.reveal_sbytes (Hacl.Spec.Poly1305_32.poly1305_finish_spec' (as_seq h0 acc) (as_seq h0 key_s)))


let mk_state r h = MkState r h

val alloc:
  unit -> StackInline poly1305_state
    (requires (fun h -> True))
    (ensures (fun h0 st h1 -> modifies_0 h0 h1 /\ live_st h1 st /\ frameOf st.h == h0.tip
      /\ frameOf st.r = h0.tip /\ (st.r `unused_in` h0) /\ (st.h `unused_in` h0)))
let alloc () =
  let buf = create limb_zero U32.(clen +^ clen) in
  let r = sub buf 0ul clen in
  let h = sub buf clen clen in
  mk_state r h
