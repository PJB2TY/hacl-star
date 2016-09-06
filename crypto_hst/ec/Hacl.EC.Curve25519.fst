module Hacl.EC.Curve25519

open FStar.HST
open Hacl.UInt8
open Hacl.Cast
open Hacl.SBuffer
open Hacl.EC.Curve25519.Parameters
open Hacl.EC.Curve25519.Bignum
open Hacl.EC.Curve25519.Crecip
open Hacl.EC.Curve25519.Ladder


#reset-options "--initial_fuel 0 --max_fuel 0"

(* Module abbreviations *)
module B  = Hacl.SBuffer
module HH = FStar.HyperHeap
module HS = FStar.HyperStack

module U8  = FStar.UInt8
module U32 = FStar.UInt32
module H8  = Hacl.UInt8
module H32  = Hacl.UInt32
module H64  = Hacl.UInt64
module H128  = Hacl.UInt128

val format_scalar: scalar:u8s{length scalar >= 32} -> Stack unit
  (requires (fun h -> live h scalar))
  (ensures  (fun h0 _ h1 -> modifies_1 scalar h0 h1 /\ live h1 scalar))
let format_scalar scalar =
  scalar.(0ul) <- (scalar.(0ul) &^ (uint8_to_sint8 248uy));
  scalar.(31ul) <- (scalar.(31ul) &^ (uint8_to_sint8 127uy));
  scalar.(31ul) <- (scalar.(31ul) |^ (uint8_to_sint8 64uy))

val expand_0: output:Hacl.EC.Curve25519.Bigint.bigint -> input:u8s{length input >= 32} -> Stack unit
  (requires (fun h -> disjoint input output /\ live h input /\ live h output))
  (ensures  (fun h0 _ h1 -> modifies_1 output h0 h1 /\ live h1 output))
let expand_0 output input =
  let mask = Hacl.UInt64.of_string "0x7ffffffffffff" in
  let open Hacl.UInt64 in
  let i0 = input.(0ul) in
  let i1 = input.(1ul) in
  let i2 = input.(2ul) in
  let i3 = input.(3ul) in
  let i4 = input.(4ul) in
  let i5 = input.(5ul) in
  let i6 = input.(6ul) in
  let i0 = (sint8_to_sint64 i0) in
  let i1 = (sint8_to_sint64 (i1)) in
  let i2 = (sint8_to_sint64 (i2)) in
  let i3 = (sint8_to_sint64 (i3)) in
  let i4 = (sint8_to_sint64 (i4)) in
  let i5 = (sint8_to_sint64 (i5)) in
  let i6 = (sint8_to_sint64 (i6)) in
  let o0 = (i0 +%^ (i1 <<^ 8ul) +%^ (i2 <<^ 16ul) +%^ (i3 <<^ 24ul)
  	   +%^ (i4 <<^ 32ul) +%^ (i5 <<^ 40ul) +%^ ((i6 <<^ 48ul) &^ mask)) in
  output.(0ul) <- o0

val expand_1: output:Hacl.EC.Curve25519.Bigint.bigint -> input:u8s{length input >= 32} -> Stack unit
  (requires (fun h -> disjoint input output /\ live h input /\ live h output))
  (ensures  (fun h0 _ h1 -> modifies_1 output h0 h1 /\ live h1 output))
let expand_1 output input =
  let mask = Hacl.UInt64.of_string "0x7ffffffffffff" in
  let open Hacl.UInt64 in
  let i6 = input.(6ul) in
  let i7 = input.(7ul) in
  let i8 = input.(8ul) in
  let i9 = input.(9ul) in
  let i10 = input.(10ul) in
  let i11 = input.(11ul) in
  let i12 = input.(12ul) in
  let i6 = (sint8_to_sint64 (i6)) in
  let i7 = (sint8_to_sint64 (i7)) in
  let i8 = (sint8_to_sint64 (i8)) in
  let i9 = (sint8_to_sint64 (i9)) in
  let i10 = (sint8_to_sint64 (i10)) in
  let i11 = (sint8_to_sint64 (i11)) in
  let i12 = (sint8_to_sint64 (i12)) in
  let o1 = (i6 >>^ 3ul) +%^ (i7 <<^ 5ul) +%^ (i8 <<^ 13ul) +%^ (i9 <<^ 21ul)
  	   +%^ (i10 <<^ 29ul) +%^ (i11 <<^ 37ul) +%^ ((i12 <<^ 45ul) &^ mask) in
  output.(1ul) <- o1;
  () // Without this unit the extraction to OCaml breaks

