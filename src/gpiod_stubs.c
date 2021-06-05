#include <gpiod.h>
#include <assert.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/fail.h>

static value val_of_ptr(void* p)
{
  return caml_copy_nativeint((intnat) p);
}

static void* ptr_of_val(value v) {
  return (void *) Nativeint_val(v);
}


value ocaml_gpiod_is_gpiochip_device(value path) {
	return Val_bool(gpiod_is_gpiochip_device(String_val(path)));
}

value ocaml_gpiod_chip_open(value path) {
	return val_of_ptr((void *)gpiod_chip_open(String_val(path)));
}

value ocaml_gpiod_chip_ref(value chip) {
	return val_of_ptr((void *)gpiod_chip_ref(((struct gpiod_chip *) ptr_of_val(chip))));
}

value ocaml_gpiod_chip_unref(value chip) {
	return Val_unit;
}

value ocaml_gpiod_chip_get_name(value chip) {
	return caml_copy_string(gpiod_chip_get_name(((struct gpiod_chip *) ptr_of_val(chip))));
}

value ocaml_gpiod_chip_get_label(value chip) {
	return caml_copy_string(gpiod_chip_get_label(((struct gpiod_chip *) ptr_of_val(chip))));
}

value ocaml_gpiod_chip_get_num_lines(value chip) {
	return Val_int(gpiod_chip_get_num_lines(((struct gpiod_chip *) ptr_of_val(chip))));
}

value ocaml_gpiod_chip_get_line(value chip, value offset) {
	return val_of_ptr((void *)gpiod_chip_get_line(((struct gpiod_chip *) ptr_of_val(chip)), Int_val(offset)));
}

value ocaml_gpiod_chip_get_lines(value chip, value offsets, value num_offsets) {
	return val_of_ptr((void *)gpiod_chip_get_lines(((struct gpiod_chip *) ptr_of_val(chip)), ((unsigned int *) ptr_of_val(offsets)), Int_val(num_offsets)));
}

value ocaml_gpiod_chip_get_all_lines(value chip) {
	return val_of_ptr((void *)gpiod_chip_get_all_lines(((struct gpiod_chip *) ptr_of_val(chip))));
}

value ocaml_gpiod_chip_find_line(value chip, value name) {
	return Val_int(gpiod_chip_find_line(((struct gpiod_chip *) ptr_of_val(chip)), String_val(name)));
}

value ocaml_gpiod_line_bulk_new(value max_lines) {
	return val_of_ptr((void *)gpiod_line_bulk_new(Int_val(max_lines)));
}

value ocaml_gpiod_line_bulk_reset(value bulk) {
	return Val_unit;
}

value ocaml_gpiod_line_bulk_free(value bulk) {
	return Val_unit;
}

value ocaml_gpiod_line_bulk_add_line(value bulk, value line) {
	return Val_int(gpiod_line_bulk_add_line(((struct gpiod_line_bulk *) ptr_of_val(bulk)), ((struct gpiod_line *) ptr_of_val(line))));
}

value ocaml_gpiod_line_bulk_get_line(value bulk, value index) {
	return val_of_ptr((void *)gpiod_line_bulk_get_line(((struct gpiod_line_bulk *) ptr_of_val(bulk)), Int_val(index)));
}

value ocaml_gpiod_line_bulk_num_lines(value bulk) {
	return Val_int(gpiod_line_bulk_num_lines(((struct gpiod_line_bulk *) ptr_of_val(bulk))));
}

value ocaml_gpiod_line_offset(value line) {
	return Val_int(gpiod_line_offset(((struct gpiod_line *) ptr_of_val(line))));
}

value ocaml_gpiod_line_name(value line) {
	return caml_copy_string(gpiod_line_name(((struct gpiod_line *) ptr_of_val(line))));
}

value ocaml_gpiod_line_consumer(value line) {
	return caml_copy_string(gpiod_line_consumer(((struct gpiod_line *) ptr_of_val(line))));
}

