open Printf

exception InternalError

let check r =
  if Gpiod.is_null r then raise InternalError
;;

let gpio_test_pi () =
  printf "preparing call\n";
  let s = (Gpiod.version_string ()) in
  printf "done %s\n" s;
  let chip = Gpiod.chip_open_by_name "gpiochip0" in
  check chip;
  let lineRed = Gpiod.chip_get_line chip 24 in
  let lineYellow = Gpiod.chip_get_line chip 25 in
  check lineRed;
  check lineYellow;
  printf "Finished setting up\n";
  let _ = Gpiod.line_request_output lineRed "example1" 0 in
  let _ = Gpiod.line_request_output lineYellow "example1" 0 in
  let _ = Gpiod.line_set_value lineRed 1 in
  let _ = Gpiod.line_set_value lineYellow 1 in
  ()
;;

let () = gpio_test_pi () ;;
