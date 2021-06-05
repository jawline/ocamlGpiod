open Core

exception InvalidFunction of string

let sprintf = Printf.sprintf;;

let from_value_type name arg_type = match arg_type with
  | "int" -> sprintf "Int_val(%s)" name
  | "bool" -> sprintf "Bool_val(%s)" name
  | "char*" -> sprintf "String_val(%s)" name
  | _ -> if String.is_suffix arg_type ~suffix:"*" then sprintf "((%s) ptr_of_val(%s))" arg_type name else raise (InvalidFunction (sprintf "Could not match %s" arg_type))
;;

let to_value_type name arg_type = match arg_type with
  | "int" -> sprintf "Val_int(%s)" name
  | "bool" -> sprintf "Val_bool(%s)" name
  | "char*" -> sprintf "caml_copy_string(%s)" name
  | _ -> if String.is_suffix arg_type ~suffix:"*" then sprintf "val_of_ptr(%s)" name else raise (InvalidFunction (sprintf "Could not to_value %s" arg_type))
;;

let generate_function_binding name arguments return_type =
  let inp_arguments = List.map arguments ~f:(fun x -> let (_, name) = x in sprintf "value %s" name) in
  let inp_arguments = String.concat ~sep:", " inp_arguments in
  let conv_args = List.map arguments ~f:(fun x -> let (arg_type, name) = x in from_value_type name arg_type) in
  let conv_args = String.concat ~sep:", " conv_args in
  let call_fn = sprintf "%s(%s)" name conv_args in
  let body = to_value_type call_fn return_type in
  sprintf "value ocaml_%s(%s) { %s }" name inp_arguments body
;;

let read_header_file filepath =
  let lines = In_channel.read_lines filepath in
  let rec print_lines = function
    | [] -> ()
    | (x::xs) -> (printf "%s" x; print_lines xs)
  in print_lines lines
;;

read_header_file "/home/blake/libgpiod_ocaml/libgpiod/include/gpiod.h";;
