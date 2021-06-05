open Printf

let gpio_test_version_str =
  printf "preparing call\n";
  let s = (Gpiod.gpiod_version_string ()) in
  printf "done %s\n" s
;;

let () = gpio_test_version_str ;;
