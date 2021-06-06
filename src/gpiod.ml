let gpio_is_null (x : nativeint) : bool = Nativeint.( = ) x 0

external gpiod_is_gpiochip_device : string -> bool = "ocaml_gpiod_is_gpiochip_device"
external gpiod_chip_open : string -> nativeint = "ocaml_gpiod_chip_open"
external gpiod_chip_ref : nativeint -> nativeint = "ocaml_gpiod_chip_ref"
external gpiod_chip_unref : nativeint -> unit = "ocaml_gpiod_chip_unref"
external gpiod_chip_get_name : nativeint -> string = "ocaml_gpiod_chip_get_name"
external gpiod_chip_get_label : nativeint -> string = "ocaml_gpiod_chip_get_label"
external gpiod_chip_get_num_lines : nativeint -> int = "ocaml_gpiod_chip_get_num_lines"
external gpiod_chip_get_line : nativeint -> int -> nativeint = "ocaml_gpiod_chip_get_line"

external gpiod_chip_get_lines
  :  nativeint
  -> nativeint
  -> int
  -> nativeint
  = "ocaml_gpiod_chip_get_lines"

external gpiod_chip_get_all_lines
  :  nativeint
  -> nativeint
  = "ocaml_gpiod_chip_get_all_lines"

external gpiod_chip_find_line : nativeint -> string -> int = "ocaml_gpiod_chip_find_line"
external gpiod_line_bulk_new : int -> nativeint = "ocaml_gpiod_line_bulk_new"
external gpiod_line_bulk_reset : nativeint -> unit = "ocaml_gpiod_line_bulk_reset"
external gpiod_line_bulk_free : nativeint -> unit = "ocaml_gpiod_line_bulk_free"

external gpiod_line_bulk_add_line
  :  nativeint
  -> nativeint
  -> int
  = "ocaml_gpiod_line_bulk_add_line"

external gpiod_line_bulk_get_line
  :  nativeint
  -> int
  -> nativeint
  = "ocaml_gpiod_line_bulk_get_line"

external gpiod_line_bulk_num_lines : nativeint -> int = "ocaml_gpiod_line_bulk_num_lines"
external gpiod_line_offset : nativeint -> int = "ocaml_gpiod_line_offset"
external gpiod_line_name : nativeint -> string = "ocaml_gpiod_line_name"
external gpiod_line_consumer : nativeint -> string = "ocaml_gpiod_line_consumer"
external gpiod_line_direction : nativeint -> int = "ocaml_gpiod_line_direction"
external gpiod_line_is_active_low : nativeint -> bool = "ocaml_gpiod_line_is_active_low"
external gpiod_line_bias : nativeint -> int = "ocaml_gpiod_line_bias"
external gpiod_line_is_used : nativeint -> bool = "ocaml_gpiod_line_is_used"
external gpiod_line_drive : nativeint -> int = "ocaml_gpiod_line_drive"
external gpiod_line_get_chip : nativeint -> nativeint = "ocaml_gpiod_line_get_chip"

external gpiod_line_request
  :  nativeint
  -> nativeint
  -> int
  -> int
  = "ocaml_gpiod_line_request"

external gpiod_line_request_input
  :  nativeint
  -> string
  -> int
  = "ocaml_gpiod_line_request_input"

external gpiod_line_request_output
  :  nativeint
  -> string
  -> int
  -> int
  = "ocaml_gpiod_line_request_output"

external gpiod_line_request_rising_edge_events
  :  nativeint
  -> string
  -> int
  = "ocaml_gpiod_line_request_rising_edge_events"

external gpiod_line_request_falling_edge_events
  :  nativeint
  -> string
  -> int
  = "ocaml_gpiod_line_request_falling_edge_events"

external gpiod_line_request_both_edges_events
  :  nativeint
  -> string
  -> int
  = "ocaml_gpiod_line_request_both_edges_events"

external gpiod_line_request_input_flags
  :  nativeint
  -> string
  -> int
  -> int
  = "ocaml_gpiod_line_request_input_flags"

external gpiod_line_request_output_flags
  :  nativeint
  -> string
  -> int
  -> int
  -> int
  = "ocaml_gpiod_line_request_output_flags"

external gpiod_line_request_rising_edge_events_flags
  :  nativeint
  -> string
  -> int
  -> int
  = "ocaml_gpiod_line_request_rising_edge_events_flags"

external gpiod_line_request_falling_edge_events_flags
  :  nativeint
  -> string
  -> int
  -> int
  = "ocaml_gpiod_line_request_falling_edge_events_flags"

external gpiod_line_request_both_edges_events_flags
  :  nativeint
  -> string
  -> int
  -> int
  = "ocaml_gpiod_line_request_both_edges_events_flags"

