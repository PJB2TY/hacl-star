(** This module provides direct access to all HACL* implementations *)

open SharedDefs

type bytes = CBytes.t
(** [bytes] is ultimately an alias for [Stdlib.Bytes.t], the type of buffers currently used
    throughout the library *)

(** {1 AEAD} *)
(** {2 Chacha20-Poly1305}
    Different implementations of Chacha20-Poly1305. A {{!EverCrypt.Chacha20_Poly1305}
    multiplexing interface} is also available.
*)

module Chacha20_Poly1305_32 : Chacha20_Poly1305
(** Portable C implementation of Chacha20-Poly1305 that runs on any 32-bit platform *)

module Chacha20_Poly1305_128 : Chacha20_Poly1305
(** 128-bit vectorized C implementation of Chacha20-Poly1305 that runs on platforms with {{!AutoConfig2.VEC128} 128-bit vector support} *)

module Chacha20_Poly1305_256 : Chacha20_Poly1305
(** 256-bit vectorized C implementation of Chacha20-Poly1305 that runs on platforms with {{!AutoConfig2.VEC256} 256-bit vector support} *)

(** {1 ECDH, EdDSA, and ECDSA} *)
(** {2:curve Curve25519}
    Different implementations of ECDH using Curve25519. A {{!EverCrypt.Curve25519}
    multiplexing interface} is also available.
*)

module Curve25519_51 : Curve25519
(** Portable C implementation that is optimized for use on 64-bit platforms that
    support 128-bit arithmetic, will still compile and execute on 32-bit platforms *)

module Curve25519_64 : Curve25519
(** Hybrid C/assembly implementation: the field arithmetic functions are in Intel assembly
    (generated by Vale) and rely on the {{!AutoConfig2.ADX} Intel ADX} and {{!AutoConfig2.BMI2} BMI2} instruction sets; the elliptic
    curve functions and the main API are in portable C *)

(** {2 Ed25519}
    EdDSA using Curve25519*)

module Ed25519 : EdDSA
(** Portable implementation *)

(** {2 P-256} *)

