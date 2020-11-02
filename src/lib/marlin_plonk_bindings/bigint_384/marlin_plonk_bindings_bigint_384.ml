type t

external num_limbs : unit -> int = "caml_bigint_384_num_limbs"

external bytes_per_limb : unit -> int = "caml_bigint_384_bytes_per_limb"

external compare : t -> t -> int = "caml_bigint_384_compare"

external div : t -> t -> t = "caml_bigint_384_div"

external test_bit : t -> int -> bool = "caml_bigint_384_test_bit"

external print : t -> unit = "caml_bigint_384_print"

external to_string : t -> string = "caml_bigint_384_to_string"

external of_numeral : string -> int -> int -> t = "caml_bigint_384_of_numeral"

external of_decimal_string : string -> t = "caml_bigint_384_of_decimal_string"
