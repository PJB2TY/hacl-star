module Hacl.Test.SHA2_384

open FStar.Buffer
open FStar.UInt32
open FStar.HyperStack.All

module Hash = Hacl.SHA2_384


val test_1a: unit -> ST unit
  (requires (fun h -> True))
  (ensures  (fun h0 r h1 -> True))
let test_1a () =

  (* Push a new memory frame *)
  (**) push_frame();

  let output_len = 48ul in
  let output = FStar.Buffer.create 0uy output_len in

  let plaintext_len = 3ul in
  let plaintext = FStar.Buffer.createL [
      0x61uy; 0x62uy; 0x63uy;
    ] in

  let expected = FStar.Buffer.createL [
    0xcbuy; 0x00uy; 0x75uy; 0x3fuy; 0x45uy; 0xa3uy; 0x5euy; 0x8buy;
    0xb5uy; 0xa0uy; 0x3duy; 0x69uy; 0x9auy; 0xc6uy; 0x50uy; 0x07uy;
    0x27uy; 0x2cuy; 0x32uy; 0xabuy; 0x0euy; 0xdeuy; 0xd1uy; 0x63uy;
    0x1auy; 0x8buy; 0x60uy; 0x5auy; 0x43uy; 0xffuy; 0x5buy; 0xeduy;
    0x80uy; 0x86uy; 0x07uy; 0x2buy; 0xa1uy; 0xe7uy; 0xccuy; 0x23uy;
    0x58uy; 0xbauy; 0xecuy; 0xa1uy; 0x34uy; 0xc8uy; 0x25uy; 0xa7uy
  ] in

  (* Allocate memory for state *)
  let state = FStar.Buffer.create 0uL Hash.size_state in

  (* Call the hash function *)
  Hash.init state;
  Hash.update_last state plaintext (FStar.Int.Cast.uint32_to_uint64 plaintext_len);
  Hash.finish state output;

  (* Display the result *)
  TestLib.compare_and_print (C.String.of_literal "Test 1a") expected output 48ul;

  (* Pop the memory frame *)
  (**) pop_frame()


val test_1b: unit -> ST unit
  (requires (fun h -> True))
  (ensures  (fun h0 r h1 -> True))
let test_1b () =

  (* Push a new memory frame *)
  (**) push_frame();

  let output_len = 48ul in
  let output = FStar.Buffer.create 0uy output_len in

  let plaintext_len = 3ul in
  let plaintext = FStar.Buffer.createL [
      0x61uy; 0x62uy; 0x63uy;
    ] in

  let expected = FStar.Buffer.createL [
    0xcbuy; 0x00uy; 0x75uy; 0x3fuy; 0x45uy; 0xa3uy; 0x5euy; 0x8buy;
    0xb5uy; 0xa0uy; 0x3duy; 0x69uy; 0x9auy; 0xc6uy; 0x50uy; 0x07uy;
    0x27uy; 0x2cuy; 0x32uy; 0xabuy; 0x0euy; 0xdeuy; 0xd1uy; 0x63uy;
    0x1auy; 0x8buy; 0x60uy; 0x5auy; 0x43uy; 0xffuy; 0x5buy; 0xeduy;
    0x80uy; 0x86uy; 0x07uy; 0x2buy; 0xa1uy; 0xe7uy; 0xccuy; 0x23uy;
    0x58uy; 0xbauy; 0xecuy; 0xa1uy; 0x34uy; 0xc8uy; 0x25uy; 0xa7uy
  ] in

  (* Call the hash function *)
  Hash.hash output plaintext plaintext_len;

  (* Display the result *)
  TestLib.compare_and_print (C.String.of_literal "Test 1b") expected output 48ul;

  (* Pop the memory frame *)
  (**) pop_frame()



val test_2a: unit -> ST unit
  (requires (fun h -> True))
  (ensures  (fun h0 r h1 -> True))