module P256 : sig

  (** Buffers have the following size constraints:
      - [pk]: 64 bytes, corresponding to the "raw" representation of an elliptic curve point (see {!section:points})
      - [sk], [k]: 32 bytes
      - [signature]: 64 bytes
      - [msg]: depends on which hash function is being used (see {!section:ecdsa})
  *)

  (** {1:points Point representation and conversions}
      Elliptic curve points have 2 32-byte coordinates {i (x, y)} and can be represented in 3 ways:
      - "raw" form (64 bytes): the concatenation of the 2 coordinates
      - "compressed" form (33 bytes): the first byte is either [\x02] or [\x03], followed
      by {i y}
      - "uncompressed" form (65 bytes): the first byte is always [\04], followed by the "raw" form

      These functions convert points between these representations:
*)

  val raw_to_compressed : bytes -> bytes
    (** [raw_to_compressed p] converts a "raw" point [p] (64 bytes) to a "compressed" point (33 bytes) *)

  val raw_to_uncompressed : bytes -> bytes
    (** [raw_to_uncompressed p] converts a "raw" point [p] (64 bytes) to an "uncompressed" point (65 bytes) *)

  val compressed_to_raw : bytes -> bytes option
    (** [compressed_to_raw p] attempts to convert a "compressed" point [p] (33 bytes) to a "raw" point (64 bytes)
        and returns it if successful. *)

  val uncompressed_to_raw : bytes -> bytes option
    (** [uncompressed_to_raw p] attempts to convert an "uncompressed" point [p] (65 bytes) to a "raw" point (64 bytes)
        and returns it if successful. *)

  (** {1 Point validation} *)

  val valid_sk : sk:bytes -> bool
    (** [valid_sk sk] checks if the contents of [sk] can be used as a secret key or as a signing secret.
    This is the case if 0 < [sk] < the order of the curve. *)

  val valid_pk : pk:bytes -> bool
  (** [valid_pk pk] checks if the contents of [pk] is a valid public key, as specified in {{: https://csrc.nist.gov/publications/detail/sp/800-56a/rev-3/final}NIST SP 800-56A}. *)

  (** {1 ECDH}
      ECDH key agreement protocol
  *)

  val dh_initiator : sk:bytes -> bytes option
  (** [dh_initiator sk] takes a 32-byte secret key [sk] and returns the corresponding
      64-byte public key. *)

  val dh_responder : sk:bytes -> pk:bytes -> bytes option
  (** [dh_responder sk pk] takes a 32-byte secret key [sk] and another party's 64-byte public
      key and returns the 64-byte ECDH shared key. *)

  (** {1:ecdsa ECDSA}
      ECDSA signing and signature verification functions

      For the [sign] and [verify] functions included in this module
      [msg] is the digest of the message to be signed, requiring users to use a cryptographic hash function
      of their choosing before calling them. In this case, [msg] needs to be at least 32 bytes long.
  *)

  include ECDSA

  (** The functions in the other submodules take the unhashed message [msg] and first hash it using their corresponding
      version of the SHA-2 hash function. In this case, there is no minimum size requirement for [msg]. *)

  module SHA2_256 : ECDSA
  module SHA2_384 : ECDSA
  module SHA2_512 : ECDSA

  (** Versions of these functions which write their output in a buffer passed in as
      an argument *)
  module Noalloc : sig

    (** {1 Point representation and conversions} *)

    val raw_to_compressed : p:bytes -> result:bytes -> unit
    (** [raw_to_compressed p result] converts a "raw" point [p] (64 bytes) to a "compressed" point [result] (33 bytes) *)

    val raw_to_uncompressed : p:bytes -> result:bytes -> unit
    (** [raw_to_uncompressed p result] converts a "raw" point [p] (64 bytes) to an "uncompressed" point [result] (65 bytes) *)

    val compressed_to_raw : p:bytes -> result:bytes -> bool
    (** [compressed_to_raw p result] converts a "compressed" point [p] (33 bytes) to a "raw" point [result] (64 bytes).
        Returns true if successful. *)

    val uncompressed_to_raw : p:bytes -> result:bytes -> bool
    (** [uncompressed_to_raw p result] converts an "uncompressed" point [p] (65 bytes) to a "raw" point [result] (64 bytes).
        Returns true if successful. *)

    (** {1 ECDH}
        ECDH key agreement protocol
    *)

    val dh_initiator : sk:bytes -> pk:bytes -> bool
    (** [dh_initiator sk pk] takes a 32-byte secret key [sk] and writes the corresponding
        64-byte public key in [pk]. *)

    val dh_responder : sk:bytes -> pk:bytes -> shared:bytes -> bool
    (** [dh_responder sk pk shared] takes a 32-byte secret key [sk] and another party's 64-byte public
        key and writes the 64-byte ECDH shared key in [shared]. Buffer [shared] must be distinct from
        [pk]. *)
  end

end
(** ECDSA and ECDH functions using P-256 *)


(** {1 Hashing } *)
(** {2 SHA-2}

    Portable C implementations of SHA-2.
    Multiplexing interfaces for {{!EverCrypt.SHA2_224}SHA-224} and {{!EverCrypt.SHA2_256}SHA-256} are also available.
*)

module SHA2_224 : HashFunction
(** Direct hashing with SHA-224

The [digest] buffer must match the digest size of SHA-224, which is 28 bytes.
*)

module SHA2_256 : HashFunction
(** Direct hashing with SHA-256

The [digest] buffer must match the digest size of SHA-256, which is 32 bytes.
*)


module SHA2_384 : HashFunction
(** Direct hashing with SHA-384

The [digest] buffer must match the digest size of SHA-384, which is 48 bytes.
*)


module SHA2_512 : HashFunction
(** Direct hashing with SHA-512

The [digest] buffer must match the digest size of SHA-512, which is 64 bytes.
*)



(** {2 SHA-3}

    Portable C implementations of SHA-3
*)

module SHA3_224 : HashFunction
(** Direct hashing with SHA3-224

The [digest] buffer must match the digest size of SHA3-224, which is 28 bytes.
*)

module SHA3_256 : HashFunction
(** Direct hashing with SHA3-256

The [digest] buffer must match the digest size of SHA3-256, which is 32 bytes.
*)

module SHA3_384 : HashFunction
(** Direct hashing with SHA3-384

The [digest] buffer must match the digest size of SHA3-384, which is 48 bytes.
*)

module SHA3_512 : HashFunction
(** Direct hashing with SHA3-512

The [digest] buffer must match the digest size of SHA3-512, which is 64 bytes.
*)

module Keccak : sig
  val shake128 : msg:bytes -> size:int -> bytes
  (** [shake128 msg size] hashes [msg] using SHAKE-128 and returns a digest of [size] bytes. *)

  val shake256 : msg:bytes -> size:int -> bytes
  (** [shake256 msg size] hashes [msg] using SHAKE-256 and returns a digest of [size] bytes. *)

  val keccak : rate:int -> capacity:int -> suffix:int -> msg:bytes -> size:int -> bytes
  (** Direct access to the general Keccak function, of which all the SHA-3 and SHAKE functions
      are {{:https://en.wikipedia.org/wiki/SHA-3#Instances}instances}. While the library
      does run some sanity checks for the parameters, users should be extremely careful
      if using the Keccak function directly. *)

  (** Versions of these functions which write their output in a buffer passed in as
      an argument *)
  module Noalloc : sig
    val shake128 : msg:bytes -> digest:bytes -> unit
    (** [shake128 msg size] hashes [msg] using SHAKE-128 and returns a digest of [size] bytes. *)

    val shake256 : msg:bytes -> digest:bytes -> unit
    (** [shake256 msg digest] hashes [msg] using SHAKE-256 and outputs the result in [digest]. *)

    val keccak : rate:int -> capacity:int -> suffix:int -> msg:bytes -> digest:bytes -> unit
    (** Direct access to the general Keccak function, of which all the SHA-3 and SHAKE functions
        are {{:https://en.wikipedia.org/wiki/SHA-3#Instances}instances}. While the library
        does run some sanity checks for the parameters, users should be extremely careful
        if using the Keccak function directly. *)
  end
end
(** SHAKE-128, SHAKE-256, and the general Keccak function

    Contrary to other Keccak/SHA-3 variants, SHAKE-128 and SHAKE-256 produce digests of
    any size. When calling these functions, it will correspond to the size of the [digest] buffer.
*)

(** {2:blake2 BLAKE2}
    The BLAKE2 hash function has 2 variants:
    - BLAKE2b, optimised for 64-bit architectures
    - BLAKE2s, optimised for 8- to 32-bit architectures
*)

module Blake2b_32 : Blake2
(** Portable BLAKE2b implementation *)

module Blake2b_256 : Blake2
(** Vectorized BLAKE2b implementation, requiring {{!AutoConfig2.VEC256} 256-bit vector support} *)

module Blake2s_32 : Blake2
(** Portable BLAKE2s implementation *)

module Blake2s_128 : Blake2
(** Vectorized BLAKE2s implementation, requiring {{!AutoConfig2.VEC128} 128-bit vector support} *)

(** {2 Legacy (deprecated)}
Legacy algorithms, which are {b not suitable for cryptographic applications.} *)

module MD5 : HashFunction [@@deprecated]
(** Direct hashing with MD5

{b This function should not be used for cryptographic applications!}

The [digest] buffer must match the digest size of MD5, which is 16 bytes. *)

module SHA1 : HashFunction [@@deprecated]
(** Direct hashing with SHA-1

{b This function should not be used for cryptographic applications!}

The [digest] buffer must match the digest size of SHA-1, which is 20 bytes. *)


(** {1 MACs}
Message authentication codes

{{!mac}Multiplexing interfaces} for these algorithms are also available.
*)

(** {2 HMAC} *)

module HMAC_SHA2_256 : MAC
(** Portable C implementation of HMAC-SHA-256 *)

module HMAC_SHA2_384 : MAC
(** Portable C implementation of HMAC-SHA-384 *)

module HMAC_SHA2_512 : MAC
(** Portable C implementation of HMAC-SHA-512 *)

module HMAC_BLAKE2b : MAC
(** Portable C implementation of HMAC-BLAKE2b *)

module HMAC_BLAKE2s : MAC
(** Portable C implementation of HMAC-BLAKE2s *)


(** {2 Poly1305} *)

module Poly1305_32 : MAC
(** Portable C implementation of Poly1305 *)

module Poly1305_128 : MAC
(** Vectorized C implementation of Poly1305 that runs on platforms with {{!AutoConfig2.VEC128} 128-bit vector support} *)

module Poly1305_256 : MAC
(** Vectorized C implementation of Poly1305 that runs on platforms with {{!AutoConfig2.VEC256} 256-bit vector support} *)


(** {1 NaCl } *)

module NaCl : sig
  val box_beforenm : pk:bytes -> sk:bytes -> bytes option
  (** [box_beforenm pk sk] precomputes a 32-byte {{!section:curve}X25519 shared key} [ck] using one party's
      32-byte public key [pk] and the other party's 32-byte secret key [sk]. The shared key
      can then be used in the Box precomputation interface ([box_afternm] and [box_open_afternm] functions)
      in both {!Easy} and {!Detached}.

      This is useful when calling the functions repeatedly, as it avoids computing the
      shared key on every function call.
  *)

  val box_beforenm_noalloc : pk:bytes -> sk:bytes -> ck:bytes -> bool
  (** [box_beforenm_noalloc pk sk ck] is a version of [box_beforenm] which takes an additional argument [ck]
      where the result is written, returning `true` if it is successful, similar to the functions in
      {!NaCl.Easy.Noalloc} and {!NaCl.Detached}.

      Buffers [pk], [sk], and [ck] must be distinct.
  *)

  module Easy : sig
    (** {1 Box}
        {2 One-shot interface} *)

    val box : pt:bytes -> n:bytes -> pk:bytes -> sk:bytes -> bytes option
    (** [box pt n pk sk] authenticates and encrypts plaintext [pt] using public key [pk],
        secret key [sk], and nonce [n] and returns both the message authentication tag
        and the ciphertext in a single buffer if successful. *)

    val box_open : ct:bytes -> n:bytes -> pk:bytes -> sk:bytes -> bytes option
    (** [box_open ct n pk sk] attempts to verify and decrypt ciphertext [ct] using public key [pk],
        secret key [sk], and nonce [n] and returns the plaintext if successful. *)

    (** {2 Precomputation interface }
        The shared key [ck] is obtained using {!NaCl.box_beforenm}. *)

    val box_afternm : pt:bytes -> n:bytes -> ck:bytes -> bytes option
    (** [box_afternm pt n ck] authenticates and encrypts [pt] using shared key [ck] and
        nonce [n] and returns both the message authentication tag and the ciphertext
        in a single buffer if successful. *)

    val box_open_afternm : ct:bytes -> n:bytes -> ck:bytes -> bytes option
    (** [box_open ct n pk sk] attempts to verify and decrypt ciphertext [ct] using
        shared key [ck] and nonce [n] and returns the plaintext if successful. *)

    (** {1 Secretbox} *)

    val secretbox : pt:bytes -> n:bytes -> key:bytes -> bytes option
    (** [secretbox pt n key] authenticates and encrypts plaintext [pt] using
        secret key [key] and nonce [n] and returns both the message authentication tag
        and the ciphertext in a single buffer if successful. *)

    val secretbox_open : ct:bytes -> n:bytes -> key:bytes -> bytes option
    (** [secretbox_open ct n key] attempts to verify and decrypt ciphertext [ct] using
        secret key [key] and nonce [n] and returns the plaintext if successful. *)

    (** {1 Noalloc} *)

    (** Versions of these functions which write their output in a buffer passed in as
        an argument

        Buffers have the following size requirements:
        - [ct] must be 16 bytes longer than [pt] to also include the message
        authentication tag
        - [pk], [sk], [ck]: 32 bytes
        - [n]: 24 bytes
    *)
    module Noalloc : sig
    (** {1 Box}
        {2 One-shot interface} *)

      val box : pt:bytes -> n:bytes -> pk:bytes -> sk:bytes -> ct:bytes -> bool
      (** [box pt n pk sk ct] authenticates and encrypts plaintext [pt] using public key [pk],
          secret key [sk], and nonce [n] and writes both the message authentication tag
          and the ciphertext in [ct].
          Returns true if successful. *)

      val box_open : ct:bytes -> n:bytes -> pk:bytes -> sk:bytes -> pt:bytes -> bool
      (** [box_open ct n pk sk pt] attempts to verify and decrypt ciphertext [ct] using public key [pk],
          secret key [sk], and nonce [n] and if successful writes the plaintext in [pt]
          and returns true. *)

      (** {2 Precomputation interface }
          The shared key [ck] is obtained using {!NaCl.box_beforenm} or {!NaCl.box_beforenm_noalloc}. *)

      val box_afternm : pt:bytes -> n:bytes -> ck:bytes -> ct:bytes -> bool
      (** [box_afternm pt n ck ct] authenticates and encrypts [pt] using shared key [ck] and
          nonce [n] and writes both the message authentication tag and the ciphertext in [ct].
          Returns true if successful. *)

      val box_open_afternm : ct:bytes -> n:bytes -> ck:bytes -> pt:bytes -> bool
      (** [box_open ct n pk sk pt] attempts to verify and decrypt ciphertext [ct] using
          shared key [ck] and nonce [n] and if successful writes the plaintext in [pt]
          and returns true. *)

      (** {1 Secretbox} *)

      val secretbox : pt:bytes -> n:bytes -> key:bytes -> ct:bytes -> bool
      (** [secretbox pt n key ct] authenticates and encrypts plaintext [pt] using
          secret key [key] and nonce [n] and writes both the message authentication tag
          and the ciphertext in [ct].
          Returns true if successful. *)

      val secretbox_open : ct:bytes -> n:bytes -> key:bytes -> pt:bytes -> bool
      (** [secretbox_open ct n key pt] attempts to verify and decrypt ciphertext [ct] using
          secret key [key] and nonce [n] and if successful writes the plaintext in [pt]
          and returns true. *)
    end
  end
  (** The {i easy} interface concatenates the ciphertext and the 16-byte long message
      authentication tag into a single buffer.

      Buffers have the following size requirements:
      - [ct]: at least 16 bytes
      - [pk], [sk], [ck]: 32 bytes
      - [n]: 24 bytes
*)

  module Detached : sig
    (** {1 Box}
        {2 One-shot interface} *)

    val box : pt:bytes -> n:bytes -> pk:bytes -> sk:bytes -> ct:bytes -> tag:bytes -> bool
    (** [box pt n pk sk ct tag] authenticates and encrypts plaintext [pt] using public key [pk],
        secret key [sk], and nonce [n] and writes the ciphertext in [ct] and
        the message authentication tag in [tag].
        Returns true if successful. *)

    val box_open : ct:bytes -> tag:bytes -> n:bytes -> pk:bytes -> sk:bytes -> pt:bytes -> bool
    (** [box_open ct tag n pk sk pt] attempts to verify and decrypt ciphertext [ct] and
        message authentication tag [tag] using public key [pk],
        secret key [sk], and nonce [n] and if successful writes the plaintext in [pt]
        and returns true. *)

    (** {2 Precomputation interface }
        The shared key [ck] is obtained using {!NaCl.box_beforenm}. *)

    val box_afternm : pt:bytes -> n:bytes -> ck:bytes -> ct:bytes -> tag:bytes -> bool
    (** [box_afternm pt n ck ct tag] authenticates and encrypts [pt] using shared key [ck] and
        nonce [n] and writes the ciphertext in [ct] and the message authentication tag in [tag].
        Returns true if successful. *)

    val box_open_afternm : ct:bytes -> tag:bytes -> n:bytes -> ck:bytes -> pt:bytes -> bool
    (** [box_open_afternm ct tag n ck pt] attempts to verify and decrypt ciphertext [ct] and
        message authentication tag [tag] using
        shared key [ck] and nonce [n] and if successful writes the plaintext in [pt]
        and returns true. *)

    (** {1 Secretbox} *)

    val secretbox : pt:bytes -> n:bytes -> key:bytes -> ct:bytes -> tag:bytes -> bool
    (** [secretbox pt n key ct tag] authenticates and encrypts plaintext [pt] using
        secret key [key] and nonce [n] and writes the ciphertext in [ct]
        and the message authentication tag in [tag].
        Returns true if successful. *)

    val secretbox_open : ct:bytes -> tag:bytes -> n:bytes -> key:bytes -> pt:bytes -> bool
    (** [secretbox_open ct tag n key pt] attempts to verify and decrypt ciphertext [ct] and
        message authentication tag [tag] using
        secret key [key] and nonce [n] and if successful writes the plaintext in [pt]
        and returns true. *)
  end
  (** The {i detached} interface uses 2 separate buffers for the ciphertext and
      the message authentication tag. This allows users to encrypt and decrypt data in-place,
      by passing the same buffer for both plaintext and ciphertext.

      Buffers have the following size requirements:
      - [tag]: 16 bytes
      - [pk], [sk], [ck]: 32 bytes
      - [n]: 24 bytes
  *)
end
(** Box (public-key authenticated encryption) and Secretbox (secret-key authenticated encryption)

    Portable C implementations offering both the {i easy} and {i detached} interfaces of Box and Secretbox.
    For Box, the {i precomputation interface} is also supported.
*)

(** {1 Key derivation} *)
(** {2 HKDF}
    HMAC-based key derivation function

    Portable implementations of HKDF.
    {{!EverCrypt.hkdf} Agile and multiplexing interfaces} are also available.
*)

module HKDF_SHA2_256 : HKDF
(** Portable C implementation of HKDF using SHA2-256 *)

module HKDF_SHA2_512 : HKDF
(** Portable C implementation of HKDF using SHA2-512 *)

module HKDF_BLAKE2b : HKDF
(** Portable C implementation of HKDF using BLAKE2b *)

module HKDF_BLAKE2s : HKDF
(** Portable C implementation of HKDF using BLAKE2s *)

(** {1 Randomness (not verified)} *)

module RandomBuffer : sig
  val randombytes : size:int -> bytes option
  (** [randombytes size] attempts to create a buffer containing [size] random bytes *)

  val randombytes_noalloc : out:bytes -> bool
  (** [randombytes_noalloc out] attempts to fill [out] with random bytes and returns true if successful. *)


end
(** A randomness function implemented with platform-dependent code for Unix and Windows

    The [randombytes] function is handwritten, unverified C code.
    In Unix, it is implemented using the {{: https://man7.org/linux/man-pages/man2/getrandom.2.html} [getrandom]} syscall, with a fallback to [/dev/urandom].
    In Windows, it is implemented using {{: https://docs.microsoft.com/en-us/windows/win32/api/wincrypt/nf-wincrypt-cryptgenrandom} [CryptGenRandom]}.
*)
