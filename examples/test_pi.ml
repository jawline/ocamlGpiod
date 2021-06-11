open Printf

Printf.printf "Starting up\n";;

module Gpiod = Gpiod.Stubs(Gpiod_stubs);;

exception InternalError of string

let open_line chip nr =
  match Gpiod.chip_get_line (Some chip) nr with
  | Some v -> v
  | None -> raise (InternalError "Could not open a line")
;;

let gpio_test_pi () =
  printf "preparing call\n";
  let s = (Gpiod.version_string ()) in
  printf "done %s\n" s;
  let chip = match Gpiod.chip_open_by_name "gpiochip0" with
    | Some v -> v
    | None -> raise (InternalError "Could not open gpiochip0")
  in
  printf "Opening lines\n";
  let lineRed = open_line chip 24 in
  let lineYellow = open_line chip 25 in
  printf "Finished setting up\n";
  let _ = Gpiod.line_request_output (Some lineRed) "example1" 0 in
  let _ = Gpiod.line_request_output (Some lineYellow) "example1" 0 in
  let _ = Gpiod.line_set_value (Some lineRed) 1 in
  let _ = Gpiod.line_set_value (Some lineYellow) 1 in
  ()
;;

let () = gpio_test_pi () ;;