let test_2a () =

  (* Push a new memory frame *)
  (**) push_frame();

  let output_len = 48ul in
  let output = FStar.Buffer.create 0uy output_len in

  let plaintext_len = 0ul in
  let plaintext = FStar.Buffer.createL [] in

  let expected = FStar.Buffer.createL [
    0x38uy; 0xb0uy; 0x60uy; 0xa7uy; 0x51uy; 0xacuy; 0x96uy; 0x38uy;
    0x4cuy; 0xd9uy; 0x32uy; 0x7euy; 0xb1uy; 0xb1uy; 0xe3uy; 0x6auy;
    0x21uy; 0xfduy; 0xb7uy; 0x11uy; 0x14uy; 0xbeuy; 0x07uy; 0x43uy;
    0x4cuy; 0x0cuy; 0xc7uy; 0xbfuy; 0x63uy; 0xf6uy; 0xe1uy; 0xdauy;
    0x27uy; 0x4euy; 0xdeuy; 0xbfuy; 0xe7uy; 0x6fuy; 0x65uy; 0xfbuy;
    0xd5uy; 0x1auy; 0xd2uy; 0xf1uy; 0x48uy; 0x98uy; 0xb9uy; 0x5buy
  ] in

  (* Allocate memory for state *)
  let state = FStar.Buffer.create 0uL Hash.size_state in

  (* Call the hash function *)
  Hash.init state;
  Hash.update_last state plaintext (FStar.Int.Cast.uint32_to_uint64 plaintext_len);
  Hash.finish state output;

  (* Display the result *)
  TestLib.compare_and_print (C.String.of_literal "Test 2a") expected output 48ul;

  (* Pop the memory frame *)
  (**) pop_frame()


val test_2b: unit -> ST unit
  (requires (fun h -> True))
  (ensures  (fun h0 r h1 -> True))
let test_2b () =

  (* Push a new memory frame *)
  (**) push_frame();

  let output_len = 48ul in
  let output = FStar.Buffer.create 0uy output_len in

  let plaintext_len = 0ul in
  let plaintext = FStar.Buffer.createL [] in

  let expected = FStar.Buffer.createL [
    0x38uy; 0xb0uy; 0x60uy; 0xa7uy; 0x51uy; 0xacuy; 0x96uy; 0x38uy;
    0x4cuy; 0xd9uy; 0x32uy; 0x7euy; 0xb1uy; 0xb1uy; 0xe3uy; 0x6auy;
    0x21uy; 0xfduy; 0xb7uy; 0x11uy; 0x14uy; 0xbeuy; 0x07uy; 0x43uy;
    0x4cuy; 0x0cuy; 0xc7uy; 0xbfuy; 0x63uy; 0xf6uy; 0xe1uy; 0xdauy;
    0x27uy; 0x4euy; 0xdeuy; 0xbfuy; 0xe7uy; 0x6fuy; 0x65uy; 0xfbuy;
    0xd5uy; 0x1auy; 0xd2uy; 0xf1uy; 0x48uy; 0x98uy; 0xb9uy; 0x5buy
  ] in

  (* Call the hash function *)
  Hash.hash output plaintext plaintext_len;

  (* Display the result *)
  TestLib.compare_and_print (C.String.of_literal "Test 2b") expected output 48ul;

  (* Pop the memory frame *)
  (**) pop_frame()



val test_3a: unit -> ST unit
  (requires (fun h -> True))
  (ensures  (fun h0 r h1 -> True))
