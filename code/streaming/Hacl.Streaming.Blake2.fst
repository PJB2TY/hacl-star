module Hacl.Streaming.Blake2

module HS = FStar.HyperStack
module B = LowStar.Buffer
module G = FStar.Ghost
module S = FStar.Seq
module U32 = FStar.UInt32
module U64 = FStar.UInt64
module U128 = FStar.UInt128
module Case = FStar.Int.Cast.Full
module F = Hacl.Streaming.Functor
module I = Hacl.Streaming.Interface
module P = Hacl.Impl.Poly1305
module ST = FStar.HyperStack.ST

module Agile = Spec.Agile.Hash
module Hash = Spec.Hash.Definitions

open LowStar.BufferOps
open FStar.Mul

module Loops = Lib.LoopCombinators

/// Opening a bunch of modules for Blake2
/// =======================================

inline_for_extraction noextract
let uint8 = Lib.IntTypes.uint8

inline_for_extraction noextract
let uint32 = Lib.IntTypes.uint32

module Spec = Spec.Blake2
open Hacl.Impl.Blake2.Core
module Core = Hacl.Impl.Blake2.Core
open Hacl.Impl.Blake2.Generic
module Impl = Hacl.Impl.Blake2.Generic
module Incr = Spec.Hash.Incremental

/// An instance of the stateful type class for blake2
/// =========================================================

#set-options "--max_fuel 0 --max_ifuel 0 --z3rlimit 100"

/// Some lemmas I could not find in Math.Lemmas
let add_zero_left_is_same (n : int) :
  Lemma(0 + n = n) = ()

let to_hash_alg (a : Spec.alg) =
  match a with
  | Spec.Blake2S -> Hash.Blake2S
  | Spec.Blake2B -> Hash.Blake2B

let index = unit

let alg = Spec.alg

let m_spec = Core.m_spec

/// The stateful state: (wv, hash)
inline_for_extraction noextract
let s (a : alg) (m : m_spec) = state_p a m & state_p a m

inline_for_extraction noextract
let extra_state_zero_element a : Hash.extra_state (to_hash_alg a) =
  Hash.nat_to_extra_state (to_hash_alg a) 0

inline_for_extraction noextract
let t (a : alg) = Hash.words_state' (to_hash_alg a)

