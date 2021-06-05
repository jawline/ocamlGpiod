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