let test_3a () =

  (* Push a new memory frame *)
  (**) push_frame();

  let output_len = 48ul in
  let output = FStar.Buffer.create 0uy output_len in

  let plaintext_len = 56ul in
  let plaintext = FStar.Buffer.createL [
    0x61uy; 0x62uy; 0x63uy; 0x64uy; 0x62uy; 0x63uy; 0x64uy; 0x65uy;
    0x63uy; 0x64uy; 0x65uy; 0x66uy; 0x64uy; 0x65uy; 0x66uy; 0x67uy;
    0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy;
    0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x68uy; 0x69uy; 0x6auy; 0x6buy;
    0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy;
    0x6buy; 0x6cuy; 0x6duy; 0x6euy; 0x6cuy; 0x6duy; 0x6euy; 0x6fuy;
    0x6duy; 0x6euy; 0x6fuy; 0x70uy; 0x6euy; 0x6fuy; 0x70uy; 0x71uy
  ] in

  let expected = FStar.Buffer.createL [
    0x33uy; 0x91uy; 0xfduy; 0xdduy; 0xfcuy; 0x8duy; 0xc7uy; 0x39uy;
    0x37uy; 0x07uy; 0xa6uy; 0x5buy; 0x1buy; 0x47uy; 0x09uy; 0x39uy;
    0x7cuy; 0xf8uy; 0xb1uy; 0xd1uy; 0x62uy; 0xafuy; 0x05uy; 0xabuy;
    0xfeuy; 0x8fuy; 0x45uy; 0x0duy; 0xe5uy; 0xf3uy; 0x6buy; 0xc6uy;
    0xb0uy; 0x45uy; 0x5auy; 0x85uy; 0x20uy; 0xbcuy; 0x4euy; 0x6fuy;
    0x5fuy; 0xe9uy; 0x5buy; 0x1fuy; 0xe3uy; 0xc8uy; 0x45uy; 0x2buy
  ] in

  (* Allocate memory for state *)
  let state = FStar.Buffer.create 0uL Hash.size_state in

  (* Call the hash function *)
  Hash.init state;
  Hash.update_last state plaintext (FStar.Int.Cast.uint32_to_uint64 plaintext_len);
  Hash.finish state output;

  (* Display the result *)
  TestLib.compare_and_print (C.String.of_literal "Test 3a") expected output 48ul;

  (* Pop the memory frame *)
  (**) pop_frame()


val test_3b: unit -> ST unit
  (requires (fun h -> True))
  (ensures  (fun h0 r h1 -> True))
let test_3b () =

  (* Push a new memory frame *)
  (**) push_frame();

  let output_len = 48ul in
  let output = FStar.Buffer.create 0uy output_len in

  let plaintext_len = 56ul in
  let plaintext = FStar.Buffer.createL [
    0x61uy; 0x62uy; 0x63uy; 0x64uy; 0x62uy; 0x63uy; 0x64uy; 0x65uy;
    0x63uy; 0x64uy; 0x65uy; 0x66uy; 0x64uy; 0x65uy; 0x66uy; 0x67uy;
    0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy;
    0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x68uy; 0x69uy; 0x6auy; 0x6buy;
    0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy;
    0x6buy; 0x6cuy; 0x6duy; 0x6euy; 0x6cuy; 0x6duy; 0x6euy; 0x6fuy;
    0x6duy; 0x6euy; 0x6fuy; 0x70uy; 0x6euy; 0x6fuy; 0x70uy; 0x71uy
  ] in

  let expected = FStar.Buffer.createL [
    0x33uy; 0x91uy; 0xfduy; 0xdduy; 0xfcuy; 0x8duy; 0xc7uy; 0x39uy;
    0x37uy; 0x07uy; 0xa6uy; 0x5buy; 0x1buy; 0x47uy; 0x09uy; 0x39uy;
    0x7cuy; 0xf8uy; 0xb1uy; 0xd1uy; 0x62uy; 0xafuy; 0x05uy; 0xabuy;
    0xfeuy; 0x8fuy; 0x45uy; 0x0duy; 0xe5uy; 0xf3uy; 0x6buy; 0xc6uy;
    0xb0uy; 0x45uy; 0x5auy; 0x85uy; 0x20uy; 0xbcuy; 0x4euy; 0x6fuy;
    0x5fuy; 0xe9uy; 0x5buy; 0x1fuy; 0xe3uy; 0xc8uy; 0x45uy; 0x2buy
  ] in

  (* Call the hash function *)
  Hash.hash output plaintext plaintext_len;

  (* Display the result *)
  TestLib.compare_and_print (C.String.of_literal "Test 3b") expected output 48ul;

  (* Pop the memory frame *)
  (**) pop_frame()