val expand_2: output:Hacl.EC.Curve25519.Bigint.bigint -> input:u8s{length input >= 32} -> Stack unit
  (requires (fun h -> disjoint input output /\ live h input /\ live h output))
  (ensures  (fun h0 _ h1 -> modifies_1 output h0 h1 /\ live h1 output))
let expand_2 output input =
  let mask = Hacl.UInt64.of_string "0x7ffffffffffff" in
  let open Hacl.UInt64 in
  let i12 = input.(12ul) in
  let i13 = input.(13ul) in
  let i14 = input.(14ul) in
  let i15 = input.(15ul) in
  let i16 = input.(16ul) in
  let i17 = input.(17ul) in
  let i18 = input.(18ul) in
  let i19 = input.(19ul) in
  let i12 = (sint8_to_sint64 (i12)) in
  let i13 = (sint8_to_sint64 (i13)) in
  let i14 = (sint8_to_sint64 (i14)) in
  let i15 = (sint8_to_sint64 (i15)) in
  let i16 = (sint8_to_sint64 (i16)) in
  let i17 = (sint8_to_sint64 (i17)) in
  let i18 = (sint8_to_sint64 (i18)) in
  let i19 = (sint8_to_sint64 (i19)) in
  let o2 = (i12 >>^ 6ul) +%^ (i13 <<^ 2ul) +%^ (i14 <<^ 10ul) +%^ (i15 <<^ 18ul)
  	   +%^ (i16 <<^ 26ul) +%^ (i17 <<^ 34ul) +%^ (i18 <<^ 42ul) +%^ ((i19 <<^ 50ul) &^ mask) in
  output.(2ul) <- o2;
  () // Without this unit the extraction to OCaml breaks

val expand_3: output:Hacl.EC.Curve25519.Bigint.bigint -> input:u8s{length input >= 32} -> Stack unit
  (requires (fun h -> disjoint input output /\ live h input /\ live h output))
  (ensures  (fun h0 _ h1 -> modifies_1 output h0 h1 /\ live h1 output))
let expand_3 output input =
  let mask = Hacl.UInt64.of_string "0x7ffffffffffff" in
  let open Hacl.UInt64 in
  let i19 = input.(19ul) in
  let i20 = input.(20ul) in
  let i21 = input.(21ul) in
  let i22 = input.(22ul) in
  let i23 = input.(23ul) in
  let i24 = input.(24ul) in
  let i25 = input.(25ul) in
  let i19 = (sint8_to_sint64 (i19)) in
  let i20 = (sint8_to_sint64 (i20)) in
  let i21 = (sint8_to_sint64 (i21)) in
  let i22 = (sint8_to_sint64 (i22)) in
  let i23 = (sint8_to_sint64 (i23)) in
  let i24 = (sint8_to_sint64 (i24)) in
  let i25 = (sint8_to_sint64 (i25)) in
  let o3 = (i19 >>^ 1ul) +%^ (i20 <<^ 7ul) +%^ (i21 <<^ 15ul) +%^ (i22 <<^ 23ul)
  	   +%^ (i23 <<^ 31ul) +%^ (i24 <<^ 39ul) +%^ ((i25 <<^ 47ul) &^ mask) in
  output.(3ul) <- o3;
  () // Without this unit the extraction to OCaml breaks

val expand_4: output:Hacl.EC.Curve25519.Bigint.bigint -> input:u8s{length input >= 32} -> Stack unit
  (requires (fun h -> disjoint input output /\ live h input /\ live h output))
  (ensures  (fun h0 _ h1 -> modifies_1 output h0 h1 /\ live h1 output))
let expand_4 output input =
  let mask = Hacl.UInt64.of_string "0x7ffffffffffff" in
  let open Hacl.UInt64 in
  let i25 = input.(25ul) in
  let i26 = input.(26ul) in
  let i27 = input.(27ul) in
  let i28 = input.(28ul) in
  let i29 = input.(29ul) in
  let i30 = input.(30ul) in
  let i31 = input.(31ul) in
  let i25 = (sint8_to_sint64 (i25)) in
  let i26 = (sint8_to_sint64 (i26)) in
  let i27 = (sint8_to_sint64 (i27)) in
  let i28 = (sint8_to_sint64 (i28)) in
  let i29 = (sint8_to_sint64 (i29)) in
  let i30 = (sint8_to_sint64 (i30)) in
  let i31 = (sint8_to_sint64 (i31)) in
  let o4 = (i25 >>^ 4ul) +%^ (i26 <<^ 4ul) +%^ (i27 <<^ 12ul) +%^ (i28 <<^ 20ul) 
  	   +%^ (i29 <<^ 28ul) +%^ (i30 <<^ 36ul) +%^ ((i31 <<^ 44ul) &^ mask) in
  output.(4ul) <- o4; 
  () // Without this unit the extraction to OCaml breaks