inline_for_extraction noextract
let get_wv (#a : alg) (#m : m_spec) (s : s a m) : Tot (state_p a m) =
  match s with wv, _ -> wv

inline_for_extraction noextract
let get_state_p (#a : alg) (#m : m_spec) (s : s a m) : Tot (state_p a m) =
  match s with _, p -> p

inline_for_extraction noextract
let state_v (#a : alg) (#m : m_spec) (h : HS.mem) (s : s a m) : GTot (Spec.state a) =
  Core.state_v h (get_state_p s)

inline_for_extraction noextract
let s_v (#a : alg) (#m : m_spec) (h : HS.mem) (s : s a m) : GTot (t a) =
  state_v h s

/// Small helper which facilitates inferencing implicit arguments for buffer
/// operations
inline_for_extraction noextract
let state_to_lbuffer (#a : alg) (#m : m_spec) (s : state_p a m) :
  B.lbuffer (element_t a m) (4 * U32.v (row_len a m)) =
  s

inline_for_extraction noextract
let stateful_blake2 (a : alg) (m : m_spec) : I.stateful unit =
  I.Stateful
    (fun () -> s a m) (* s *)
    (* footprint *)
    (fun #_ _ acc ->
      let wv, b = acc in
      B.loc_union
       (B.loc_addr_of_buffer (state_to_lbuffer wv))
       (B.loc_addr_of_buffer (state_to_lbuffer b)))
    (* freeable *)
    (fun #_ _ acc ->
      let wv, b = acc in
      B.freeable (state_to_lbuffer wv) /\
      B.freeable (state_to_lbuffer b))
    (* invariant *)
    (fun #_ h acc ->
      let wv, b = acc in
      B.live h (state_to_lbuffer wv) /\
      B.live h (state_to_lbuffer b) /\
      B.disjoint (state_to_lbuffer wv) (state_to_lbuffer b))
    (fun () -> t a) (* t *)
    (fun () h acc -> s_v h acc) (* v *)
    (fun #_ h acc -> let wv, b = acc in ()) (* invariant_loc_in_footprint *)
    (fun #_ l acc h0 h1 -> let wv, b = acc in ()) (* frame_invariant *)
    (fun #_ _ _ _ _ -> ()) (* frame_freeable *)
    (* alloca *)
    (fun () ->
      let wv = alloc_state a m in
      let b = alloc_state a m in
      wv, b)
    (* create_in *)
    (fun () r ->
      let wv = B.malloc r (zero_element a m) U32.(4ul *^ row_len a m) in
      let b = B.malloc r (zero_element a m) U32.(4ul *^ row_len a m) in
      wv, b)
    (* free *)
    (fun _ acc ->
      match acc with wv, b ->
      B.free (state_to_lbuffer wv);
      B.free (state_to_lbuffer b))
    (* copy *)
    (fun _ src dst ->
      match src with src_wv, src_b ->
      match dst with src_wv, dst_b ->
      B.blit (state_to_lbuffer src_b) 0ul (state_to_lbuffer dst_b) 0ul
             U32.(4ul *^ row_len a m))

inline_for_extraction noextract
let key_size_ty (a : alg) = key_size:nat{0 <= key_size /\ key_size <= Spec.max_key a}

inline_for_extraction noextract
let key_size_t (a : alg) = key_size:U32.t{0 <= U32.v key_size /\ U32.v key_size <= Spec.max_key a}

(*
/// Pay attention to the fact that the ``key_size`` parameter is not Low* and
/// appears in extracted code: it must be a constant.
inline_for_extraction noextract
let k (#a : alg) (key_size : key_size_ty a) : I.stateful unit =
  if key_size > 0 then
    I.stateful_buffer uint8 (U32.uint_to_t key_size) (Lib.IntTypes.u8 0)
  else I.stateful_unused unit *)

/// Defining stateful keys
inline_for_extraction noextract
let stateful_key_t (a : alg) (key_size : key_size_ty a) : Type =
  if key_size = 0 then unit else b:B.buffer uint8 { B.length b == key_size }

inline_for_extraction noextract
let buffer_to_stateful_key_t (a : alg) (key_size : key_size_ty a{key_size > 0})
                             (k : B.buffer uint8 { B.length k == key_size }) :
  Tot (stateful_key_t a key_size) =
  k

inline_for_extraction noextract
let unit_to_stateful_key_t (a : alg) :
  Tot (stateful_key_t a 0) =
  ()

/// Pay attention to the fact that the ``key_size`` parameter is not Low* and
/// appears in extracted code: it must be a constant.
/// TODO: this definition could be moved to Hacl.Streaming.Interface, it could
/// be pretty useful in other situations as it generalizes ``stateful_buffer`` in
/// the case the length is zero. Note that rather than being unit, the type could
/// be buffer too (and we would use null whenever needed).
inline_for_extraction noextract
let stateful_key (a : alg) (key_size : key_size_ty a) : I.stateful unit =
  I.Stateful
    (fun _ -> stateful_key_t a key_size)
    (fun #_ h s -> if key_size = 0 then B.loc_none else B.loc_addr_of_buffer (s <: B.buffer uint8))
    (fun #_ h s -> if key_size = 0 then True else B.freeable (s <: B.buffer uint8))
    (fun #_ h s -> if key_size = 0 then True else B.live h (s <: B.buffer uint8))
    (fun _ -> s:S.seq uint8 { S.length s == key_size })
    (fun _ h s -> if key_size = 0 then Seq.empty else B.as_seq h (s <: B.buffer uint8))
    (fun #_ h s -> ())
    (fun #_ l s h0 h1 -> ())
    (fun #_ l s h0 h1 -> ())
    (fun () ->
       if key_size = 0 then unit_to_stateful_key_t a
       else
         buffer_to_stateful_key_t a key_size (B.alloca (Lib.IntTypes.u8 0)
                                                       (U32.uint_to_t key_size)))
    (fun () r -> 
      if key_size = 0 then unit_to_stateful_key_t a
      else
        buffer_to_stateful_key_t a key_size (B.malloc r (Lib.IntTypes.u8 0)
                                                        (U32.uint_to_t key_size)))
    (fun _ s -> if key_size = 0 then () else  B.free (s <: B.buffer uint8))
    (fun _ s_src s_dst ->
      if key_size = 0 then ()
      else B.blit (s_src <: B.buffer uint8) 0ul
                  (s_dst <: B.buffer uint8) 0ul (U32.uint_to_t key_size))

let stateful_key_to_buffer (#a : alg) (#key_size : key_size_ty a)
                           (key : stateful_key_t a key_size) :
  b:B.buffer uint8 { B.length b = key_size } =
  if key_size = 0 then B.null #uint8 else key
  
let k = stateful_key

//inline_for_extraction noextract
//let k (#a : alg) (key_size : key_size_t a) =
//  I.stateful_buffer uint8 key_len (Lib.IntTypes.u8 0)

/// The functor currently limits the size of the data, so we can't go as far as blake2b can go
#push-options "--z3cliopt smt.arith.nl=false"
let max_total_hash_length (a : alg) :
  n:nat{n <= Spec.Hash.Definitions.max_input_length (to_hash_alg a)} =
  assert_norm(
    Spec.max_limb Spec.Blake2S <= Spec.Hash.Definitions.max_input_length (to_hash_alg a));
  Spec.max_limb Spec.Blake2S
#pop-options

let max_input_length (a : alg) (key_size : nat) : nat =
  if key_size = 0 then max_total_hash_length a
  else max_total_hash_length a - Spec.size_block a

inline_for_extraction noextract
let block (a : alg) = (block: S.seq uint8 { S.length block = Spec.size_block a })

inline_for_extraction noextract
let block_len (a : alg) : U32.t = Core.size_block a

inline_for_extraction noextract
let output_size (a : alg) : nat = Spec.max_output a

inline_for_extraction noextract
let output_len (a : alg) = U32.uint_to_t (output_size a)

/// The prevlen parameter computed by the streaming functor and given to ``update_multi``
/// or ``update_last`` is equal to the length of the data processed so far (without the
/// key). In the case of blake2, however, we also need to count the key (if it is not
/// an empty seq) in the total length of processed data.
inline_for_extraction noextract
let blake2_prevlength (a : alg) (key_size : nat) (prevlen : nat) : nat =
  if key_size = 0 then prevlen else prevlen + Spec.size_block a

let blake2_prevlength_add_right_eq (a : alg) (key_size : nat) (prevlen len : nat) :
  Lemma(
    blake2_prevlength a key_size prevlen + len = blake2_prevlength a key_size (prevlen + len))
  = ()

/// Same function as above but with low-level types
inline_for_extraction noextract
let blake2_prevlen_ (a : alg) (key_len : U32.t)
                    (prevlen : U64.t { U64.v prevlen <= max_input_length a (U32.v key_len) }) :
  x:U64.t  { U64.v x = blake2_prevlength a (U32.v key_len) (U64.v prevlen) } =
  if U32.(key_len =^ 0ul) then prevlen
  else U64.(prevlen +^ FStar.Int.Cast.uint32_to_uint64 (block_len a))

inline_for_extraction noextract
let blake2_prevlen (a : alg) (key_len : U32.t)
                   (prevlen : U64.t{ U64.v prevlen <= max_input_length a (U32.v key_len) }) :
  x:Spec.limb_t a {
    Lib.IntTypes.uint_v x = blake2_prevlength a (U32.v key_len) (U64.v prevlen) } =
  let open Lib.IntTypes in
  match a with
  | Spec.Blake2S -> to_u64 #U64 #PUB (blake2_prevlen_ a key_len prevlen)
  | Spec.Blake2B ->
    [@inline_let] let x : uint64 = to_u64 #U64 #PUB (blake2_prevlen_ a key_len prevlen) in
    Lib.IntTypes.cast U128 SEC x

let init_s (#a : alg) (#key_size : key_size_ty a) ()
           (key : Seq.lseq uint8 key_size) : Tot (t a) =
  Spec.blake2_init a key_size key (output_size a)

let update_multi_s (#a : alg) (key_size : key_size_ty a) () (acc : t a)
                   (prevlen : nat{prevlen % Spec.size_block a = 0})
                   (input : Seq.seq uint8{ prevlen + S.length input <= max_input_length a key_size /\
                                           S.length input % Spec.size_block a = 0 }) :
  Tot (t a) =
  let es = Hash.nat_to_extra_state (to_hash_alg a) (blake2_prevlength a key_size prevlen) in
  let s = (acc, es) in
  fst (Agile.update_multi (to_hash_alg a) s input)

let update_last_s (#a : alg) (key_size : key_size_ty a) () (acc : t a)
                  (prevlen : nat{prevlen % Spec.size_block a = 0})
                  (input : Seq.seq uint8{ S.length input + prevlen <= max_input_length a key_size /\
                                          S.length input <= Spec.size_block a }) :
  Tot (t a) =
  let es = Hash.nat_to_extra_state (to_hash_alg a) (blake2_prevlength a key_size prevlen) in
  let s = (acc, es) in
  fst (Spec.Hash.Incremental.update_last (to_hash_alg a) s prevlen input)

let finish_s (#a : alg) (#key_size : key_size_ty a) ()
             (key : S.seq uint8{S.length key = key_size}) (acc : t a) :
  output : S.seq uint8 { S.length output = U32.v (output_len a) } =
  (* The extra state is actually not used, so we initialize it to a dummy value *)
  let s = (acc, Hash.nat_to_extra_state (to_hash_alg a) 0) in
  Spec.Hash.PadFinish.finish (to_hash_alg a) s

let spec_s (a : alg) (#key_size : key_size_ty a) ()
           (key : S.seq uint8{S.length key = key_size})
           (input : S.seq uint8{S.length input <= max_input_length a key_size}) = 
  Spec.blake2 a input key_size key (output_size a)

/// Interlude for spec proofs
/// =====================================
val update_multi_zero:
  #a : alg ->
  key_size : key_size_ty a ->
  i:index ->
  acc:t a ->
  prevlen:nat{prevlen % Spec.size_block a = 0} ->
  Lemma
  (requires (prevlen <= max_input_length a key_size))
  (ensures (update_multi_s #a key_size i acc prevlen S.empty == acc))

let update_multi_zero #a key_size () acc prevlen =
  let es = Hash.nat_to_extra_state (to_hash_alg a) (blake2_prevlength a key_size prevlen) in
  let s = (acc, es) in
  Spec.Hash.Lemmas.update_multi_zero (to_hash_alg a) s

val update_multi_associative:
  #a : alg ->
  key_size : key_size_ty a ->
  i:index ->
  acc: t a ->
  prevlen1:nat ->
  prevlen2:nat ->
  input1:S.seq uint8 ->
  input2:S.seq uint8 ->
  Lemma
  (requires (
    prevlen1 % Spec.size_block a = 0 /\
    S.length input1 % Spec.size_block a = 0 /\
    S.length input2 % Spec.size_block a = 0 /\
    prevlen1 + S.length input1 + S.length input2 <= max_input_length a key_size /\
    prevlen2 = prevlen1 + S.length input1))
  (ensures (
    let input = S.append input1 input2 in
    S.length input % Spec.size_block a = 0 /\
    prevlen2 % Spec.size_block a = 0 /\
    update_multi_s key_size i (update_multi_s key_size i acc prevlen1 input1) prevlen2 input2 ==
      update_multi_s key_size i acc prevlen1 input))

let update_multi_associative #a key_size () acc prevlen1 prevlen2 input1 input2 =
  let es = Hash.nat_to_extra_state (to_hash_alg a) (blake2_prevlength a key_size prevlen1) in
  let s = (acc, es) in
  Spec.Hash.Lemmas.update_multi_associative (to_hash_alg a) s input1 input2;
  Spec.Hash.Incremental.Lemmas.update_multi_extra_state_eq (to_hash_alg a) s input1;
  Spec.Hash.Lemmas.extra_state_add_nat_bound_lem2 #(to_hash_alg a) es (S.length input1)
 
/// A helper function: the hash incremental function defined with the functions
/// locally defined (with a signature adapted to the functor).
val blake2_hash_incremental_s :
  a : alg ->
  #key_size : key_size_ty a ->
  i:index ->
  key: I.((k a key_size).t ()) ->
  input:S.seq uint8 { S.length input <= max_input_length a key_size } ->
  output:S.seq uint8 { S.length output = output_size a }

let size_block_props (a : Spec.alg) :
  Lemma(
    Spec.size_block a = Spec.Hash.Definitions.block_length (to_hash_alg a) /\
    Spec.size_block a > 0) = ()

#push-options "--z3cliopt smt.arith.nl=false"
let blake2_hash_incremental_s a #key_size i key input =
  (**) size_block_props a;
  (**) Math.Lemmas.modulo_lemma 0 (Spec.size_block a);
  let bs, l = Spec.Hash.Incremental.split_blocks (to_hash_alg a) input in
  let acc1 = init_s #a #key_size i key in
  let acc2 = update_multi_s #a key_size i acc1 0 bs in
  let acc3 = update_last_s #a key_size i acc2 (S.length bs) l in
  let acc4 = finish_s #a #key_size i key acc3 in
  acc4
#pop-options

/// The following helper lemmas prove that the blake2 specification functions defined above
/// with a signature adapted to the functor give the same result, if properly called,
/// as the original hash incremental functions.
val blake2_hash_incremental_s_is_hash_incremental :
  a : alg ->
  #key_size : key_size_ty a ->
  i:index ->
  key: I.((k a key_size).t ()) ->
  input:S.seq uint8 { S.length input <= max_input_length a key_size } ->
  Lemma(
    blake2_hash_incremental_s a #key_size i key input ==
      Spec.Hash.Incremental.blake2_hash_incremental (to_hash_alg a) key_size key input)

let init_s_blake2_init_eq
  (a : alg)
  (#key_size : key_size_ty a)
  (i:index)
  (key: I.((k a key_size).t ())) :
  Lemma(
    (init_s #a #key_size i key,
     Hash.nat_to_extra_state (to_hash_alg a) (blake2_prevlength a key_size 0)) ==
      Spec.Hash.Incremental.blake2_init (to_hash_alg a) key_size key) =
  ()

#push-options "--z3cliopt smt.arith.nl=false"
let blake2_hash_incremental_s_is_hash_incremental a #key_size i key input =
  size_block_props a;
  Math.Lemmas.modulo_lemma 0 (Spec.size_block a);
  let bs, l = Spec.Hash.Incremental.split_blocks (to_hash_alg a) input in
  let acc1 = init_s #a #key_size i key in
  let acc2 = update_multi_s key_size i acc1 0 bs in
  let acc3 = update_last_s key_size i acc2 (S.length bs) l in
  let acc4 = finish_s #a #key_size i key acc3 in
  assert(acc4 == blake2_hash_incremental_s a #key_size i key input); (* sanity check *)
  let s1 = Spec.Hash.Incremental.blake2_init (to_hash_alg a) key_size key in
  let s2 = Agile.update_multi (to_hash_alg a) s1 bs in
  let prevlen = S.length bs in (* dummy value: this variable is actually not used *)
  let s3 = Spec.Hash.Incremental.update_last (to_hash_alg a) s2 prevlen l in
  let s4 = Spec.Hash.PadFinish.finish (to_hash_alg a) s3 in
  let s4' = Spec.Hash.Incremental.blake2_hash_incremental (to_hash_alg a) key_size key input in
  assert(s4 == s4'); (* sanity check *)
  (* The proof *)
  (* 1 *)
  let es1 = Hash.nat_to_extra_state (to_hash_alg a) (blake2_prevlength a key_size 0) in
  let s1' = (acc1, es1) in
  init_s_blake2_init_eq a i key;
  assert(s1' == s1);
  (* 2 *)
  Spec.Hash.Incremental.Lemmas.update_multi_extra_state_eq (to_hash_alg a) s1 bs;
  Spec.Hash.Lemmas.extra_state_v_of_nat (to_hash_alg a) (blake2_prevlength a key_size 0);
  assert(Hash.extra_state_v es1 + S.length bs <= Hash.max_extra_state (to_hash_alg a));
  Spec.Hash.Lemmas.extra_state_add_nat_bound_lem2 #(to_hash_alg a) es1 (S.length bs);
  let es2 = Hash.nat_to_extra_state (to_hash_alg a) (blake2_prevlength a key_size (S.length bs)) in
  let s2' = (acc2, es2) in
  blake2_prevlength_add_right_eq a key_size 0 (S.length bs);
  add_zero_left_is_same (S.length bs);
  assert(blake2_prevlength a key_size 0 + S.length bs = blake2_prevlength a key_size (S.length bs));
  assert(s2' == s2);
  (* 3 *)
  let es3 = Hash.nat_to_extra_state (to_hash_alg a) 0 in
  let s3' = (acc3, es3) in
  assert(s3' == s3);
  (* 4 *)
  assert(acc4 == s4)
#pop-options

#push-options "--z3cliopt smt.arith.nl=false"
val spec_is_incremental:
  a : alg ->
  #key_size : key_size_ty a ->
  i:index ->
  key: I.((k a key_size).t ()) ->
  input:S.seq uint8 { S.length input <= max_input_length a key_size } ->
  Lemma (
    (**) size_block_props a;
    (**) Math.Lemmas.modulo_lemma 0 (Spec.size_block a);
    let bs, l = Spec.Hash.Incremental.split_blocks (to_hash_alg a) input in
    let hash0 = init_s #a #key_size i key in
    let hash1 = update_multi_s key_size i hash0 0 bs in
    let hash2 = update_last_s key_size i hash1 (S.length bs) l in
    finish_s #a #key_size i key hash2 `S.equal` (spec_s a #key_size) i key input)
#pop-options

#push-options "--z3cliopt smt.arith.nl=false"
let spec_is_incremental a #key_size i key input =
  blake2_hash_incremental_s_is_hash_incremental a i key input;
  (**) size_block_props a;
  Spec.Hash.Incremental.blake2_is_hash_incremental (to_hash_alg a) key_size key input
#pop-options

val update_multi_eq :
  #a : alg ->
  key_size : key_size_ty a ->
  nb : nat ->
  acc : t a ->
  prevlen : nat {prevlen % Spec.size_block a = 0 } ->
  blocks : S.seq uint8 ->
  Lemma
    (requires (
      prevlen + S.length blocks <= max_input_length a key_size /\
      blake2_prevlength a key_size prevlen + S.length blocks <= Hash.max_extra_state (to_hash_alg a) /\
      S.length blocks = Hash.block_length (to_hash_alg a) * nb))
    (ensures (
      let prevlen' = blake2_prevlength a key_size prevlen in
      update_multi_s key_size () acc prevlen blocks ==
        Loops.repeati #(Hash.words_state' (to_hash_alg a)) nb
                       (Spec.blake2_update1 a prevlen' blocks) acc))

let update_multi_eq #a key_size nb acc prevlen blocks =
  let blocks', _ = Seq.split blocks (nb * Hash.block_length (to_hash_alg a)) in
  assert(blocks' `Seq.equal` blocks);
  let prevlen' = blake2_prevlength a key_size prevlen in
  let es = Hash.nat_to_extra_state (to_hash_alg a) prevlen' in
  Spec.Hash.Incremental.repeati_blake2_update1_is_update_multi (to_hash_alg a)
                                                               nb prevlen'
                                                               blocks acc;
  Spec.Hash.Lemmas.extra_state_add_nat_bound_lem1 #(to_hash_alg a) es (S.length blocks);
  assert(
    Hash.nat_to_extra_state (to_hash_alg a) (prevlen' + S.length blocks) ==
    Hash.extra_state_add_nat #(to_hash_alg a) es (S.length blocks))

val update_last_eq :
  #a : alg ->
  key_size : key_size_ty a ->
  prevlen : nat{prevlen % Hash.block_length (to_hash_alg a) = 0} ->
  last : S.seq uint8 {S.length last <= Hash.block_length (to_hash_alg a) /\
                      prevlen + S.length last <= max_input_length a key_size} ->
  acc : t a ->
  Lemma
  (ensures (
    let prevlen' = blake2_prevlength a key_size prevlen in
    Spec.blake2_update_last a prevlen' (S.length last) last acc ==
      update_last_s key_size () acc prevlen last))

let update_last_eq #a key_size prevlen last acc =
  (* Checking how to unfold the ``update_last_s`` definition *)
  let prevlen' = blake2_prevlength a key_size prevlen in
  let es = Hash.nat_to_extra_state (to_hash_alg a) prevlen' in
  let s = acc, es in
  let s' = Spec.Hash.Incremental.update_last_blake (to_hash_alg a) s prevlen' last in
  (* TODO: SH: if accf is defined before s', the proof loops at the definition of s' *)
  let accf = update_last_s key_size () acc prevlen last in
  assert(accf == fst s');
  (* Make sure the blocks decomposition is what we expect *)
  let blocks, last_block, rem = Spec.Hash.Incremental.last_split_blake (to_hash_alg a) last in
  assert(blocks `S.equal` S.empty);
  assert(rem = S.length last);
  assert(last_block == Spec.get_last_padded_block a last (S.length last));
  (* Prove that the last call to ``update_multi`` does nothing (there is no call to
   * ``update_multi`` in ``blake2_update_last`` *)
  let s2 = Spec.Agile.Hash.update_multi (to_hash_alg a) s blocks in
  Spec.Hash.Lemmas.update_multi_zero (to_hash_alg a) s;
  assert(s2 == s);
  (* Prove that the extra state update computes the same total length as in ``blake2_update_last`` *)
  Spec.Hash.Lemmas.extra_state_add_nat_bound_lem1 #(to_hash_alg a) es (S.length last);
  assert(Hash.extra_state_v (Hash.extra_state_add_nat es (S.length last)) ==
         Hash.extra_state_v es + S.length last)

/// TODO: duplicate with Spec.Hash.Incremental.fst - MOVE
/// Equality between the state types defined by blake2s and the generic hash.
/// The equality is not trivial because of subtleties linked to the way types are
/// encoded for Z3.
val state_types_equalities : (a : alg) ->
  Lemma(Spec.Blake2.state a == Hash.words_state' (to_hash_alg a))

let state_types_equalities a =
  let open Lib.Sequence in
  let open Lib.IntTypes in
  (* Because of the necessity to be able to normalize, we basically do
   * the same proof twice. TODO: find a better way *)
  match a with
  | Spec.Blake2S ->
    let a = Spec.Blake2S in (* small trick to get a proper normalization *)
    let row = Spec.row a in
    assert(Spec.state a == lseq row 4);
    assert_norm(Hash.words_state' (to_hash_alg a) == m:Seq.seq row {Seq.length m = 4});
    assert_norm(lseq row 4 == m:Seq.seq row {Seq.length m == 4});
    assert(lseq row 4 == m:Seq.seq row {Seq.length m = 4})
  | Spec.Blake2B ->
    let a = Spec.Blake2B in
    let row = Spec.row a in
    assert(Spec.state a == lseq row 4);
    assert_norm(Hash.words_state' (to_hash_alg a) == m:Seq.seq row {Seq.length m = 4});
    assert_norm(lseq row 4 == m:Seq.seq row {Seq.length m == 4});
    assert(lseq row 4 == m:Seq.seq row {Seq.length m = 4})

(* TODO: find a way not to duplicate the block spec *)
inline_for_extraction noextract
val mk_update_multi:
  a : alg ->
  m : m_spec ->
  key_size : key_size_ty a ->
  (i:G.erased index -> (
  let i = G.reveal i in
  s:s a m ->
  prevlen:U64.t { U64.v prevlen % U32.v (block_len a) = 0 } ->
  blocks:B.buffer uint8 { B.length blocks % U32.v (block_len a) = 0 } ->
  len: U32.t { U32.v len = B.length blocks /\
               U64.v prevlen + U32.v len <= max_input_length a key_size } ->
  ST.Stack unit
  (requires fun h0 ->
    let state = stateful_blake2 a m in
    state.I.invariant #i h0 s /\
    B.live h0 blocks /\
    B.(loc_disjoint (state.I.footprint #i h0 s) (loc_buffer blocks)))
  (ensures fun h0 _ h1 ->
    let state = stateful_blake2 a m in
    B.(modifies (state.I.footprint #i h0 s) h0 h1) /\
    state.I.footprint #i h0 s == state.I.footprint #i h1 s /\
    state.I.invariant #i h1 s /\
    state.I.v i h1 s == update_multi_s #a key_size i (state.I.v i h0 s) (U64.v prevlen)
                                                  (B.as_seq h0 blocks) /\
    (state.I.freeable #i h0 s ==> state.I.freeable #i h1 s))))

#push-options "--z3cliopt smt.arith.nl=false"
let mk_update_multi a m key_size i acc prevlen blocks len =
  (**) size_block_props a;
  [@inline_let] let wv = get_wv acc in
  [@inline_let] let h = get_state_p acc in
  (**) let h0 = ST.get () in
  let nb = U32.(len /^ block_len a) in
  (**) Math.Lemmas.div_exact_r (U32.v len) (U32.v (block_len a));
  (**) Math.Lemmas.multiply_fractions (U32.v len) (U32.v (block_len a));
  [@inline_let] let prevlen' = blake2_prevlen a (U32.uint_to_t key_size) prevlen in
  (**) assert(Lib.Buffer.disjoint wv h);
  Impl.blake2_update_multi #a #m #len (Impl.blake2_update_block #a #m) wv h
                           prevlen' blocks nb;
  (**) let h3 = ST.get () in
  (**) assert(s_v h3 acc ==
  (**)    Loops.repeati #(Spec.Blake2.state a) (U32.v nb)
  (**)                  (Spec.blake2_update1 a (Lib.IntTypes.uint_v prevlen')
  (**)                                       (B.as_seq h0 blocks))
  (**)                  (s_v h0 acc));
  (**) state_types_equalities a;
  (**) assert(Spec.Blake2.state a == Hash.words_state' (to_hash_alg a));
  (**) update_multi_eq key_size (U32.v nb) (s_v h0 acc) (U64.v prevlen) (B.as_seq h0 blocks);
  (**) assert(Lib.IntTypes.uint_v prevlen' = blake2_prevlength a key_size (U64.v prevlen));
  (**) assert(s_v h3 acc == update_multi_s key_size () (s_v h0 acc) (U64.v prevlen) (B.as_seq h0 blocks));
  (**) assert(B.(modifies ((stateful_blake2 a m).I.footprint #() h0 acc) h0 h3))
#pop-options

inline_for_extraction noextract
val mk_update_last:
  a : alg ->
  m : m_spec ->
  key_size : key_size_ty a ->
  (i: G.erased index -> (
  let i = G.reveal i in
  s:s a m ->
  prevlen:U64.t { U64.v prevlen % U32.v (block_len a) = 0 } ->
  last:B.buffer uint8 ->
  last_len:U32.t{
    last_len = B.len last /\
    U32.v last_len <= U32.v (block_len a) /\
    U64.v prevlen + U32.v last_len <= max_input_length a key_size} ->
  ST.Stack unit
  (requires fun h0 ->
    let state = stateful_blake2 a m in
    state.I.invariant #i h0 s /\
    B.live h0 last /\
    B.(loc_disjoint (state.I.footprint #i h0 s) (loc_buffer last)))
  (ensures fun h0 _ h1 ->
    let state = stateful_blake2 a m in
    state.I.invariant #i h1 s /\
    state.I.v i h1 s == update_last_s #a key_size i (state.I.v i h0 s)
                                      (U64.v prevlen) (B.as_seq h0 last) /\
    B.(modifies (state.I.footprint #i h0 s) h0 h1) /\
    state.I.footprint #i h0 s == state.I.footprint #i h1 s /\
    (state.I.freeable #i h0 s ==> state.I.freeable #i h1 s))))

#push-options "--ifuel 1 --z3cliopt smt.arith.nl=false"
let mk_update_last a m key_size i acc prevlen last last_len =
  (**) size_block_props a;
  [@inline_let] let wv = get_wv acc in
  [@inline_let] let h = get_state_p acc in
  (**) let h0 = ST.get () in
  (**) assert_norm(U64.v prevlen + U32.v last_len <= Spec.Blake2.max_limb a);
  [@inline_let]
  let prevlen' = blake2_prevlen a (U32.uint_to_t key_size) prevlen in
  (**) assert((U64.v prevlen) % Hash.block_length (to_hash_alg a) = 0);
  (**) assert(B.length last <= Hash.block_length (to_hash_alg a));
  (**) assert(U64.v prevlen + B.length last <= max_input_length a key_size);
  Impl.blake2_update_last #a #m (Impl.blake2_update_block #a #m) #last_len
                          wv h prevlen' last_len last;
  (* TODO: SH: if not put at the proper place, this call makes the proof loop or randomly fail *)
  (**) update_last_eq key_size (U64.v prevlen) (B.as_seq h0 last) (s_v h0 acc);
  (**) let h2 = ST.get () in
  (**) assert(
  (**)   Core.state_v h2 h ==
  (**)     Spec.blake2_update_last a (Lib.IntTypes.uint_v prevlen') (U32.v last_len)
  (**)                               (B.as_seq h0 last)
  (**)                               (Core.state_v h0 h));
  (**) assert(s_v h2 acc ==
  (**)   update_last_s key_size () (s_v h0 acc) (U64.v prevlen) (B.as_seq h0 last))
#pop-options

/// Pay attention to the fact that the ``key_size`` parameter is not Low* and
/// appears in extracted code (in some tests which must be reduced, for the definition
/// of the key type, for some arithmetic and for the size of the buffer to allocate
/// for the key): it must thus be a constant.
#push-options "--ifuel 1 --z3cliopt smt.arith.nl=false"
inline_for_extraction noextract
let blake2 (a : alg) (m : m_spec) (key_size : key_size_ty a) //: I.block unit =
  =
  I.Block
    I.Erased (* key management *)
    
    (stateful_blake2 a m) (* state *)
    (k a key_size) (* key *)
    
    (fun () -> max_input_length a (Spec.max_key a)) (* max_input_length *)
    (fun () -> output_len a) (* output_len *)
    (fun () -> block_len a) (* block_len *)
    
    (fun () k -> init_s #a #key_size () k) (* init_s *)
    (fun () acc prevlen input -> update_multi_s key_size () acc prevlen input) (* update_multi_s *)
    (fun () acc prevlen input -> update_last_s key_size () acc prevlen input) (* update_last_s *)
    (fun () k acc -> finish_s #a #key_size () k acc) (* finish_s *)
    (fun () -> spec_s a #key_size ()) (* spec_s *)

    (fun () prevlen acc -> update_multi_zero key_size () prevlen acc) (* update_multi_zero *)
    (* update_multi_associative *)
    (fun () acc prevlen1 prevlen2 input1 input2 ->
      update_multi_associative key_size () acc prevlen1 prevlen2 input1 input2)
    (fun () k input -> spec_is_incremental a #key_size () k input) (* spec_is_incremental *)
    (fun _ acc -> ()) (* index_of_state *)

    (* init *)
    (fun _ key acc ->
      [@inline_let] let wv = get_wv acc in
      [@inline_let] let h = get_state_p acc in
      [@inline_let]
      let key : b:B.buffer uint8{B.length b = key_size} =
        if key_size = 0 then B.null #uint8 else key in
      Impl.blake2_init #a #m (Impl.blake2_update_block #a #m) wv h
                       (U32.uint_to_t key_size) key
                       (output_len a))

    (* update_multi *)
    (fun _ acc prevlen blocks len -> mk_update_multi a m key_size () acc prevlen blocks len)

    (* update_last *)
    (fun _ acc prevlen last last_len ->
      mk_update_last a m key_size () acc prevlen last last_len)

    (* finish *)
    (fun _ k acc dst ->
      [@inline_let] let wv = get_wv acc in
      [@inline_let] let h = get_state_p acc in
      Impl.blake2_finish #a #m (output_len a) dst h)
#pop-options

/// The incremental hash functions instantiations
let mk_create_in (a : alg) (m : m_spec) (key_size : key_size_ty a) =
  F.create_in (blake2 a m key_size) () (s a m) (I.optional_key () I.Erased (k a key_size))

let mk_init (a : alg) (m : m_spec) (key_size : key_size_ty a) =
  F.init (blake2 a m key_size) (G.hide ()) (s a m) (I.optional_key () I.Erased (k a key_size))

let mk_update (a : alg) (m : m_spec) (key_size : key_size_ty a) =
  F.update (blake2 a m key_size) (G.hide ()) (s a m) (I.optional_key () I.Erased (k a key_size))

let mk_finish (a : alg) (m : m_spec) (key_size : key_size_ty a) =
  F.mk_finish (blake2 a m key_size) () (s a m) (I.optional_key () I.Erased (k a key_size))

let mk_free (a : alg) (m : m_spec) (key_size : key_size_ty a) =
  F.free (blake2 a m key_size) (G.hide ()) (s a m) (I.optional_key () I.Erased (k a key_size))