val test_4a: unit -> ST unit
  (requires (fun h -> True))
  (ensures  (fun h0 r h1 -> True))
let test_4a () =

  (* Push a new memory frame *)
  (**) push_frame();

  let output_len = 48ul in
  let output = FStar.Buffer.create 0uy output_len in

  let plaintext_len = 112ul in
  let plaintext = FStar.Buffer.createL [
      0x61uy; 0x62uy; 0x63uy; 0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy;
      0x62uy; 0x63uy; 0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy;
      0x63uy; 0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy;
      0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy;
      0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy;
      0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy;
      0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy; 0x6euy;
      0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy; 0x6euy; 0x6fuy;
      0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy; 0x6euy; 0x6fuy; 0x70uy;
      0x6auy; 0x6buy; 0x6cuy; 0x6duy; 0x6euy; 0x6fuy; 0x70uy; 0x71uy;
      0x6buy; 0x6cuy; 0x6duy; 0x6euy; 0x6fuy; 0x70uy; 0x71uy; 0x72uy;
      0x6cuy; 0x6duy; 0x6euy; 0x6fuy; 0x70uy; 0x71uy; 0x72uy; 0x73uy;
      0x6duy; 0x6euy; 0x6fuy; 0x70uy; 0x71uy; 0x72uy; 0x73uy; 0x74uy;
      0x6euy; 0x6fuy; 0x70uy; 0x71uy; 0x72uy; 0x73uy; 0x74uy; 0x75uy
    ] in

  let expected = FStar.Buffer.createL [
    0x09uy; 0x33uy; 0x0cuy; 0x33uy; 0xf7uy; 0x11uy; 0x47uy; 0xe8uy;
    0x3duy; 0x19uy; 0x2fuy; 0xc7uy; 0x82uy; 0xcduy; 0x1buy; 0x47uy;
    0x53uy; 0x11uy; 0x1buy; 0x17uy; 0x3buy; 0x3buy; 0x05uy; 0xd2uy;
    0x2fuy; 0xa0uy; 0x80uy; 0x86uy; 0xe3uy; 0xb0uy; 0xf7uy; 0x12uy;
    0xfcuy; 0xc7uy; 0xc7uy; 0x1auy; 0x55uy; 0x7euy; 0x2duy; 0xb9uy;
    0x66uy; 0xc3uy; 0xe9uy; 0xfauy; 0x91uy; 0x74uy; 0x60uy; 0x39uy
  ] in

  (* Allocate memory for state *)
  let state = FStar.Buffer.create 0uL Hash.size_state in

  (* Call the hash function *)
  Hash.init state;
  Hash.update_last state plaintext (FStar.Int.Cast.uint32_to_uint64 plaintext_len);
  Hash.finish state output;

  (* Display the result *)
  TestLib.compare_and_print (C.String.of_literal "Test 4a") expected output 48ul;

  (* Pop the memory frame *)
  (**) pop_frame()


val test_4b: unit -> ST unit
  (requires (fun h -> True))
  (ensures  (fun h0 r h1 -> True))
