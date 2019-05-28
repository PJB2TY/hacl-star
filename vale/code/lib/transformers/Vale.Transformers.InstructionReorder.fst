module Vale.Transformers.InstructionReorder

/// Open all the relevant modules from the x64 semantics.

open Vale.X64.Bytes_Code_s
open Vale.X64.Instruction_s
open Vale.X64.Instructions_s
open Vale.X64.Machine_Semantics_s
open Vale.X64.Machine_s
open Vale.X64.Print_s

open Vale.X64.InsLemmas // this one is from [code]; is that ok?; we use it primarily for the sanity checks

/// Open the PossiblyMonad so that we can keep track of failure cases
/// for easier debugging.

open Vale.Transformers.PossiblyMonad

/// Finally some convenience module renamings

module L = FStar.List.Tot

/// We first need to talk about what locations may be accessed (either
/// via a read or via a write) by an instruction.
///
/// This allows us to define read and write sets for instructions.
///
/// TODO FIXME WARNING UNSOUND: We completely ignore [HavocFlags]
/// here. Technically, we need to add both flags to the write sets
/// whenever there is a flag havoc that happens.

type access_location =
  | ALoc64 : operand -> access_location
  | ALoc128 : operand128 -> access_location
  | ALocCf : access_location
  | ALocOf : access_location

let access_location_of_explicit (t:instr_operand_explicit) (i:instr_operand_t t) : access_location =
  match t with
  | IOp64 -> ALoc64 i
  | IOpXmm -> ALoc128 i

let access_location_of_implicit (t:instr_operand_implicit) : access_location =
  match t with
  | IOp64One i -> ALoc64 i
  | IOpXmmOne i -> ALoc128 i
  | IOpFlagsCf -> ALocCf
  | IOpFlagsOf -> ALocOf

type rw_set = (list access_location) & (list access_location)