val expand: output:Hacl.EC.Curve25519.Bigint.bigint -> input:u8s{length input >= 32} -> Stack unit
  (requires (fun h -> disjoint input output /\ live h input /\ live h output))
  (ensures  (fun h0 _ h1 -> modifies_1 output h0 h1 /\ live h1 output))
let expand output input =
  expand_0 output input;
  expand_1 output input;
  expand_2 output input;
  expand_3 output input;
  expand_4 output input

val contract_0: output:u8s{length output >= 32} -> input:Hacl.EC.Curve25519.Bigint.bigint{disjoint output input}  -> STL unit
  (requires (fun h -> disjoint input output /\ live h input /\ live h output))
  (ensures  (fun h0 _ h1 -> live h1 output /\ modifies_1 output h0 h1))
let contract_0 output input =
  let i0 = input.(0ul) in
  let i1 = input.(1ul) in
  let open Hacl.UInt64 in
  output.(0ul) <- (sint64_to_sint8 (i0 >>^ 0ul));
  output.(1ul) <- (sint64_to_sint8 (i0 >>^ 8ul));
  output.(2ul) <- (sint64_to_sint8 (i0 >>^ 16ul));
  output.(3ul) <- (sint64_to_sint8 (i0 >>^ 24ul));
  output.(4ul) <- (sint64_to_sint8 (i0 >>^ 32ul));
  output.(5ul) <- (sint64_to_sint8 (i0 >>^ 40ul));
  output.(6ul) <- (sint64_to_sint8 ((i0 >>^ 48ul) +%^ (i1 <<^ 3ul)))

val contract_1: output:u8s{length output >= 32} -> input:Hacl.EC.Curve25519.Bigint.bigint{disjoint output input}  -> STL unit
  (requires (fun h -> disjoint input output /\ live h input /\ live h output))
  (ensures  (fun h0 _ h1 -> live h1 output /\ modifies_1 output h0 h1))
let contract_1 output input =
  let i1 = input.(1ul) in
  let i2 = input.(2ul) in
  let open Hacl.UInt64 in
  output.(7ul) <- (sint64_to_sint8 (i1 >>^ 5ul));
  output.(8ul) <- (sint64_to_sint8 (i1 >>^ 13ul));
  output.(9ul) <- (sint64_to_sint8 (i1 >>^ 21ul));
  output.(10ul) <- (sint64_to_sint8 (i1 >>^ 29ul));
  output.(11ul) <- (sint64_to_sint8 (i1 >>^ 37ul));
  output.(12ul) <- (sint64_to_sint8 ((i1 >>^ 45ul) +%^ (i2 <<^ 6ul)))

val contract_2: output:u8s{length output >= 32} -> input:Hacl.EC.Curve25519.Bigint.bigint{disjoint output input}  -> STL unit
  (requires (fun h -> disjoint input output /\ live h input /\ live h output))
  (ensures  (fun h0 _ h1 -> live h1 output /\ modifies_1 output h0 h1))
let contract_2 output input =
  let i2 = input.(2ul) in
  let i3 = input.(3ul) in
  let open Hacl.UInt64 in
  output.(13ul) <- (sint64_to_sint8 (i2 >>^ 2ul));
  output.(14ul) <- (sint64_to_sint8 (i2 >>^ 10ul));
  output.(15ul) <- (sint64_to_sint8 (i2 >>^ 18ul));
  output.(16ul) <- (sint64_to_sint8 (i2 >>^ 26ul));
  output.(17ul) <- (sint64_to_sint8 (i2 >>^ 34ul));
  output.(18ul) <- (sint64_to_sint8 (i2 >>^ 42ul));
  output.(19ul) <- (sint64_to_sint8 ((i2 >>^ 50ul) +%^ (i3 <<^ 1ul)))

val contract_3: output:u8s{length output >= 32} -> input:Hacl.EC.Curve25519.Bigint.bigint{disjoint output input}  -> STL unit
  (requires (fun h -> disjoint input output /\ live h input /\ live h output))
  (ensures  (fun h0 _ h1 -> live h1 output /\ modifies_1 output h0 h1))