let test_4b () =

  (* Push a new memory frame *)
  (**) push_frame();

  let output_len = 48ul in
  let output = FStar.Buffer.create 0uy output_len in

  let plaintext_len = 112ul in
  let plaintext = FStar.Buffer.createL [
      0x61uy; 0x62uy; 0x63uy; 0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy;
      0x62uy; 0x63uy; 0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy;
      0x63uy; 0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy;
      0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy;
      0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy;
      0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy;
      0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy; 0x6euy;
      0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy; 0x6euy; 0x6fuy;
      0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy; 0x6euy; 0x6fuy; 0x70uy;
      0x6auy; 0x6buy; 0x6cuy; 0x6duy; 0x6euy; 0x6fuy; 0x70uy; 0x71uy;
      0x6buy; 0x6cuy; 0x6duy; 0x6euy; 0x6fuy; 0x70uy; 0x71uy; 0x72uy;
      0x6cuy; 0x6duy; 0x6euy; 0x6fuy; 0x70uy; 0x71uy; 0x72uy; 0x73uy;
      0x6duy; 0x6euy; 0x6fuy; 0x70uy; 0x71uy; 0x72uy; 0x73uy; 0x74uy;
      0x6euy; 0x6fuy; 0x70uy; 0x71uy; 0x72uy; 0x73uy; 0x74uy; 0x75uy
    ] in

  let expected = FStar.Buffer.createL [
    0x09uy; 0x33uy; 0x0cuy; 0x33uy; 0xf7uy; 0x11uy; 0x47uy; 0xe8uy;
    0x3duy; 0x19uy; 0x2fuy; 0xc7uy; 0x82uy; 0xcduy; 0x1buy; 0x47uy;
    0x53uy; 0x11uy; 0x1buy; 0x17uy; 0x3buy; 0x3buy; 0x05uy; 0xd2uy;
    0x2fuy; 0xa0uy; 0x80uy; 0x86uy; 0xe3uy; 0xb0uy; 0xf7uy; 0x12uy;
    0xfcuy; 0xc7uy; 0xc7uy; 0x1auy; 0x55uy; 0x7euy; 0x2duy; 0xb9uy;
    0x66uy; 0xc3uy; 0xe9uy; 0xfauy; 0x91uy; 0x74uy; 0x60uy; 0x39uy
  ] in

  (* Call the hash function *)
  Hash.hash output plaintext plaintext_len;

  (* Display the result *)
  TestLib.compare_and_print (C.String.of_literal "Test 4b") expected output 48ul;

  (* Pop the memory frame *)
  (**) pop_frame()



val test_5: unit -> ST unit
  (requires (fun h -> True))
  (ensures  (fun h0 r h1 -> True))
let test_5 () =

  (* Push a new memory frame *)
  (**) push_frame();

  let output_len = 48ul in
  let output = FStar.Buffer.create 0uy output_len in

  let plaintext_len = 1000000ul in
  let plaintext = FStar.Buffer.create 0x61uy plaintext_len in

  let expected = FStar.Buffer.createL [
    0x9duy; 0x0euy; 0x18uy; 0x09uy; 0x71uy; 0x64uy; 0x74uy; 0xcbuy;
    0x08uy; 0x6euy; 0x83uy; 0x4euy; 0x31uy; 0x0auy; 0x4auy; 0x1cuy;
    0xeduy; 0x14uy; 0x9euy; 0x9cuy; 0x00uy; 0xf2uy; 0x48uy; 0x52uy;
    0x79uy; 0x72uy; 0xceuy; 0xc5uy; 0x70uy; 0x4cuy; 0x2auy; 0x5buy;
    0x07uy; 0xb8uy; 0xb3uy; 0xdcuy; 0x38uy; 0xecuy; 0xc4uy; 0xebuy;
    0xaeuy; 0x97uy; 0xdduy; 0xd8uy; 0x7fuy; 0x3duy; 0x89uy; 0x85uy
  ] in

  (* Call the hash function *)
  Hash.hash output plaintext plaintext_len;

  (* Display the result *)
  TestLib.compare_and_print (C.String.of_literal "Test 5") expected output 48ul;

  (* Pop the memory frame *)
  (**) pop_frame()



