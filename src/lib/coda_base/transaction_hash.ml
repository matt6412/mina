open Core_kernel

module T = struct
  include Blake2.Make ()
end

include T

module Base58_check = Codable.Make_base58_check (struct
  type t = Stable.Latest.t [@@deriving bin_io_unversioned, compare]

  let version_byte = Base58_check.Version_bytes.transaction_hash

  let description = "Transaction Hash"
end)

[%%define_locally
Base58_check.(of_base58_check, of_base58_check_exn, to_base58_check)]

let to_yojson t = `String (to_base58_check t)

let of_yojson = function
  | `String str ->
      Result.map_error (of_base58_check str) ~f:(fun _ ->
          "Transaction_hash.of_yojson: Error decoding string from \
           base58_check format" )
  | _ ->
      Error "Transaction_hash.of_yojson: Expected a string"

let hash_command = Fn.compose digest_string Command_transaction.to_base58_check

let hash_fee_transfer =
  Fn.compose digest_string Fee_transfer.Single.to_base58_check

let hash_coinbase = Fn.compose digest_string Coinbase.to_base58_check

module Command_transaction_with_valid_signature = struct
  type hash = T.t [@@deriving sexp, compare, hash]

  let hash_to_yojson = to_yojson

  let hash_of_yojson = of_yojson

  [%%versioned
  module Stable = struct
    module V1 = struct
      type t =
        ( (Command_transaction.Valid.Stable.V1.t[@hash.ignore])
        , (T.Stable.V1.t[@to_yojson hash_to_yojson]) )
        With_hash.Stable.V1.t
      [@@deriving sexp, hash, to_yojson]

      let to_latest = Fn.id

      (* Compare only on hashes, comparing on the data too would be slower and
         add no value.
      *)
      let compare (x : t) (y : t) = T.compare x.hash y.hash
    end
  end]

  let create (c : Command_transaction.Valid.t) : t =
    {data= c; hash= hash_command (Command_transaction.forget_check c)}

  let data ({data; _} : t) = data

  let command ({data; _} : t) = Command_transaction.forget_check data

  let hash ({hash; _} : t) = hash

  let forget_check ({data; hash} : t) =
    {With_hash.data= Command_transaction.forget_check data; hash}

  include Comparable.Make (Stable.Latest)
end

module Command_transaction = struct
  type hash = T.t [@@deriving sexp, compare, hash]

  let hash_to_yojson = to_yojson

  let hash_of_yojson = of_yojson

  [%%versioned
  module Stable = struct
    module V1 = struct
      type t =
        ( (Command_transaction.Stable.V1.t[@hash.ignore])
        , (T.Stable.V1.t[@to_yojson hash_to_yojson]) )
        With_hash.Stable.V1.t
      [@@deriving sexp, hash, to_yojson]

      let to_latest = Fn.id

      (* Compare only on hashes, comparing on the data too would be slower and
         add no value.
      *)
      let compare (x : t) (y : t) = T.compare x.hash y.hash
    end
  end]

  let create (c : Command_transaction.t) : t = {data= c; hash= hash_command c}

  let data ({data; _} : t) = data

  let command ({data; _} : t) = data

  let hash ({hash; _} : t) = hash

  include Comparable.Make (Stable.Latest)
end
