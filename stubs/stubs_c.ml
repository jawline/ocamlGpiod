let c_headers = "#include <gpiod.h>\n";;

let main () =
  Printf.printf "Building C stubs\n";
  let stubs_out = open_out "libgpiod_stubs.c" in
  let stubs_fmt = Format.formatter_of_out_channel stubs_out in
  Format.fprintf stubs_fmt "%s@\n" c_headers;
  Cstubs_structs.write_c stubs_fmt (module Gpiod_bindings.Stubs);
  Format.pp_print_flush stubs_fmt ();
  close_out stubs_out
;;

let () = main ();
