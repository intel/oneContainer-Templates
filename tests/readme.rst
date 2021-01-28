Tests
=====

M4 Templates Bahavior Tests
---------------------------

`m4 <m4/>`_ folder contains behavior tests for the key (mostly `system <../system/>`)
templates. These tests verify correctness of macro expansion, use ``m4``
compiler and don't use docker. They are integrated into build system and are
executed each time you configure and build the project::

  cmake .
  make -j$(nproc)

So, project will fail to build if any of these tests will fail.

Docker component tests
----------------------

`components <components/>`_ folder contains per-component tests. Effectively
these tests generate Dockerfile-s sufficient to build specific component (it
is supposed that component template will bring required dependencies).
Generation of the Dockerfile-s happens during the project build, but test
execution should be separately triggerred via ``ctest``. Test execution
consists of building a docker image. For example, the following command will
build the project and run (all) libva component tests::

  cmake .
  make -j$(nproc)
  ctest -V -R libva

Mind that since project has a lot of components, building docker images for
all of them (and this is default behavior) will take significant amount of
time. Be aware of the ctest level timeout which might be easily exceeded, to
adjust it use the following option::

  ctest -V --timeout 3600   # timeout for 1 hour

It is possible to limit builds of component docker images to the particular
target layer. In particular there are the following layers to pay attention
on:

* Default layer (specify it as empty "" string)
* ``base`` layer which is effectively base OS image

Configuring the project with ``-DDOCKER_BUILD_TARGET=<layer name>`` would
give the desired effect. For example, to limit docker build to pulling base
images from the Dockerhub and, more importantly, verifying the syntax of the
Dockerfiles::

  cmake -DDOCKER_BUILD_TARGET=base .
  make-j$(nproc)
  ctest -V

Docker stack tests
------------------

`stacks <stacks/>`_ folder contains tests to produce and build docker images
for the entire sample stacks. Under stack we understand a docker image
containing multiple components, typically to achieve specific usage goal.
For example, media stack might contain all ingredients required to perform
some media task, like hw video processing. Dockerfile-s for these tests are
being generated within project build stage, docker images are being built
with ctest command. You can limit docker build to the desired target layer
in the same way as for component tests.

Links
-----

* `ctest <https://cmake.org/cmake/help/latest/manual/ctest.1.html>`_
* `docker-build <https://docs.docker.com/engine/reference/commandline/build/>`_
