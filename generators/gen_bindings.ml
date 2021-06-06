let c_headers =
  "\n\
   #include <gpiod.h>\n\
   #include <assert.h>\n\
   #include <errno.h>\n\
   #include <string.h>\n\
   #include <stdio.h>\n\
   #include <caml/mlvalues.h>\n\
   #include <caml/memory.h>\n\
   #include <caml/alloc.h>\n\
   #include <caml/fail.h>\n"
;;

let () =
  let mode = Sys.argv.(1) in
  let fname = Sys.argv.(2) in
  let oc = open_out_bin fname in
  let format = Format.formatter_of_out_channel oc in
  let fn =
    match mode with
    | "ml" -> Cstubs.write_ml
    | "c" ->
      Format.fprintf format "%s@\n" c_headers;
      Cstubs.write_c
    | _ -> assert false
  in
  fn
    ~concurrency:Cstubs.unlocked
    format
    ~prefix:"sys_socket"
    (module Sys_socket_stubs.Def);
  Format.pp_print_flush format ();
  close_out oc
;;