external gpiod_line_request_bulk
  :  nativeint
  -> nativeint
  -> nativeint
  -> int
  = "ocaml_gpiod_line_request_bulk"

external gpiod_line_request_bulk_input
  :  nativeint
  -> string
  -> int
  = "ocaml_gpiod_line_request_bulk_input"

external gpiod_line_request_bulk_output
  :  nativeint
  -> string
  -> nativeint
  -> int
  = "ocaml_gpiod_line_request_bulk_output"

external gpiod_line_request_bulk_rising_edge_events
  :  nativeint
  -> string
  -> int
  = "ocaml_gpiod_line_request_bulk_rising_edge_events"

external gpiod_line_request_bulk_falling_edge_events
  :  nativeint
  -> string
  -> int
  = "ocaml_gpiod_line_request_bulk_falling_edge_events"

external gpiod_line_request_bulk_both_edges_events
  :  nativeint
  -> string
  -> int
  = "ocaml_gpiod_line_request_bulk_both_edges_events"

external gpiod_line_request_bulk_input_flags
  :  nativeint
  -> string
  -> int
  -> int
  = "ocaml_gpiod_line_request_bulk_input_flags"

external gpiod_line_request_bulk_output_flags
  :  nativeint
  -> string
  -> int
  -> nativeint
  -> int
  = "ocaml_gpiod_line_request_bulk_output_flags"

external gpiod_line_request_bulk_rising_edge_events_flags
  :  nativeint
  -> string
  -> int
  -> int
  = "ocaml_gpiod_line_request_bulk_rising_edge_events_flags"

external gpiod_line_request_bulk_falling_edge_events_flags
  :  nativeint
  -> string
  -> int
  -> int
  = "ocaml_gpiod_line_request_bulk_falling_edge_events_flags"

external gpiod_line_request_bulk_both_edges_events_flags
  :  nativeint
  -> string
  -> int
  -> int
  = "ocaml_gpiod_line_request_bulk_both_edges_events_flags"

external gpiod_line_release : nativeint -> unit = "ocaml_gpiod_line_release"
external gpiod_line_release_bulk : nativeint -> unit = "ocaml_gpiod_line_release_bulk"
external gpiod_line_get_value : nativeint -> int = "ocaml_gpiod_line_get_value"

external gpiod_line_get_value_bulk
  :  nativeint
  -> nativeint
  -> int
  = "ocaml_gpiod_line_get_value_bulk"

external gpiod_line_set_value : nativeint -> int -> int = "ocaml_gpiod_line_set_value"

external gpiod_line_set_value_bulk
  :  nativeint
  -> nativeint
  -> int
  = "ocaml_gpiod_line_set_value_bulk"

external gpiod_line_set_config
  :  nativeint
  -> int
  -> int
  -> int
  -> int
  = "ocaml_gpiod_line_set_config"

external gpiod_line_set_config_bulk
  :  nativeint
  -> int
  -> int
  -> nativeint
  -> int
  = "ocaml_gpiod_line_set_config_bulk"

external gpiod_line_set_flags : nativeint -> int -> int = "ocaml_gpiod_line_set_flags"

external gpiod_line_set_flags_bulk
  :  nativeint
  -> int
  -> int
  = "ocaml_gpiod_line_set_flags_bulk"

external gpiod_line_set_direction_input
  :  nativeint
  -> int
  = "ocaml_gpiod_line_set_direction_input"

external gpiod_line_set_direction_output
  :  nativeint
  -> int
  -> int
  = "ocaml_gpiod_line_set_direction_output"

external gpiod_line_set_direction_output_bulk
  :  nativeint
  -> nativeint
  -> int
  = "ocaml_gpiod_line_set_direction_output_bulk"

external gpiod_line_event_wait
  :  nativeint
  -> nativeint
  -> int
  = "ocaml_gpiod_line_event_wait"

external gpiod_line_event_wait_bulk
  :  nativeint
  -> nativeint
  -> nativeint
  -> int
  = "ocaml_gpiod_line_event_wait_bulk"

external gpiod_line_event_read
  :  nativeint
  -> nativeint
  -> int
  = "ocaml_gpiod_line_event_read"

external gpiod_line_event_read_multiple
  :  nativeint
  -> nativeint
  -> int
  -> int
  = "ocaml_gpiod_line_event_read_multiple"

external gpiod_line_event_get_fd : nativeint -> int = "ocaml_gpiod_line_event_get_fd"

external gpiod_line_event_read_fd
  :  int
  -> nativeint
  -> int
  = "ocaml_gpiod_line_event_read_fd"

external gpiod_line_event_read_fd_multiple
  :  int
  -> nativeint
  -> int
  -> int
  = "ocaml_gpiod_line_event_read_fd_multiple"

external gpiod_version_string : unit -> string = "ocaml_gpiod_version_string"