val test_6_loop:
  state:FStar.Buffer.buffer FStar.UInt64.t ->
  plaintext:FStar.Buffer.buffer FStar.UInt8.t ->
  ST unit
  (requires (fun h -> True))
  (ensures  (fun h0 r h1 -> True))
let test_6_loop state plaintext =
  let inv (h1: HyperStack.mem) (i: nat) : Type0 =
    live h1 state /\ i <= v 8388607ul
  in
  let f' (t:FStar.UInt32.t) :
    Stack unit
      (requires (fun h -> True))
      (ensures (fun h_1 _ h_2 -> True))
    =
    Hash.update state plaintext
  in
  C.Loops.for 0ul 8388607ul inv f'


val test_6: unit -> ST unit
  (requires (fun h -> True))
  (ensures  (fun h0 r h1 -> True))
let test_6 () =

  (* Push a new memory frame *)
  (**) push_frame();

  let output_len = 48ul in
  let output = FStar.Buffer.create 0uy output_len in

  let plaintext_len = 128ul in
  let plaintext = FStar.Buffer.createL [
      0x61uy; 0x62uy; 0x63uy; 0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy;
      0x62uy; 0x63uy; 0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy;
      0x63uy; 0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy;
      0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy;
      0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy;
      0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy;
      0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy; 0x6euy;
      0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy; 0x6euy; 0x6fuy;
      0x61uy; 0x62uy; 0x63uy; 0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy;
      0x62uy; 0x63uy; 0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy;
      0x63uy; 0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy;
      0x64uy; 0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy;
      0x65uy; 0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy;
      0x66uy; 0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy;
      0x67uy; 0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy; 0x6euy;
      0x68uy; 0x69uy; 0x6auy; 0x6buy; 0x6cuy; 0x6duy; 0x6euy; 0x6fuy
  ] in

  let expected = FStar.Buffer.createL [
    0x54uy; 0x41uy; 0x23uy; 0x5cuy; 0xc0uy; 0x23uy; 0x53uy; 0x41uy;
    0xeduy; 0x80uy; 0x6auy; 0x64uy; 0xfbuy; 0x35uy; 0x47uy; 0x42uy;
    0xb5uy; 0xe5uy; 0xc0uy; 0x2auy; 0x3cuy; 0x5cuy; 0xb7uy; 0x1buy;
    0x5fuy; 0x63uy; 0xfbuy; 0x79uy; 0x34uy; 0x58uy; 0xd8uy; 0xfduy;
    0xaeuy; 0x59uy; 0x9cuy; 0x8cuy; 0xd8uy; 0x88uy; 0x49uy; 0x43uy;
    0xc0uy; 0x4fuy; 0x11uy; 0xb3uy; 0x1buy; 0x89uy; 0xf0uy; 0x23uy;
  ] in

  (* Allocate memory for state *)
  let state = FStar.Buffer.create 0uL Hash.size_state in

  (* initialize the hash state *)
  Hash.init state;

  test_6_loop state plaintext;

  let rem_len = UInt32.rem (128ul *%^ 8388607ul) Hash.size_block in
  Hash.update_last state plaintext (FStar.Int.Cast.uint32_to_uint64 plaintext_len);
  Hash.finish state output;

  (* Display the result *)
  TestLib.compare_and_print (C.String.of_literal "Test 6") expected output 48ul;

  (* Pop the memory frame *)
  (**) pop_frame()



val main: unit -> ST C.exit_code
  (requires (fun h -> True))
  (ensures  (fun h0 r h1 -> True))
let main () =

  (* Run test vector 1 *)
  test_1a ();
  test_1b ();

  (* Run test vector 2 *)
  test_2a ();
  test_2b ();

  (* Run test vector 3 *)
  test_3a ();
  test_3b ();

  (* Run test vector 4 *)
  test_4a ();
  test_4b ();

  (* Run test vector 5 *)
  test_5 ();

  (* Run test vector 6 *)
  test_6();

  (* Exit the program *)
  C.EXIT_SUCCESS
