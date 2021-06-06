# libGpiod Ocaml Bindings

A direct (1-1) wrapper to libgpiod from ocaml. This unlocks access to the
new GPIO interface on Linux, instead of the error-prone and sluggish sysfs
approach. Bindings are systematically generated from the libgpiod header
file. Memory management and reference counting are not taken care of by
the bindings, so the corresponding reference decrement or free methods will
still need to be called.

### Dependencies

Requires libgpiod to be installed [link](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/about/).