let rec aux_read_set0 (args:list instr_operand) (oprs:instr_operands_t_args args) =
  match args with
  | [] -> []
  | (IOpEx i) :: args ->
    let l, r = coerce #(instr_operand_t i & instr_operands_t_args args) oprs in
    access_location_of_explicit i l :: aux_read_set0 args r
  | (IOpIm i) :: args ->
    access_location_of_implicit i :: aux_read_set0 args (coerce #(instr_operands_t_args args) oprs)

let rec aux_read_set1
    (outs:list instr_out) (args:list instr_operand) (oprs:instr_operands_t outs args) : list access_location =
  match outs with
  | [] -> aux_read_set0 args oprs
  | (Out, IOpEx i) :: outs ->
    let l, r = coerce #(instr_operand_t i & instr_operands_t outs args) oprs in
    aux_read_set1 outs args r
  | (InOut, IOpEx i) :: outs ->
    let l, r = coerce #(instr_operand_t i & instr_operands_t outs args) oprs in
    access_location_of_explicit i l :: aux_read_set1 outs args r
  | (Out, IOpIm i) :: outs ->
    aux_read_set1 outs args (coerce #(instr_operands_t outs args) oprs)
  | (InOut, IOpIm i) :: outs ->
    access_location_of_implicit i :: aux_read_set1 outs args (coerce #(instr_operands_t outs args) oprs)

let read_set (i:instr_t_record) (oprs:instr_operands_t i.outs i.args) : list access_location =
  aux_read_set1 i.outs i.args oprs

let rec aux_write_set
    (outs:list instr_out) (args:list instr_operand) (oprs:instr_operands_t outs args) : list access_location =
  match outs with
  | [] -> []
  | (_, IOpEx i) :: outs ->
    let l, r = coerce #(instr_operand_t i & instr_operands_t outs args) oprs in
    access_location_of_explicit i l :: aux_write_set outs args r
  | (_, IOpIm i) :: outs ->
    access_location_of_implicit i :: aux_write_set outs args (coerce #(instr_operands_t outs args) oprs)

let write_set (i:instr_t_record) (oprs:instr_operands_t i.outs i.args) : list access_location =
  aux_write_set i.outs i.args oprs

let rw_set_of_ins (i:ins) : rw_set =
  match i with
  | Instr i oprs _ ->
    read_set i oprs, write_set i oprs
  | Push src t ->
    [ALoc64 (OReg rRsp); ALoc64 src],
    [ALoc64 (OReg rRsp); ALoc64 (OStack (MReg rRsp (-8), t))]
  | Pop dst t ->
    [ALoc64 (OReg rRsp); ALoc64 (OStack (MReg rRsp 0, t))],
    [ALoc64 (OReg rRsp); ALoc64 dst]
  | Alloc _
  | Dealloc _ ->
    [ALoc64 (OReg rRsp)], [ALoc64 (OReg rRsp)]

/// We now need to define what it means for two different access
/// locations to be "disjoint".
///
/// Note that it is safe to say that two operands are not disjoint
/// even if they are, but the converse is not true. That is, to be
/// safe, we can say two operands are disjoint only if it is
/// guaranteed that they are disjoint.

let disjoint_access_locations (a1 a2:access_location) : pbool =
  match a1, a2 with
  | ALocCf, ALocCf -> ffalse "carry flag not disjoint from itself"
  | ALocOf, ALocOf -> ffalse "overflow flag not disjoint from itself"
  | ALocCf, _ | ALocOf, _ | _, ALocCf | _, ALocOf -> ttrue
  | ALoc64 o1, ALoc64 o2 -> (
      match o1, o2 with
      | OConst _, _ | _, OConst _ -> ttrue
      | OReg r1, OReg r2 -> (r1 <> r2) /- ("register " ^ print_reg_name r1 ^ " not disjoint from itself")
      | _ ->
        unimplemented "conservatively not disjoint ALoc64s"
    )
  | ALoc128 o1, ALoc128 o2 -> (
      match o1, o2 with
      | OReg128 r1, OReg128 r2 -> (r1 <> r2) /- ("register " ^ print_xmm r1 gcc ^ " not disjoint from itself")
      | _ ->
      unimplemented "conservatively not disjoint ALoc128s"
    )
  | ALoc64 o1, ALoc128 o2 | ALoc128 o1, ALoc64 o2 -> (
      unimplemented "conservatively not disjoint ALoc64 & ALoc128"
    )

/// Given two read/write sets corresponding to two neighboring
/// instructions, we can say whether exchanging those two instructions
/// should be allowed.

let rw_exchange_allowed (rw1 rw2 : rw_set) : pbool =
  let (r1, w1), (r2, w2) = rw1, rw2 in
  let (&&.) (x y:pbool) : pbool =
    match x with
    | Ok () -> y
    | Err reason -> Err reason in
  let rec for_all (f : 'a -> pbool) (l : list 'a) : pbool =
    match l with
    | [] -> ttrue
    | x :: xs -> f x &&. for_all f xs in
  let disjoint (l1 l2:list access_location) r : pbool =
    match l1 with
    | [] -> ttrue
    | x :: xs ->
      (for_all (fun y -> (disjoint_access_locations x y)) l2) /+< (r ^ " because ") in
  (disjoint r1 w2 "read set of 1st not disjoint from write set of 2nd") &&.
  (disjoint r2 w1 "read set of 2nd not disjoint from write set of 1st") &&.
  (disjoint w1 w2 "write sets not disjoint")

let ins_exchange_allowed (i1 i2 : ins) : pbool =
  (rw_exchange_allowed (rw_set_of_ins i1) (rw_set_of_ins i2))
  /+> normal (" for instructions " ^ print_ins i1 gcc ^ " and " ^ print_ins i2 gcc)

private abstract
let sanity_check_1 =
  assert_norm (!!(
    ins_exchange_allowed
      (make_instr ins_Mov64 (OReg rRax) (OConst 100))
      (make_instr ins_Add64 (OReg rRbx) (OConst 299))))

private abstract
let sanity_check_2 =
  assert_norm (not !!(
    ins_exchange_allowed
      (make_instr ins_Mov64 (OReg rRax) (OConst 100))
      (make_instr ins_Add64 (OReg rRax) (OConst 299))))

/// First, we must define what it means for two states to be
/// equivalent. Here, we basically say they must be exactly the same.
///
/// TODO: We should figure out a way to handle flags better. Currently
/// any two instructions that havoc flags cannot be exchanged since
/// they will not lead to equiv states.

let equiv_states (s1 s2 : machine_state) : GTot Type0 =
  (s1.ms_ok == s2.ms_ok) /\
  (s1.ms_regs == s2.ms_regs) /\
  (s1.ms_xmms == s2.ms_xmms) /\
  (s1.ms_flags == s2.ms_flags) /\
  (s1.ms_mem == s2.ms_mem) /\
  (s1.ms_stack == s2.ms_stack)

private abstract
let sanity_check_equiv_states (s1 s2 s3 : machine_state) :
  Lemma
    (ensures (
        (equiv_states s1 s1) /\
        (equiv_states s1 s2 ==> equiv_states s2 s1) /\
        (equiv_states s1 s2 /\ equiv_states s2 s3 ==> equiv_states s1 s3))) = ()

let lemma_eval_code_equiv_states (c : code) (fuel:nat) (s1 s2 : machine_state) :
  Lemma
    (requires (equiv_states s1 s2))
    (ensures (
        let s1'', s2'' =
          machine_eval_code c fuel s1,
          machine_eval_code c fuel s2 in
        (Some? s1'' = Some? s2'') /\
        (Some? s1'' ==> (
            (let Some s1', Some s2' = s1'', s2'' in
             equiv_states s1' s2'))))) =
  admit ()

/// If an exchange is allowed between two instructions based off of
/// their read/write sets, then both orderings of the two instructions
/// behave exactly the same, as per the previously defined
/// [equiv_states] relation.

(** Filter out observation related stuff from the state.

    REVIEW: Figure out _why_ all the taint analysis related stuff is
    part of the core semantics of x64, rather than being separated
    out. *)
let filt_state (s:machine_state) =
  { s with
    ms_trace = [] }

let lemma_instruction_exchange (i1 i2 : ins) (s1 s2 : machine_state) :
  Lemma
    (requires (
        !!(ins_exchange_allowed i1 i2) /\
        (equiv_states s1 s2)))
    (ensures (
        (let s1', s2' =
           machine_eval_ins i2 (filt_state (machine_eval_ins i1 (filt_state s1))),
           machine_eval_ins i1 (filt_state (machine_eval_ins i2 (filt_state s2))) in
         equiv_states s1' s2'))) =
  admit ()

/// Given that we can perform simple swaps between instructions, we
/// can do swaps between [code]s.

let code_exchange_allowed (c1 c2:code) : pbool =
  match c1, c2 with
  | Ins i1, Ins i2 -> ins_exchange_allowed i1 i2
  | _ -> ffalse "non instruction swaps conservatively disallowed"

let lemma_code_exchange (c1 c2 : code) (fuel:nat) (s1 s2 : machine_state) :
  Lemma
    (requires (
        !!(code_exchange_allowed c1 c2) /\
        (equiv_states s1 s2) /\
        (Some? (machine_eval_codes [c1; c2] fuel s1))))
    (ensures (
        (Some? (machine_eval_codes [c2; c1] fuel s2)) /\
        (let Some s1', Some s2' =
           machine_eval_codes [c1; c2] fuel s1,
           machine_eval_codes [c2; c1] fuel s2 in
         equiv_states s1' s2'))) =
  let Some s1', Some s2' =
    machine_eval_codes [c1; c2] fuel s1,
    machine_eval_codes [c2; c1] fuel s2 in
  match c1, c2 with
  | Ins i1, Ins i2 ->
    let Some s10 = machine_eval_code c1 fuel s1 in
    let Some s11 = machine_eval_code c1 fuel (filt_state s1) in
    // assert_norm (equiv_states s10 s11);
    // assert_norm (equiv_states (machine_eval_ins i1 (filt_state s1)) s11);
    let Some s12 = machine_eval_code c2 fuel (machine_eval_ins i1 (filt_state s1)) in
    // assert_norm (equiv_states s1' s12);
    let Some s13 = machine_eval_code c2 fuel (filt_state (machine_eval_ins i1 (filt_state s1))) in
    // assert_norm (equiv_states s12 s13);
    let s14 = machine_eval_ins i2 (filt_state (machine_eval_ins i1 (filt_state s1))) in
    // assert_norm (equiv_states s13 s14);
    assert_norm (equiv_states s1' s14);
    let Some s20 = machine_eval_code c2 fuel s2 in
    let Some s21 = machine_eval_code c2 fuel (filt_state s2) in
    // assert_norm (equiv_states s20 s21);
    // assert_norm (equiv_states (machine_eval_ins i2 (filt_state s2)) s21);
    let Some s22 = machine_eval_code c1 fuel (machine_eval_ins i2 (filt_state s2)) in
    // assert_norm (equiv_states s2' s22);
    let Some s23 = machine_eval_code c1 fuel (filt_state (machine_eval_ins i2 (filt_state s2))) in
    // assert_norm (equiv_states s22 s23);
    let s24 = machine_eval_ins i1 (filt_state (machine_eval_ins i2 (filt_state s2))) in
    // assert_norm (equiv_states s23 s24);
    assert_norm (equiv_states s2' s24);
    lemma_instruction_exchange i1 i2 s1 s2;
    assert (equiv_states s14 s24);
    sanity_check_equiv_states s1' s14 s24;
    sanity_check_equiv_states s1' s24 s2';
    assert (equiv_states s1' s2')
  | _ -> ()

/// Given that we can perform simple swaps between [code]s, we can
/// define a relation that tells us if some [codes] can be transformed
/// into another using only allowed swaps.

(* WARNING UNSOUND We need to figure out a way to check for equality
   between [code]s *)
assume val eq_code (c1 c2 : code) : (b:bool{b <==> c1 == c2})

let rec find_code (c1:code) (cs2:codes) : possibly (i:nat{i < L.length cs2 /\ c1 == L.index cs2 i}) =
  match cs2 with
  | [] -> Err ("Not found: " ^ fst (print_code c1 0 gcc))
  | h2 :: t2 ->
    if eq_code c1 h2 then (
      return 0
    ) else (
      match find_code c1 t2 with
      | Err reason -> Err reason
      | Ok i ->
        return (i+1)
    )

let rec bubble_to_top (cs:codes) (i:nat{i < L.length cs}) : possibly (cs':codes{
    let a, b, c = L.split3 cs i in
    cs' == L.append a c
  }) =
  match cs with
  | [_] -> return []
  | h :: t ->
    let x = L.index cs i in
    if i = 0 then (
      return t
    ) else (
      match bubble_to_top t (i - 1) with
      | Err reason -> Err reason
      | Ok res ->
        match code_exchange_allowed x h with
        | Err reason -> Err reason
        | Ok () ->
          return (h :: res)
    )

let rec reordering_allowed (c1 c2 : codes) : pbool =
  match c1, c2 with
  | [], [] -> ttrue
  | [], _ | _, [] -> ffalse "disagreeing lengths of codes"
  | h1 :: t1, _ ->
    i <-- find_code h1 c2;
    t2 <-- bubble_to_top c2 i;
    (* TODO: Also check _inside_ blocks/ifelse/etc rather than just at the highest level *)
    reordering_allowed t1 t2

/// If there are two sequences of instructions that can be transformed
/// amongst each other, then they behave identically as per the
/// [equiv_states] relation.

let rec lemma_bubble_to_top (cs : codes) (i:nat{i < L.length cs}) (fuel:nat) (s : machine_state)
    (x : _{x == L.index cs i}) (xs : _{Ok xs == bubble_to_top cs i})
    (s_0 : _{Some s_0 == machine_eval_code x fuel s})
    (s_1 : _{Some s_1 == machine_eval_codes xs fuel s_0}) :
  Lemma
    (ensures (
        let s_final' = machine_eval_codes cs fuel s in
        (Some? s_final') /\
        (equiv_states (Some?.v s_final') s_1))) =
  let s_final' = machine_eval_codes cs fuel s in
  match i with
  | 0 -> ()
  | _ ->
    let tlcs = L.tl cs in
    let Ok tlxs = bubble_to_top (L.tl cs) (i-1) in
    assert_norm (tlxs == L.tl xs);
    let Some s_shift = machine_eval_code (L.hd xs) fuel s in
    let Some s_shift_0 = machine_eval_code x fuel s_shift in
    sanity_check_equiv_states s s s;
    admit ();
    lemma_code_exchange x (L.hd xs) fuel s s;
    let Some s_shift_1 = machine_eval_codes tlxs fuel s_shift_0 in
    admit ();
    admit ();
    lemma_bubble_to_top tlcs (i-1) fuel s x tlxs s_0 (Some?.v (machine_eval_codes tlxs fuel s_0));
    admit ()

let rec lemma_reordering (c1 c2 : codes) (fuel:nat) (s1 s2 : machine_state) :
  Lemma
    (requires (
        !!(reordering_allowed c1 c2) /\
        (equiv_states s1 s2) /\
        (Some? (machine_eval_codes c1 fuel s1))))
    (ensures (
        (Some? (machine_eval_codes c2 fuel s2)) /\
        (let Some s1', Some s2' =
           machine_eval_codes c1 fuel s1,
           machine_eval_codes c2 fuel s2 in
         equiv_states s1' s2'))) =
  match c1 with
  | [] -> ()
  | h1 :: t1 ->
    let Ok i = find_code h1 c2 in
    let Ok t2 = bubble_to_top c2 i in
    lemma_eval_code_equiv_states h1 fuel s1 s2;
    lemma_reordering t1 t2 fuel (Some?.v (machine_eval_code h1 fuel s1)) (Some?.v (machine_eval_code h1 fuel s2));
    let Some s_0 = machine_eval_code h1 fuel s2 in
    let Some s_1 = machine_eval_codes t2 fuel s_0 in
    lemma_bubble_to_top c2 i fuel s2 h1 t2 s_0 s_1