value ocaml_gpiod_line_direction(value line) {
	return Val_int(gpiod_line_direction(((struct gpiod_line *) ptr_of_val(line))));
}

value ocaml_gpiod_line_is_active_low(value line) {
	return Val_bool(gpiod_line_is_active_low(((struct gpiod_line *) ptr_of_val(line))));
}

value ocaml_gpiod_line_bias(value line) {
	return Val_int(gpiod_line_bias(((struct gpiod_line *) ptr_of_val(line))));
}

value ocaml_gpiod_line_is_used(value line) {
	return Val_bool(gpiod_line_is_used(((struct gpiod_line *) ptr_of_val(line))));
}

value ocaml_gpiod_line_drive(value line) {
	return Val_int(gpiod_line_drive(((struct gpiod_line *) ptr_of_val(line))));
}

value ocaml_gpiod_line_get_chip(value line) {
	return val_of_ptr((void *)gpiod_line_get_chip(((struct gpiod_line *) ptr_of_val(line))));
}

value ocaml_gpiod_line_request(value line, value config, value default_val) {
	return Val_int(gpiod_line_request(((struct gpiod_line *) ptr_of_val(line)), ((const struct gpiod_line_request_config *) ptr_of_val(config)), Int_val(default_val)));
}

value ocaml_gpiod_line_request_input(value line, value consumer) {
	return Val_int(gpiod_line_request_input(((struct gpiod_line *) ptr_of_val(line)), String_val(consumer)));
}

value ocaml_gpiod_line_request_output(value line, value consumer, value default_val) {
	return Val_int(gpiod_line_request_output(((struct gpiod_line *) ptr_of_val(line)), String_val(consumer), Int_val(default_val)));
}

value ocaml_gpiod_line_request_rising_edge_events(value line, value consumer) {
	return Val_int(gpiod_line_request_rising_edge_events(((struct gpiod_line *) ptr_of_val(line)), String_val(consumer)));
}

value ocaml_gpiod_line_request_falling_edge_events(value line, value consumer) {
	return Val_int(gpiod_line_request_falling_edge_events(((struct gpiod_line *) ptr_of_val(line)), String_val(consumer)));
}

value ocaml_gpiod_line_request_both_edges_events(value line, value consumer) {
	return Val_int(gpiod_line_request_both_edges_events(((struct gpiod_line *) ptr_of_val(line)), String_val(consumer)));
}

value ocaml_gpiod_line_request_input_flags(value line, value consumer, value flags) {
	return Val_int(gpiod_line_request_input_flags(((struct gpiod_line *) ptr_of_val(line)), String_val(consumer), Int_val(flags)));
}

value ocaml_gpiod_line_request_output_flags(value line, value consumer, value flags, value default_val) {
	return Val_int(gpiod_line_request_output_flags(((struct gpiod_line *) ptr_of_val(line)), String_val(consumer), Int_val(flags), Int_val(default_val)));
}

value ocaml_gpiod_line_request_rising_edge_events_flags(value line, value consumer, value flags) {
	return Val_int(gpiod_line_request_rising_edge_events_flags(((struct gpiod_line *) ptr_of_val(line)), String_val(consumer), Int_val(flags)));
}

value ocaml_gpiod_line_request_falling_edge_events_flags(value line, value consumer, value flags) {
	return Val_int(gpiod_line_request_falling_edge_events_flags(((struct gpiod_line *) ptr_of_val(line)), String_val(consumer), Int_val(flags)));
}

value ocaml_gpiod_line_request_both_edges_events_flags(value line, value consumer, value flags) {
	return Val_int(gpiod_line_request_both_edges_events_flags(((struct gpiod_line *) ptr_of_val(line)), String_val(consumer), Int_val(flags)));
}

