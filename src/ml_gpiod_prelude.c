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


