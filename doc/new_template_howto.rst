How To Write New Component Template
-----------------------------------

.. contents::

Skeleton
========

Typical template for component ``foo`` looks as follows::

  $ cat components/foo.m4
  include(begin.m4)

  DECLARE(`FOO_VER',foo-1.2.3)

  ifelse(OS_NAME,ubuntu,dnl
    `define(`FOO_BUILD_DEPS',`ca-certificates cmake g++ wget')'
    `define(`FOO_INSTALL_DEPS',`boo')'
  )

  ifelse(OS_NAME,centos,dnl
    `define(`FOO_BUILD_DEPS',`cmake gcc-c++ wget')'
    `define(`FOO_INSTALL_DEPS',`boo')'
  )

  define(`BUILD_FOO',
  ARG FOO_REPO=https://github.com/org/foo/archive/FOO_VER.tar.gz
  RUN cd BUILD_HOME && \
    wget -O - ${FOO_REPO} | tar xz
  RUN cd BUILD_HOME/FOO_VER && mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=BUILD_PREFIX -DCMAKE_INSTALL_LIBDIR=BUILD_LIBDIR .. && \
    make -j$(nproc) && \
    make install DESTDIR=BUILD_DESTDIR && \
    make install
  )

  define(`INSTALL_FOO',
  RUN ln -s BUILD_LIBDIR/libfoo.so BUILD_LIBDIR/libgoo.so
  )

  define(`ENV_VARS_FOO'
  ENV FOO_NAME=foo
  )

  REG(FOO)

  include(end.m4)

It provides build instructions for the component ``foo`` of version
``foo-1.2.3``. Typically same instructions can be used to build a range of
``foo`` versions. Component version can be overwritten by setting ``FOO_VER``
explicitly::

  m4 -DFOO_VER=2.0.0 ...

Per convention ``FOO_VER`` m4 variable specifies component version and
``FOO_REPO`` docker argument specifies the repo to fetch component from.

Syntax
======

Template should be written with `m4 <https://www.gnu.org/software/m4/>`_
macro language. Additional helper elements (like ``DECLARE`` and ``REG``)
are being provided via specifal purpose ``begin.m4`` template. ``begin.m4``
should be only used with the conjunction of ``end.m4`` template since
there are open/closing declarations in these 2 files.

Key Declarations
================

To implement compliant component template you need to provide the following
declarations:

BUILD_FOO
  Insructions to build ``foo``. Optional.

FOO_BUILD_DEPS
  System packages component build dependends from. Optional.

FOO_INSTALL_DEPS
  System packages from which component depends at runtime. Optional.

INSTALL_FOO
  Non-trivial instruction to install ``foo``. Trivial instructions, i.e.
  copy component artifacts from build docker layer to runtime docker layer
  are populated automatically within ``INSTALL_FOO``. Optional.

ENV_VARS_FOO
  Environment variables required to run ``foo``. Optional.

REG
  Registers component template in the m4docker system core. Pay attention
  that all other declarations must follow core naming convention. Mandatory.

Variables to Use
================

There are a number of variables you will likely need to use during component
build or installation steps. These variables will be used by end-users to
customize templates behavior.

BUILD_HOME
  A directory where template can fetch, store, create artifacts.

BUILD_PREFIX
  Installation prefix.

BUILD_BINDIR
  Installation bindir.

BUILD_LIBDIR
  Installation libdir.

BUILD_DESTDIR
  Intermediate directory to copy installation targets to.

OS_NAME
  OS name for which instructions are being generated. Example: ``ubuntu``.

OS_VERSION
  OS version for which instructions are being generated. Example: ``20.04``.
