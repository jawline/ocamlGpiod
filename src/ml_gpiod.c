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
  value v = caml_alloc(1, Abstract_tag);
  *((void **) Data_abstract_val(v)) = p;
  return v;
}

static void* ptr_of_val(value v) {
  return *((void **) Data_abstract_val(v));
}

value ocaml_gpiod_is_gpiochip_device(value name) {
  bool result = gpiod_is_gpiochip_device(String_val(name));
  return Val_bool(result);
}

value ocaml_gpiod_chip_open_by_name(value name) {

  struct gpiod_chip* chip_ptr = gpiod_chip_open(String_val(name));

  if (!chip_ptr) {
    caml_failwith("could not open the given gpiod device");
  }

  return val_of_ptr(chip_ptr);
}

value ocaml_gpiod_chip_ref(value chip_value) {
  struct gpiod_chip* chip_ptr = (struct gpiod_chip *) ptr_of_val(chip_value);
  return val_of_ptr(gpiod_chip_ref(chip_ptr));
}

value ocaml_gpiod_chip_unref(value chip_value) {
  struct gpiod_chip* chip_ptr = (struct gpiod_chip *) ptr_of_val(chip_value);
  gpiod_chip_unref(chip_ptr);
  return Val_unit;
}