value ocaml_gpiod_line_request_bulk(value bulk, value config, value default_vals) {
	return Val_int(gpiod_line_request_bulk(((struct gpiod_line_bulk *) ptr_of_val(bulk)), ((const struct gpiod_line_request_config *) ptr_of_val(config)), ((const int *) ptr_of_val(default_vals))));
}

value ocaml_gpiod_line_request_bulk_input(value bulk, value consumer) {
	return Val_int(gpiod_line_request_bulk_input(((struct gpiod_line_bulk *) ptr_of_val(bulk)), String_val(consumer)));
}

value ocaml_gpiod_line_request_bulk_output(value bulk, value consumer, value default_vals) {
	return Val_int(gpiod_line_request_bulk_output(((struct gpiod_line_bulk *) ptr_of_val(bulk)), String_val(consumer), ((const int *) ptr_of_val(default_vals))));
}

value ocaml_gpiod_line_request_bulk_rising_edge_events(value bulk, value consumer) {
	return Val_int(gpiod_line_request_bulk_rising_edge_events(((struct gpiod_line_bulk *) ptr_of_val(bulk)), String_val(consumer)));
}

value ocaml_gpiod_line_request_bulk_falling_edge_events(value bulk, value consumer) {
	return Val_int(gpiod_line_request_bulk_falling_edge_events(((struct gpiod_line_bulk *) ptr_of_val(bulk)), String_val(consumer)));
}

value ocaml_gpiod_line_request_bulk_both_edges_events(value bulk, value consumer) {
	return Val_int(gpiod_line_request_bulk_both_edges_events(((struct gpiod_line_bulk *) ptr_of_val(bulk)), String_val(consumer)));
}

value ocaml_gpiod_line_request_bulk_input_flags(value bulk, value consumer, value flags) {
	return Val_int(gpiod_line_request_bulk_input_flags(((struct gpiod_line_bulk *) ptr_of_val(bulk)), String_val(consumer), Int_val(flags)));
}

value ocaml_gpiod_line_request_bulk_output_flags(value bulk, value consumer, value flags, value default_vals) {
	return Val_int(gpiod_line_request_bulk_output_flags(((struct gpiod_line_bulk *) ptr_of_val(bulk)), String_val(consumer), Int_val(flags), ((const int *) ptr_of_val(default_vals))));
}

value ocaml_gpiod_line_request_bulk_rising_edge_events_flags(value bulk, value consumer, value flags) {
	return Val_int(gpiod_line_request_bulk_rising_edge_events_flags(((struct gpiod_line_bulk *) ptr_of_val(bulk)), String_val(consumer), Int_val(flags)));
}

value ocaml_gpiod_line_request_bulk_falling_edge_events_flags(value bulk, value consumer, value flags) {
	return Val_int(gpiod_line_request_bulk_falling_edge_events_flags(((struct gpiod_line_bulk *) ptr_of_val(bulk)), String_val(consumer), Int_val(flags)));
}

value ocaml_gpiod_line_request_bulk_both_edges_events_flags(value bulk, value consumer, value flags) {
	return Val_int(gpiod_line_request_bulk_both_edges_events_flags(((struct gpiod_line_bulk *) ptr_of_val(bulk)), String_val(consumer), Int_val(flags)));
}

value ocaml_gpiod_line_release(value line) {
	return Val_unit;
}

value ocaml_gpiod_line_release_bulk(value bulk) {
	return Val_unit;
}

value ocaml_gpiod_line_get_value(value line) {
	return Val_int(gpiod_line_get_value(((struct gpiod_line *) ptr_of_val(line))));
}

value ocaml_gpiod_line_get_value_bulk(value bulk, value values) {
	return Val_int(gpiod_line_get_value_bulk(((struct gpiod_line_bulk *) ptr_of_val(bulk)), ((int *) ptr_of_val(values))));
}

value ocaml_gpiod_line_set_value(value line, value value) {
	return Val_int(gpiod_line_set_value(((struct gpiod_line *) ptr_of_val(line)), Int_val(value)));
}

