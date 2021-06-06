open Core

exception InvalidFunction of string

let printf = Printf.printf
let sprintf = Printf.sprintf

let prelude =
  "#include <gpiod.h>\n\
   #include <assert.h>\n\
   #include <errno.h>\n\
   #include <string.h>\n\
   #include <stdio.h>\n\
   #include <caml/mlvalues.h>\n\
   #include <caml/memory.h>\n\
   #include <caml/alloc.h>\n\
   #include <caml/fail.h>\n\n\
   static value val_of_ptr(void* p)\n\
   {\n\
  \  return caml_copy_nativeint((intnat) p);\n\
   }\n\n\
   static void* ptr_of_val(value v) {\n\
  \  return (void *) Nativeint_val(v);\n\
   }\n"
;;

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
  | "void" -> "unit"
  | "int" -> "int"
  | "unsigned int" -> "int"
  | "bool" -> "bool"
  | "size_t" -> "nativeint"
  | "char *" | "const char *" | "char const *" -> "string"
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
  let inp_arguments =
    if List.length inp_arguments = 0 then [ "value unused_unit" ] else inp_arguments
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
  let matcher =
    Re.Pcre.regexp "^\\s*([a-zA-Z0-9_ ]*?[\\s*])([a-zA-Z][a-zA-Z0-9_]*)[(](.*)[)]"
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
  String.concat
    ~sep:" -> "
    (List.map
       (List.append args [ return_type, "return" ])
       ~f:(fun x ->
         let ctype, _ = x in
         to_ocaml_typename ctype))
;;

let process_identified_method out_file out_ml function_parts arguments =
  let return_type = String.strip (Array.get function_parts 1) in
  let function_name = String.strip (Array.get function_parts 2) in
  printf "Generating binding for %s\n" function_name;
  let generated_fn = generate_function_binding function_name arguments return_type in
  Printf.fprintf out_file "%s\n" generated_fn;
  let arguments =
    if List.length arguments = 0 then [ "void", "unit_arg" ] else arguments
  in
  Printf.fprintf
    out_ml
    "external %s : %s = \"ocaml_%s\"\n"
    (strip_gpiod function_name)
    (as_ocaml_type_signature arguments return_type)
    function_name
;;

let process_header_line out_file out_ml line =
  let line_match = test_line line in
  match line_match with
  | Some fn ->
    (try
       let arguments = extract_arguments (Array.get fn 3) in
       if List.length arguments > 5
       then raise (InvalidFunction "too many arguments")
       else process_identified_method out_file out_ml fn arguments
     with
    | InvalidFunction x ->
      printf "Could not synthesize bindings for %s because %s\n" (Array.get fn 2) x;
      ())
  | _ -> ()
;;

let rec process_header_lines out_file out_ml = function
  | [] -> ()
  | line :: remaining_lines ->
    process_header_line out_file out_ml line;
    process_header_lines out_file out_ml remaining_lines
;;

let process_header_file filepath output_c output_ml =
  printf "Launching in %s\n" (Sys.getcwd ());
  let out_file = Out_channel.create output_c in
  let out_ml = Out_channel.create output_ml in
  let header = In_channel.read_all filepath in
  let lines = split_header_at_functions header in
  Printf.fprintf out_file "%s" prelude;
  Printf.fprintf out_ml "let is_null (x: nativeint): bool = x = Nativeint.zero;;\n";
  process_header_lines out_file out_ml lines
;;

;;
process_header_file "/usr/include/gpiod.h" "gpiod_stubs.c" "gpiod.ml"