let contract_3 output input =
  let i3 = input.(3ul) in
  let i4 = input.(4ul) in
  let open Hacl.UInt64 in
  output.(20ul) <- (sint64_to_sint8 (i3 >>^ 7ul));
  output.(21ul) <- (sint64_to_sint8 (i3 >>^ 15ul));
  output.(22ul) <- (sint64_to_sint8 (i3 >>^ 23ul));
  output.(23ul) <- (sint64_to_sint8 (i3 >>^ 31ul));
  output.(24ul) <- (sint64_to_sint8 (i3 >>^ 39ul));
  output.(25ul) <- (sint64_to_sint8 ((i3 >>^ 47ul) +%^ (i4 <<^ 4ul)))

val contract_4: output:u8s{length output >= 32} -> input:Hacl.EC.Curve25519.Bigint.bigint{disjoint output input}  -> STL unit
  (requires (fun h -> disjoint input output /\ live h input /\ live h output))
  (ensures  (fun h0 _ h1 -> live h1 output /\ modifies_1 output h0 h1))
let contract_4 output input =
  let i4 = input.(4ul) in
  let open Hacl.UInt64 in
  output.(26ul) <- (sint64_to_sint8 (i4 >>^ 4ul));
  output.(27ul) <- (sint64_to_sint8 (i4 >>^ 12ul));
  output.(28ul) <- (sint64_to_sint8 (i4 >>^ 20ul));
  output.(29ul) <- (sint64_to_sint8 (i4 >>^ 28ul));
  output.(30ul) <- (sint64_to_sint8 (i4 >>^ 36ul));
  output.(31ul) <- (sint64_to_sint8 (i4 >>^ 44ul))

val contract: output:u8s{length output >= 32} -> input:Hacl.EC.Curve25519.Bigint.bigint{disjoint output input}  -> STL unit
  (requires (fun h -> disjoint input output /\ live h input /\ live h output))
  (ensures  (fun h0 _ h1 -> live h1 output /\ modifies_1 output h0 h1))
let contract output input =
  contract_0 output input;
  contract_1 output input;
  contract_2 output input;
  contract_3 output input;
  contract_4 output input


#reset-options "--initial_fuel 0 --max_fuel 0 --z3timeout 20"

val exp: output:u8s{length output >= 32} -> q_x:u8s{length q_x >= 32 /\ disjoint q_x output} ->
  pk:u8s{length pk >= 32 /\ disjoint pk output} -> STL unit
  (requires (fun h -> live h output /\ live h q_x /\ live h pk))
  (ensures  (fun h0 _ h1 -> modifies_2 output pk h0 h1 /\ live h1 output))
let exp output q_x scalar =
  let open FStar.UInt32 in

  push_frame();
  let h0 = HST.get() in

  (* Allocate *)
  let zero = uint64_to_sint64 0uL in
  let one  = uint64_to_sint64 1uL in

  let tmp    = create zero (7ul *^ nlength) in
  let qx     = B.sub tmp 0ul nlength in
  let qy     = B.sub tmp nlength nlength in
  let qz     = B.sub tmp (2ul*^nlength) nlength in
  let resx   = B.sub tmp (3ul*^nlength) nlength in
  let resy   = B.sub tmp (4ul*^nlength) nlength in
  let resz   = B.sub tmp (5ul*^nlength) nlength in
  let zrecip = B.sub tmp (6ul*^nlength) nlength in
  let basepoint = PPoint.make qx qy qz in
  let res       = PPoint.make resx resy resz in
  cut(PPoint.distinct res basepoint);
  cut(distinct2 scalar basepoint);
  cut(distinct2 scalar res);

  (* Create basepoint *)
  expand qx q_x;
  upd qz 0ul one;
  let h1 = HST.get() in assert(modifies_0 h0 h1);

  (* Format scalar *)
  format_scalar scalar;
  let h2 = HST.get() in assert(FStar.Buffer.modifies_2_1 scalar h0 h2);
  (* Point to store the result *)

  (* Ladder *)
  assume(PPoint.live h2 res); (* TODO *)
  assume(PPoint.live h2 basepoint); (* TODO *)
  montgomery_ladder res scalar basepoint;
  let h3 = HST.get() in assert(FStar.Buffer.modifies_3 (PPoint.get_x res) (PPoint.get_y res) (PPoint.get_z res) h2 h3);

  (* Get the affine coordinates back *)
  assume (live h3 zrecip /\ live h3 (PPoint.get_z res)); (* TODO *)
  crecip' zrecip (Hacl.EC.Curve25519.PPoint.get_z res);
  fmul resy resx zrecip;
  let h4 = HST.get() in assert(FStar.Buffer.modifies_2 zrecip resy h3 h4);

  assume (Buffer.modifies_2_1 scalar h0 h4 /\ live h4 output);
  contract output resy;

  pop_frame()
