open Core

exception InvalidFunction of string

let ml_prelude = "open Ctypes

module Stubs (F : Ctypes.FOREIGN) = struct
  open F
";;

let ml_suffix =
"end";;

let from_value_type name arg_type =
  match arg_type with
  | "int" -> sprintf "Int_val(%s)" name
  | "unsigned int" -> sprintf "Int_val(%s)" name
  | "bool" -> sprintf "Bool_val(%s)" name
  | "char *" | "const char *" | "char const *" -> sprintf "String_val(%s)" name
  | _ ->
    if String.is_suffix arg_type ~suffix:"*"
    then sprintf "((%s) ptr_of_val(%s))" arg_type name
    else raise (InvalidFunction (sprintf "Could not match %s" arg_type))
;;

let to_value_type name arg_type =
  match arg_type with
  | "void" -> sprintf "Val_unit"
  | "int" -> sprintf "Val_int(%s)" name
  | "size_t" -> sprintf "caml_copy_nativeint((intnat) %s)" name
  | "unsigned int" -> sprintf "Val_int(%s)" name
  | "bool" -> sprintf "Val_bool(%s)" name
  | "char *" | "const char *" | "char const *" -> sprintf "caml_copy_string(%s)" name
  | _ ->
    if String.is_suffix arg_type ~suffix:"*"
    then sprintf "val_of_ptr((void *)%s)" name
    else raise (InvalidFunction (sprintf "Could not to_value %s" arg_type))
;;

let to_ocaml_typename arg_type =
  match arg_type with
  | "void" -> "void"
  | "int" -> "int"
  | "unsigned int" -> "int"
  | "bool" -> "bool"
  | "size_t" -> "nativeint"
  | "char *" | "const char *" | "char const *" -> "string_opt"
  | _ ->
    if String.is_prefix ~prefix:"struct" arg_type && String.is_suffix ~suffix:"*" arg_type
    then sprintf "ptr_opt %s" (String.strip (String.drop_suffix (String.drop_prefix arg_type 6) 1))
    else raise (InvalidFunction (sprintf "Could not to_ocaml_typename '%s'" arg_type))
;;

let rec matches_chr chr t =
  match chr with
  | [] -> false
  | x :: _ when Char.( = ) x t -> true
  | _ :: xs -> matches_chr xs t
;;

let rec split_inclusive chr = function
  | [] -> [], []
  | x :: xs when matches_chr chr x -> [ x ], xs
  | x :: xs ->
    let before_split, after_split = split_inclusive chr xs in
    x :: before_split, after_split
;;

let rec full_split chr xs =
  let split_header, xs = split_inclusive chr xs in
  match xs with
  | [] -> [ split_header ]
  | xs -> split_header :: full_split chr xs
;;

let rec remove_tabs xs =
  match xs with
  | [] -> []
  | '\t' :: xs -> remove_tabs xs
  | x :: xs -> x :: remove_tabs xs
;;

let rec remove_double_spaces xs =
  match xs with
  | [] -> []
  | ' ' :: ' ' :: xs -> remove_double_spaces (' ' :: xs)
  | x :: xs -> x :: remove_double_spaces xs
;;

let scan_line_for_function_definition line =
  let matcher =
    Re.Pcre.regexp "^\\s*([a-zA-Z0-9_ ]*?[\\s*])([a-zA-Z][a-zA-Z0-9_]*)[(](.*)[)]"
  in
  let matched = Re.exec_opt matcher line in
  match matched with
  | Some matched -> Some (Re.Group.all matched)
  | _ -> None
;;

let scan_line_for_struct_definition line =
  let matcher =
    Re.Pcre.regexp "struct\\s+([a-zA-Z0-9_ ]*)\\s*[;{]"
  in
  let matched = Re.exec_opt matcher line in
  match matched with
  | Some matched -> Some (Re.Group.all matched)
  | _ -> None
;;

let strip_gpiod xs =
  let gpiod_prefix = "gpiod_" in
  if String.is_prefix ~prefix:gpiod_prefix xs
  then String.drop_prefix xs (String.length gpiod_prefix)
  else xs
;;

let extract_arguments args_str =
  if String.( = ) (String.strip args_str) "void"
  then []
  else (
    let unprocessed_list = String.split_on_chars ~on:[ ',' ] args_str in
    List.map unprocessed_list ~f:(fun arg_item ->
        match String.rsplit2 arg_item ~on:'*' with
        | Some v ->
          let l, r = v in
          String.strip (String.concat [ l; "*" ]), String.strip r
        | _ ->
          let l, r = String.rsplit2_exn arg_item ~on:' ' in
          String.strip l, String.strip r))
;;

let split_header_at_functions header =
  let header = String.filter header ~f:(fun x -> not (Char.( = ) x '\n')) in
  let header = String.to_list header in
  let header = remove_tabs header in
  let header = remove_double_spaces header in
  List.map ~f:(fun x -> String.of_char_list x) (full_split [ ';'; '/' ] header)
;;

let as_ocaml_type_signature args return_type =
  let args =
    if List.length args = 0 then [ "void", "unit_arg" ] else args
  in
  let signature_parts = List.map args ~f:(fun x ->
    let ctype, _ = x in
    to_ocaml_typename ctype
  ) in
  let signature_parts = List.concat [signature_parts; [sprintf "(returning (%s))" (to_ocaml_typename return_type)]] in
  String.concat
    ~sep:" @-> "
    signature_parts
;;

let process_identified_method out_ml function_parts arguments =
  let return_type = String.strip (Array.get function_parts 1) in
  let function_name = String.strip (Array.get function_parts 2) in
  fprintf
    out_ml
    "let %s = foreign \"%s\" (%s)\n\n"
    (strip_gpiod function_name)
    function_name
    (as_ocaml_type_signature arguments return_type)
;;

let process_header_line seen_names out_ml line =
  match scan_line_for_function_definition line with
  | Some fn ->
    (try
       let arguments = extract_arguments (Array.get fn 3) in
       process_identified_method out_ml fn arguments
     with
    | InvalidFunction x ->
      printf "Could not synthesize bindings for %s because %s\n" (Array.get fn 2) x;
      ())
  | _ -> (
    match scan_line_for_struct_definition line with
    | Some parts ->
      let struct_name = String.strip (Array.get parts 1) in
      if not (Hash_set.mem seen_names struct_name) then (
        fprintf out_ml "type %s\nlet %s : %s structure typ = structure \"%s\"\n\n" struct_name struct_name struct_name struct_name;
        Hash_set.add seen_names struct_name;
        ()
      ) else (
        printf "Saw %s twice\n" struct_name
      )
    | _ -> ()
  )
;;

let rec process_header_lines seen_names out_ml = function
  | [] -> ()
  | line :: remaining_lines ->
    process_header_line seen_names out_ml line;
    process_header_lines seen_names out_ml remaining_lines
;;

let process_header_file filepath output_ml =
  printf "Launching in %s\n" (Sys.getcwd ());
  let out_ml = Out_channel.create output_ml in
  let header = In_channel.read_all filepath in
  let lines = split_header_at_functions header in
  fprintf out_ml "%s" ml_prelude;
  process_header_lines (Hash_set.create (module String)) out_ml lines;
  fprintf out_ml "%s" ml_suffix
;;

let c_headers = "#include <gpiod.h>\n"

let main () =
  process_header_file "/usr/include/gpiod.h" "gpiod_bindings.ml"

let () = main ()