value ocaml_gpiod_line_set_value_bulk(value bulk, value values) {
	return Val_int(gpiod_line_set_value_bulk(((struct gpiod_line_bulk *) ptr_of_val(bulk)), ((const int *) ptr_of_val(values))));
}

value ocaml_gpiod_line_set_config(value line, value direction, value flags, value value) {
	return Val_int(gpiod_line_set_config(((struct gpiod_line *) ptr_of_val(line)), Int_val(direction), Int_val(flags), Int_val(value)));
}

value ocaml_gpiod_line_set_config_bulk(value bulk, value direction, value flags, value values) {
	return Val_int(gpiod_line_set_config_bulk(((struct gpiod_line_bulk *) ptr_of_val(bulk)), Int_val(direction), Int_val(flags), ((const int *) ptr_of_val(values))));
}

value ocaml_gpiod_line_set_flags(value line, value flags) {
	return Val_int(gpiod_line_set_flags(((struct gpiod_line *) ptr_of_val(line)), Int_val(flags)));
}

value ocaml_gpiod_line_set_flags_bulk(value bulk, value flags) {
	return Val_int(gpiod_line_set_flags_bulk(((struct gpiod_line_bulk *) ptr_of_val(bulk)), Int_val(flags)));
}

value ocaml_gpiod_line_set_direction_input(value line) {
	return Val_int(gpiod_line_set_direction_input(((struct gpiod_line *) ptr_of_val(line))));
}

value ocaml_gpiod_line_set_direction_output(value line, value value) {
	return Val_int(gpiod_line_set_direction_output(((struct gpiod_line *) ptr_of_val(line)), Int_val(value)));
}

value ocaml_gpiod_line_set_direction_output_bulk(value bulk, value values) {
	return Val_int(gpiod_line_set_direction_output_bulk(((struct gpiod_line_bulk *) ptr_of_val(bulk)), ((const int *) ptr_of_val(values))));
}

value ocaml_gpiod_line_event_wait(value line, value timeout) {
	return Val_int(gpiod_line_event_wait(((struct gpiod_line *) ptr_of_val(line)), ((const struct timespec *) ptr_of_val(timeout))));
}

value ocaml_gpiod_line_event_wait_bulk(value bulk, value timeout, value event_bulk) {
	return Val_int(gpiod_line_event_wait_bulk(((struct gpiod_line_bulk *) ptr_of_val(bulk)), ((const struct timespec *) ptr_of_val(timeout)), ((struct gpiod_line_bulk *) ptr_of_val(event_bulk))));
}

value ocaml_gpiod_line_event_read(value line, value event) {
	return Val_int(gpiod_line_event_read(((struct gpiod_line *) ptr_of_val(line)), ((struct gpiod_line_event *) ptr_of_val(event))));
}

value ocaml_gpiod_line_event_read_multiple(value line, value events, value num_events) {
	return Val_int(gpiod_line_event_read_multiple(((struct gpiod_line *) ptr_of_val(line)), ((struct gpiod_line_event *) ptr_of_val(events)), Int_val(num_events)));
}

value ocaml_gpiod_line_event_get_fd(value line) {
	return Val_int(gpiod_line_event_get_fd(((struct gpiod_line *) ptr_of_val(line))));
}

value ocaml_gpiod_line_event_read_fd(value fd, value event) {
	return Val_int(gpiod_line_event_read_fd(Int_val(fd), ((struct gpiod_line_event *) ptr_of_val(event))));
}

value ocaml_gpiod_line_event_read_fd_multiple(value fd, value events, value num_events) {
	return Val_int(gpiod_line_event_read_fd_multiple(Int_val(fd), ((struct gpiod_line_event *) ptr_of_val(events)), Int_val(num_events)));
}

value ocaml_gpiod_version_string() {
	return caml_copy_string(gpiod_version_string());
}

