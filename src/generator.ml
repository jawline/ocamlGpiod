open Core

exception InvalidFunction of string

let sprintf = Printf.sprintf

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
  | "void" -> "()"
  | "int" -> "int"
  | "unsigned int" -> "int"
  | "bool" -> "bool"
  | "char *" | "const char *" | "char const *"  -> "string"
  | _ ->
    if String.is_suffix arg_type ~suffix:"*"
    then "nativeint"
    else raise (InvalidFunction (sprintf "Could not to_ocaml_typename '%s'" arg_type))
;;

let generate_function_binding name arguments return_type =
  let inp_arguments =
    List.map arguments ~f:(fun x ->
        let _, name = x in
        sprintf "value %s" name)
  in
  let inp_arguments = String.concat ~sep:", " inp_arguments in
  let conv_args =
    List.map arguments ~f:(fun x ->
        let arg_type, name = x in
        from_value_type name arg_type)
  in
  let conv_args = String.concat ~sep:", " conv_args in
  let call_fn = sprintf "%s(%s)" name conv_args in
  let body = to_value_type call_fn return_type in
  sprintf "value ocaml_%s(%s) {\n\treturn %s;\n}\n" name inp_arguments body
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

let test_line line =
  let matcher = Re.Pcre.regexp "\\s*(.*?[\\s*])([a-zA-Z][a-zA-Z0-9_]*)[(](.*)[)];" in
  let matched = Re.exec_opt matcher line in
  match matched with
  | Some matched -> Some (Re.Group.all matched)
  | _ -> None
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

let process_header_file preamble_file filepath output_c output_ml =
  printf "Starting to read\n";
  let out_file = Out_channel.create output_c in
  let out_ml = Out_channel.create output_ml in
  let prelude = In_channel.read_all preamble_file in
  Printf.fprintf out_file "%s" prelude;
  let lines = In_channel.read_all filepath in
  let lines = String.filter lines ~f:(function x -> not (Char.( = ) x '\n')) in
  let lines = String.to_list lines in
  let lines = remove_tabs lines in
  let lines = remove_double_spaces lines in
  let lines =
    List.map ~f:(fun x -> String.of_char_list x) (full_split [ ';'; '/' ] lines)
  in
  let rec do_lines = function
    | [] -> ()
    | x :: xs ->
      let line_match = test_line x in
      (match line_match with
      | Some fn ->
        (try (
           (* printf "Parts %s %s %s\n" (Array.get fn 1) (Array.get fn 2) (Array.get fn 3); *)
           let processed_arguments = extract_arguments (Array.get fn 3) in
           let generated_fn =
             generate_function_binding
               (String.strip (Array.get fn 2))
               processed_arguments
               (String.strip (Array.get fn 1))
           in
           Printf.fprintf out_file "%s\n" generated_fn;
           let ocaml_args = List.map (List.append processed_arguments [(String.strip (Array.get fn 1), "return")]) ~f:(fun x -> let ctype, _ = x in to_ocaml_typename ctype) in
           Printf.fprintf out_ml "external %s : %s = \"%s\"\n" (Array.get fn 2) (String.concat ~sep:" -> " ocaml_args) (Array.get fn 2)
        ) with
        | InvalidFunction x ->
          printf "Could not synthesize bindings for %s because %s\n" (Array.get fn 2) x;
          ())
      | _ -> ());
      (* printf "Continue %s\n" x; *)
      do_lines xs
  in
  do_lines lines
;;

;;
process_header_file
  "/home/blake/ocamlGpiod/src/ml_gpiod_prelude.c"
  "/home/blake/ocamlGpiod/libgpiod/include/gpiod.h"
  "/home/blake/ocamlGpiod/src/gpiod_stubs.c"
  "/home/blake/ocamlGpiod/src/gpiod.ml"
